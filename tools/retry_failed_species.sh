#!/usr/bin/env bash
# 只重新生成小于5KB的物种占位符图（即之前失败的）
# 用法: bash tools/retry_failed_species.sh

set -euo pipefail

SPECIES_DIR="assets/placeholders/species"
API="http://127.0.0.1:1468/generate"
cd "$(dirname "$0")/.."

# 先检测服务是否正常
echo "Testing API availability..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$API" \
  -X POST -H "Content-Type: application/json" \
  -d '{"prompt":"a green plant, botanical illustration","width":512,"height":512}')

if [ "$HTTP_CODE" != "200" ]; then
  echo "❌ API returned $HTTP_CODE — not ready yet. Try again later."
  exit 1
fi
echo "✅ API is ready."

COUNT=0
TOTAL=$(find "$SPECIES_DIR" -name "*.png" -size -5k | wc -l | tr -d ' ')
echo "Found $TOTAL placeholder images to regenerate."
echo "---"

FAIL_STREAK=0

find "$SPECIES_DIR" -name "*.png" -size -5k -print0 | sort -z | while IFS= read -r -d '' file; do
  BASENAME=$(basename "$file" .png)
  COUNT=$((COUNT + 1))

  # Skip unknown.png
  if [ "$BASENAME" = "unknown" ]; then
    continue
  fi

  DISPLAY_NAME=$(echo "$BASENAME" | tr '_' ' ')
  echo "[$COUNT/$TOTAL] Generating: $BASENAME ..."

  # 先备份原占位符
  cp "$file" "${file}.bak"

  HTTP_CODE=$(curl -s -o "$file" -w "%{http_code}" --max-time 45 "$API" \
    -X POST -H "Content-Type: application/json" \
    -d "{\"prompt\":\"A beautiful botanical watercolor illustration of ${DISPLAY_NAME}, soft natural lighting, detailed leaves and petals, white background, artistic style\",\"width\":512,\"height\":512}")

  FILE_SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0)

  if [ "$HTTP_CODE" = "200" ] && [ "$FILE_SIZE" -gt 5000 ]; then
    echo "  ✅ OK ($FILE_SIZE bytes)"
    rm -f "${file}.bak"
  else
    # 恢复原占位符，不覆盖
    mv "${file}.bak" "$file"
    echo "  ❌ FAILED (HTTP $HTTP_CODE, size $FILE_SIZE) — placeholder restored"
    # 连续失败3次则停止
    FAIL_STREAK=$((FAIL_STREAK + 1))
    if [ "$FAIL_STREAK" -ge 3 ]; then
      echo "⚠️  3 consecutive failures — stopping. Re-run when API is stable."
      exit 1
    fi
    sleep 1
    continue
  fi

  FAIL_STREAK=0
  sleep 0.3
done

echo "---"
REMAINING=$(find "$SPECIES_DIR" -name "*.png" -size -5k | wc -l | tr -d ' ')
echo "Done. Remaining placeholders: $REMAINING"
