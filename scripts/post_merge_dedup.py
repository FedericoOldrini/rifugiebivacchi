#!/usr/bin/env python3
"""
Post-merge dedup: operates directly on cai_app_data.json to:
1. Filter out Wikidata records that are NOT mountain shelters (houses, palaces, parks, etc.)
   Also removes generic junk records ("House", "Rifugio" with no qualifying name).
2. Deduplicate remaining records by coordinate proximity (≤500m default)
   - Same-source: up to 50m with strict name matching
   - Cross-source: up to 200m with adaptive name thresholds
   - Cross-source identical names: up to 500m
   - Keeps the record with highest trust score + most details
   - Merges additional data (images, fields) from discarded records

Usage:
    python3 scripts/post_merge_dedup.py [--dry-run] [--threshold 500]

Output:
    - cai_app_data.json (overwritten with deduped data)
    - scripts/data/post_merge_dedup_log.json (detailed log)
"""

import json
import math
import os
import sys
import argparse
from collections import defaultdict
from datetime import datetime
from typing import Optional, List, Dict, Any, Tuple, Set

# ──────────────────────────────────────────────────────────────
# Trust hierarchy (same as shared.py)
# ──────────────────────────────────────────────────────────────

SOURCE_TRUST = {
    "verified_manager": 100,
    "rifugi.cai": 80,
    "opendata_regional": 60,
    "capanneti.ch": 55,
    "openstreetmap": 40,
    "refuges.info": 35,
    "wikidata": 20,
}

# ──────────────────────────────────────────────────────────────
# Shelter name detection for Wikidata filtering
# ──────────────────────────────────────────────────────────────

# Keywords that indicate a record IS a mountain shelter
SHELTER_NAME_KEYWORDS = [
    # Italian
    "rifugio",
    "bivacco",
    "capanna",
    "malga",
    "alpe ",
    "baita",
    "casera",
    "maso",
    "stavolo",
    "casone",
    "tabià",
    # German
    "hütte",
    "biwak",
    "berggasthaus",
    "berghaus",
    "berghotel",
    "bergheim",
    "bergrestaurant",
    "schutzhütte",
    "berghütte",
    "clubhütte",
    "clubhaus",
    "hospiz",
    # French
    "refuge",
    "cabane",
    "bivouac",
    "hospice",
    "chalet",
    # Romansh
    "chamonna",
    "chamanna",
    # English
    " hut",
    "mountain house",
    "alpine hut",
    "alp hut",
    # Slovenian
    "koča",
    # Generic
    "alp ",
]

# Minimum altitude to consider a Wikidata record legitimate even without name match
WIKIDATA_MIN_ALTITUDE = 500


# Wikidata records that are known to be non-shelter junk despite passing
# altitude checks (urban buildings, etc.).
WIKIDATA_JUNK_IDS = frozenset(
    [
        "Q29882620",  # House (Wikidata)
        "Q29882639",  # House (Wikidata)
        "Q29882644",  # House (Wikidata)
        "Q29882599",  # House (Wikidata)
        "Q130647626",  # House (Wikidata)
        "Q130646831",  # House (Wikidata)
    ]
)

# Names that indicate a Wikidata record is NOT a shelter even if at altitude
WIKIDATA_JUNK_NAMES = frozenset(
    [
        "house",
        "casa",
        "palazzo",
        "palace",
        "building",
        "gebäude",
        "kirche",
        "church",
        "chiesa",
        "fountain",
        "brunnen",
        "fontana",
    ]
)


def is_wikidata_shelter(record):
    # type: (Dict[str, Any]) -> bool
    """Check if a Wikidata record is likely a mountain shelter.

    Rejects records with:
    - Known junk Wikidata IDs (urban buildings)
    - Generic non-shelter names ("House", "Casa", etc.)
    """
    source_id = record.get("sourceId", "")
    name = record.get("name", "").lower().strip()

    # Reject known junk Wikidata IDs
    if source_id in WIKIDATA_JUNK_IDS:
        return False

    # Reject generic non-shelter names (bare name with no qualifier)
    if name in WIKIDATA_JUNK_NAMES:
        return False

    # Check name keywords
    for kw in SHELTER_NAME_KEYWORDS:
        if kw in name:
            return True

    # Check altitude — if it has altitude > 500m, it's probably legit
    alt = record.get("geo", {}).get("altitude")
    if alt is not None and alt != "" and alt != "?":
        try:
            if float(alt) >= WIKIDATA_MIN_ALTITUDE:
                return True
        except (ValueError, TypeError):
            pass

    return False


# ──────────────────────────────────────────────────────────────
# Haversine distance
# ──────────────────────────────────────────────────────────────


