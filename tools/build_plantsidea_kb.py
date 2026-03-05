#!/usr/bin/env python3
"""
Builds Botanica's `assets/data/plantsidea.json`.

Goals:
  - Keep existing fields used by the Flutter app (`plant_id`, `common_names`, etc.)
  - Add a structured, extensible knowledge layer for:
      taxonomy, origin, growth, care, problems, and extreme-weather handling
  - Ensure a minimum coverage of 300+ species entries.

This script is intentionally deterministic and avoids scraping paywalled / brittle
HTML. It uses:
  - GBIF public API (taxonomy + vernacular names where available)
  - Wikipedia MediaWiki API (intro extracts) to pull a *native-range hint* when
    available. This is treated as supplemental metadata (not a primary
    horticultural authority).

Run:
  python tools/build_plantsidea_kb.py
"""

from __future__ import annotations

import concurrent.futures
import dataclasses
import datetime as dt
import json
import re
import sys
import time
import urllib.parse
from pathlib import Path
from typing import Any, Iterable, Mapping

import requests


REPO_ROOT = Path(__file__).resolve().parents[1]
PLANTS_IDEA_PATH = REPO_ROOT / "assets" / "data" / "plantsidea.json"
PLACEHOLDER_SPECIES_DIR = REPO_ROOT / "assets" / "placeholders" / "species"
UNKNOWN_PLACEHOLDER_PNG = PLACEHOLDER_SPECIES_DIR / "unknown.png"

GBIF_MATCH_URL = "https://api.gbif.org/v1/species/match"
GBIF_VERNACULAR_URL = "https://api.gbif.org/v1/species/{key}/vernacularNames"
WIKI_API_URL = "https://en.wikipedia.org/w/api.php"

LEGACY_PLANT_IDS: set[str] = {
    # Original shipped entries (kept id-stable because the app may persist them).
    "monstera_deliciosa",
    "epipremnum_aureum",
    "sansevieria_trifasciata",
    "chlorophytum_comosum",
    "ficus_lyrata",
    "zz_plant",
    "spathiphyllum_wallisii",
    "aloe_vera",
    "calathea_orbifolia",
    "pilea_peperomioides",
    "ficus_elastica",
    "dracaena_marginata",
    "philodendron_hederaceum",
    "hoya_carnosa",
    "nephrolepis_exaltata",
    "phalaenopsis_orchid",
    "crassula_ovata",
    "anthurium_andraeanum",
}


