#!/usr/bin/env python3
"""物种图生成脚本 v3 — 智能限流退避 + JSON API 格式"""
import json, os, shutil, subprocess, sys, time, glob

API = "http://127.0.0.1:1468/generate"
SPECIES_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholders", "species")
MIN_SIZE = 5000
BASE_DELAY = 8  # 基础间隔8秒
MAX_RETRY = 6

def generate_one(name: str, dest: str) -> bool:
    display = name.replace("_", " ")
    prompt = f"A beautiful botanical watercolor illustration of {display}, soft natural lighting, detailed leaves and petals, white background, artistic style"
    payload = json.dumps({"prompt": prompt, "width": 512, "height": 512})

    for attempt in range(1, MAX_RETRY + 1):
        try:
            result = subprocess.run(
                ["curl", "-s", "--max-time", "90", API,
                 "-X", "POST", "-H", "Content-Type: application/json",
                 "-d", payload],
                capture_output=True, text=True, timeout=100
            )
            resp_text = result.stdout.strip()
            if not resp_text:
                print(f"  ⚠️ Empty response (attempt {attempt}/{MAX_RETRY})")
                time.sleep(10 * attempt)
                continue

            # 检测429限流
            if "429" in resp_text:
                wait = 15 * attempt
                print(f"  ⏳ 429 rate limit, waiting {wait}s (attempt {attempt}/{MAX_RETRY})")
                time.sleep(wait)
                continue

            # 检测其他错误
            if '"detail"' in resp_text and '"ok"' not in resp_text:
                wait = 10 * attempt
                print(f"  ⚠️ API error, waiting {wait}s (attempt {attempt}/{MAX_RETRY})")
                time.sleep(wait)
                continue

            data = json.loads(resp_text)
            saved = data.get("saved_path", "")
            if saved and os.path.isfile(saved):
                size = os.path.getsize(saved)
                if size > MIN_SIZE:
                    shutil.copy2(saved, dest)
                    print(f"  ✅ OK ({size} bytes)")
                    return True
                else:
                    print(f"  ⚠️ File too small ({size}B), retry...")
            else:
                print(f"  ⚠️ No saved_path or file missing (attempt {attempt}/{MAX_RETRY})")

        except Exception as e:
            print(f"  ⚠️ Exception: {e} (attempt {attempt}/{MAX_RETRY})")

        time.sleep(8 * attempt)

    return False

def main():
    os.chdir(os.path.join(os.path.dirname(__file__), ".."))

    # 找出所有需要生成的占位符
    targets = []
    for f in sorted(glob.glob(os.path.join(SPECIES_DIR, "*.png"))):
        basename = os.path.splitext(os.path.basename(f))[0]
        if basename == "unknown":
            continue
        if os.path.getsize(f) <= MIN_SIZE:
            targets.append((basename, f))

    total = len(targets)
    print(f"Found {total} placeholder images to regenerate.")
    print("---")

    success = 0
    fail = 0
    fail_streak = 0

    for i, (name, path) in enumerate(targets, 1):
        print(f"[{i}/{total}] Generating: {name} ...")
        if generate_one(name, path):
            success += 1
            fail_streak = 0
            time.sleep(BASE_DELAY)
        else:
            fail += 1
            fail_streak += 1
            print(f"  ❌ FAILED after {MAX_RETRY} retries")
            if fail_streak >= 5:
                print(f"⚠️  5 consecutive failures — stopping.")
                print(f"Success: {success} / Fail: {fail} / Remaining: {total - i}")
                sys.exit(1)

    remaining = len([f for f in glob.glob(os.path.join(SPECIES_DIR, "*.png"))
                     if os.path.basename(f) != "unknown.png" and os.path.getsize(f) <= MIN_SIZE])
    print("---")
    print(f"Done. Success: {success} / Fail: {fail} / Remaining: {remaining}")

if __name__ == "__main__":
    main()
