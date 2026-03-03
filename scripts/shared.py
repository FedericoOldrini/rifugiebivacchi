#!/usr/bin/env python3
"""
Utilità condivise per la pipeline di importazione dati multi-source.

Contiene:
- Formato unificato dei rifugi (conforme al modello Rifugio in rifugio.dart)
- Funzioni di deduplicazione (coordinate + fuzzy name matching)
- Trust hierarchy per la risoluzione dei conflitti
- Logging e statistiche
"""

import json
import math
import re
import sys
import unicodedata
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

# ── Costanti ────────────────────────────────────────────────────────

# Soglie di deduplicazione (dal ROADMAP)
DEDUP_DISTANCE_THRESHOLD_M = 200  # distanza massima in metri
DEDUP_NAME_SIMILARITY_THRESHOLD = 0.8  # Levenshtein similarity minima

# Trust hierarchy: punteggio più alto = fonte più affidabile
# "gestore verificato > CAI > dati regionali > OSM > Wikidata" (ROADMAP)
SOURCE_TRUST = {
    "verified_manager": 100,
    "rifugi.cai": 80,
    "opendata_regional": 60,
    "capanneti.ch": 55,  # Portale ufficiale CAS Ticino, dati curati
    "openstreetmap": 40,
    "refuges.info": 35,
    "wikidata": 20,
}

# Bounding box Italia (con margine per zone di confine)
ITALY_BBOX = {
    "min_lat": 35.5,
    "max_lat": 47.5,
    "min_lng": 6.5,
    "max_lng": 18.6,
}

# Mapping tipo struttura → tipo normalizzato (it)
TYPE_MAPPING = {
    # CAI types
    "rifugio custodito": "rifugio",
    "rifugio incustodito": "rifugio",
    "bivacco": "bivacco",
    "capanna sociale": "rifugio",
    "punto d'appoggio": "rifugio",
    # OSM types
    "alpine_hut": "rifugio",
    "wilderness_hut": "bivacco",
    # Refuges.info types
    "refuge gardé": "rifugio",
    "refuge non gardé": "rifugio",
    "cabane non gardée": "bivacco",
    "gîte d'étape": "rifugio",
    "abri": "bivacco",
    # Capanneti.ch types (status field)
    "custodita": "rifugio",
    "non custodita": "bivacco",
    "capanna": "rifugio",
    # Generic
    "rifugio": "rifugio",
    "malga": "malga",
    "hütte": "rifugio",
    "biwak": "bivacco",
}

# Directory per i dati intermedi
DATA_DIR = Path(__file__).parent / "data"


# ── Modello dati unificato ──────────────────────────────────────────


def _overlay_if_enriched(target: dict, key: str, value) -> None:
    """
    Helper: sovrascrive target[key] con value solo se:
    - value non e' None
    - target[key] e' assente o vuoto/None
    Usato per applicare enrichment senza sovrascrivere dati CAI originali.
    """
    if value is None:
        return
    existing = target.get(key)
    if existing is None or existing == "" or existing == 0:
        target[key] = value