def _now_utc_iso() -> str:
    return dt.datetime.now(tz=dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _slugify(value: str) -> str:
    value = value.strip().lower()
    value = value.replace("×", " x ")
    value = re.sub(r"[()\\[\\]{}]", " ", value)
    value = re.sub(r"[^a-z0-9]+", "_", value)
    value = re.sub(r"_+", "_", value).strip("_")
    return value or "unknown"


def _clamp_int(value: int, *, lo: int, hi: int) -> int:
    return max(lo, min(hi, int(value)))


def _dedupe_keep_order(items: Iterable[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for raw in items:
        name = (raw or "").strip()
        if not name:
            continue
        key = re.sub(r"\s+", " ", name).lower()
        if key in seen:
            continue
        seen.add(key)
        out.append(name)
    return out


def _sync_species_placeholders(plants: Iterable[Mapping[str, Any]]) -> int:
    """
    Ensures every `assets/placeholders/species/<plant_id>.png` referenced by
    `image_path` exists by copying the all-white `unknown.png` template.

    This keeps `image_path` stable per-plant and allows dropping in real art
    later without touching JSON again.
    """
    if not UNKNOWN_PLACEHOLDER_PNG.exists():
        return 0

    created = 0
    template = UNKNOWN_PLACEHOLDER_PNG.read_bytes()
    for plant in plants:
        image_path = plant.get("image_path")
        if not isinstance(image_path, str) or not image_path.strip():
            continue
        image_path = image_path.strip()
        if not image_path.startswith("assets/placeholders/species/"):
            continue
        if image_path.endswith("/unknown.png"):
            continue
        dest = REPO_ROOT / image_path
        if dest.exists():
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(template)
        created += 1
    return created


@dataclasses.dataclass(frozen=True)
class SeedPlant:
    scientific_name: str
    profile_id: str
    # Optional stable id override (used for existing entries like "zz_plant").
    plant_id: str | None = None
    # Optional overrides when a profile is too coarse (e.g., shade-tolerant
    # outdoor perennials still use `outdoor_perennial` care templates, but need
    # more accurate light guidance).
    light_override: str | None = None


def _youtube_search_url(query: str) -> str:
    return "https://www.youtube.com/results?search_query=" + urllib.parse.quote_plus(f"{query} plant care")


def _baidu_baike_search_url(query: str) -> str:
    return "https://baike.baidu.com/search/word?word=" + urllib.parse.quote(query)


def _bilibili_search_url(query: str) -> str:
    return "https://search.bilibili.com/all?keyword=" + urllib.parse.quote(query)


def _wikipedia_url(title: str) -> str:
    return "https://en.wikipedia.org/wiki/" + urllib.parse.quote(title.replace(" ", "_"))


def _gbif_taxon_url(usage_key: int) -> str:
    return f"https://www.gbif.org/species/{usage_key}"


_CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def _contains_cjk(text: str) -> bool:
    return bool(_CJK_RE.search(text or ""))


def _requests_session() -> requests.Session:
    s = requests.Session()
    s.headers.update(
        {
            "User-Agent": "BotanicaKBBuilder/1.0 (offline build; contact: local)",
            "Accept": "application/json",
        }
    )
    return s


def _gbif_match(session: requests.Session, name: str) -> dict[str, Any]:
    resp = session.get(
        GBIF_MATCH_URL,
        params={"name": name, "kingdom": "Plantae"},
        timeout=25,
    )
    resp.raise_for_status()
    data = resp.json()
    if not isinstance(data, dict):
        return {}
    return data


def _gbif_vernacular_names(session: requests.Session, usage_key: int) -> list[str]:
    resp = session.get(
        GBIF_VERNACULAR_URL.format(key=usage_key),
        params={"limit": 100},
        timeout=25,
    )
    resp.raise_for_status()
    data = resp.json()
    results = data.get("results") if isinstance(data, dict) else None
    if not isinstance(results, list):
        return []

    english: list[str] = []
    for row in results:
        if not isinstance(row, dict):
            continue
        lang = (row.get("language") or "").strip().lower()
        # GBIF uses ISO 639-3 in many records (e.g., "eng").
        if lang not in {"eng", "en"}:
            continue
        name = (row.get("vernacularName") or "").strip()
        if not name:
            continue
        # Clean common noise.
        name = name.replace("-", " ").replace("’", "'")
        name = re.sub(r"\s+", " ", name).strip()
        if len(name) < 2:
            continue
        english.append(name)

    # Prefer shorter, more common-ish names first.
    english = _dedupe_keep_order(sorted(english, key=lambda s: (len(s), s.lower())))
    return english[:5]


_NATIVE_RANGE_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"\bnative to ([^.]+)\.", re.IGNORECASE),
    re.compile(r"\bis native to ([^.]+)\.", re.IGNORECASE),
    re.compile(r"\bendemic to ([^.]+)\.", re.IGNORECASE),
    re.compile(r"\boriginating in ([^.]+)\.", re.IGNORECASE),
    re.compile(r"\boriginating from ([^.]+)\.", re.IGNORECASE),
]


def _wiki_native_range_hint(session: requests.Session, scientific_name: str) -> str | None:
    title = scientific_name.strip().replace("×", "x")
    if not title:
        return None

    resp = session.get(
        WIKI_API_URL,
        params={
            "action": "query",
            "prop": "extracts",
            "exintro": 1,
            "explaintext": 1,
            "redirects": 1,
            "titles": title.replace(" ", "_"),
            "format": "json",
        },
        timeout=25,
    )
    if resp.status_code != 200:
        return None
    data = resp.json()
    query = data.get("query") if isinstance(data, dict) else None
    pages = (query or {}).get("pages") if isinstance(query, dict) else None
    if not isinstance(pages, dict) or not pages:
        return None
    # pages is keyed by pageid; take the first value.
    page = next(iter(pages.values()))
    if not isinstance(page, dict):
        return None
    extract = page.get("extract")
    if not isinstance(extract, str) or not extract.strip():
        return None

    text = extract.strip()
    for pat in _NATIVE_RANGE_PATTERNS:
        m = pat.search(text)
        if not m:
            continue
        hint = m.group(1).strip()
        hint = re.sub(r"\s+", " ", hint)
        # Avoid extremely long captures.
        if 5 <= len(hint) <= 160:
            return hint
    return None


def _size_range(min_cm: int, max_cm: int) -> dict[str, int]:
    min_cm = max(0, int(min_cm))
    max_cm = max(min_cm, int(max_cm))
    return {"min": min_cm, "max": max_cm}


def _default_mature_size(profile_id: str, growth_form: str) -> dict[str, Any]:
    # Rough, app-friendly ranges (container-grown where relevant).
    if profile_id in {"outdoor_tree_temperate", "fruit_tree_temperate", "fruit_tree_subtropical"}:
        return {
            "height_cm": _size_range(300, 700),
            "spread_cm": _size_range(250, 600),
            "notes": {
                "en": "Ranges assume home-garden or dwarf/semi-dwarf forms; standard trees can grow much larger in-ground."
            },
        }
    if profile_id in {"outdoor_shrub_temperate", "outdoor_shrub_subtropical"}:
        return {
            "height_cm": _size_range(80, 250),
            "spread_cm": _size_range(80, 250),
        }
    if profile_id in {"outdoor_perennial", "outdoor_annual"}:
        return {
            "height_cm": _size_range(20, 120),
            "spread_cm": _size_range(20, 90),
        }
    if profile_id in {"herb_mediterranean", "herb_moist"}:
        return {
            "height_cm": _size_range(20, 90),
            "spread_cm": _size_range(20, 70),
        }
    if profile_id in {"cactus", "succulent"}:
        return {
            "height_cm": _size_range(10, 60),
            "spread_cm": _size_range(10, 60),
        }
    if profile_id == "orchid_epiphyte":
        return {
            "height_cm": _size_range(25, 80),
            "spread_cm": _size_range(20, 60),
        }
    if profile_id == "fern":
        return {
            "height_cm": _size_range(30, 90),
            "spread_cm": _size_range(30, 90),
        }
    if profile_id == "indoor_palm":
        return {
            "height_cm": _size_range(120, 250),
            "spread_cm": _size_range(90, 180),
        }
    if growth_form in {"trailing", "climbing"}:
        return {
            "height_cm": _size_range(20, 80),
            "spread_cm": _size_range(30, 120),
            "vine_length_cm": _size_range(80, 350),
        }
    if growth_form in {"tree_like"}:
        return {
            "height_cm": _size_range(150, 350),
            "spread_cm": _size_range(90, 220),
        }
    return {
        "height_cm": _size_range(25, 120),
        "spread_cm": _size_range(25, 120),
    }


def _guess_growth_form(profile_id: str, genus: str | None, scientific_name: str) -> str:
    name = scientific_name.lower()
    genus = (genus or "").strip()
    if profile_id in {"cactus"}:
        return "succulent"
    if profile_id in {"succulent"}:
        return "succulent"
    if profile_id == "orchid_epiphyte":
        return "orchid"
    if profile_id == "fern":
        return "fern"
    if profile_id == "indoor_humidity":
        return "clumping"
    if profile_id.startswith("fruit_tree") or profile_id.startswith("outdoor_tree"):
        return "tree_like"
    if profile_id.startswith("outdoor_shrub"):
        return "upright"

    trailing_genera = {
        "Epipremnum",
        "Philodendron",
        "Scindapsus",
        "Hoya",
        "Ceropegia",
        "Pothos",
        "Tradescantia",
        "Cissus",
        "Rhipsalis",
        "Hedera",
        "Clematis",
        "Wisteria",
        "Passiflora",
        "Jasminum",
    }
    if genus in trailing_genera or "hederaceum" in name or "scandens" in name:
        return "trailing"
    clumping_genera = {"Goeppertia", "Calathea", "Maranta", "Ctenanthe", "Stromanthe", "Aglaonema"}
    if genus in clumping_genera:
        return "clumping"
    climbing_genera = {"Monstera", "Rhaphidophora", "Syngonium"}
    if genus in climbing_genera:
        return "climbing"
    rosette_markers = {"aloe", "agave", "haworthia", "haworthiopsis", "echeveria", "sempervivum"}
    if any(m in name for m in rosette_markers):
        return "rosette"
    return "upright"


def _default_growth_rate(profile_id: str) -> str:
    if profile_id in {"succulent", "cactus"}:
        return "slow"
    if profile_id in {"orchid_epiphyte", "fern"}:
        return "moderate"
    if profile_id in {"herb_moist"}:
        return "fast"
    if profile_id.startswith("outdoor_annual"):
        return "fast"
    return "moderate"


def _profile_light(profile_id: str) -> str:
    return {
        "indoor_tropical": "bright_indirect",
        "indoor_low_light": "low_to_bright_indirect",
        "indoor_palm": "bright_indirect",
        "indoor_humidity": "medium_indirect",
        "fern": "medium_indirect",
        "orchid_epiphyte": "bright_indirect",
        "carnivorous_tropical": "bright_indirect",
        "carnivorous_bog": "bright_direct",
        "succulent": "bright_direct",
        "cactus": "bright_direct",
        "herb_mediterranean": "bright_direct",
        "herb_moist": "bright_direct",
        "outdoor_perennial": "bright_direct",
        "outdoor_annual": "bright_direct",
        "outdoor_shrub_temperate": "bright_direct",
        "outdoor_tree_temperate": "bright_direct",
        "fruit_tree_temperate": "bright_direct",
        "fruit_tree_subtropical": "bright_direct",
    }.get(profile_id, "bright_indirect")


def _profile_difficulty(profile_id: str) -> str:
    return {
        "indoor_tropical": "easy",
        "indoor_low_light": "easy",
        "indoor_palm": "medium",
        "indoor_humidity": "hard",
        "fern": "medium",
        "orchid_epiphyte": "medium",
        "carnivorous_tropical": "hard",
        "carnivorous_bog": "hard",
        "succulent": "easy",
        "cactus": "easy",
        "herb_mediterranean": "easy",
        "herb_moist": "easy",
        "outdoor_perennial": "easy",
        "outdoor_annual": "easy",
        "outdoor_shrub_temperate": "easy",
        "outdoor_tree_temperate": "medium",
        "fruit_tree_temperate": "medium",
        "fruit_tree_subtropical": "medium",
    }.get(profile_id, "easy")


def _profile_category(profile_id: str) -> str:
    if profile_id == "carnivorous_bog":
        return "outdoor"
    if profile_id == "carnivorous_tropical":
        return "indoor"
    if profile_id.startswith("indoor") or profile_id in {"fern", "orchid_epiphyte", "succulent", "cactus"}:
        return "indoor"
    if profile_id.startswith("herb"):
        return "herb"
    if profile_id.startswith("fruit_tree"):
        return "fruit_tree"
    if profile_id.startswith("outdoor_tree"):
        return "outdoor_tree"
    if profile_id.startswith("outdoor_shrub"):
        return "outdoor_shrub"
    if profile_id.startswith("outdoor_"):
        return "outdoor"
    return "indoor"


def _profile_tags(profile_id: str) -> list[str]:
    base: list[str] = []
    if profile_id.startswith("indoor"):
        base += ["indoor"]
    if profile_id == "indoor_humidity":
        base += ["humidity_loving"]
    if profile_id.startswith("carnivorous"):
        base += ["carnivorous"]
    if profile_id in {"succulent", "cactus"}:
        base += ["succulent", "drought_tolerant"]
    if profile_id == "cactus":
        base += ["cactus"]
    if profile_id == "fern":
        base += ["fern", "humidity_loving"]
    if profile_id == "orchid_epiphyte":
        base += ["orchid", "epiphyte"]
    if profile_id.startswith("herb"):
        base += ["edible", "herb"]
    if profile_id.startswith("fruit_tree"):
        base += ["edible", "fruit_tree"]
    if profile_id.startswith("outdoor_"):
        base += ["outdoor"]
    if "temperate" in profile_id:
        base += ["temperate"]
    if "subtropical" in profile_id:
        base += ["subtropical"]
    return _dedupe_keep_order(base)


def _profile_suitability(profile_id: str) -> dict[str, Any]:
    category = _profile_category(profile_id)
    if category == "indoor":
        return {"indoor": True, "outdoor": False, "container": True, "ground": False}
    if category == "herb":
        return {"indoor": True, "outdoor": True, "container": True, "ground": True}
    if category == "fruit_tree":
        return {"indoor": False, "outdoor": True, "container": True, "ground": True}
    return {"indoor": False, "outdoor": True, "container": True, "ground": True}


def _profile_hardiness(profile_id: str) -> dict[str, Any] | None:
    # Coarse defaults; individual cultivars vary.
    if profile_id == "fruit_tree_temperate":
        return {"usda_zones": {"min": 3, "max": 8}}
    if profile_id == "outdoor_tree_temperate":
        return {"usda_zones": {"min": 4, "max": 9}}
    if profile_id == "outdoor_shrub_temperate":
        return {"usda_zones": {"min": 4, "max": 9}}
    if profile_id == "fruit_tree_subtropical":
        return {"usda_zones": {"min": 9, "max": 11}}
    return None


def _profile_native_habitat(profile_id: str) -> str:
    return {
        "indoor_tropical": "Typically associated with tropical/subtropical forests where plants grow in filtered light and warm conditions.",
        "indoor_low_light": "Often from forest understories where light is dappled and drying winds are limited.",
        "indoor_palm": "Commonly from warm regions and forest edges/understories with bright shade and steady humidity.",
        "indoor_humidity": "Typically from tropical rainforest understories with warm temperatures, consistent moisture, and high humidity.",
        "fern": "Commonly associated with humid forests, shaded stream margins, and consistently moist microclimates.",
        "orchid_epiphyte": "Often epiphytic in tropical forests, growing on trees with airy roots and high humidity.",
        "succulent": "Often from seasonally dry regions and rocky slopes where drainage is fast and drought periods occur.",
        "cactus": "Typically from arid or semi-arid habitats with intense sun, fast drainage, and episodic rainfall.",
        "herb_mediterranean": "Often from Mediterranean-type climates with sunny exposure, dry summers, and well-drained soils.",
        "herb_moist": "Often from open, cultivated, or meadow-like habitats where soil is fertile and moisture is more consistent.",
        "outdoor_perennial": "Often from meadows, woodland edges, and temperate garden-like habitats with seasonal cycles.",
        "outdoor_annual": "Typically cultivated annuals adapted to open sites with sun and regular moisture during the growing season.",
        "outdoor_shrub_temperate": "Often associated with temperate woodland edges and shrublands with seasonal temperature swings.",
        "outdoor_tree_temperate": "Typically from temperate forests and parklands with cold winters and warm summers.",
        "fruit_tree_temperate": "Associated with temperate orchards and woodland edges; requires full sun for best flowering and fruiting.",
        "fruit_tree_subtropical": "Associated with warm subtropical orchards; sensitive to hard freezes; prefers sun and good drainage.",
        "carnivorous_bog": "Native to nutrient-poor bogs and wetlands where soils are acidic and low in minerals.",
        "carnivorous_tropical": "Often associated with humid tropical forests where roots prefer airy, low-mineral media and high humidity.",
    }.get(profile_id, "Varies by species and cultivar; confirm habitat when possible.")


def _profile_care(profile_id: str) -> dict[str, Any]:
    # Structured defaults designed for weather-based and season-based reminders.
    if profile_id == "indoor_humidity":
        return {
            "watering": {
                "method": "evenly_moist",
                "growing_season_days": {"min": 3, "max": 6},
                "dormant_season_days": {"min": 5, "max": 10},
                "notes": {
                    "en": "Keep the mix lightly and consistently moist, but never waterlogged. Use room-temperature water and avoid letting the plant dry out fully."
                },
            },
            "fertilizing": {
                "growing_season_days": 30,
                "dormant_season_days": 0,
                "notes": {"en": "Feed lightly during active growth; excess fertilizer can scorch sensitive foliage."},
            },
            "soil": {
                "mix": "Moisture-retentive but airy mix (coco/peat + perlite + fine bark).",
                "ph": {"min": 5.5, "max": 7.0},
            },
            "temperature_c": {"ideal": {"min": 18, "max": 27}, "tolerates": {"min": 15, "max": 32}},
            "humidity_pct": {"ideal": {"min": 60, "max": 85}},
            "pruning": {"when": {"en": "Anytime."}, "how": {"en": "Remove damaged leaves at the base; keep leaves clean and avoid harsh sun."}},
            "pests_and_diseases": {
                "common_pests": ["spider mites", "thrips", "mealybugs"],
                "common_diseases": ["root rot"],
                "prevention": ["Maintain humidity with airflow (not stagnant air).", "Use pots with drainage; avoid soggy media."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 32, "actions": ["Increase humidity and shade; improve airflow; keep soil evenly moist."]},
                "frost": {"risk_below_c": 15, "actions": ["Keep away from cold drafts and cold window glass; maintain stable warmth."]},
                "storm": {"actions": ["If outdoors seasonally, bring inside; wind and sun can scorch leaves quickly."]},
                "heavy_rain": {"actions": ["Avoid waterlogged pots; ensure drainage and shelter if needed."]},
            },
            "climate_strategies": {
                "dry_indoor_winter": ["Use a humidifier; keep away from heating vents; water with room-temperature water."],
                "hard_water": ["If tips brown and tap water is hard, consider filtered/low-mineral water and flush salts periodically."],
            },
        }

    if profile_id == "carnivorous_bog":
        return {
            "watering": {
                "method": "tray_method_distilled",
                "growing_season_days": {"min": 1, "max": 3},
                "dormant_season_days": {"min": 2, "max": 5},
                "notes": {
                    "en": "Use rainwater/distilled/RO water. Keep media consistently moist (often via tray method); avoid mineral-heavy tap water."
                },
            },
            "fertilizing": {
                "growing_season_days": 0,
                "dormant_season_days": 0,
                "notes": {"en": "Do not fertilize the soil; these plants are adapted to nutrient-poor bog media."},
            },
            "soil": {
                "mix": "Nutrient-poor bog mix (e.g., sphagnum peat + perlite/sand). Avoid compost and standard potting soil.",
                "ph": {"min": 3.5, "max": 5.5},
            },
            "temperature_c": {"ideal": {"min": 10, "max": 30}, "tolerates": {"min": -10, "max": 35}},
            "humidity_pct": {"ideal": {"min": 40, "max": 80}},
            "pruning": {
                "when": {"en": "Late winter / early spring, and as leaves die back."},
                "how": {"en": "Remove dead traps/pitchers to reduce mold; avoid damaging new growth points."},
            },
            "pests_and_diseases": {
                "common_pests": ["aphids", "thrips"],
                "common_diseases": ["rhizome rot", "botrytis"],
                "prevention": [
                    "Use mineral-free water.",
                    "Ensure plenty of sun and airflow.",
                    "Avoid stagnant, anaerobic conditions in the pot.",
                ],
            },
            "extreme_weather": {
                "heatwave": {
                    "risk_above_c": 35,
                    "actions": [
                        "Keep tray topped up with cool, clean water.",
                        "Provide light shade during extreme heat if pitchers/traps scorch.",
                    ],
                },
                "frost": {
                    "risk_below_c": -10,
                    "actions": [
                        "These plants can tolerate cold when dormant, but protect pots from deep freezes with mulch or insulation.",
                        "Do not keep them warm all winter; dormancy supports long-term health.",
                    ],
                },
                "storm": {"actions": ["Shelter containers from hail and tipping; remove debris from rosettes/pitchers afterward."]},
                "heavy_rain": {"actions": ["Avoid overflow of mineral-rich runoff; ensure the pot cannot flood with muddy water."]},
            },
            "climate_strategies": {
                "hot_dry": ["Use larger pots to buffer heat; keep tray moist; avoid afternoon heat reflected from concrete."],
                "cold_winter": ["Provide outdoor dormancy but protect containers from repeated freeze-thaw cycles."],
            },
        }

    if profile_id == "carnivorous_tropical":
        return {
            "watering": {
                "method": "moist_low_mineral",
                "growing_season_days": {"min": 3, "max": 6},
                "dormant_season_days": {"min": 5, "max": 10},
                "notes": {
                    "en": "Use rainwater/distilled/RO water when possible. Keep medium lightly moist with strong airflow; avoid waterlogging."
                },
            },
            "fertilizing": {
                "growing_season_days": 0,
                "dormant_season_days": 0,
                "notes": {"en": "Avoid standard fertilizers in the medium; excess salts can burn sensitive roots."},
            },
            "soil": {
                "mix": "Airy, low-nutrient mix (e.g., long-fiber sphagnum + perlite/bark).",
                "ph": {"min": 4.5, "max": 6.5},
            },
            "temperature_c": {"ideal": {"min": 18, "max": 30}, "tolerates": {"min": 12, "max": 35}},
            "humidity_pct": {"ideal": {"min": 55, "max": 85}},
            "pruning": {"when": {"en": "Anytime."}, "how": {"en": "Remove dead pitchers and leaves; keep the crown airy to prevent rot."}},
            "pests_and_diseases": {
                "common_pests": ["aphids", "mealybugs", "spider mites"],
                "common_diseases": ["root rot", "crown rot"],
                "prevention": ["High humidity + airflow (not stagnant air).", "Use low-mineral water and an airy mix."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 35, "actions": ["Increase shading and airflow; keep medium evenly moist; avoid heat buildup near windows."]},
                "frost": {"risk_below_c": 12, "actions": ["Keep away from cold drafts/glass; bring indoors before cold snaps."]},
                "storm": {"actions": ["If grown outdoors seasonally, bring under cover; wind can tear pitchers."]},
                "heavy_rain": {"actions": ["Avoid prolonged saturation; ensure fast drainage and airflow."]},
            },
            "climate_strategies": {
                "dry_indoor_winter": ["Use a humidifier or terrarium-style enclosure with airflow; keep bright light."],
                "hot_humid": ["Increase airflow; reduce watering frequency slightly to avoid stagnation."],
            },
        }

    if profile_id == "succulent":
        return {
            "watering": {
                "method": "soak_and_dry",
                "growing_season_days": {"min": 14, "max": 21},
                "dormant_season_days": {"min": 21, "max": 35},
                "notes": {
                    "en": "Water deeply, then allow the potting mix to dry out fully. In cool/low-light winter conditions, extend the interval."
                },
            },
            "fertilizing": {
                "growing_season_days": 60,
                "dormant_season_days": 0,
                "notes": {"en": "Use a low-nitrogen cactus/succulent fertilizer at half strength during active growth."},
            },
            "soil": {
                "mix": "Fast-draining cactus/succulent mix; add pumice/perlite for extra drainage.",
                "ph": {"min": 6.0, "max": 7.5},
            },
            "temperature_c": {
                "ideal": {"min": 18, "max": 30},
                "tolerates": {"min": 10, "max": 38},
            },
            "humidity_pct": {"ideal": {"min": 20, "max": 50}},
            "pruning": {
                "when": {"en": "Spring–summer, as needed."},
                "how": {"en": "Remove dead/damaged parts with clean tools; allow cut surfaces to callus before watering heavily."},
            },
            "pests_and_diseases": {
                "common_pests": ["mealybugs", "scale", "spider mites"],
                "common_diseases": ["root rot"],
                "prevention": [
                    "Use a gritty mix and a pot with drainage.",
                    "Avoid frequent small waterings; water thoroughly then drain.",
                    "Quarantine new plants for 2–3 weeks.",
                ],
            },
            "extreme_weather": {
                "heatwave": {
                    "risk_above_c": 38,
                    "actions": [
                        "Shade from harsh afternoon sun (especially behind glass).",
                        "Increase airflow; avoid misting in extreme heat if humidity is already high.",
                        "Check for rapid drying; water early in the day if needed.",
                    ],
                },
                "frost": {
                    "risk_below_c": 5,
                    "actions": [
                        "Bring indoors or protect from freezing temperatures.",
                        "Keep dry on the coldest nights to reduce rot risk.",
                    ],
                },
                "storm": {"actions": ["Move containers to shelter to prevent tipping and hail damage."]},
                "heavy_rain": {"actions": ["Move containers under cover; saturated mix + low light increases rot risk."]},
            },
            "climate_strategies": {
                "hot_dry": ["Use a light shade cloth outdoors; water early morning; avoid black pots in full sun."],
                "cool_wet": ["Prioritize airflow; reduce watering frequency; use warmer microclimates or indoor growth lights."],
            },
        }

    if profile_id == "cactus":
        care = _profile_care("succulent")
        care["watering"]["growing_season_days"] = {"min": 21, "max": 35}
        care["watering"]["dormant_season_days"] = {"min": 35, "max": 56}
        care["fertilizing"]["growing_season_days"] = 75
        care["humidity_pct"] = {"ideal": {"min": 15, "max": 45}}
        care["pruning"]["how"] = {"en": "Prune only when needed (damage/shape). Use gloves and clean tools; allow wounds to dry/callus."}
        return care

    if profile_id == "fern":
        return {
            "watering": {
                "method": "evenly_moist",
                "growing_season_days": {"min": 3, "max": 6},
                "dormant_season_days": {"min": 5, "max": 10},
                "notes": {"en": "Keep the mix consistently lightly moist; avoid letting it dry out completely."},
            },
            "fertilizing": {
                "growing_season_days": 30,
                "dormant_season_days": 0,
                "notes": {"en": "Feed lightly in spring–summer; avoid heavy fertilization that can scorch fronds."},
            },
            "soil": {
                "mix": "Moisture-retentive but well-draining potting mix with extra organic matter.",
                "ph": {"min": 5.5, "max": 7.0},
            },
            "temperature_c": {"ideal": {"min": 16, "max": 26}, "tolerates": {"min": 10, "max": 30}},
            "humidity_pct": {
                "ideal": {"min": 50, "max": 80},
                "notes": {"en": "Aim for higher humidity; dry indoor air can cause browning tips."},
            },
            "pruning": {"when": {"en": "Anytime."}, "how": {"en": "Remove brown/damaged fronds at the base with clean scissors."}},
            "pests_and_diseases": {
                "common_pests": ["spider mites", "scale", "mealybugs"],
                "common_diseases": ["root rot"],
                "prevention": ["Maintain humidity, but avoid waterlogged soil.", "Provide airflow and bright shade/indirect light."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 32, "actions": ["Increase humidity and shade; keep soil evenly moist; improve airflow."]},
                "frost": {"risk_below_c": 5, "actions": ["Protect from cold drafts; bring indoors before frost."]},
                "storm": {"actions": ["Shelter hanging baskets to prevent tearing fronds and drying winds."]},
                "heavy_rain": {"actions": ["Ensure drainage; remove standing water from trays/saucers."]},
            },
            "climate_strategies": {
                "hot_dry": ["Use a humidifier or pebble tray indoors; group plants; avoid direct HVAC vents."],
                "cool_wet": ["Reduce watering interval slightly; keep temperature stable; avoid cold, saturated media."],
            },
        }

    if profile_id == "orchid_epiphyte":
        return {
            "watering": {
                "method": "flush_and_drain",
                "growing_season_days": {"min": 5, "max": 10},
                "dormant_season_days": {"min": 7, "max": 14},
                "notes": {"en": "Water thoroughly, then let the medium drain completely. Avoid water sitting in the crown."},
            },
            "fertilizing": {
                "growing_season_days": 14,
                "dormant_season_days": 30,
                "notes": {"en": "Use a diluted orchid fertilizer; reduce feeding in lower-light winter conditions."},
            },
            "soil": {
                "mix": "Chunky orchid bark mix (or bark + sphagnum) for airflow around roots.",
                "ph": {"min": 5.5, "max": 6.8},
            },
            "temperature_c": {"ideal": {"min": 18, "max": 28}, "tolerates": {"min": 14, "max": 32}},
            "humidity_pct": {"ideal": {"min": 45, "max": 70}},
            "pruning": {
                "when": {"en": "After blooming."},
                "how": {"en": "Remove spent spikes as desired; keep leaves dry and ensure airflow."},
            },
            "pests_and_diseases": {
                "common_pests": ["mealybugs", "scale", "spider mites"],
                "common_diseases": ["crown rot", "root rot"],
                "prevention": ["Prioritize airflow around roots.", "Avoid standing water in decorative pots and the leaf crown."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 32, "actions": ["Increase airflow and shading; water earlier; avoid heat buildup near windows."]},
                "frost": {"risk_below_c": 12, "actions": ["Keep away from cold glass and drafts; bring indoors well before frost."]},
                "storm": {"actions": ["Move outdoors orchids inside; protect spikes from wind damage."]},
                "heavy_rain": {"actions": ["Shelter epiphytes; prolonged saturation increases rot risk."]},
            },
            "climate_strategies": {
                "hot_humid": ["Increase airflow; avoid stagnant wet media; water early morning."],
                "cool_dry": ["Use room-temperature water; increase humidity modestly; ensure light remains bright but indirect."],
            },
        }

    if profile_id in {"herb_mediterranean"}:
        return {
            "watering": {
                "method": "dry_between",
                "growing_season_days": {"min": 5, "max": 10},
                "dormant_season_days": {"min": 10, "max": 21},
                "notes": {"en": "Many Mediterranean herbs prefer drying slightly between waterings; avoid constantly wet soil."},
            },
            "fertilizing": {"growing_season_days": 45, "dormant_season_days": 0, "notes": {"en": "Light feeding is usually sufficient; overfertilization reduces flavor."}},
            "soil": {"mix": "Well-draining mix; add grit/sand for containers.", "ph": {"min": 6.0, "max": 7.8}},
            "temperature_c": {"ideal": {"min": 12, "max": 28}, "tolerates": {"min": -5, "max": 35}},
            "humidity_pct": {"ideal": {"min": 30, "max": 60}},
            "pruning": {"when": {"en": "After flowering / during active growth."}, "how": {"en": "Pinch and trim regularly to keep plants compact and productive."}},
            "pests_and_diseases": {
                "common_pests": ["aphids", "spider mites"],
                "common_diseases": ["powdery mildew", "root rot"],
                "prevention": ["Plant in full sun with airflow.", "Avoid overhead watering late in the day."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 35, "actions": ["Water deeply early morning; provide light afternoon shade for containers."]},
                "frost": {"risk_below_c": -5, "actions": ["Mulch roots; protect tender herbs; move containers to shelter."]},
                "storm": {"actions": ["Stake taller herbs; protect containers from tipping."]},
                "heavy_rain": {"actions": ["Improve drainage; avoid waterlogged beds; elevate containers."]},
            },
            "climate_strategies": {
                "humid": ["Increase spacing and airflow; prune for air movement; watch for mildew."],
                "cool_short_season": ["Use containers to warm the root zone; start indoors and transplant after last frost."],
            },
        }

    if profile_id in {"herb_moist"}:
        return {
            "watering": {
                "method": "evenly_moist",
                "growing_season_days": {"min": 2, "max": 5},
                "dormant_season_days": {"min": 4, "max": 10},
                "notes": {"en": "Leafy herbs grow best with steady moisture and good drainage; avoid repeated drought stress."},
            },
            "fertilizing": {"growing_season_days": 30, "dormant_season_days": 0, "notes": {"en": "Use a balanced fertilizer lightly; harvest frequently to keep plants tender."}},
            "soil": {"mix": "Rich, well-draining soil with compost.", "ph": {"min": 6.0, "max": 7.5}},
            "temperature_c": {"ideal": {"min": 16, "max": 30}, "tolerates": {"min": 10, "max": 35}},
            "humidity_pct": {"ideal": {"min": 35, "max": 70}},
            "pruning": {"when": {"en": "Weekly, during active growth."}, "how": {"en": "Pinch growing tips and harvest outer leaves to encourage branching."}},
            "pests_and_diseases": {
                "common_pests": ["aphids", "whiteflies", "spider mites"],
                "common_diseases": ["downy mildew", "leaf spot"],
                "prevention": ["Water at soil level when possible.", "Provide airflow; avoid crowding."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 35, "actions": ["Provide afternoon shade; water early; harvest more often to reduce stress."]},
                "frost": {"risk_below_c": 2, "actions": ["Cover with frost cloth; move containers inside overnight."]},
                "storm": {"actions": ["Shelter containers; re-stake plants after wind."]},
                "heavy_rain": {"actions": ["Ensure drainage; avoid compacted, saturated soil; watch for fungal leaf spots."]},
            },
            "climate_strategies": {
                "hot_sunny": ["Use light shade and mulch; keep consistent moisture."],
                "cool_spring": ["Harden off seedlings; protect from late frosts with row cover."],
            },
        }

    if profile_id in {"fruit_tree_temperate"}:
        return {
            "watering": {
                "method": "deep_infrequent",
                "growing_season_days": {"min": 7, "max": 14},
                "dormant_season_days": {"min": 14, "max": 30},
                "notes": {
                    "en": "Young trees need consistent deep watering during establishment; mature trees are watered during dry spells."
                },
            },
            "fertilizing": {
                "growing_season_days": 90,
                "dormant_season_days": 0,
                "notes": {"en": "Fertilize in early spring based on soil test and vigor; avoid late-season nitrogen."},
            },
            "soil": {"mix": "Well-drained loam; avoid waterlogged sites.", "ph": {"min": 6.0, "max": 7.0}},
            "temperature_c": {"ideal": {"min": 12, "max": 28}, "tolerates": {"min": -25, "max": 35}},
            "humidity_pct": {"ideal": {"min": 30, "max": 70}},
            "pruning": {
                "when": {"en": "Late winter while dormant (and summer touch-ups if needed)."},
                "how": {"en": "Prune for structure and airflow; remove crossing branches and water sprouts."},
            },
            "pests_and_diseases": {
                "common_pests": ["aphids", "scale", "caterpillars"],
                "common_diseases": ["powdery mildew", "leaf spot", "canker"],
                "prevention": ["Choose resistant cultivars when possible.", "Prune for airflow and sanitize tools."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 35, "actions": ["Deep water early; mulch root zone; protect young trees from sunscald."]},
                "frost": {"risk_below_c": -10, "actions": ["Protect blossoms from late spring frosts with covers/sprinkling where appropriate."]},
                "storm": {"actions": ["Stake young trees; thin overloaded branches; inspect after wind for splits."]},
                "heavy_rain": {"actions": ["Improve drainage; avoid working saturated soil; monitor for root issues."]},
            },
            "climate_strategies": {
                "cool_short_season": ["Select low-chill / early varieties; plant in full sun; use windbreaks."],
                "hot_humid": ["Prune for airflow; monitor fungal disease; use mulch to moderate soil moisture swings."],
            },
        }

    if profile_id in {"fruit_tree_subtropical"}:
        return {
            "watering": {
                "method": "deep_infrequent",
                "growing_season_days": {"min": 5, "max": 10},
                "dormant_season_days": {"min": 10, "max": 21},
                "notes": {"en": "Water deeply; allow partial drying between waterings. Avoid constant saturation."},
            },
            "fertilizing": {"growing_season_days": 60, "dormant_season_days": 90, "notes": {"en": "Use a citrus/fruit-tree fertilizer during active growth; adjust to local seasons."}},
            "soil": {"mix": "Well-drained soil; raised beds help in heavy or wet sites.", "ph": {"min": 6.0, "max": 7.5}},
            "temperature_c": {"ideal": {"min": 18, "max": 32}, "tolerates": {"min": 0, "max": 40}},
            "humidity_pct": {"ideal": {"min": 35, "max": 70}},
            "pruning": {"when": {"en": "After harvest / late winter."}, "how": {"en": "Prune lightly for airflow and manageable size; remove dead and crossing branches."}},
            "pests_and_diseases": {
                "common_pests": ["scale", "aphids", "whiteflies"],
                "common_diseases": ["root rot", "leaf spot"],
                "prevention": ["Avoid waterlogged soil; improve airflow; monitor regularly."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 40, "actions": ["Deep water early; use mulch; provide temporary shade for young trees."]},
                "frost": {"risk_below_c": 0, "actions": ["Protect with frost cloth; move containers; use microclimates near walls."]},
                "storm": {"actions": ["Stake and shelter containers; prune weakly attached limbs; check after winds."]},
                "heavy_rain": {"actions": ["Ensure drainage; avoid standing water; watch for fungal outbreaks after storms."]},
            },
            "climate_strategies": {
                "coastal_wind": ["Use windbreaks; stake young trees; rinse salt spray from foliage if needed."],
                "humid_rainy": ["Prune for airflow; monitor leaf diseases; use raised beds."],
            },
        }

    if profile_id in {"indoor_low_light"}:
        base = _profile_care("indoor_tropical")
        base["watering"]["growing_season_days"] = {"min": 10, "max": 18}
        base["watering"]["dormant_season_days"] = {"min": 14, "max": 28}
        base["humidity_pct"] = {"ideal": {"min": 30, "max": 60}}
        base["fertilizing"]["growing_season_days"] = 60
        base["fertilizing"]["dormant_season_days"] = 0
        base["climate_strategies"]["low_light"] = [
            "Water less frequently and prioritize drainage; low light slows drying and growth.",
            "Rotate the pot periodically to keep growth even.",
        ]
        return base

    if profile_id in {"indoor_palm"}:
        base = _profile_care("indoor_tropical")
        base["watering"]["method"] = "evenly_moist"
        base["watering"]["growing_season_days"] = {"min": 5, "max": 9}
        base["watering"]["dormant_season_days"] = {"min": 7, "max": 14}
        base["humidity_pct"] = {"ideal": {"min": 40, "max": 70}}
        base["pests_and_diseases"]["common_pests"] = ["spider mites", "scale", "mealybugs"]
        base["pests_and_diseases"]["prevention"].append("Rinse foliage periodically to reduce dust and mites.")
        return base

    if profile_id in {"indoor_tropical"}:
        return {
            "watering": {
                "method": "dry_top_then_water",
                "growing_season_days": {"min": 6, "max": 10},
                "dormant_season_days": {"min": 10, "max": 16},
                "notes": {"en": "Water when the top layer of mix dries; avoid keeping roots constantly wet."},
            },
            "fertilizing": {
                "growing_season_days": 30,
                "dormant_season_days": 0,
                "notes": {"en": "Feed during active growth; pause or reduce in winter if growth slows."},
            },
            "soil": {
                "mix": "Well-draining indoor potting mix; add bark/perlite for airflow.",
                "ph": {"min": 5.8, "max": 7.0},
            },
            "temperature_c": {"ideal": {"min": 18, "max": 27}, "tolerates": {"min": 12, "max": 32}},
            "humidity_pct": {"ideal": {"min": 40, "max": 70}},
            "pruning": {"when": {"en": "Spring–summer, as needed."}, "how": {"en": "Remove yellow leaves and trim for shape; use clean tools."}},
            "pests_and_diseases": {
                "common_pests": ["spider mites", "mealybugs", "scale", "fungus gnats"],
                "common_diseases": ["root rot"],
                "prevention": [
                    "Use pots with drainage; empty saucers.",
                    "Let the surface dry slightly to reduce fungus gnats.",
                    "Inspect undersides of leaves weekly.",
                ],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 32, "actions": ["Increase shade and airflow; keep watering consistent; avoid fertilizing during heat stress."]},
                "frost": {"risk_below_c": 10, "actions": ["Keep away from cold windows and drafts; move indoors before cold snaps."]},
                "storm": {"actions": ["If outdoors for summer, bring inside or under cover; wind can shred foliage."]},
                "heavy_rain": {"actions": ["Avoid leaving containers waterlogged; ensure drainage and shelter if needed."]},
            },
            "climate_strategies": {
                "dry_indoor_winter": ["Increase humidity, but prioritize airflow to avoid fungal issues.", "Keep away from heating vents."],
                "low_light": ["Reduce watering frequency; consider a grow light for compact growth."],
            },
        }

    # Outdoor generic templates.
    if profile_id in {"outdoor_perennial"}:
        return {
            "watering": {
                "method": "deep_infrequent",
                "growing_season_days": {"min": 5, "max": 10},
                "dormant_season_days": {"min": 10, "max": 21},
                "notes": {"en": "After establishment, water during dry spells; newly planted perennials need more consistent moisture."},
            },
            "fertilizing": {"growing_season_days": 90, "dormant_season_days": 0, "notes": {"en": "Compost in spring is often enough; fertilize lightly based on growth and bloom."}},
            "soil": {"mix": "Well-drained garden soil improved with compost.", "ph": {"min": 6.0, "max": 7.5}},
            "temperature_c": {"ideal": {"min": 10, "max": 28}, "tolerates": {"min": -20, "max": 35}},
            "humidity_pct": {"ideal": {"min": 30, "max": 70}},
            "pruning": {"when": {"en": "After bloom or late winter (varies by plant)."}, "how": {"en": "Remove spent flowers; cut back dead stems; divide clumps as needed."}},
            "pests_and_diseases": {
                "common_pests": ["aphids", "slugs", "caterpillars"],
                "common_diseases": ["powdery mildew", "leaf spot"],
                "prevention": ["Water at soil level; space plants for airflow; remove diseased debris."],
            },
            "extreme_weather": {
                "heatwave": {"risk_above_c": 35, "actions": ["Water early; mulch; provide temporary shade for new plantings."]},
                "frost": {"risk_below_c": -5, "actions": ["Mulch crowns; protect early growth; cover tender shoots during late frosts."]},
                "storm": {"actions": ["Stake tall flowers; cut back damaged stems; remove debris after storms."]},
                "heavy_rain": {"actions": ["Improve drainage; avoid compacting wet soil; watch for fungal outbreaks."]},
            },
            "climate_strategies": {
                "hot_dry": ["Mulch 5–8 cm; use drip irrigation; select drought-tolerant companions."],
                "cool_wet": ["Improve drainage with raised beds; avoid heavy clay compaction; prune for airflow."],
            },
        }

    if profile_id in {"outdoor_annual"}:
        base = _profile_care("outdoor_perennial")
        base["watering"]["growing_season_days"] = {"min": 2, "max": 5}
        base["fertilizing"]["growing_season_days"] = 30
        base["temperature_c"] = {"ideal": {"min": 16, "max": 30}, "tolerates": {"min": 5, "max": 35}}
        base["pruning"]["how"] = {"en": "Pinch early for branching and deadhead often to keep blooms coming."}
        return base

    if profile_id in {"outdoor_shrub_temperate"}:
        base = _profile_care("outdoor_perennial")
        base["watering"]["growing_season_days"] = {"min": 7, "max": 14}
        base["fertilizing"]["growing_season_days"] = 180
        base["temperature_c"]["tolerates"]["min"] = -25
        base["pruning"] = {"when": {"en": "After flowering or late winter (species-dependent)."}, "how": {"en": "Prune to shape and remove dead wood; avoid removing next season’s buds."}}
        return base

    if profile_id in {"outdoor_tree_temperate"}:
        base = _profile_care("fruit_tree_temperate")
        base["fertilizing"]["growing_season_days"] = 365
        base["pruning"]["when"] = {"en": "Late winter; structural pruning for young trees."}
        base["pruning"]["how"] = {"en": "Prune for structure and clearance; remove dead/damaged limbs; avoid topping."}
        return base

    # Fallback to indoor tropical.
    return _profile_care("indoor_tropical")