def haversine(lat1, lon1, lat2, lon2):
    # type: (float, float, float, float) -> float
    """Distance in meters between two GPS points."""
    R = 6371000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    )
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def get_coords(record):
    # type: (Dict[str, Any]) -> Tuple[float, float]
    geo = record.get("geo", {})
    return geo.get("lat", 0.0), geo.get("lng", 0.0)


# ──────────────────────────────────────────────────────────────
# Record richness scoring
# ──────────────────────────────────────────────────────────────


def count_non_empty(obj, prefix=""):
    # type: (Any, str) -> int
    """Recursively count non-null, non-empty fields in a nested dict."""
    if obj is None or obj == "" or obj == "?" or obj == []:
        return 0
    if isinstance(obj, dict):
        total = 0
        for k, v in obj.items():
            total += count_non_empty(v, prefix + k + ".")
        return total
    if isinstance(obj, list):
        return len(obj)  # Count list items (e.g., mediaList length)
    # Primitive non-empty value
    return 1


def record_richness(record):
    # type: (Dict[str, Any]) -> int
    """Score a record by how much useful data it contains."""
    score = 0

    # Count fields in geo (altitude, locality, region, etc.)
    score += count_non_empty(record.get("geo", {}))

    # Count services
    score += count_non_empty(record.get("services", {}))

    # Count contacts
    score += count_non_empty(record.get("contacts", {}))

    # Count accessibility
    score += count_non_empty(record.get("accessibilita", {}))

    # Count property
    score += count_non_empty(record.get("property", {}))

    # Media list: each image is worth 2 points
    media = record.get("mediaList") or []
    score += len(media) * 2

    # Bonus for having description
    desc = (record.get("geo", {}).get("description") or "").strip()
    if desc:
        score += 3

    # Bonus for having owner
    if record.get("owner"):
        score += 1

    # Bonus for buildYear
    if record.get("buildYear"):
        score += 1

    # Bonus for status
    if record.get("status") and record.get("status") != "?":
        score += 1

    return score


def record_priority(record):
    # type: (Dict[str, Any]) -> Tuple[int, int]
    """Return (trust_score, richness) tuple for sorting. Higher = better."""
    source = record.get("source", "")
    trust = SOURCE_TRUST.get(source, 0)
    richness = record_richness(record)
    return (trust, richness)


# ──────────────────────────────────────────────────────────────
# Merge: enrich winner with data from losers
# ──────────────────────────────────────────────────────────────


def merge_media_lists(winner_media, loser_media):
    # type: (List[Dict], List[Dict]) -> List[Dict]
    """Merge media lists, avoiding duplicate URLs."""
    existing_urls = set()
    for m in winner_media:
        url = m.get("url", "")
        if url:
            existing_urls.add(url)

    merged = list(winner_media)
    for m in loser_media:
        url = m.get("url", "")
        if url and url not in existing_urls:
            merged.append(m)
            existing_urls.add(url)
    return merged


def merge_dict_fields(winner_dict, loser_dict):
    # type: (Optional[Dict], Optional[Dict]) -> Optional[Dict]
    """Overlay loser's non-empty fields onto winner where winner is empty."""
    if not loser_dict:
        return winner_dict
    if not winner_dict:
        return dict(loser_dict)

    result = dict(winner_dict)
    for k, v in loser_dict.items():
        existing = result.get(k)
        if (
            existing is None
            or existing == ""
            or existing == "?"
            or existing == []
            or existing == False
        ):
            if v is not None and v != "" and v != "?" and v != []:
                result[k] = v
    return result


def merge_records(winner, losers):
    # type: (Dict[str, Any], List[Dict[str, Any]]) -> Dict[str, Any]
    """
    Merge data from loser records into the winner.
    Winner keeps all its fields; losers fill in blanks and add images.
    """
    result = json.loads(json.dumps(winner))  # Deep copy

    for loser in losers:
        # Merge nested dicts (fill in blanks)
        for key in ["geo", "services", "contacts", "accessibilita", "property"]:
            result[key] = merge_dict_fields(result.get(key), loser.get(key))

        # Merge media
        winner_media = result.get("mediaList") or []
        loser_media = loser.get("mediaList") or []
        if loser_media:
            result["mediaList"] = merge_media_lists(winner_media, loser_media)

        # Fill in top-level fields if winner is missing them
        for key in ["owner", "buildYear", "status", "regionalType"]:
            w_val = result.get(key)
            l_val = loser.get(key)
            if (
                (w_val is None or w_val == "" or w_val == "?")
                and l_val
                and l_val != ""
                and l_val != "?"
            ):
                result[key] = l_val

    return result


# ──────────────────────────────────────────────────────────────
# Pair validation: should two nearby records be merged?
# ──────────────────────────────────────────────────────────────