@dataclass
class UnifiedShelter:
    """
    Formato unificato per un rifugio/bivacco, conforme al modello
    Rifugio in rifugio.dart. Usato come formato intermedio nella pipeline.
    """

    # Identificativi
    source: str  # es. "openstreetmap", "wikidata", "refuges.info"
    source_id: str  # ID nativo nella fonte (es. "node/12345" per OSM)

    # Dati essenziali (obbligatori)
    name: str
    lat: float
    lng: float
    shelter_type: str  # "rifugio", "bivacco", "malga"
    country: str = "IT"  # ISO 3166-1 alpha-2

    # Dati geografici (opzionali)
    altitude: Optional[float] = None
    region: Optional[str] = None
    province: Optional[str] = None
    municipality: Optional[str] = None
    valley: Optional[str] = None
    locality: Optional[str] = None

    # Descrizione
    description: Optional[str] = None
    site_description: Optional[str] = None

    # Servizi
    capacity: Optional[int] = None  # posti letto
    wifi: Optional[bool] = None
    electricity: Optional[bool] = None
    restaurant: Optional[bool] = None
    pos_payment: Optional[bool] = None
    hot_water: Optional[bool] = None
    showers: Optional[bool] = None

    # Contatti
    phone: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None

    # Proprietà
    operator: Optional[str] = None
    owner: Optional[str] = None
    status: Optional[str] = None

    # Media
    image_urls: list = field(default_factory=list)

    # Metadati pipeline
    import_date: Optional[str] = None

    # JSON originale completo (solo per record CAI, NON serializzato nei dati intermedi).
    # Permette a to_cai_format() di preservare tutti i campi CAI-specifici
    # (accessibilita, buildYear, regionalType, services extra, property extra, etc.)
    # che non sono tracciati nel dataclass UnifiedShelter.
    _original_json: Optional[dict] = field(default=None, repr=False)

    def __post_init__(self):
        if self.import_date is None:
            self.import_date = datetime.now(timezone.utc).isoformat()

    def to_cai_format(self) -> dict:
        """
        Converte nel formato JSON compatibile con cai_app_data.json
        (lo stesso formato atteso da Rifugio.fromJson in rifugio.dart).

        Per record CAI: parte dal JSON originale e ci sovrappone solo i
        campi che la pipeline potrebbe aver arricchito (es. immagini da
        Wikidata, contatti da enrichment). Questo preserva tutti i campi
        CAI-specifici: accessibilita, buildYear, regionalType, services
        extra (postiTotali, defibrillatore, sharedWC...), property extra
        (taxCode, pec, reference...), contacts.secondaryPhone, etc.

        Per record non-CAI: costruisce il JSON dai campi del dataclass
        (queste fonti non hanno i campi extra).
        """
        if self._original_json is not None:
            return self._to_cai_format_from_original()
        return self._to_cai_format_new()

    def _to_cai_format_from_original(self) -> dict:
        """
        Per record CAI: parte dal JSON originale e applica gli enrichment
        della pipeline (immagini aggiuntive, campi riempiti da altre fonti).
        """
        import copy

        assert self._original_json is not None
        result = copy.deepcopy(self._original_json)

        # Sovrapponi campi che la pipeline potrebbe aver arricchito
        # (solo se il valore nel dataclass e' diverso da None e dal valore originale)

        # Country (potrebbe non essere presente nel JSON originale)
        result["country"] = self.country

        # Geo: aggiorna solo campi che la pipeline traccia e che erano vuoti
        geo = result.setdefault("geo", {})
        _overlay_if_enriched(geo, "region", self.region)
        _overlay_if_enriched(geo, "province", self.province)
        _overlay_if_enriched(geo, "municipality", self.municipality)
        _overlay_if_enriched(geo, "valley", self.valley)
        _overlay_if_enriched(geo, "locality", self.locality)
        _overlay_if_enriched(geo, "description", self.description)
        _overlay_if_enriched(geo, "site", self.site_description)
        if self.altitude is not None and not geo.get("altitude"):
            geo["altitude"] = str(int(self.altitude))

        # Services: aggiorna solo i campi tracciati dalla pipeline
        services = result.setdefault("services", {})
        _overlay_if_enriched(services, "postiLetto", self.capacity)
        _overlay_if_enriched(services, "wifi", self.wifi)
        _overlay_if_enriched(services, "elettricita", self.electricity)
        _overlay_if_enriched(services, "ristorante", self.restaurant)
        _overlay_if_enriched(services, "pagamentoPos", self.pos_payment)
        _overlay_if_enriched(services, "hotWater", self.hot_water)
        _overlay_if_enriched(services, "showers", self.showers)

        # Contacts: aggiorna solo i campi tracciati dalla pipeline
        contacts = result.setdefault("contacts", {})
        _overlay_if_enriched(contacts, "mainPhone", self.phone)
        _overlay_if_enriched(contacts, "email", self.email)
        _overlay_if_enriched(contacts, "website", self.website)

        # Property: aggiorna solo name (operator)
        prop = result.setdefault("property", {})
        if self.operator and not prop.get("name"):
            prop["name"] = self.operator

        # Owner e status
        _overlay_if_enriched(result, "owner", self.owner)
        _overlay_if_enriched(result, "status", self.status)

        # Media: unisci immagini (quelle originali + quelle aggiunte dalla pipeline)
        original_urls = set()
        for media in result.get("mediaList", []):
            if isinstance(media, dict) and media.get("url"):
                original_urls.add(media["url"])

        if self.image_urls:
            media_list = result.get("mediaList", [])
            for url in self.image_urls:
                if url not in original_urls:
                    media_list.append({"url": url})
                    original_urls.add(url)
            if media_list:
                result["mediaList"] = media_list

        return result

    def _to_cai_format_new(self) -> dict:
        """
        Per record non-CAI: costruisce il JSON dai campi del dataclass.
        """
        result = {
            "source": self.source,
            "sourceId": self.source_id,
            "name": self.name,
            "country": self.country,
            "geo": {
                "lat": self.lat,
                "lng": self.lng,
                "altitude": str(int(self.altitude)) if self.altitude else None,
                "locality": self.locality,
                "region": self.region,
                "province": self.province,
                "municipality": self.municipality,
                "valley": self.valley,
                "description": self.description,
                "site": self.site_description,
            },
            "services": {
                "postiLetto": self.capacity,
                "wifi": self.wifi,
                "elettricita": self.electricity,
                "ristorante": self.restaurant,
                "pagamentoPos": self.pos_payment,
                "hotWater": self.hot_water,
                "showers": self.showers,
            },
            "contacts": {
                "mainPhone": self.phone,
                "email": self.email,
                "website": self.website,
            },
            "property": {
                "name": self.operator or self.owner,
            },
            "type": self._type_to_cai_type(),
            "owner": self.owner,
            "status": self.status,
        }

        # Media
        if self.image_urls:
            result["mediaList"] = [{"url": url} for url in self.image_urls]

        # Rimuovi i campi None dai dizionari annidati per pulizia
        for key in ["geo", "services", "contacts", "property"]:
            if key in result and isinstance(result[key], dict):
                result[key] = {k: v for k, v in result[key].items() if v is not None}

        return result

    def _type_to_cai_type(self) -> str:
        """Converte il tipo normalizzato nel formato CAI."""
        mapping = {
            "rifugio": "Rifugio custodito",
            "bivacco": "Bivacco",
            "malga": "Rifugio custodito",  # approssimazione
        }
        return mapping.get(self.shelter_type, "Rifugio custodito")