def _care_defaults_from_care(profile_id: str, care: Mapping[str, Any]) -> dict[str, int]:
    watering = care.get("watering") if isinstance(care.get("watering"), dict) else {}
    grow = watering.get("growing_season_days") if isinstance(watering.get("growing_season_days"), dict) else {}
    water_base = int(((grow.get("min") or 7) + (grow.get("max") or 7)) / 2)
    fert = care.get("fertilizing") if isinstance(care.get("fertilizing"), dict) else {}
    fert_base = int(fert.get("growing_season_days") or 30)

    mist = 0
    if profile_id in {"fern"}:
        mist = 2
    elif profile_id in {"indoor_humidity"}:
        mist = 2
    elif profile_id in {"orchid_epiphyte", "indoor_tropical", "indoor_palm"}:
        mist = 3
    elif profile_id.startswith("carnivorous"):
        mist = 3

    rotate = 0
    if profile_id.startswith("indoor") or profile_id in {"fern", "orchid_epiphyte", "succulent", "cactus"}:
        rotate = 14

    prune = 90
    if profile_id in {"outdoor_annual", "herb_moist"}:
        prune = 21
    elif profile_id in {"succulent", "cactus"}:
        prune = 180
    elif profile_id.startswith("fruit_tree"):
        prune = 365

    return {
        "waterBaseDays": _clamp_int(water_base, lo=0, hi=60),
        "fertilizeBaseDays": _clamp_int(fert_base, lo=0, hi=365),
        "mistBaseDays": _clamp_int(mist, lo=0, hi=30),
        "rotateBaseDays": _clamp_int(rotate, lo=0, hi=60),
        "pruneBaseDays": _clamp_int(prune, lo=0, hi=365),
    }