def normalize_name_for_compare(name):
    # type: (str) -> str
    """Normalize a name for comparison: lowercase, strip prefixes, accents."""
    import unicodedata

    name = name.lower().strip()
    # Remove common prefixes (order matters: longer prefixes first)
    for prefix in [
        "refuge-bivouac ",
        "refugio-vivac ",
        "rifugio non gestito ",
        "rifugio incustodito ",
        "bivacco fisso ",
        "rifugio ",
        "bivacco ",
        "capanna ",
        "malga ",
        "baita ",
        "refuge ",
        "bivouac ",
        "bivouak ",
        "cabane ",
        "cabana ",
        "hutte ",
        "hütte ",
        "alpe ",
        "alp ",
        "berggasthaus ",
        "berghaus ",
        "berghotel ",
        "sac ",
        "sac-hütte ",
        "sac-hutte ",
        "planinarska kuca ",
        "planinarski dom ",
    ]:
        if name.startswith(prefix):
            name = name[len(prefix) :]
            break
    # Strip accents
    nfkd = unicodedata.normalize("NFKD", name)
    name = "".join(c for c in nfkd if not unicodedata.combining(c))
    # Normalize number words to digits for equivalence
    number_map = {
        "zero": "0",
        "uno": "1",
        "due": "2",
        "tre": "3",
        "quattro": "4",
        "cinque": "5",
        "sei": "6",
        "sette": "7",
        "otto": "8",
        "nove": "9",
        "dieci": "10",
    }
    words = name.split()
    words = [number_map.get(w, w) for w in words]
    return " ".join(words)


# Set of generic/meaningless names that should not block a merge when
# a specific name is available nearby.
_GENERIC_NAMES = frozenset(
    [
        "refuge",
        "refugio",
        "rifugio",
        "bivouac",
        "bivacco",
        "cabane",
        "hutte",
        "hütte",
        "capanna",
        "berghaus",
        "berggasthaus",
        "shelter",
        "mountain hut",
    ]
)


def _is_generic_name(name):
    # type: (str) -> bool
    """Return True if name is generic (just a type word with no qualifier)."""
    return (
        normalize_name_for_compare(name).strip() == ""
        or name.lower().strip() in _GENERIC_NAMES
    )


def _extract_toponym_words(normalized_name):
    # type: (str) -> set
    """Extract meaningful toponym words (len >= 4, not stopwords/type words)."""
    stopwords = {
        # Italian articles/prepositions
        "del",
        "dei",
        "della",
        "delle",
        "dello",
        "degli",
        "di",
        "da",
        "dal",
        "dalla",
        "sul",
        "sulla",
        "nel",
        "nella",
        "con",
        "per",
        # French/German/English
        "les",
        "des",
        "aux",
        "the",
        "von",
        "und",
        "zum",
        "zur",
        # Adjectives commonly in shelter names
        "non",
        "gestito",
        "incustodito",
        "custodito",
        "vecchio",
        "nuovo",
        "alto",
        "basso",
    }
    # Structure type words that should NOT count as toponyms
    type_words = {
        "rifugio",
        "bivacco",
        "capanna",
        "malga",
        "baita",
        "alpe",
        "refuge",
        "bivouac",
        "cabane",
        "cabana",
        "hutte",
        "almhutte",
        "berggasthaus",
        "berghaus",
        "berghotel",
        "cuile",
        "house",
        "casa",
        "casera",
        "casetta",
        "cascina",
        "shelter",
    }
    return {
        w
        for w in normalized_name.split()
        if len(w) >= 4 and w not in stopwords and w not in type_words
    }


def _uninvert_parenthetical(name):
    # type: (str) -> str
    """Convert 'Fora (Alp di)' → 'alp di fora' for matching inverted names.
    Also handles 'Lago (Alpe del)' → 'alpe del lago'.
    Returns lowercase with parenthetical prefix moved to front, or original if no match."""
    import re

    # Match: "Main (Prefix stuff)" → "prefix stuff main"
    m = re.match(r"^(.+?)\s*\((.+?)\)\s*$", name.strip())
    if m:
        main_part = m.group(1).strip().lower()
        paren_part = m.group(2).strip().lower()
        return paren_part + " " + main_part
    return name.lower().strip()


