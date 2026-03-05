#!/usr/bin/env python3
"""
Checks that asset paths referenced in Dart + JSON files exist on disk.

Why:
- Botanica intentionally uses stable asset paths so designers can replace
  placeholder PNGs later by filename only.
- A missing file silently degrades UX (fallbacks, broken thumbnails).

What it scans:
- Dart: any string literal containing "assets/..."
- JSON under assets/data/: common image keys like `imagePath`, `image_path`

Exit codes:
- 0: all referenced assets exist
- 2: at least one missing asset was found
"""

from __future__ import annotations

import json
import re
from pathlib import Path


ASSET_RE = re.compile(r"""['"](?P<path>assets/[^'"]+)['"]""")


def _iter_dart_asset_refs(root: Path) -> set[str]:
    refs: set[str] = set()
    for path in root.rglob("*.dart"):
        if "build" in path.parts or ".dart_tool" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for m in ASSET_RE.finditer(text):
            p = m.group("path").strip()
            if p.startswith("assets/"):
                # Ignore interpolated runtime paths like 'assets/foo/$id.png'.
                if "$" in p:
                    continue
                refs.add(p)
    return refs


def _iter_json_asset_refs(data_dir: Path) -> set[str]:
    refs: set[str] = set()
    if not data_dir.exists():
        return refs

    def visit(obj: object) -> None:
        if isinstance(obj, dict):
            for k, v in obj.items():
                if k in {"imagePath", "image_path", "coverAsset", "asset"} and isinstance(
                    v, str
                ):
                    p = v.strip()
                    if p.startswith("assets/"):
                        refs.add(p)
                visit(v)
        elif isinstance(obj, list):
            for item in obj:
                visit(item)

    for path in data_dir.rglob("*.json"):
        try:
            doc = json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            continue
        visit(doc)

    return refs


def main() -> int:
    root = Path(__file__).resolve().parents[1]

    dart_refs = _iter_dart_asset_refs(root / "lib")
    json_refs = _iter_json_asset_refs(root / "assets" / "data")
    refs = sorted(dart_refs.union(json_refs))

    missing: list[str] = []
    for rel in refs:
        full = root / rel
        if not full.exists():
            missing.append(rel)

    if missing:
        print("✗ Missing asset files:\n")
        for m in missing:
            print(f"- {m}")
        print(f"\nFound {len(missing)} missing assets out of {len(refs)} references.")
        return 2

    print(f"✓ All referenced assets exist ({len(refs)} references checked).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