def _normalized_common_name(common_names: Mapping[str, list[str]]) -> dict[str, str]:
    out: dict[str, str] = {}
    for locale, names in common_names.items():
        if not names:
            continue
        first = (names[0] or "").strip()
        if first:
            out[locale] = first
    return out


def _base_history(scientific: str, family: str | None, native_hint: str | None, category: str) -> str:
    where = native_hint or "a wide range of regions"
    if category in {"herb", "fruit_tree"}:
        return f"{scientific} is widely cultivated in gardens and farms. It is associated with {where} in botanical sources and is grown today for its practical value and ornamental presence."
    if category.startswith("outdoor"):
        return f"{scientific} is a garden plant valued for seasonal interest and landscape structure. Botanical sources associate it with {where}."
    return f"{scientific} is a popular houseplant known for its form and adaptability. Botanical sources associate it with {where}."


def _base_habit(profile_id: str, growth_form: str, light: str) -> str:
    light_phrase = {
        "bright_direct": "full sun or very bright light",
        "bright_indirect": "bright, indirect light",
        "medium_indirect": "medium to bright indirect light",
        "low_to_bright_indirect": "low to bright indirect light",
        "low_to_bright": "low to bright light",
    }.get(light, "bright, indirect light")

    if profile_id in {"succulent", "cactus"}:
        return f"A drought-tolerant {growth_form}-type plant. Provide {light_phrase} and let the mix dry fully between waterings."
    if profile_id == "fern":
        return f"A {growth_form}-type plant that prefers steady moisture and higher humidity. Provide {light_phrase} and avoid dry drafts."
    if profile_id == "orchid_epiphyte":
        return "An epiphytic orchid that prefers airflow around its roots. Water thoroughly, drain well, and avoid leaving water in the crown."
    if profile_id.startswith("herb"):
        return f"An edible herb grown for fresh growth. Provide {light_phrase}, harvest/pinch regularly, and keep soil well-drained."
    if profile_id.startswith("fruit_tree"):
        return "A fruiting tree grown outdoors in sun. Water deeply during establishment, prune for structure and airflow, and protect blossoms from extreme weather."
    if profile_id.startswith("outdoor_"):
        return "A garden plant grown outdoors. Provide sun appropriate to the species, water deeply during establishment, and improve drainage to prevent root issues."
    return f"A {growth_form}-growing plant that does best in {light_phrase}. Water when the top layer dries and avoid soggy soil."


