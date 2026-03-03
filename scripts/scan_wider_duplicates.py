#!/usr/bin/env python3
"""
Scan cai_app_data.json for potential duplicates at distances 30-200m.
This is an analysis-only script to understand the scope of remaining duplicates
before modifying the dedup threshold.

Usage:
    python3 scripts/scan_wider_duplicates.py
"""

import json
import math
import os
import sys
from collections import defaultdict
from typing import Optional, List, Dict, Any, Tuple

# Import functions from post_merge_dedup
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from post_merge_dedup import (
    haversine,
    get_coords,
    normalize_name_for_compare,
    simple_name_similarity,
    _extract_toponym_words,
    SOURCE_TRUST,
)


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    input_path = os.path.join(project_root, "cai_app_data.json")

    print(f"Loading {input_path}...")
    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"  Loaded {len(data)} records\n")

    # Scan for pairs in the 30-200m range
    MIN_DIST = 30.0
    MAX_DIST = 200.0

    # Spatial grid index (cell ~250m)
    cell_size = MAX_DIST / 111000.0 * 2.5
    grid = defaultdict(list)  # type: Dict[Tuple[int, int], List[int]]
    for i, r in enumerate(data):
        lat, lon = get_coords(r)
        gx = int(lat / cell_size)
        gy = int(lon / cell_size)
        grid[(gx, gy)].append(i)

    print(f"Scanning for pairs in {MIN_DIST}-{MAX_DIST}m range...\n")

    # Categorize pairs by likelihood
    likely_duplicates = []  # High confidence: should merge
    possible_duplicates = []  # Medium: needs review
    unlikely_duplicates = []  # Low: probably distinct

    pairs_checked = 0

    for (gx, gy), indices in grid.items():
        neighbors = []
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                neighbors.extend(grid.get((gx + dx, gy + dy), []))

        for i in indices:
            r1 = data[i]
            lat1, lon1 = get_coords(r1)
            for j in neighbors:
                if j <= i:
                    continue
                r2 = data[j]
                lat2, lon2 = get_coords(r2)
                d = haversine(lat1, lon1, lat2, lon2)
                if d < MIN_DIST or d > MAX_DIST:
                    continue

                pairs_checked += 1

                name1 = r1.get("name", "")
                name2 = r2.get("name", "")
                src1 = r1.get("source", "")
                src2 = r2.get("source", "")
                name_sim = simple_name_similarity(name1, name2)

                # Get altitudes
                alt1_raw = r1.get("geo", {}).get("altitude")
                alt2_raw = r2.get("geo", {}).get("altitude")
                alt_diff = None
                if alt1_raw and alt2_raw:
                    try:
                        alt_diff = abs(float(alt1_raw) - float(alt2_raw))
                    except (ValueError, TypeError):
                        pass

                # Toponym analysis
                n1 = normalize_name_for_compare(name1)
                n2 = normalize_name_for_compare(name2)
                topo1 = _extract_toponym_words(n1)
                topo2 = _extract_toponym_words(n2)
                shared_topo = topo1 & topo2

                # Containment check
                contains = n1 in n2 or n2 in n1 if n1 and n2 else False

                pair_info = {
                    "distance_m": round(d, 1),
                    "name1": name1,
                    "name2": name2,
                    "source1": src1,
                    "source2": src2,
                    "name_sim": round(name_sim, 3),
                    "alt1": alt1_raw,
                    "alt2": alt2_raw,
                    "alt_diff": round(alt_diff, 1) if alt_diff is not None else None,
                    "shared_toponyms": sorted(shared_topo),
                    "contains": contains,
                    "norm1": n1,
                    "norm2": n2,
                    "idx1": i,
                    "idx2": j,
                    "sourceId1": r1.get("sourceId", ""),
                    "sourceId2": r2.get("sourceId", ""),
                    "cross_source": src1 != src2,
                }

                # Classify
                if src1 == src2:
                    # Same source: very unlikely to be duplicates at 30-200m
                    if name_sim >= 0.85 or contains:
                        possible_duplicates.append(pair_info)
                    elif shared_topo and name_sim >= 0.65:
                        possible_duplicates.append(pair_info)
                    # else: skip, same source at 30m+ is almost never a dup
                else:
                    # Cross-source: main target
                    if alt_diff is not None and alt_diff > 100:
                        # Big altitude difference - skip unless suspicious
                        if alt1_raw and alt2_raw:
                            try:
                                a1, a2 = float(alt1_raw), float(alt2_raw)
                                if min(a1, a2) <= 10:
                                    # One has suspicious altitude
                                    if name_sim >= 0.5:
                                        possible_duplicates.append(pair_info)
                                    continue
                            except (ValueError, TypeError):
                                pass
                        unlikely_duplicates.append(pair_info)
                        continue

                    if name_sim >= 0.85 or contains:
                        likely_duplicates.append(pair_info)
                    elif shared_topo and name_sim >= 0.5:
                        likely_duplicates.append(pair_info)
                    elif name_sim >= 0.65:
                        possible_duplicates.append(pair_info)

    # Sort by distance
    likely_duplicates.sort(key=lambda x: x["distance_m"])
    possible_duplicates.sort(key=lambda x: x["distance_m"])

    # Print results
    print(f"Total pairs checked in {MIN_DIST}-{MAX_DIST}m range: {pairs_checked}\n")

    print("=" * 80)
    print(f"LIKELY DUPLICATES ({len(likely_duplicates)} pairs)")
    print("=" * 80)
    for p in likely_duplicates:
        print(
            f"\n  {p['distance_m']}m | sim={p['name_sim']:.3f} | "
            f"alt_diff={p['alt_diff']}"
        )
        print(f"    [{p['source1']}] {p['name1']} (alt {p['alt1']})")
        print(f"    [{p['source2']}] {p['name2']} (alt {p['alt2']})")
        if p["shared_toponyms"]:
            print(f"    Shared toponyms: {p['shared_toponyms']}")
        if p["contains"]:
            print(f"    *** Name containment detected ***")

    print(f"\n{'=' * 80}")
    print(f"POSSIBLE DUPLICATES ({len(possible_duplicates)} pairs)")
    print("=" * 80)
    for p in possible_duplicates:
        print(
            f"\n  {p['distance_m']}m | sim={p['name_sim']:.3f} | "
            f"alt_diff={p['alt_diff']}"
        )
        print(f"    [{p['source1']}] {p['name1']} (alt {p['alt1']})")
        print(f"    [{p['source2']}] {p['name2']} (alt {p['alt2']})")
        if p["shared_toponyms"]:
            print(f"    Shared toponyms: {p['shared_toponyms']}")
        if p["contains"]:
            print(f"    *** Name containment detected ***")

    # Summary statistics
    print(f"\n{'=' * 80}")
    print(f"SUMMARY")
    print(f"{'=' * 80}")
    print(f"  Likely duplicates:   {len(likely_duplicates)}")
    print(f"  Possible duplicates: {len(possible_duplicates)}")
    print(f"  Total candidates:    {len(likely_duplicates) + len(possible_duplicates)}")

    # Distance distribution of likely duplicates
    if likely_duplicates:
        print(f"\n  Distance distribution (likely):")
        buckets = {"30-50m": 0, "50-75m": 0, "75-100m": 0, "100-150m": 0, "150-200m": 0}
        for p in likely_duplicates:
            d = p["distance_m"]
            if d < 50:
                buckets["30-50m"] += 1
            elif d < 75:
                buckets["50-75m"] += 1
            elif d < 100:
                buckets["75-100m"] += 1
            elif d < 150:
                buckets["100-150m"] += 1
            else:
                buckets["150-200m"] += 1
        for bucket, count in buckets.items():
            print(f"    {bucket}: {count}")

    # Source combination analysis
    if likely_duplicates:
        from collections import Counter

        src_combos = Counter()
        for p in likely_duplicates:
            combo = tuple(sorted([p["source1"], p["source2"]]))
            src_combos[combo] += 1
        print(f"\n  Source combinations (likely):")
        for combo, count in src_combos.most_common():
            print(f"    {combo[0]} + {combo[1]}: {count}")

    # Save detailed results to JSON
    out_path = os.path.join(script_dir, "data", "wider_duplicates_scan.json")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(
            {
                "scan_range_m": [MIN_DIST, MAX_DIST],
                "total_records": len(data),
                "pairs_checked": pairs_checked,
                "likely_duplicates": likely_duplicates,
                "possible_duplicates": possible_duplicates,
                "likely_count": len(likely_duplicates),
                "possible_count": len(possible_duplicates),
            },
            f,
            ensure_ascii=False,
            indent=2,
        )
    print(f"\nDetailed results saved to {out_path}")


if __name__ == "__main__":
    main()