# ── Deduplicazione ──────────────────────────────────────────────────


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Calcola la distanza in metri tra due punti sulla Terra
    usando la formula di Haversine.
    """
    R = 6371000  # raggio terrestre in metri

    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_phi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    return R * c


def normalize_name(name: str) -> str:
    """
    Normalizza un nome per il confronto fuzzy:
    - lowercase
    - rimuove accenti
    - rimuove prefissi comuni (rifugio, bivacco, malga, refuge, cabane, hütte...)
    - rimuove punteggiatura
    """
    if not name:
        return ""

    # Lowercase
    s = name.lower().strip()

    # Rimuove accenti (NFD decomposition + strip combining chars)
    s = unicodedata.normalize("NFD", s)
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")

    # Rimuove prefissi comuni
    prefixes = [
        r"^rifugio\s+",
        r"^rif\.\s*",
        r"^bivacco\s+",
        r"^biv\.\s*",
        r"^malga\s+",
        r"^alpe\s+",
        r"^baita\s+",
        r"^capanna\s+",
        r"^refuge\s+",
        r"^cabane\s+",
        r"^hutte\s+",
        r"^biwak\s+",
    ]
    for prefix in prefixes:
        s = re.sub(prefix, "", s)

    # Rimuove punteggiatura e spazi extra
    s = re.sub(r"[^\w\s]", "", s)
    s = re.sub(r"\s+", " ", s).strip()

    return s


def levenshtein_similarity(s1: str, s2: str) -> float:
    """
    Calcola la similarità di Levenshtein normalizzata tra 0 e 1.
    1.0 = identici, 0.0 = completamente diversi.
    """
    if not s1 and not s2:
        return 1.0
    if not s1 or not s2:
        return 0.0

    len1, len2 = len(s1), len(s2)
    max_len = max(len1, len2)

    # Matrice distanza di Levenshtein
    matrix = [[0] * (len2 + 1) for _ in range(len1 + 1)]

    for i in range(len1 + 1):
        matrix[i][0] = i
    for j in range(len2 + 1):
        matrix[0][j] = j

    for i in range(1, len1 + 1):
        for j in range(1, len2 + 1):
            cost = 0 if s1[i - 1] == s2[j - 1] else 1
            matrix[i][j] = min(
                matrix[i - 1][j] + 1,  # eliminazione
                matrix[i][j - 1] + 1,  # inserimento
                matrix[i - 1][j - 1] + cost,  # sostituzione
            )

    distance = matrix[len1][len2]
    return 1.0 - (distance / max_len)


def is_duplicate(
    shelter_a: UnifiedShelter,
    shelter_b: UnifiedShelter,
    distance_threshold: float = DEDUP_DISTANCE_THRESHOLD_M,
    name_threshold: float = DEDUP_NAME_SIMILARITY_THRESHOLD,
) -> bool:
    """
    Determina se due rifugi sono lo stesso luogo fisico.
    Criteri (entrambi devono essere soddisfatti):
    1. Distanza tra coordinate ≤ distance_threshold (default 200m)
    2. Similarità del nome ≥ name_threshold (default 0.8)
    """
    # Controllo distanza
    dist = haversine_distance(
        shelter_a.lat, shelter_a.lng, shelter_b.lat, shelter_b.lng
    )
    if dist > distance_threshold:
        return False

    # Controllo nome
    name_a = normalize_name(shelter_a.name)
    name_b = normalize_name(shelter_b.name)
    similarity = levenshtein_similarity(name_a, name_b)

    return similarity >= name_threshold


def get_trust_score(source: str) -> int:
    """Restituisce il punteggio di trust per una fonte dati."""
    return SOURCE_TRUST.get(source, 0)


# ── Normalizzazione tipo ────────────────────────────────────────────


def normalize_type(raw_type: str, name: str = "") -> str:
    """
    Normalizza il tipo di struttura in uno dei tre valori:
    'rifugio', 'bivacco', 'malga'.
    Usa sia il tipo esplicito che il nome come fallback.
    """
    raw_lower = raw_type.lower().strip() if raw_type else ""

    # Prima prova il mapping diretto
    if raw_lower in TYPE_MAPPING:
        return TYPE_MAPPING[raw_lower]

    # Poi prova un match parziale sul tipo
    for key, value in TYPE_MAPPING.items():
        if key in raw_lower:
            return value

    # Fallback: analizza il nome
    name_lower = name.lower() if name else ""
    if "bivacco" in name_lower or "biv." in name_lower:
        return "bivacco"
    if "malga" in name_lower or "alpe " in name_lower or "baita" in name_lower:
        return "malga"

    # Default
    return "rifugio"


# ── I/O ─────────────────────────────────────────────────────────────


def save_intermediate(shelters: list, filename: str) -> Path:
    """
    Salva i dati intermedi come JSON nella directory scripts/data/.
    Restituisce il path del file salvato.
    Esclude _original_json dalla serializzazione (troppo grande e non necessario).
    """
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    filepath = DATA_DIR / filename

    data = []
    for s in shelters:
        d = asdict(s)
        # Rimuovi _original_json: non serve nei file intermedi
        # e sarebbe enorme (intero JSON originale per ogni record CAI)
        d.pop("_original_json", None)
        data.append(d)

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return filepath


def load_intermediate(filename: str) -> list:
    """Carica dati intermedi dal formato JSON."""
    filepath = DATA_DIR / filename

    if not filepath.exists():
        print(f"  WARN: File non trovato: {filepath}")
        return []

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    shelters = []
    for d in data:
        try:
            # Rimuovi _original_json se presente (non dovrebbe, ma per sicurezza)
            d.pop("_original_json", None)
            shelters.append(UnifiedShelter(**d))
        except TypeError as e:
            print(f"  WARN: Errore nel parsing di {d.get('name', '?')}: {e}")

    return shelters


def load_cai_data(filepath: str = "cai_app_data.json") -> list:
    """
    Carica i dati CAI esistenti e li converte in UnifiedShelter
    per poterli confrontare con le nuove fonti.

    Salva il JSON originale completo in _original_json cosi' che
    to_cai_format() possa preservare tutti i campi CAI-specifici
    (accessibilita, buildYear, regionalType, services extra, etc.)
    """
    cai_path = Path(__file__).parent.parent / filepath

    if not cai_path.exists():
        print(f"  ERRORE: {cai_path} non trovato")
        sys.exit(1)

    with open(cai_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    shelters = []
    for item in data:
        geo = item.get("geo", {})
        services = item.get("services", {})
        contacts = item.get("contacts", {})
        prop = item.get("property", {})

        lat = geo.get("lat", 0)
        lng = geo.get("lng", 0)

        # Salta coordinate chiaramente invalide
        if lat == 0 and lng == 0:
            continue

        try:
            altitude = float(geo["altitude"]) if geo.get("altitude") else None
        except (ValueError, TypeError):
            altitude = None

        shelter_type = normalize_type(item.get("type", ""), item.get("name", ""))

        shelters.append(
            UnifiedShelter(
                source="rifugi.cai",
                source_id=item.get("sourceId", ""),
                name=item.get("name", ""),
                lat=lat,
                lng=lng,
                altitude=altitude,
                shelter_type=shelter_type,
                country=item.get("country", "IT"),
                region=geo.get("region"),
                province=geo.get("province"),
                municipality=geo.get("municipality"),
                valley=geo.get("valley"),
                locality=geo.get("locality"),
                description=geo.get("description"),
                site_description=geo.get("site"),
                capacity=services.get("postiLetto"),
                wifi=services.get("wifi"),
                electricity=services.get("elettricita"),
                restaurant=services.get("ristorante"),
                pos_payment=services.get("pagamentoPos"),
                hot_water=services.get("hotWater"),
                showers=services.get("showers"),
                phone=contacts.get("mainPhone"),
                email=contacts.get("email"),
                website=contacts.get("website"),
                operator=prop.get("name"),
                owner=item.get("owner"),
                status=item.get("status"),
                _original_json=item,  # Preserva JSON originale completo
            )
        )

    return shelters


# ── Logging ─────────────────────────────────────────────────────────


def print_stats(source_name: str, shelters: list):
    """Stampa statistiche per una fonte importata."""
    if not shelters:
        print(f"\n  {source_name}: 0 strutture importate")
        return

    types = {}
    with_altitude = 0
    with_capacity = 0
    with_images = 0

    for s in shelters:
        types[s.shelter_type] = types.get(s.shelter_type, 0) + 1
        if s.altitude:
            with_altitude += 1
        if s.capacity:
            with_capacity += 1
        if s.image_urls:
            with_images += 1

    print(f"\n  {source_name}: {len(shelters)} strutture importate")
    for t, count in sorted(types.items()):
        print(f"    {t}: {count}")
    print(f"    con altitudine: {with_altitude}/{len(shelters)}")
    print(f"    con posti letto: {with_capacity}/{len(shelters)}")
    print(f"    con immagini: {with_images}/{len(shelters)}")