def _common_problems(profile_id: str) -> list[str]:
    if profile_id in {"succulent", "cactus"}:
        return [
            "Soft/mushy tissue from overwatering",
            "Etiolated (stretched) growth from low light",
            "Mealybugs or scale in leaf joints",
        ]
    if profile_id == "fern":
        return ["Brown/crispy tips from dry air", "Yellowing from waterlogged soil", "Spider mites in dry conditions"]
    if profile_id == "orchid_epiphyte":
        return ["Bud blast from stress or cold drafts", "Root rot from poor airflow", "Crown rot from water sitting in the crown"]
    if profile_id.startswith("herb"):
        return ["Bolting in heat", "Aphids on tender growth", "Root rot in poorly drained soil"]
    if profile_id.startswith("fruit_tree"):
        return ["Poor fruit set due to late frosts or pollination issues", "Pest pressure in humid seasons", "Canker or leaf spots in wet conditions"]
    if profile_id.startswith("outdoor_"):
        return ["Powdery mildew in stagnant air", "Root rot in heavy soils", "Heat stress during drought"]
    return ["Yellow leaves from watering issues", "Leaf spot from poor airflow", "Common houseplant pests (mites, mealybugs, scale)"]


def _build_entry(
    *,
    seed: SeedPlant,
    existing: Mapping[str, Any] | None,
    gbif: Mapping[str, Any],
    common_names_en: list[str],
    native_hint: str | None,
    care_guide_url: str | None,
) -> dict[str, Any]:
    match_type = (gbif.get("matchType") or "").strip().upper()
    if match_type == "HIGHERRANK":
        scientific = seed.scientific_name.strip()
    else:
        scientific = (gbif.get("canonicalName") or gbif.get("scientificName") or seed.scientific_name).strip()
        if not scientific:
            scientific = seed.scientific_name.strip()

    usage_key = gbif.get("usageKey")
    genus = (gbif.get("genus") or "").strip() or None
    family = (gbif.get("family") or "").strip() or None
    order = (gbif.get("order") or "").strip() or None
    rank = (gbif.get("rank") or "").strip() or None

    if match_type == "HIGHERRANK":
        # GBIF occasionally returns a higher-rank match even when a binomial was
        # provided. Keep the seed name for the record and avoid downgrading the
        # plant to genus-level.
        seed_tokens = seed.scientific_name.strip().split()
        if seed_tokens:
            genus = seed_tokens[0]
        if len(seed_tokens) >= 2:
            rank = "SPECIES"

    profile_id = seed.profile_id
    category = _profile_category(profile_id)
    light_override = (seed.light_override or "").strip() or None
    light = light_override or _profile_light(profile_id)
    difficulty = _profile_difficulty(profile_id)
    tags = _profile_tags(profile_id)

    growth_form = _guess_growth_form(profile_id, genus, scientific)
    growth_rate = _default_growth_rate(profile_id)
    mature_size = _default_mature_size(profile_id, growth_form)

    care = _profile_care(profile_id)
    care_defaults = _care_defaults_from_care(profile_id, care)

    common_names: dict[str, list[str]] = {}
    if existing:
        raw_common_names = existing.get("common_names")
        if isinstance(raw_common_names, dict):
            for k, v in raw_common_names.items():
                if isinstance(k, str) and isinstance(v, list):
                    common_names[k] = [str(x) for x in v if str(x).strip()]

    if not common_names.get("en"):
        if common_names_en:
            common_names["en"] = common_names_en
        else:
            # Fallback: use scientific name as display label.
            common_names["en"] = [scientific]

    common_names = {k: _dedupe_keep_order(v) for k, v in common_names.items()}
    common_name = _normalized_common_name(common_names)

    # Keep existing id & image if present; otherwise derive.
    plant_id = seed.plant_id or (existing.get("plant_id") if existing else None)
    if not isinstance(plant_id, str) or not plant_id.strip():
        plant_id = _slugify(scientific)

    image_path = (existing.get("image_path") if existing else None) if isinstance(existing, dict) else None
    if isinstance(image_path, str) and image_path.strip().endswith("/unknown.png"):
        # Avoid persisting "unknown.png" in the knowledge base. Use a per-plant
        # placeholder filename so we can later drop in real art without
        # touching JSON.
        image_path = None
    if not isinstance(image_path, str) or not image_path.strip():
        image_path = f"assets/placeholders/species/{plant_id}.png"

    is_legacy = plant_id in LEGACY_PLANT_IDS

    pet_safe = False
    if existing and isinstance(existing.get("pet_safe"), bool):
        pet_safe = bool(existing.get("pet_safe"))

    existing_difficulty = None
    if is_legacy and existing:
        existing_difficulty = existing.get("difficulty")
    if isinstance(existing_difficulty, str) and existing_difficulty.strip():
        difficulty_value = existing_difficulty.strip()
    else:
        difficulty_value = difficulty

    existing_light = None
    if is_legacy and existing:
        existing_light = existing.get("light")
    if isinstance(existing_light, str) and existing_light.strip():
        light_value = existing_light.strip()
    else:
        light_value = light

    if is_legacy and existing and isinstance(existing.get("care_defaults"), dict):
        raw = existing.get("care_defaults") or {}
        parsed: dict[str, int] = {}
        ok = True
        for key in ("waterBaseDays", "fertilizeBaseDays", "mistBaseDays", "rotateBaseDays", "pruneBaseDays"):
            value = raw.get(key)
            if not isinstance(value, (int, float)):
                ok = False
                break
            parsed[key] = max(0, int(value))
        if ok:
            care_defaults = parsed

    history_by_locale: dict[str, str] = {}
    habit_by_locale: dict[str, str] = {}
    if existing:
        if isinstance(existing.get("history"), dict):
            history_by_locale = {str(k): str(v) for k, v in existing["history"].items() if str(v).strip()}
        if isinstance(existing.get("habit"), dict):
            habit_by_locale = {str(k): str(v) for k, v in existing["habit"].items() if str(v).strip()}

    if "en" not in history_by_locale:
        history_by_locale["en"] = _base_history(scientific, family, native_hint, category)
    if "en" not in habit_by_locale:
        habit_by_locale["en"] = _base_habit(profile_id, growth_form, light_value)

    # Build resources (existing wins unless missing).
    resources: dict[str, Any] = {}
    if existing and isinstance(existing.get("external_resources"), dict):
        resources.update({str(k): v for k, v in existing["external_resources"].items()})

    query_name = ""
    for locale in ("zh", "en"):
        localized = common_names.get(locale)
        if localized:
            candidate = (localized[0] or "").strip()
            if candidate:
                query_name = candidate
                break
    if not query_name:
        query_name = scientific

    bilibili_query = f"{query_name} 养护" if _contains_cjk(query_name) else f"{query_name} plant care"

    # Wikipedia (best-effort; not guaranteed to exist).
    resources.setdefault("wikipedia", _wikipedia_url(scientific))
    resources.setdefault("youtube_search", _youtube_search_url(scientific))
    resources.setdefault("baidu_baike_search", _baidu_baike_search_url(query_name))
    resources.setdefault("bilibili_search", _bilibili_search_url(bilibili_query))
    if usage_key:
        resources.setdefault("gbif", _gbif_taxon_url(int(usage_key)))
    if care_guide_url:
        resources.setdefault("care_guide", care_guide_url)

    toxicity = {
        "pets": "pet_safe" if pet_safe else "unknown",
        "humans": "unknown",
        "notes": {
            "en": "If ingestion is suspected, contact a veterinarian/poison control. Avoid relying on a single source for toxicity confirmation."
        },
    }

    suitability = _profile_suitability(profile_id)
    hardiness = _profile_hardiness(profile_id)
    if hardiness:
        suitability = {**suitability, **hardiness}

    entry: dict[str, Any] = {
        "plant_id": plant_id,
        "profile_id": profile_id,
        "common_name": common_name,
        "common_names": common_names,
        "scientific_name": scientific,
        "category": category,
        "tags": tags,
        "image_path": image_path,
        "difficulty": difficulty_value,
        "pet_safe": pet_safe,
        "light": light_value,
        "history": history_by_locale,
        "habit": habit_by_locale,
        "care_basis": "profile_template",
        "botanical": {
            "rank": rank or "unknown",
            "family": family or "unknown",
            "order": order or "unknown",
            "genus": genus or scientific.split(" ")[0],
            "native_range": {"en": native_hint} if native_hint else {"en": "Unknown / needs confirmation"},
            "native_habitat": {"en": _profile_native_habitat(profile_id)},
        },
        "growth": {
            "rate": growth_rate,
            "form": growth_form if growth_form in {"upright", "trailing", "climbing", "rosette", "tree_like", "clumping", "epiphytic", "succulent", "fern", "orchid", "other"} else "other",
            "mature_size_cm": mature_size,
        },
        "suitability": suitability,
        "care_defaults": care_defaults,
        "care": care,
        "common_problems": _common_problems(profile_id),
        "toxicity": toxicity,
        "external_resources": resources,
    }
    return entry


