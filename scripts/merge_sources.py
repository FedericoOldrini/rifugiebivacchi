#!/usr/bin/env python3
"""
Merge multi-source: orchestratore deduplicazione e produzione dataset unificato.

Flusso:
1. Carica dati CAI esistenti (base di fiducia)
2. Carica dati intermedi da OSM, Wikidata, Refuges.info
3. Per ogni fonte: deduplica contro il dataset unificato
   - Se duplicato: arricchisce il record esistente (immagini, dati mancanti)
   - Se nuovo: aggiunge al dataset
4. Risolve conflitti usando la trust hierarchy
5. Produce cai_app_data_enriched.json

Trust hierarchy: CAI > OSM > Refuges.info > Wikidata
(i gestori verificati sono nel dataset CAI stesso)

Output: cai_app_data_enriched.json (root del progetto)

Regole di qualita' (ROADMAP):
- Ogni struttura: nome + coordinate valide + altitudine + tipo
- Nessun duplicato ammesso
- Log con statistiche complete
"""

import json
import sys
import time
from dataclasses import asdict
from pathlib import Path
from typing import Optional

sys.path.insert(0, str(Path(__file__).parent))

from shared import (
    UnifiedShelter,
    is_duplicate,
    get_trust_score,
    haversine_distance,
    normalize_name,
    levenshtein_similarity,
    load_cai_data,
    load_intermediate,
    save_intermediate,
    print_stats,
    DEDUP_DISTANCE_THRESHOLD_M,
    DEDUP_NAME_SIMILARITY_THRESHOLD,
)

# ── Configurazione ──────────────────────────────────────────────────

# File intermedi da caricare (ordine = ordine di merge)
# L'ordine conta: fonti con trust piu' alto prima, cosi' i loro dati
# diventano il record primario e le fonti successive arricchiscono.
INTERMEDIATE_FILES = [
    ("openstreetmap", "osm_shelters.json"),
    ("refuges.info", "refuges_info_shelters.json"),
    ("wikidata", "wikidata_shelters.json"),
    ("capanneti.ch", "capanneti_shelters.json"),
]

# File di enrichment name-based (senza coordinate GPS)
# Questi vengono usati per arricchire i record esistenti
# cercando match per nome + altitudine invece che per coordinate.
ENRICHMENT_FILES = [
    ("opendata_regional", "opendata_enrichment.json"),
]

# Output
OUTPUT_FILE = "cai_app_data_enriched.json"
MERGE_LOG_FILE = "merge_log.json"

# Paesi da includere nel merge (IT + CH per capanneti.ch)
ALLOWED_COUNTRIES = {"IT", "CH"}


# ── Merge logic ─────────────────────────────────────────────────────


class MergeStats:
    """Raccoglie statistiche del merge per il log finale."""

    def __init__(self):
        self.sources = {}
        self.total_input = 0
        self.total_output = 0
        self.duplicates_found = 0
        self.enrichments = 0
        self.new_added = 0
        self.conflicts_resolved = 0
        self.skipped_non_italy = 0
        self.skipped_quality = 0

    def add_source(self, name: str, count: int):
        self.sources[name] = {
            "input": count,
            "duplicates": 0,
            "new": 0,
            "enrichments": 0,
        }

    def to_dict(self) -> dict:
        return {
            "sources": self.sources,
            "total_input": self.total_input,
            "total_output": self.total_output,
            "duplicates_found": self.duplicates_found,
            "enrichments": self.enrichments,
            "new_added": self.new_added,
            "conflicts_resolved": self.conflicts_resolved,
            "skipped_non_italy": self.skipped_non_italy,
            "skipped_quality": self.skipped_quality,
        }


def find_duplicate(
    shelter: UnifiedShelter,
    dataset: list,
    threshold_m: float = DEDUP_DISTANCE_THRESHOLD_M,
) -> Optional[int]:
    """
    Cerca un duplicato nel dataset per lo shelter dato.
    Restituisce l'indice nel dataset o None se non trovato.

    Ottimizzazione: pre-filtra per latitudine E longitudine
    per evitare calcoli haversine inutili.
    """
    import math

    # ~200m in gradi di latitudine (approssimazione)
    lat_margin = threshold_m / 111000.0
    # ~200m in gradi di longitudine (varia con latitudine, usiamo cos(lat))
    cos_lat = math.cos(math.radians(shelter.lat)) or 0.01
    lng_margin = lat_margin / cos_lat

    for i, existing in enumerate(dataset):
        # Pre-filtro rapido su latitudine E longitudine
        if abs(shelter.lat - existing.lat) > lat_margin:
            continue
        if abs(shelter.lng - existing.lng) > lng_margin:
            continue

        if is_duplicate(shelter, existing):
            return i

    return None