def simple_name_similarity(name1, name2):
    # type: (str, str) -> float
    """Name similarity with toponym awareness, generic-name handling,
    and inverted-name detection (e.g., 'Alp di Fora' ↔ 'Fora (Alp di)')."""
    n1 = normalize_name_for_compare(name1)
    n2 = normalize_name_for_compare(name2)
    if not n1 or not n2:
        return 0.0
    if n1 == n2:
        return 1.0

    # Check inverted parenthetical names before other comparisons
    # "Fora (Alp di)" uninverted → "alp di fora"
    u1 = _uninvert_parenthetical(name1)
    u2 = _uninvert_parenthetical(name2)
    # Compare uninverted forms against each normalized form
    u1_norm = normalize_name_for_compare(u1) if u1 != name1.lower().strip() else n1
    u2_norm = normalize_name_for_compare(u2) if u2 != name2.lower().strip() else n2
    if u1_norm and u2_norm:
        if u1_norm == n2 or u2_norm == n1 or u1_norm == u2_norm:
            return 0.90
        # Check containment with uninverted forms
        if u1_norm in n2 or n2 in u1_norm or u2_norm in n1 or n1 in u2_norm:
            return 0.85

    # If one name is generic ("Refuge") and the other is specific, treat
    # them as a match (score 0.75) — the specific name will survive as winner.
    if _is_generic_name(name1) or _is_generic_name(name2):
        return 0.75

    # Check if one contains the other
    if n1 in n2 or n2 in n1:
        return 0.85

    # Word overlap (Jaccard)
    words1 = set(n1.split())
    words2 = set(n2.split())
    if not words1 or not words2:
        return 0.0
    overlap = words1 & words2
    total = words1 | words2
    jaccard = len(overlap) / len(total) if total else 0.0

    # Toponym boost: if both names share a meaningful toponym word,
    # ensure similarity is at least 0.65 (catches cases like
    # "SAC Waldweid" vs "SAC-Hütte Waldweid" where prefix stripping
    # differs but the toponym "waldweid" is shared).
    topo1 = _extract_toponym_words(n1)
    topo2 = _extract_toponym_words(n2)
    shared_toponyms = topo1 & topo2
    if shared_toponyms:
        jaccard = max(jaccard, 0.65)

    return jaccard


def _has_suspicious_altitude(rec):
    # type: (Dict[str, Any]) -> bool
    """Return True if a record's altitude looks obviously wrong (e.g., ≤10m
    for a mountain shelter, which usually indicates bad Wikidata data)."""
    alt_raw = rec.get("geo", {}).get("altitude")
    if alt_raw is None:
        return False
    try:
        return float(alt_raw) <= 10
    except (ValueError, TypeError):
        return False