def _load_existing_plantsidea() -> dict[str, Any]:
    if not PLANTS_IDEA_PATH.exists():
        return {"schema_version": 1, "generated_at": _now_utc_iso(), "plants": []}
    with PLANTS_IDEA_PATH.open("r", encoding="utf-8") as f:
        decoded = json.load(f)
    if not isinstance(decoded, dict):
        raise SystemExit("plantsidea.json root must be an object")
    plants = decoded.get("plants")
    if not isinstance(plants, list):
        raise SystemExit('plantsidea.json missing "plants" list')
    return decoded


def _build_seed_list(existing: list[Mapping[str, Any]]) -> list[SeedPlant]:
    # Keep existing ids stable and enrich them first.
    seeds: list[SeedPlant] = []
    for row in existing:
        if not isinstance(row, dict):
            continue
        pid = row.get("plant_id")
        sname = row.get("scientific_name")
        if not isinstance(pid, str) or not isinstance(sname, str):
            continue
        pid = pid.strip()
        sname = sname.strip()
        if not pid or not sname:
            continue
        if pid not in LEGACY_PLANT_IDS:
            continue

        # Existing entries are all indoor in the current seed.
        profile_id = "indoor_tropical"
        if pid in {"sansevieria_trifasciata", "zz_plant"}:
            profile_id = "indoor_low_light"
        if pid in {"nephrolepis_exaltata"}:
            profile_id = "fern"
        if pid in {"phalaenopsis_orchid"}:
            profile_id = "orchid_epiphyte"
        if pid in {"aloe_vera", "crassula_ovata"}:
            profile_id = "succulent"
        if pid in {"calathea_orbifolia"}:
            profile_id = "indoor_humidity"

        seeds.append(SeedPlant(scientific_name=sname, profile_id=profile_id, plant_id=pid))

    # Expanded coverage seeds (scientific names only; common names pulled from GBIF when possible).
    def add_many(names: Iterable[str], profile_id: str, *, light_override: str | None = None) -> None:
        for n in names:
            n = (n or "").strip()
            if not n:
                continue
            seeds.append(SeedPlant(scientific_name=n, profile_id=profile_id, light_override=light_override))

    add_many(
        [
            # Indoor tropical foliage
            "Monstera adansonii",
            "Monstera dubia",
            "Monstera siltepecana",
            "Rhaphidophora tetrasperma",
            "Rhaphidophora decursiva",
            "Scindapsus pictus",
            "Syngonium podophyllum",
            "Epipremnum pinnatum",
            "Aglaonema commutatum",
            "Aglaonema costatum",
            "Dieffenbachia seguine",
            "Alocasia macrorrhizos",
            "Alocasia zebrina",
            "Alocasia x amazonica",
            "Colocasia esculenta",
            "Caladium bicolor",
            "Dracaena fragrans",
            "Dracaena reflexa",
            "Ficus benjamina",
            "Ficus microcarpa",
            "Ficus pumila",
            "Pachira aquatica",
            "Schefflera arboricola",
            "Hedera helix",
            "Fittonia albivenis",
            "Hypoestes phyllostachya",
            "Peperomia obtusifolia",
            "Peperomia caperata",
            "Peperomia argyreia",
            "Tradescantia zebrina",
            "Tradescantia pallida",
            "Begonia rex-cultorum",
            "Begonia maculata",
            "Begonia semperflorens",
            "Kalanchoe blossfeldiana",
            "Cyclamen persicum",
            "Saintpaulia ionantha",
            "Soleirolia soleirolii",
            "Ceropegia woodii",
            "Curio rowleyanus",
            "Curio radicans",
            "Plectranthus verticillatus",
            "Fatsia japonica",
            "Cordyline fruticosa",
            "Oxalis triangularis",
            "Cissus rhombifolia",
            "Ledebouria petiolata",
            "Clivia miniata",
            "Jasminum polyanthum",
            "Hoya australis",
            "Hoya pubicalyx",
            "Hoya kerrii",
            "Anthurium crystallinum",
            "Anthurium clarinervium",
            "Anthurium scherzerianum",
            "Philodendron erubescens",
            "Thaumatophyllum bipinnatifidum",
            "Thaumatophyllum xanadu",
            "Guzmania lingulata",
            "Aechmea fasciata",
            "Tillandsia ionantha",
            "Tillandsia xerographica",
            "Coffea arabica",
        ],
        "indoor_tropical",
    )

    add_many(
        [
            # Sun-tolerant indoor plants (often benefit from some direct sun).
            "Yucca gigantea",
            "Beaucarnea recurvata",
            "Codiaeum variegatum",
        ],
        "indoor_tropical",
        light_override="bright_direct",
    )

    add_many(
        [
            # High-light indoor bloomers / large foliage plants.
            "Gardenia jasminoides",
            "Strelitzia reginae",
            "Strelitzia nicolai",
        ],
        "indoor_tropical",
        light_override="low_to_bright",
    )

    add_many(["Sarracenia purpurea", "Dionaea muscipula"], "carnivorous_bog")
    add_many(["Nepenthes alata"], "carnivorous_tropical")

    add_many(
        [
            # Indoor palms
            "Dypsis lutescens",
            "Howea forsteriana",
            "Chamaedorea elegans",
            "Chamaedorea seifrizii",
            "Rhapis excelsa",
            "Phoenix roebelenii",
            "Livistona chinensis",
        ],
        "indoor_palm",
    )

    add_many(
        [
            # Ferns and humidity lovers
            "Adiantum raddianum",
            "Asplenium nidus",
            "Platycerium bifurcatum",
            "Pteris cretica",
        ],
        "fern",
    )

    add_many(
        [
            # High-humidity foliage (prayer plants + similar)
            "Selaginella kraussiana",
            "Maranta leuconeura",
            "Goeppertia roseopicta",
            "Goeppertia makoyana",
            "Goeppertia insignis",
            "Ctenanthe setosa",
            "Stromanthe sanguinea",
        ],
        "indoor_humidity",
    )

    add_many(
        [
            # Orchids (use genus where hybrids are common)
            "Cattleya",
            "Dendrobium",
            "Oncidium",
            "Paphiopedilum",
            "Cymbidium",
            "Vanilla planifolia",
        ],
        "orchid_epiphyte",
    )

    add_many(
        [
            # Low-light tolerant indoor plants
            "Aglaonema modestum",
            "Aspidistra elatior",
        ],
        "indoor_low_light",
    )

    add_many(
        [
            # Succulents
            "Haworthiopsis attenuata",
            "Haworthiopsis fasciata",
            "Gasteria verrucosa",
            "Echeveria elegans",
            "Echeveria agavoides",
            "Echeveria setosa",
            "Echeveria pulvinata",
            "Sedum morganianum",
            "Sedum rubrotinctum",
            "Sedum adolphii",
            "Sedum spurium",
            "Sempervivum tectorum",
            "Lithops",
            "Lithops lesliei",
            "Fenestraria rhopalophylla",
            "Lapidaria margaretae",
            "Pachyphytum oviferum",
            "Kalanchoe tomentosa",
            "Kalanchoe daigremontiana",
            "Kalanchoe beharensis",
            "Kalanchoe luciae",
            "Aeonium arboreum",
            "Graptopetalum paraguayense",
            "Portulacaria afra",
            "Crassula perforata",
            "Crassula muscosa",
            "Crassula tetragona",
            "Adenium obesum",
            "Agave attenuata",
            "Agave americana",
            "Sansevieria cylindrica",
            "Euphorbia trigona",
            "Euphorbia milii",
            "Euphorbia lactea",
            "Euphorbia obesa",
            "Euphorbia tirucalli",
        ],
        "succulent",
    )

    add_many(
        [
            # Cacti
            "Schlumbergera truncata",
            "Rhipsalis baccifera",
            "Opuntia microdasys",
            "Opuntia ficus-indica",
            "Mammillaria elongata",
            "Mammillaria bocasana",
            "Mammillaria spinosissima",
            "Astrophytum myriostigma",
            "Astrophytum asterias",
            "Parodia magnifica",
            "Rebutia minuscula",
            "Echinocactus grusonii",
            "Gymnocalycium mihanovichii",
            "Gymnocalycium baldianum",
            "Cereus repandus",
            "Hylocereus undatus",
            "Echinopsis pachanoi",
            "Echinopsis oxygona",
            "Ferocactus latispinus",
            "Disocactus anguliger",
        ],
        "cactus",
    )

    add_many(
        [
            # Herbs (Mediterranean)
            "Salvia rosmarinus",
            "Thymus vulgaris",
            "Origanum vulgare",
            "Salvia officinalis",
            "Lavandula angustifolia",
            "Foeniculum vulgare",
            "Artemisia dracunculus",
            "Laurus nobilis",
        ],
        "herb_mediterranean",
    )

    add_many(
        [
            # Herbs (moist / leafy)
            "Ocimum basilicum",
            "Mentha spicata",
            "Mentha x piperita",
            "Petroselinum crispum",
            "Coriandrum sativum",
            "Anethum graveolens",
            "Allium schoenoprasum",
            "Melissa officinalis",
            "Cymbopogon citratus",
            "Zingiber officinale",
            "Curcuma longa",
            "Stevia rebaudiana",
            "Matricaria chamomilla",
            "Calendula officinalis",
        ],
        "herb_moist",
    )

    add_many(
        [
            # Temperate fruit trees/shrubs
            "Malus domestica",
            "Pyrus communis",
            "Prunus persica",
            "Prunus armeniaca",
            "Prunus domestica",
            "Prunus avium",
            "Prunus cerasus",
            "Prunus dulcis",
            "Prunus mume",
            "Ficus carica",
            "Punica granatum",
            "Diospyros kaki",
            "Cydonia oblonga",
            "Actinidia deliciosa",
            "Morus alba",
            "Morus nigra",
            "Corylus avellana",
            "Vaccinium corymbosum",
            "Rubus idaeus",
            "Rubus fruticosus",
            "Fragaria x ananassa",
            "Vitis vinifera",
            "Ribes nigrum",
            "Ribes rubrum",
            "Sambucus nigra",
        ],
        "fruit_tree_temperate",
    )

    add_many(
        [
            # Subtropical/tropical fruit (often container-grown in cooler zones)
            "Citrus limon",
            "Citrus sinensis",
            "Citrus reticulata",
            "Citrus aurantiifolia",
            "Citrus paradisi",
            "Citrus maxima",
            "Citrus aurantium",
            "Persea americana",
            "Mangifera indica",
            "Carica papaya",
            "Musa x paradisiaca",
            "Ananas comosus",
            "Psidium guajava",
            "Passiflora edulis",
            "Olea europaea",
            "Litchi chinensis",
            "Eriobotrya japonica",
            "Annona cherimola",
        ],
        "fruit_tree_subtropical",
    )

    add_many(
        [
            # Outdoor shrubs (temperate ornamentals)
            "Buddleja davidii",
            "Hibiscus syriacus",
            "Rosa rugosa",
            "Rosa gallica",
            "Rosa canina",
            "Cistus ladanifer",
            "Syringa vulgaris",
            "Forsythia x intermedia",
            "Spiraea japonica",
            "Weigela florida",
            "Viburnum opulus",
            "Buxus sempervirens",
            "Ilex aquifolium",
            "Nandina domestica",
            "Pittosporum tobira",
            "Photinia x fraseri",
            "Loropetalum chinense",
            "Osmanthus fragrans",
            "Abelia x grandiflora",
            "Philadelphus coronarius",
        ],
        "outdoor_shrub_temperate",
    )

    add_many(
        [
            # Sun to part-shade tolerant shrubs.
            "Hydrangea paniculata",
            "Hydrangea arborescens",
        ],
        "outdoor_shrub_temperate",
        light_override="low_to_bright",
    )

    add_many(
        [
            # Part-shade shrubs (morning sun / afternoon shade in hot climates).
            "Hydrangea macrophylla",
            "Hydrangea quercifolia",
            "Camellia japonica",
            "Camellia sasanqua",
            "Pieris japonica",
        ],
        "outdoor_shrub_temperate",
        light_override="bright_indirect",
    )

    add_many(
        [
            # Shade-preferring shrubs.
            "Rhododendron ponticum",
            "Skimmia japonica",
        ],
        "outdoor_shrub_temperate",
        light_override="medium_indirect",
    )

    add_many(
        [
            # Outdoor trees (temperate)
            "Acer palmatum",
            "Acer rubrum",
            "Magnolia grandiflora",
            "Magnolia stellata",
            "Cornus florida",
            "Cercis canadensis",
            "Prunus serrulata",
            "Lagerstroemia indica",
            "Ginkgo biloba",
            "Betula pendula",
            "Quercus robur",
            "Quercus rubra",
            "Liquidambar styraciflua",
            "Platanus x acerifolia",
            "Fagus sylvatica",
            "Ulmus parvifolia",
            "Tilia cordata",
            "Salix babylonica",
        ],
        "outdoor_tree_temperate",
    )

    add_many(
        [
            # Outdoor perennials
            "Hemerocallis fulva",
            "Iris germanica",
            "Iris sibirica",
            "Paeonia lactiflora",
            "Rudbeckia hirta",
            "Echinacea purpurea",
            "Achillea millefolium",
            "Coreopsis grandiflora",
            "Gaillardia aristata",
            "Salvia nemorosa",
            "Nepeta cataria",
            "Delphinium elatum",
            "Lupinus polyphyllus",
            "Phlox paniculata",
            "Miscanthus sinensis",
            "Pennisetum alopecuroides",
            "Tulipa gesneriana",
            "Narcissus pseudonarcissus",
            "Hyacinthus orientalis",
            "Crocus vernus",
            "Lilium lancifolium",
            "Dahlia pinnata",
        ],
        "outdoor_perennial",
    )

    add_many(
        [
            # Shade/woodland perennials and groundcovers.
            "Hosta plantaginea",
            "Helleborus orientalis",
            "Astilbe chinensis",
            "Brunnera macrophylla",
            "Lamium maculatum",
            "Ajuga reptans",
            "Vinca minor",
            "Pachysandra terminalis",
        ],
        "outdoor_perennial",
        light_override="medium_indirect",
    )

    add_many(
        [
            # Part-shade perennials.
            "Digitalis purpurea",
            "Aquilegia vulgaris",
            "Heuchera sanguinea",
            "Bergenia cordifolia",
            "Liriope muscari",
        ],
        "outdoor_perennial",
        light_override="bright_indirect",
    )

    add_many(
        [
            # Sun to part-shade perennials.
            "Zantedeschia aethiopica",
            "Gerbera jamesonii",
        ],
        "outdoor_perennial",
        light_override="low_to_bright",
    )

    add_many(
        [
            # Outdoor annuals
            "Petunia x atkinsiana",
            "Tagetes erecta",
            "Zinnia elegans",
            "Antirrhinum majus",
            "Helianthus annuus",
            "Cosmos bipinnatus",
            "Tropaeolum majus",
            "Pelargonium x hortorum",
            "Salvia splendens",
            "Lobularia maritima",
            "Celosia argentea",
            "Ageratum houstonianum",
            "Portulaca grandiflora",
            "Gazania rigens",
        ],
        "outdoor_annual",
    )

    add_many(
        [
            # Shade annuals.
            "Impatiens walleriana",
        ],
        "outdoor_annual",
        light_override="medium_indirect",
    )

    add_many(
        [
            # Part-shade annuals.
            "Lobelia erinus",
        ],
        "outdoor_annual",
        light_override="bright_indirect",
    )

    add_many(
        [
            # Sun to part-shade annuals.
            "Viola tricolor",
            "Nicotiana alata",
        ],
        "outdoor_annual",
        light_override="low_to_bright",
    )

    # To guarantee 300+ coverage, add a wider set of common ornamentals and edibles.
    add_many(
        [
            "Solanum lycopersicum",
            "Capsicum annuum",
            "Cucumis sativus",
            "Cucurbita pepo",
            "Phaseolus vulgaris",
            "Pisum sativum",
            "Lactuca sativa",
            "Spinacia oleracea",
            "Brassica oleracea",
            "Daucus carota",
            "Raphanus sativus",
            "Beta vulgaris",
            "Allium cepa",
            "Allium sativum",
        ],
        "outdoor_annual",
    )

    # Deduplicate by (plant_id if present else scientific name slug).
    unique: list[SeedPlant] = []
    seen: set[str] = set()
    for s in seeds:
        key = (s.plant_id or _slugify(s.scientific_name)).lower()
        if key in seen:
            continue
        seen.add(key)
        unique.append(s)
    return unique