def enrich_shelter(
    existing: UnifiedShelter, new: UnifiedShelter, stats: MergeStats
) -> UnifiedShelter:
    """
    Arricchisce un record esistente con dati da una fonte meno affidabile.

    Regole:
    - Campi None nel record esistente → riempiti dalla nuova fonte
    - Campi gia' presenti → mantenuti (trust hierarchy)
    - Immagini → unite (senza duplicati)
    - source rimane quella del record con trust piu' alto
    """
    existing_trust = get_trust_score(existing.source)
    new_trust = get_trust_score(new.source)

    changed = False

    # Campi opzionali: riempi se mancanti nel record esistente
    fillable_fields = [
        "altitude",
        "region",
        "province",
        "municipality",
        "valley",
        "locality",
        "description",
        "site_description",
        "capacity",
        "wifi",
        "electricity",
        "restaurant",
        "pos_payment",
        "hot_water",
        "showers",
        "phone",
        "email",
        "website",
        "operator",
        "owner",
        "status",
    ]

    for field_name in fillable_fields:
        existing_val = getattr(existing, field_name)
        new_val = getattr(new, field_name)

        if existing_val is None and new_val is not None:
            setattr(existing, field_name, new_val)
            changed = True
        elif (
            existing_val is not None
            and new_val is not None
            and existing_val != new_val
            and new_trust > existing_trust
        ):
            # Conflitto: la nuova fonte ha trust piu' alto
            setattr(existing, field_name, new_val)
            stats.conflicts_resolved += 1
            changed = True

    # Immagini: unisci senza duplicati
    if new.image_urls:
        existing_urls_set = set(existing.image_urls)
        for url in new.image_urls:
            if url not in existing_urls_set:
                existing.image_urls.append(url)
                existing_urls_set.add(url)
                changed = True

    if changed:
        stats.enrichments += 1

    return existing


def load_enrichment_data(filename: str) -> list:
    """
    Carica dati di enrichment (formato speciale con nomi IT/DE, senza coordinate).
    Restituisce una lista di dict con campi: name_it, name_de, altitude,
    municipality, owner, phone, email, website, mountain_group, region, province.
    """
    filepath = Path(__file__).parent / "data" / filename

    if not filepath.exists():
        print(f"  WARN: File enrichment non trovato: {filepath}")
        return []

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    print(f"   Caricati {len(data)} record di enrichment da {filename}")
    return data


def find_name_match(
    enrich_record: dict,
    unified: list,
    name_threshold: float = 0.75,
    altitude_tolerance_m: float = 100.0,
) -> Optional[int]:
    """
    Cerca un match nel dataset unificato per un record di enrichment
    basandosi solo sul nome (+ altitudine come conferma).

    Per ogni record, normalizza sia il nome IT che DE dall'enrichment e
    li confronta con ogni shelter nel dataset. Se la similarita' migliore
    supera la soglia, restituisce l'indice del match.

    Se entrambi hanno altitudine, la usa come conferma aggiuntiva (±100m).
    """
    name_it = enrich_record.get("name_it", "") or ""
    name_de = enrich_record.get("name_de", "") or ""
    enrich_altitude = enrich_record.get("altitude")

    # Normalizza nomi enrichment (possono avere sia IT che DE)
    norm_names = []
    if name_it:
        norm_names.append(normalize_name(name_it))
    if name_de:
        norm_names.append(normalize_name(name_de))

    if not norm_names:
        return None

    best_idx = None
    best_score = 0.0

    for i, shelter in enumerate(unified):
        norm_shelter = normalize_name(shelter.name)
        if not norm_shelter:
            continue

        # Confronta con tutti i nomi dell'enrichment (IT e DE)
        max_sim = 0.0
        for norm_enrich in norm_names:
            sim = levenshtein_similarity(norm_enrich, norm_shelter)
            if sim > max_sim:
                max_sim = sim

        if max_sim < name_threshold:
            continue

        # Bonus/conferma altitudine se disponibile in entrambi
        if (
            enrich_altitude is not None
            and shelter.altitude is not None
            and abs(enrich_altitude - shelter.altitude) <= altitude_tolerance_m
        ):
            # Altitudine conferma: boost del punteggio
            max_sim += 0.05

        if max_sim > best_score:
            best_score = max_sim
            best_idx = i

    return best_idx


