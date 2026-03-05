#!/usr/bin/env bash
# 物种图生成脚本 v2 — 适配新 API（返回 JSON + saved_path）
# 用法: bash tools/gen_species_v2.sh

set -euo pipefail

SPECIES_DIR="assets/placeholders/species"
API="http://127.0.0.1:1468/generate"
cd "$(dirname "$0")/.."

# 检测服务
echo "Testing API..."
RESP=$(curl -s --max-time 60 "$API" \
  -X POST -H "Content-Type: application/json" \
  -d '{"prompt":"a green plant, botanical illustration, white background","width":512,"height":512}')

SAVED=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('saved_path',''))" 2>/dev/null || echo "")
if [ -z "$SAVED" ] || [ ! -f "$SAVED" ]; then
  echo "❌ API test failed. Response: $RESP"
  exit 1
fi
echo "✅ API ready (new JSON format, saved_path works)."

COUNT=0
FAIL_STREAK=0
TOTAL=$(find "$SPECIES_DIR" -name "*.png" ! -size +5k ! -name "unknown.png" | wc -l | tr -d ' ')
SUCCESS=0
FAIL=0
echo "Found $TOTAL placeholder images to regenerate."
echo "---"

find "$SPECIES_DIR" -name "*.png" ! -size +5k ! -name "unknown.png" -print0 | sort -z | while IFS= read -r -d '' file; do
  BASENAME=$(basename "$file" .png)
  COUNT=$((COUNT + 1))
  DISPLAY_NAME=$(echo "$BASENAME" | tr '_' ' ')

  echo "[$COUNT/$TOTAL] Generating: $BASENAME ..."

  # 每张图最多重试5次（含429退避）
  RETRY=0
  MAX_RETRY=5
  GOT_IT=false
  while [ "$RETRY" -lt "$MAX_RETRY" ]; do
    RESP=$(curl -s --max-time 90 "$API" \
      -X POST -H "Content-Type: application/json" \
      -d "{\"prompt\":\"A beautiful botanical watercolor illustration of ${DISPLAY_NAME}, soft natural lighting, detailed leaves and petals, white background, artistic style\",\"width\":512,\"height\":512}" 2>/dev/null || echo "")

    # 检测429限流
    if echo "$RESP" | grep -q "429"; then
      WAIT=$((10 * (RETRY + 1)))
      echo "  ⏳ Rate limited (429), waiting ${WAIT}s... (retry $((RETRY+1))/$MAX_RETRY)"
      sleep "$WAIT"
      RETRY=$((RETRY + 1))
      continue
    fi

    # 检测500错误
    if echo "$RESP" | grep -q '"detail"'; then
      echo "  ⚠️ API error, waiting 8s... (retry $((RETRY+1))/$MAX_RETRY)"
      sleep 8
      RETRY=$((RETRY + 1))
      continue
    fi

    SAVED=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('saved_path',''))" 2>/dev/null || echo "")

    if [ -n "$SAVED" ] && [ -f "$SAVED" ]; then
      FILE_SIZE=$(stat -f%z "$SAVED" 2>/dev/null || stat -c%s "$SAVED" 2>/dev/null || echo 0)
      if [ "$FILE_SIZE" -gt 5000 ]; then
        cp "$SAVED" "$file"
        echo "  ✅ OK ($FILE_SIZE bytes)"
        FAIL_STREAK=0
        SUCCESS=$((SUCCESS + 1))
        GOT_IT=true
        break
      fi
    fi

    RETRY=$((RETRY + 1))
    sleep 5
  done

  if [ "$GOT_IT" = false ]; then
    echo "  ❌ FAILED after $MAX_RETRY retries"
    FAIL=$((FAIL + 1))
    FAIL_STREAK=$((FAIL_STREAK + 1))
    if [ "$FAIL_STREAK" -ge 5 ]; then
      echo "⚠️  5 consecutive failures — stopping. Re-run when API is stable."
      echo "Success: $SUCCESS / Fail: $FAIL"
      exit 1
    fi
  fi

  # 基础间隔5秒，避免触发限流
  sleep 5
done

echo "---"
REMAINING=$(find "$SPECIES_DIR" -name "*.png" ! -size +5k ! -name "unknown.png" | wc -l | tr -d ' ')
echo "Done. Success: $SUCCESS / Remaining: $REMAINING"