def main() -> int:
    existing_root = _load_existing_plantsidea()
    existing_plants_raw = existing_root.get("plants")
    existing_plants: list[Mapping[str, Any]] = (
        [x for x in existing_plants_raw if isinstance(x, dict)] if isinstance(existing_plants_raw, list) else []
    )
    existing_by_id: dict[str, Mapping[str, Any]] = {}
    for p in existing_plants:
        pid = p.get("plant_id")
        if isinstance(pid, str) and pid.strip():
            existing_by_id[pid.strip()] = p

    seeds = _build_seed_list(existing_plants)
    if len(seeds) < 300:
        print(f"Seed list too small ({len(seeds)}). Add more plants.", file=sys.stderr)
        return 2

    # Care guide URLs by profile (authoritative general guidance).
    care_guides = {
        "indoor_tropical": "https://extension.illinois.edu/houseplants",
        "indoor_low_light": "https://extension.illinois.edu/houseplants",
        "indoor_palm": "https://extension.illinois.edu/houseplants",
        "indoor_humidity": "https://extension.illinois.edu/houseplants",
        "fern": "https://extension.illinois.edu/houseplants",
        "orchid_epiphyte": "https://extension.illinois.edu/houseplants",
        "carnivorous_bog": "https://plants.ces.ncsu.edu/plants/dionaea-muscipula/",
        "carnivorous_tropical": "https://gardeningsolutions.ifas.ufl.edu/plants/ornamentals/carnivorous-plants.html",
        "succulent": "https://hortnews.extension.iastate.edu/1997/3-14-1997/cacti.html",
        "cactus": "https://hortnews.extension.iastate.edu/1997/3-14-1997/cacti.html",
        "herb_mediterranean": "https://extension.umn.edu/vegetables/growing-herbs",
        "herb_moist": "https://extension.umn.edu/vegetables/growing-herbs",
        "fruit_tree_temperate": "https://extension.psu.edu/pruning-deciduous-fruit-trees",
        "fruit_tree_subtropical": "https://extension.psu.edu/pruning-deciduous-fruit-trees",
        "outdoor_perennial": "https://www.uaex.uada.edu/yard-garden/resource-library/perennials/frost_protection.aspx",
        "outdoor_annual": "https://www.uaex.uada.edu/yard-garden/resource-library/perennials/frost_protection.aspx",
        "outdoor_shrub_temperate": "https://www.uaex.uada.edu/yard-garden/resource-library/perennials/frost_protection.aspx",
        "outdoor_tree_temperate": "https://www.uaex.uada.edu/yard-garden/resource-library/perennials/frost_protection.aspx",
    }

    session = _requests_session()

    # Pre-fetch GBIF + Wikipedia hints concurrently (kept conservative).
    def fetch_one(seed: SeedPlant) -> tuple[SeedPlant, dict[str, Any], list[str], str | None]:
        gbif = {}
        common = []
        native_hint = None
        try:
            gbif = _gbif_match(session, seed.scientific_name)
            match_type = (gbif.get("matchType") or "").strip().upper()
            rank = (gbif.get("rank") or "").strip().upper()
            is_species_level = match_type != "HIGHERRANK" and rank not in {"GENUS", "FAMILY", "ORDER", "CLASS", "PHYLUM", "KINGDOM"}

            key = gbif.get("usageKey")
            if is_species_level and isinstance(key, int):
                try:
                    common = _gbif_vernacular_names(session, key)
                except Exception:
                    common = []
        except Exception:
            gbif = {}

        try:
            wiki_query = seed.scientific_name
            if gbif:
                match_type = (gbif.get("matchType") or "").strip().upper()
                rank = (gbif.get("rank") or "").strip().upper()
                if match_type != "HIGHERRANK" and rank not in {"GENUS", "FAMILY", "ORDER", "CLASS", "PHYLUM", "KINGDOM"}:
                    wiki_query = (gbif.get("canonicalName") or seed.scientific_name)
            native_hint = _wiki_native_range_hint(session, wiki_query)
        except Exception:
            native_hint = None

        # Be polite to public endpoints when running without cache.
        time.sleep(0.02)
        return seed, gbif, common, native_hint

    results: list[tuple[SeedPlant, dict[str, Any], list[str], str | None]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as ex:
        futures = [ex.submit(fetch_one, s) for s in seeds]
        for f in concurrent.futures.as_completed(futures):
            results.append(f.result())

    # Stable output order: by derived plant_id then scientific name.
    built: list[dict[str, Any]] = []
    for seed, gbif, common_en, native_hint in results:
        existing = existing_by_id.get(seed.plant_id) if seed.plant_id else None
        care_guide = care_guides.get(seed.profile_id)
        entry = _build_entry(
            seed=seed,
            existing=existing,
            gbif=gbif,
            common_names_en=common_en,
            native_hint=native_hint,
            care_guide_url=care_guide,
        )
        built.append(entry)

    built.sort(key=lambda e: (e.get("plant_id") or "", e.get("scientific_name") or ""))

    # Root metadata. Keep original keys but bump schema_version.
    out_root: dict[str, Any] = {
        "schema_version": 2,
        "generated_at": _now_utc_iso(),
        "reference_sources": [
            {
                "id": "uiuc_houseplants",
                "title": "Houseplants (care, watering, fertilizing, light)",
                "organization": "University of Illinois Extension",
                "url": "https://extension.illinois.edu/houseplants",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "umd_watering_indoor_plants",
                "title": "Watering Indoor Plants",
                "organization": "University of Maryland Extension",
                "url": "https://extension.umd.edu/resource/watering-indoor-plants/",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "isu_cacti_succulents",
                "title": "Cacti and Succulents (general care)",
                "organization": "Iowa State University Extension and Outreach",
                "url": "https://hortnews.extension.iastate.edu/1997/3-14-1997/cacti.html",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "ncsu_venus_flytrap",
                "title": "Dionaea muscipula (Venus flytrap)",
                "organization": "NC State Extension (Plant Toolbox)",
                "url": "https://plants.ces.ncsu.edu/plants/dionaea-muscipula/",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "uf_ifas_carnivorous",
                "title": "Carnivorous plants (general care)",
                "organization": "UF/IFAS Gardening Solutions",
                "url": "https://gardeningsolutions.ifas.ufl.edu/plants/ornamentals/carnivorous-plants.html",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "umn_growing_herbs",
                "title": "Growing herbs",
                "organization": "University of Minnesota Extension",
                "url": "https://extension.umn.edu/vegetables/growing-herbs",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "uaex_frost_protection",
                "title": "Frost Protection",
                "organization": "University of Arkansas Cooperative Extension Service",
                "url": "https://www.uaex.uada.edu/yard-garden/resource-library/perennials/frost_protection.aspx",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "psu_prune_fruit_trees",
                "title": "Pruning deciduous fruit trees",
                "organization": "Penn State Extension",
                "url": "https://extension.psu.edu/pruning-deciduous-fruit-trees",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "usda_hardiness_zones",
                "title": "USDA Plant Hardiness Zone Map",
                "organization": "USDA",
                "url": "https://planthardiness.ars.usda.gov/",
                "accessed_at": _now_utc_iso()[:10],
            },
            {
                "id": "gbif_taxonomy",
                "title": "GBIF Species API (taxonomy + vernacular names)",
                "organization": "GBIF",
                "url": "https://www.gbif.org/developer/species",
                "accessed_at": _now_utc_iso()[:10],
            },
        ],
        "plants": built,
    }

    # Basic sanity checks.
    if len(out_root["plants"]) < 300:
        print(f"Only produced {len(out_root['plants'])} plants; expected >= 300", file=sys.stderr)
        return 3
    ids = [p.get("plant_id") for p in out_root["plants"]]
    if len(ids) != len(set(ids)):
        print("Duplicate plant_id values detected; aborting write.", file=sys.stderr)
        return 4

    created = _sync_species_placeholders(out_root["plants"])
    if created:
        print(f"Created {created} missing species placeholder PNGs in {PLACEHOLDER_SPECIES_DIR}")

    PLANTS_IDEA_PATH.write_text(json.dumps(out_root, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(out_root['plants'])} plant entries -> {PLANTS_IDEA_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