def apply_enrichment(
    shelter: UnifiedShelter, enrich_record: dict, stats: MergeStats
) -> bool:
    """
    Applica i dati di enrichment (telefono, email, website, proprietario)
    a uno shelter esistente, solo se il campo e' attualmente None.

    Restituisce True se almeno un campo e' stato arricchito.
    """
    changed = False

    # Campi di contatto
    if shelter.phone is None and enrich_record.get("phone"):
        shelter.phone = enrich_record["phone"]
        changed = True

    if shelter.email is None and enrich_record.get("email"):
        shelter.email = enrich_record["email"]
        changed = True

    if shelter.website is None and enrich_record.get("website"):
        shelter.website = enrich_record["website"]
        changed = True

    # Proprietario
    if shelter.owner is None and enrich_record.get("owner"):
        shelter.owner = enrich_record["owner"]
        changed = True

    # Comune (se mancante)
    if shelter.municipality is None and enrich_record.get("municipality"):
        shelter.municipality = enrich_record["municipality"]
        changed = True

    # Regione e provincia (se mancanti)
    if shelter.region is None and enrich_record.get("region"):
        shelter.region = enrich_record["region"]
        changed = True

    if shelter.province is None and enrich_record.get("province"):
        shelter.province = enrich_record["province"]
        changed = True

    if changed:
        stats.enrichments += 1

    return changed


def passes_quality_check(shelter: UnifiedShelter) -> bool:
    """
    Verifica i requisiti minimi di qualita' (ROADMAP):
    - Nome non vuoto
    - Coordinate valide
    - Tipo valido
    """
    if not shelter.name or not shelter.name.strip():
        return False

    if not (-90 <= shelter.lat <= 90 and -180 <= shelter.lng <= 180):
        return False

    if shelter.lat == 0 and shelter.lng == 0:
        return False

    if shelter.shelter_type not in ("rifugio", "bivacco", "malga"):
        return False

    return True


# ── Main merge ──────────────────────────────────────────────────────


