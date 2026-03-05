#!/bin/bash
# Batch generate species placeholder images sequentially.
# Usage: bash scripts/gen_species_images.sh

API="http://127.0.0.1:1468/generate"
DIR="/Users/pigpeppa/Downloads/Botanica/assets/placeholders/species"
DONE=0
FAIL=0
TOTAL=0

for png in "$DIR"/*.png; do
  fname=$(basename "$png")
  species_id="${fname%.png}"

  # Skip if already a real image (>5KB)
  size=$(stat -f%z "$png" 2>/dev/null || echo "0")
  if [ "$size" -gt 5000 ]; then
    continue
  fi

  TOTAL=$((TOTAL + 1))
  # Convert underscore to space for prompt
  nice_name=$(echo "$species_id" | tr '_' ' ')

  echo "[$TOTAL] Generating: $species_id ..."
  resp=$(curl -s "$API" -H 'Content-Type: application/json' -d "{
    \"prompt\": \"4K, botanical watercolor illustration of ${nice_name} plant, accurate botanical details, cream background, elegant premium aesthetic, no text.\",
    \"model\": \"gemini-3-pro-image-1k-16-9\",
    \"save_dir\": \"$DIR\",
    \"filename\": \"$fname\"
  }")

  # Check result
  new_size=$(stat -f%z "$png" 2>/dev/null || echo "0")
  if [ "$new_size" -gt 5000 ]; then
    DONE=$((DONE + 1))
    echo "  ✅ OK ($new_size bytes)"
  else
    FAIL=$((FAIL + 1))
    echo "  ❌ FAILED"
  fi
done

echo ""
echo "=== DONE: $DONE success, $FAIL failed, $TOTAL total ==="