def should_merge(r1, r2, distance_m):
    # type: (Dict[str, Any], Dict[str, Any], float) -> bool
    """
    Decide whether two nearby records should be merged.

    Distance ranges and thresholds:

    SAME SOURCE:
    - ≤20m  → name_sim ≥ 0.5 (relaxed, very close)
    - 20-50m → name_sim ≥ 0.85 (conservative)
    - >50m  → never merge same-source (different structures nearby)

    CROSS-SOURCE:
    - ≤5m   → always merge (same GPS point)
    - 5-30m → merge unless altitude/name evidence says distinct
    - 30-100m → merge if name_sim ≥ 0.65 OR shared toponym + containment
    - 100-200m → merge only if name containment OR name_sim ≥ 0.85
    - 200-500m → merge only if identical normalized name OR name_sim ≥ 0.90
                  OR name containment with shared toponym

    Universal:
    - Altitude diff > 100m → NOT same place (with exceptions for bad data)
    - Altitude diff > 50m AND name_sim < 0.5 → NOT same place
    - Water points (Fontaine/Source) → never merge with shelters
    - Bergerie/Caserma forestale → never merge with shelters
    - Vecchio/Nuovo/Winter/D'hiver → distinct buildings
    """
    s1 = r1.get("source", "")
    s2 = r2.get("source", "")

    name1 = r1.get("name", "")
    name2 = r2.get("name", "")
    name_sim = simple_name_similarity(name1, name2)

    # Normalized names for containment and toponym checks
    n1 = normalize_name_for_compare(name1)
    n2 = normalize_name_for_compare(name2)
    contains = (n1 in n2 or n2 in n1) if (n1 and n2) else False
    topo1 = _extract_toponym_words(n1)
    topo2 = _extract_toponym_words(n2)
    shared_toponyms = topo1 & topo2

    # Detect "vecchio/nuovo" pattern: "Rifugio X" vs "Rifugio X Vecchio" or
    # "Rifugio X Nuovo" — these are typically distinct buildings even if nearby.
    _old_new_words = {
        "vecchio",
        "nuovo",
        "old",
        "new",
        "ancien",
        "winter",
        "hiver",
        "d'hiver",
    }
    words1 = set(n1.split())
    words2 = set(n2.split())
    diff_words = words1.symmetric_difference(words2)
    has_old_new_distinction = bool(diff_words & _old_new_words)

    # Detect "Fontaine/Source" from refuges.info — these are often water points,
    # not shelters. They should NOT be merged with nearby shelters.
    # Exception: "Source refuge/bivouac X" is a refuges.info naming pattern for
    # actual shelters, NOT water points.
    _water_only_prefixes = ("fontaine ",)
    _source_but_shelter_keywords = (
        "refuge",
        "bivouac",
        "cabane",
        "rifugio",
        "bivacco",
        "hutte",
        "hütte",
    )
    name1_lower = name1.lower().strip()
    name2_lower = name2.lower().strip()
    is_water_point_pair = False
    if s1 != s2:

        def _is_water_point(nm):
            # type: (str) -> bool
            nm_l = nm.lower().strip()
            # "Fontaine ..." is always a water point
            if any(nm_l.startswith(p) for p in _water_only_prefixes):
                return True
            # "Source ..." is a water point UNLESS followed by shelter keyword
            if nm_l.startswith("source "):
                rest = nm_l[7:]
                if any(kw in rest for kw in _source_but_shelter_keywords):
                    return False
                return True
            return False

        n1_is_water = _is_water_point(name1)
        n2_is_water = _is_water_point(name2)
        # One is a water point and the other is not
        if n1_is_water != n2_is_water:
            is_water_point_pair = True

    # Universal rule: check altitude difference FIRST (applies to ALL pairs)
    alt1_raw = r1.get("geo", {}).get("altitude")
    alt2_raw = r2.get("geo", {}).get("altitude")
    alt_diff = None  # type: Optional[float]
    if alt1_raw and alt2_raw:
        try:
            alt_diff = abs(float(alt1_raw) - float(alt2_raw))
        except (ValueError, TypeError):
            pass

    # Large altitude difference = normally distinct structures
    if alt_diff is not None and alt_diff > 100:
        # Exception 1: if sources differ AND one has obviously wrong altitude
        # (e.g., Wikidata showing 2m for an alpine bivouac) AND names match
        # well AND they're close — allow merge anyway.
        if s1 != s2 and distance_m <= 30 and name_sim >= 0.7:
            if _has_suspicious_altitude(r1) or _has_suspicious_altitude(r2):
                pass  # allow merge despite altitude diff
            else:
                # Exception 2: extremely close (≤5m) cross-source with decent
                # name similarity — altitude data from one source is likely wrong
                # (e.g., refuges.info typo 3852 vs CAI 3582).
                if distance_m <= 5 and name_sim >= 0.5:
                    pass  # allow merge
                else:
                    return False
        else:
            # Exception 2 also applies here (≤5m even if name_sim < 0.7)
            if s1 != s2 and distance_m <= 5 and name_sim >= 0.5:
                pass  # allow merge
            else:
                return False

    # ── Same source ──────────────────────────────────────────
    if s1 == s2:
        # Same-source pairs with different structure types (e.g., "Capanna" vs
        # "Bivacco", "Rifugio" vs "Bivacco") are almost always distinct
        # buildings at the same location. Do NOT merge them.
        type1 = r1.get("type", "").lower()
        type2 = r2.get("type", "").lower()
        if type1 and type2 and type1 != type2:
            # Check if the types represent fundamentally different structures
            shelter_groups = {
                "rifugio": "managed",
                "rifugio custodito": "managed",
                "rifugio non gestito": "unmanaged",
                "rifugio incustodito": "unmanaged",
                "capanna sociale": "managed",
                "bivacco": "bivacco",
                "bivacco fisso": "bivacco",
            }
            g1 = shelter_groups.get(type1)
            g2 = shelter_groups.get(type2)
            if g1 and g2 and g1 != g2:
                return False

        if distance_m <= 20:
            # Very close same-source: relaxed threshold.
            return name_sim >= 0.5
        elif distance_m <= 50:
            # Medium same-source: conservative.
            # Must have high name similarity to merge (e.g., exact duplicate
            # like "Bivacco Fiorio" + "Bivacco Fiorio" from same source).
            return name_sim >= 0.85
        else:
            # >50m same-source: normally never merge. At this distance,
            # same-source pairs are almost always distinct structures
            # (e.g., rifugio + locale invernale, vecchio + nuovo).
            # Exception: identical normalized names at ≤300m — OSM duplicate
            # ways/nodes for the same building (e.g., two "Rifugio Monte
            # Curcio" at 221m apart, both OSM).
            if distance_m <= 300 and n1 and n2 and n1 == n2:
                return True
            return False

    # ── Cross-source below here ──────────────────────────────

    # Moderate altitude difference + low name sim = distinct
    if alt_diff is not None and alt_diff > 50 and name_sim < 0.5:
        return False

    # Rule: Very close (≤5m) — almost certainly same place
    if distance_m <= 5:
        return True

    # Rule: Close range (5-30m) — merge unless evidence of distinct
    if distance_m <= 30:
        return True

    # Rule: Medium range (30-100m) — need name evidence
    if distance_m <= 100:
        # Water point vs shelter → don't merge
        if is_water_point_pair:
            return False
        # "Vecchio/Nuovo" distinction → distinct buildings
        if has_old_new_distinction and alt_diff is not None and alt_diff > 20:
            return False
        # Merge if:
        # - name_sim ≥ 0.65 (shared toponym gives at least 0.65)
        # - OR name containment with shared toponym
        if name_sim >= 0.65:
            return True
        if contains and shared_toponyms:
            return True
        return False

    # ── Protection: bergerie/caserma/pastorale are distinct structure types ──
    # "Bergerie" (sheep pen), "Caserma forestale" (forestry barrack),
    # "Cabane pastorale" / "Alpeggio" (pastoral hut) are NOT the same as
    # nearby managed rifugi and should never be merged with them.
    _distinct_structure_keywords = (
        "bergerie",
        "caserma forestale",
        "caserma",
        "pastorale",
        "alpeggio",
    )

    def _is_distinct_structure(nm):
        # type: (str) -> bool
        nm_l = nm.lower().strip()
        return any(kw in nm_l for kw in _distinct_structure_keywords)

    n1_distinct = _is_distinct_structure(name1)
    n2_distinct = _is_distinct_structure(name2)
    if n1_distinct != n2_distinct:
        # One is a distinct structure type and the other is not
        return False

    # Rule: Long range (100-200m) — need strong name evidence
    # At this distance, only merge when names clearly indicate same shelter
    # (e.g., "Rifugio Falck" vs "Rifugio Enrico Falck" at 122m)
    if distance_m <= 200:
        if is_water_point_pair:
            return False
        if has_old_new_distinction:
            return False
        if name_sim >= 0.85:
            return True
        if contains and shared_toponyms:
            return True
        # Shared toponym alone with decent similarity
        if shared_toponyms and name_sim >= 0.65:
            return True
        return False

    # Rule: Extended range (200-500m) — cross-source only, very strict
    # At this distance, GPS inaccuracy across sources (OSM, Wikidata,
    # refuges.info, capanneti.ch) can cause identical shelters to appear
    # far apart. Only merge when names are identical or near-identical.
    if distance_m <= 500:
        if is_water_point_pair:
            return False
        if has_old_new_distinction:
            return False
        # Identical normalized name → always merge
        if n1 and n2 and n1 == n2:
            return True
        # Very high name similarity (≥0.90) → merge
        if name_sim >= 0.90:
            return True
        # Name containment with shared toponym → merge
        # (e.g., "Capanna Dötra" vs "Dötra", "Alp di Fora" vs "Fora (Alp di)")
        if contains and shared_toponyms:
            return True
        # High name similarity (≥0.85) with shared toponym → merge
        if name_sim >= 0.85 and shared_toponyms:
            return True
        return False

    # Beyond 500m → never merge
    return False