def merge_all():
    print("=" * 60)
    print("MERGE MULTI-SOURCE — Dataset unificato")
    print("=" * 60)

    stats = MergeStats()

    # 1. Carica dati CAI (base)
    print("\n1. Caricamento dati CAI...")
    cai_shelters = load_cai_data()
    print(f"   CAI: {len(cai_shelters)} strutture")
    stats.add_source("rifugi.cai", len(cai_shelters))
    stats.total_input += len(cai_shelters)

    # Inizializza il dataset unificato con i dati CAI
    unified = list(cai_shelters)

    # 2. Carica e mergia ogni fonte intermedia
    for source_name, filename in INTERMEDIATE_FILES:
        print(f"\n2. Merge fonte: {source_name} ({filename})...")

        shelters = load_intermediate(filename)
        if not shelters:
            print(f"   Nessun dato trovato per {source_name}")
            continue

        stats.add_source(source_name, len(shelters))
        stats.total_input += len(shelters)

        new_count = 0
        dup_count = 0
        skipped_country = 0
        skipped_quality_count = 0

        for shelter in shelters:
            # Filtro paese
            if shelter.country not in ALLOWED_COUNTRIES:
                skipped_country += 1
                continue

            # Controllo qualita'
            if not passes_quality_check(shelter):
                skipped_quality_count += 1
                continue

            # Cerca duplicato nel dataset unificato
            dup_idx = find_duplicate(shelter, unified)

            if dup_idx is not None:
                # Duplicato: arricchisci il record esistente
                unified[dup_idx] = enrich_shelter(unified[dup_idx], shelter, stats)
                dup_count += 1
                stats.duplicates_found += 1
                stats.sources[source_name]["duplicates"] += 1
            else:
                # Nuovo: aggiungi al dataset
                unified.append(shelter)
                new_count += 1
                stats.new_added += 1
                stats.sources[source_name]["new"] += 1

        stats.skipped_non_italy += skipped_country
        stats.skipped_quality += skipped_quality_count
        stats.sources[source_name]["enrichments"] = stats.enrichments

        print(f"   Duplicati trovati: {dup_count}")
        print(f"   Nuove strutture: {new_count}")
        if skipped_country > 0:
            print(
                f"   Scartati (fuori {'/'.join(ALLOWED_COUNTRIES)}): {skipped_country}"
            )
        if skipped_quality_count > 0:
            print(f"   Scartati (qualita'): {skipped_quality_count}")

    # 3. Enrichment name-based (fonti senza coordinate GPS)
    for source_name, filename in ENRICHMENT_FILES:
        print(f"\n3. Enrichment name-based: {source_name} ({filename})...")

        enrichment_data = load_enrichment_data(filename)
        if not enrichment_data:
            print(f"   Nessun dato di enrichment trovato per {source_name}")
            continue

        stats.add_source(source_name, len(enrichment_data))
        stats.total_input += len(enrichment_data)

        matched = 0
        enriched = 0

        for enrich_record in enrichment_data:
            match_idx = find_name_match(enrich_record, unified)
            if match_idx is not None:
                matched += 1
                if apply_enrichment(unified[match_idx], enrich_record, stats):
                    enriched += 1

        stats.sources[source_name]["duplicates"] = matched
        stats.sources[source_name]["enrichments"] = enriched

        print(f"   Record di enrichment: {len(enrichment_data)}")
        print(f"   Match trovati per nome: {matched}")
        print(f"   Record arricchiti: {enriched}")

    stats.total_output = len(unified)

    # 4. Statistiche finali
    print(f"\n{'=' * 60}")
    print("STATISTICHE MERGE")
    print(f"{'=' * 60}")
    print(f"\n  Input totale:        {stats.total_input}")
    print(f"  Output finale:       {stats.total_output}")
    print(f"  Duplicati trovati:   {stats.duplicates_found}")
    print(f"  Arricchimenti:       {stats.enrichments}")
    print(f"  Nuove strutture:     {stats.new_added}")
    print(f"  Conflitti risolti:   {stats.conflicts_resolved}")
    print(f"  Scartati (non IT):   {stats.skipped_non_italy}")
    print(f"  Scartati (qualita'): {stats.skipped_quality}")

    # Distribuzione tipo nel dataset finale
    type_counts = {}
    with_images = 0
    with_altitude = 0
    with_capacity = 0
    for s in unified:
        type_counts[s.shelter_type] = type_counts.get(s.shelter_type, 0) + 1
        if s.image_urls:
            with_images += 1
        if s.altitude:
            with_altitude += 1
        if s.capacity:
            with_capacity += 1

    print(f"\n  Per tipo:")
    for t, c in sorted(type_counts.items()):
        print(f"    {t}: {c}")
    print(f"\n  Con altitudine: {with_altitude}/{len(unified)}")
    print(f"  Con posti letto: {with_capacity}/{len(unified)}")
    print(f"  Con immagini: {with_images}/{len(unified)}")

    # Distribuzione per fonte originale
    source_counts = {}
    for s in unified:
        source_counts[s.source] = source_counts.get(s.source, 0) + 1
    print(f"\n  Per fonte (record primario):")
    for src, c in sorted(source_counts.items(), key=lambda x: -x[1]):
        print(f"    {src}: {c}")

    # 4. Converti in formato cai_app_data.json e salva
    print(f"\n{'=' * 60}")
    print(f"Salvataggio {OUTPUT_FILE}...")

    output_data = [s.to_cai_format() for s in unified]

    output_path = Path(__file__).parent.parent / OUTPUT_FILE
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)

    print(f"  Salvato: {output_path}")
    print(f"  {len(output_data)} strutture nel dataset finale")

    # 5. Salva log di merge
    log_path = Path(__file__).parent / "data" / MERGE_LOG_FILE
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(stats.to_dict(), f, ensure_ascii=False, indent=2)
    print(f"  Log: {log_path}")

    print(f"\n{'=' * 60}")
    print("MERGE COMPLETATO!")
    print(f"{'=' * 60}\n")

    return stats


if __name__ == "__main__":
    merge_all()
