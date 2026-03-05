#!/usr/bin/env python3
"""
Ensures Botanica's PlantIdea knowledge base has per-plant placeholder images.

- Updates `assets/data/plantsidea.json` so each plant has:
    "image_path": "assets/placeholders/species/<plant_id>.png"
- Creates missing PNG files by copying `assets/placeholders/species/unknown.png`

This makes it easy to later replace images by dropping real PNGs with the same
names, without changing any code or JSON IDs.
"""

from __future__ import annotations

import json
from pathlib import Path


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    data_path = root / "assets" / "data" / "plantsidea.json"
    unknown_png = root / "assets" / "placeholders" / "species" / "unknown.png"

    if not data_path.exists():
        raise SystemExit(f"Missing: {data_path}")
    if not unknown_png.exists():
        raise SystemExit(f"Missing: {unknown_png}")

    doc = json.loads(data_path.read_text(encoding="utf-8"))
    plants = doc.get("plants")
    if not isinstance(plants, list):
        raise SystemExit('plantsidea.json must contain a top-level "plants" list')

    unknown_bytes = unknown_png.read_bytes()

    updated_paths = 0
    created_files = 0

    for plant in plants:
        if not isinstance(plant, dict):
            continue
        plant_id = str(plant.get("plant_id") or "").strip()
        if not plant_id:
            continue

        desired_rel = f"assets/placeholders/species/{plant_id}.png"
        if plant.get("image_path") != desired_rel:
            plant["image_path"] = desired_rel
            updated_paths += 1

        out_path = root / desired_rel
        if not out_path.exists():
            out_path.parent.mkdir(parents=True, exist_ok=True)
            out_path.write_bytes(unknown_bytes)
            created_files += 1

    data_path.write_text(
        json.dumps(doc, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(
        f"✓ Updated image_path for {updated_paths} plants\n"
        f"✓ Created {created_files} placeholder PNGs\n"
        f"- Output JSON: {data_path}\n"
        f"- Placeholder source: {unknown_png}"
    )


if __name__ == "__main__":
    main()