# ──────────────────────────────────────────────────────────────
# Clustering: find groups of records within threshold distance
# ──────────────────────────────────────────────────────────────


def find_clusters(records, threshold_m):
    # type: (List[Dict[str, Any]], float) -> List[List[int]]
    """
    Find clusters of records within threshold_m of each other.
    Uses a grid spatial index + union-find for connected components.
    Only unions pairs that pass should_merge() validation.
    Returns list of clusters (each cluster = list of indices with len >= 2).
    """
    n = len(records)

    # Spatial grid index
    cell_size = max(threshold_m / 111000.0 * 2, 0.001)  # ~2x threshold in degrees
    grid = defaultdict(list)  # type: Dict[Tuple[int, int], List[int]]
    for i, r in enumerate(records):
        lat, lon = get_coords(r)
        gx = int(lat / cell_size)
        gy = int(lon / cell_size)
        grid[(gx, gy)].append(i)

    # Union-Find
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        # type: (int) -> int
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        # type: (int, int) -> None
        px, py = find(x), find(y)
        if px == py:
            return
        if rank[px] < rank[py]:
            px, py = py, px
        parent[py] = px
        if rank[px] == rank[py]:
            rank[px] += 1

    # Find pairs within threshold, validate, and union them
    pairs_found = 0
    pairs_skipped = 0
    for (gx, gy), indices in grid.items():
        neighbors = []
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                neighbors.extend(grid.get((gx + dx, gy + dy), []))

        for i in indices:
            lat1, lon1 = get_coords(records[i])
            for j in neighbors:
                if j <= i:
                    continue
                lat2, lon2 = get_coords(records[j])
                d = haversine(lat1, lon1, lat2, lon2)
                if d <= threshold_m:
                    if should_merge(records[i], records[j], d):
                        union(i, j)
                        pairs_found += 1
                    else:
                        pairs_skipped += 1

    print(
        f"  Pairs merged: {pairs_found}, pairs skipped (distinct structures): {pairs_skipped}"
    )

    # Build clusters from union-find
    clusters_map = defaultdict(list)  # type: Dict[int, List[int]]
    for i in range(n):
        root = find(i)
        clusters_map[root].append(i)

    # Return only clusters with 2+ members
    clusters = [members for members in clusters_map.values() if len(members) >= 2]
    return clusters


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(
        description="Post-merge dedup for cai_app_data.json"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Analyze only, don't write output"
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=500.0,
        help="Distance threshold in meters (default: 500)",
    )
    parser.add_argument("--input", default="cai_app_data.json", help="Input JSON file")
    parser.add_argument(
        "--output", default="cai_app_data.json", help="Output JSON file"
    )
    args = parser.parse_args()

    # Resolve paths relative to project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    input_path = os.path.join(project_root, args.input)
    output_path = os.path.join(project_root, args.output)
    log_path = os.path.join(script_dir, "data", "post_merge_dedup_log.json")

    print(f"Loading {input_path}...")
    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"  Loaded {len(data)} records")

    log = {
        "timestamp": datetime.now().isoformat(),
        "input_file": args.input,
        "input_count": len(data),
        "threshold_m": args.threshold,
        "dry_run": args.dry_run,
    }

    # ── Phase 1: Filter out Wikidata non-shelter records ─────

    print("\n═══ Phase 1: Filter Wikidata non-shelters ═══")

    kept = []
    removed_junk = []
    wikidata_count = 0

    for r in data:
        if r.get("source") == "wikidata":
            wikidata_count += 1
            if is_wikidata_shelter(r):
                kept.append(r)
            else:
                removed_junk.append(r)
        else:
            kept.append(r)

    print(f"  Wikidata records: {wikidata_count}")
    print(f"  Wikidata shelters kept: {wikidata_count - len(removed_junk)}")
    print(f"  Wikidata junk removed: {len(removed_junk)}")
    print(f"  Records after filtering: {len(kept)}")

    log["phase1"] = {
        "wikidata_total": wikidata_count,
        "wikidata_shelters_kept": wikidata_count - len(removed_junk),
        "wikidata_junk_removed": len(removed_junk),
        "records_after_filter": len(kept),
        "junk_examples": [
            {
                "name": r["name"],
                "sourceId": r["sourceId"],
                "country": r.get("country", "?"),
            }
            for r in removed_junk[:20]
        ],
    }

    # ── Phase 1.5: Remove generic/useless records ────────────
    # Records with only a bare type-word name (e.g., "Rifugio", "Bivacco")
    # and no meaningful data are noise. Remove them from ALL sources.

    print("\n═══ Phase 1.5: Remove generic/useless records ═══")

    generic_removed = []
    kept_after_generic = []
    for r in kept:
        name = r.get("name", "").strip()
        if _is_generic_name(name):
            # Only remove if the record has very little data (richness ≤ 3)
            # to avoid removing a well-populated record that just has a bad name
            if record_richness(r) <= 3:
                generic_removed.append(r)
                continue
        kept_after_generic.append(r)

    print(f"  Generic junk removed: {len(generic_removed)}")
    if generic_removed:
        for r in generic_removed:
            print(
                f'    - "{r.get("name", "")}" [{r.get("source", "")}:{r.get("sourceId", "")}]'
            )
    print(f"  Records after generic filter: {len(kept_after_generic)}")

    log["phase1_5"] = {
        "generic_junk_removed": len(generic_removed),
        "records_after_filter": len(kept_after_generic),
        "removed": [
            {
                "name": r.get("name", ""),
                "source": r.get("source", ""),
                "sourceId": r.get("sourceId", ""),
            }
            for r in generic_removed
        ],
    }

    kept = kept_after_generic

    # ── Phase 2: Coordinate-based dedup ──────────────────────

    print(f"\n═══ Phase 2: Coordinate dedup (threshold ≤{args.threshold}m) ═══")

    clusters = find_clusters(kept, args.threshold)
    print(f"  Found {len(clusters)} clusters of nearby records")

    # Count records in clusters
    records_in_clusters = sum(len(c) for c in clusters)
    print(f"  Records involved: {records_in_clusters}")

    # Process each cluster: split into sub-groups, then pick winner per sub-group.
    #
    # Why sub-groups?  Union-find is transitive: if A↔C and B↔C both pass
    # should_merge(), A and B end up in the same cluster even when A↔B does
    # NOT pass (e.g. "Rifugio Omio" (CAI) and "Bivacco Saglio" (CAI) are
    # bridged by "Rifugio Antonio Omio" (OSM)).  Splitting prevents losing
    # records that should survive as distinct structures.
    indices_to_remove = set()  # type: Set[int]
    merge_actions = []

    for cluster_indices in clusters:
        # Sort by priority: highest trust first, then richness
        cluster_records = [(i, kept[i]) for i in cluster_indices]
        cluster_records.sort(key=lambda x: record_priority(x[1]), reverse=True)

        # Split into sub-groups: greedy assignment.
        # Each sub-group has an anchor (highest priority record).
        # A record joins a sub-group if should_merge() approves it with
        # the anchor AND with all existing members of that sub-group.
        sub_groups = []  # type: List[List[Tuple[int, Dict[str, Any]]]]

        for idx, rec in cluster_records:
            placed = False
            for sg in sub_groups:
                anchor_idx, anchor = sg[0]
                lat_a, lon_a = get_coords(anchor)
                lat_r, lon_r = get_coords(rec)
                d = haversine(lat_a, lon_a, lat_r, lon_r)
                if d <= args.threshold and should_merge(anchor, rec, d):
                    sg.append((idx, rec))
                    placed = True
                    break
            if not placed:
                sub_groups.append([(idx, rec)])

        # Process each sub-group independently
        for sg in sub_groups:
            if len(sg) < 2:
                continue  # single record, nothing to merge

            winner_idx, winner = sg[0]
            losers = [rec for _, rec in sg[1:]]
            loser_indices = [idx for idx, _ in sg[1:]]

            # Merge data from losers into winner
            merged = merge_records(winner, losers)
            kept[winner_idx] = merged

            # Mark losers for removal
            for idx in loser_indices:
                indices_to_remove.add(idx)

            # Log the merge
            action = {
                "winner": {
                    "name": winner.get("name", ""),
                    "source": winner.get("source", ""),
                    "sourceId": winner.get("sourceId", ""),
                    "trust": SOURCE_TRUST.get(winner.get("source", ""), 0),
                    "richness": record_richness(winner),
                },
                "losers": [
                    {
                        "name": r.get("name", ""),
                        "source": r.get("source", ""),
                        "sourceId": r.get("sourceId", ""),
                        "trust": SOURCE_TRUST.get(r.get("source", ""), 0),
                        "richness": record_richness(r),
                    }
                    for r in losers
                ],
                "cluster_size": len(cluster_indices),
                "sub_groups_in_cluster": len(sub_groups),
            }

            # Calculate distances within sub-group for logging
            lat_w, lon_w = get_coords(winner)
            for li, r in enumerate(losers):
                lat_l, lon_l = get_coords(r)
                d = haversine(lat_w, lon_w, lat_l, lon_l)
                action["losers"][li]["distance_m"] = round(d, 1)

            merge_actions.append(action)

    # Remove losers
    result = [r for i, r in enumerate(kept) if i not in indices_to_remove]

    duplicates_removed = len(indices_to_remove)
    print(f"  Duplicates removed: {duplicates_removed}")
    print(f"  Records after dedup: {len(result)}")

    # Source distribution
    from collections import Counter

    source_dist = Counter(r.get("source", "?") for r in result)
    print(f"\n  Source distribution after dedup:")
    for src, count in source_dist.most_common():
        print(f"    {src}: {count}")

    log["phase2"] = {
        "clusters_found": len(clusters),
        "records_in_clusters": records_in_clusters,
        "duplicates_removed": duplicates_removed,
        "records_after_dedup": len(result),
        "source_distribution": dict(source_dist),
        "merge_actions_count": len(merge_actions),
        "merge_actions_extended": [
            a
            for a in merge_actions
            if any(l.get("distance_m", 0) > 100 for l in a.get("losers", []))
        ],
        "merge_actions_sample": merge_actions[:50],
    }

    # ── Summary ──────────────────────────────────────────────

    total_removed = len(removed_junk) + len(generic_removed) + duplicates_removed
    print(f"\n═══ Summary ═══")
    print(f"  Input:             {len(data)} records")
    print(f"  Wikidata junk:    -{len(removed_junk)}")
    print(f"  Generic junk:     -{len(generic_removed)}")
    print(f"  Coord duplicates: -{duplicates_removed}")
    print(f"  Total removed:    -{total_removed}")
    print(f"  Output:            {len(result)} records")

    log["summary"] = {
        "input_count": len(data),
        "wikidata_junk_removed": len(removed_junk),
        "generic_junk_removed": len(generic_removed),
        "coord_duplicates_removed": duplicates_removed,
        "total_removed": total_removed,
        "output_count": len(result),
    }

    # ── Write output ─────────────────────────────────────────

    if args.dry_run:
        print("\n[DRY RUN] No files written.")
    else:
        # Save deduped data
        print(f"\nWriting {len(result)} records to {output_path}...")
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print("  Done.")

    # Always write log
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(log, f, ensure_ascii=False, indent=2)
    print(f"Log written to {log_path}")


if __name__ == "__main__":
    main()
