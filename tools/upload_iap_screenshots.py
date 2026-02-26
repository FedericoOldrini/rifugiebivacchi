#!/usr/bin/env python3
"""
Upload screenshot di review per gli In-App Purchase su App Store Connect.

Carica gli screenshot generati da generate_iap_screenshots.py
sugli IAP già creati usando l'App Store Connect API.

L'endpoint per gli screenshot di review IAP è:
- POST /v1/inAppPurchaseAppStoreReviewScreenshots (reserve)
- PUT upload URL (upload asset)
- PATCH /v1/inAppPurchaseAppStoreReviewScreenshots/{id} (commit)

Requisiti:
- Python 3.7+
- PyJWT, cryptography, requests: pip3 install PyJWT cryptography requests

Uso:
    python3 tools/upload_iap_screenshots.py
    python3 tools/upload_iap_screenshots.py --dry-run
"""

import sys
import time
import hashlib
import argparse
from pathlib import Path
from typing import Dict, List, Optional

try:
    import jwt
    import requests
except ImportError:
    print(
        "❌ Pacchetti mancanti. Installa con: pip3 install PyJWT cryptography requests"
    )
    sys.exit(1)


# ── Configurazione ────────────────────────────────────────────────────────────

ISSUER_ID = "d2d23ddf-c15d-44d4-9a56-705cbab0f2dc"
API_KEY_ID = "M6WVD946N7"
KEY_FILE = Path.home() / "private_keys" / f"AuthKey_{API_KEY_ID}.p8"

APP_ID = "6758655300"
BASE_URL = "https://api.appstoreconnect.apple.com"

PROJECT_ROOT = Path(__file__).parent.parent
SCREENSHOT_DIR = PROJECT_ROOT / "screenshots" / "iap_review"

# Mapping: Product ID → IAP ID su App Store Connect + filename screenshot
IAP_CONFIG = {
    "rifugi_donation_coffee": {
        "iap_id": "6759737563",
        "screenshot_file": "iap_review_coffee.png",
    },
    "rifugi_donation_lunch": {
        "iap_id": "6759736096",
        "screenshot_file": "iap_review_lunch.png",
    },
    "rifugi_donation_generous": {
        "iap_id": "6759736097",
        "screenshot_file": "iap_review_generous.png",
    },
}


# ── JWT Auth ──────────────────────────────────────────────────────────────────


def generate_token() -> str:
    """Genera JWT token per App Store Connect API"""
    if not KEY_FILE.exists():
        print(f"❌ API key non trovata: {KEY_FILE}")
        sys.exit(1)

    private_key = KEY_FILE.read_text()
    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }
    headers_jwt = {"alg": "ES256", "kid": API_KEY_ID, "typ": "JWT"}
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers_jwt)


def api_headers(token: str) -> Dict[str, str]:
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }


# ── API Helpers ───────────────────────────────────────────────────────────────


def api_get(token: str, path: str) -> Optional[Dict]:
    url = f"{BASE_URL}/{path}" if not path.startswith("http") else path
    resp = requests.get(url, headers=api_headers(token))
    if resp.status_code != 200:
        print(f"   ❌ GET {path} → {resp.status_code}: {resp.text[:300]}")
        return None
    return resp.json()


def api_post(token: str, path: str, data: Dict) -> Optional[Dict]:
    url = f"{BASE_URL}/{path}"
    resp = requests.post(url, headers=api_headers(token), json=data)
    if resp.status_code not in (200, 201):
        print(f"   ❌ POST {path} → {resp.status_code}: {resp.text[:500]}")
        return None
    return resp.json()


def api_patch(token: str, path: str, data: Dict) -> Optional[Dict]:
    url = f"{BASE_URL}/{path}"
    resp = requests.patch(url, headers=api_headers(token), json=data)
    if resp.status_code != 200:
        print(f"   ❌ PATCH {path} → {resp.status_code}: {resp.text[:500]}")
        return None
    return resp.json()


def api_delete(token: str, path: str) -> bool:
    url = f"{BASE_URL}/{path}"
    resp = requests.delete(url, headers=api_headers(token))
    if resp.status_code not in (200, 204):
        print(f"   ❌ DELETE {path} → {resp.status_code}: {resp.text[:300]}")
        return False
    return True


# ── IAP Screenshot Flow ──────────────────────────────────────────────────────


def get_existing_review_screenshot(token: str, iap_id: str) -> Optional[str]:
    """Controlla se esiste già uno screenshot di review per questo IAP"""
    data = api_get(
        token,
        f"v1/inAppPurchases/{iap_id}/appStoreReviewScreenshot",
    )
    if data and "data" in data and data["data"]:
        return data["data"]["id"]
    return None


def delete_existing_screenshot(token: str, screenshot_id: str) -> bool:
    """Elimina screenshot di review esistente"""
    return api_delete(
        token, f"v1/inAppPurchaseAppStoreReviewScreenshots/{screenshot_id}"
    )


def reserve_screenshot(
    token: str, iap_id: str, filename: str, file_size: int
) -> Optional[Dict]:
    """Riserva uno slot per l'upload dello screenshot di review IAP"""
    data = api_post(
        token,
        "v1/inAppPurchaseAppStoreReviewScreenshots",
        {
            "data": {
                "type": "inAppPurchaseAppStoreReviewScreenshots",
                "attributes": {
                    "fileName": filename,
                    "fileSize": file_size,
                },
                "relationships": {
                    "inAppPurchaseV2": {
                        "data": {
                            "type": "inAppPurchases",
                            "id": iap_id,
                        }
                    }
                },
            }
        },
    )
    if data and "data" in data:
        return data["data"]
    return None


def upload_asset(upload_operations: List[Dict], file_path: Path) -> bool:
    """Esegue l'upload effettivo del file seguendo le upload operations"""
    file_data = file_path.read_bytes()

    for op in upload_operations:
        url = op["url"]
        offset = op.get("offset", 0)
        length = op["length"]
        method = op.get("method", "PUT")
        request_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}

        chunk = file_data[offset : offset + length]

        if method.upper() == "PUT":
            resp = requests.put(url, headers=request_headers, data=chunk)
        else:
            resp = requests.post(url, headers=request_headers, data=chunk)

        if resp.status_code not in (200, 201):
            print(
                f"      ❌ Upload chunk fallito: {resp.status_code} {resp.text[:200]}"
            )
            return False

    return True


def commit_screenshot(token: str, screenshot_id: str, checksum: str) -> bool:
    """Conferma l'upload dello screenshot"""
    data = api_patch(
        token,
        f"v1/inAppPurchaseAppStoreReviewScreenshots/{screenshot_id}",
        {
            "data": {
                "type": "inAppPurchaseAppStoreReviewScreenshots",
                "id": screenshot_id,
                "attributes": {
                    "sourceFileChecksum": checksum,
                    "uploaded": True,
                },
            }
        },
    )
    return data is not None


def upload_iap_screenshot(
    token: str, iap_id: str, product_id: str, file_path: Path
) -> bool:
    """Upload completo screenshot di review per un IAP: check existing → reserve → upload → commit"""
    filename = file_path.name
    file_size = file_path.stat().st_size
    md5 = hashlib.md5(file_path.read_bytes()).hexdigest()

    print(f"\n   📦 IAP: {product_id}")
    print(f"      File: {filename} ({file_size / 1024:.0f} KB)")

    # 1. Controlla se esiste già uno screenshot
    print(f"      Controllo screenshot esistente...")
    existing_id = get_existing_review_screenshot(token, iap_id)
    if existing_id:
        print(f"      🗑️  Rimozione screenshot esistente (ID: {existing_id})...")
        if not delete_existing_screenshot(token, existing_id):
            print(f"      ❌ Impossibile rimuovere screenshot esistente")
            return False
        time.sleep(1)

    # 2. Reserve
    print(f"      📝 Prenotazione slot upload...")
    reservation = reserve_screenshot(token, iap_id, filename, file_size)
    if not reservation:
        return False

    screenshot_id = reservation["id"]
    upload_ops = reservation["attributes"].get("uploadOperations", [])

    if not upload_ops:
        print(f"      ⚠️  Nessuna upload operation ricevuta, provo commit diretto...")
        return commit_screenshot(token, screenshot_id, md5)

    # 3. Upload
    print(f"      📤 Upload in corso ({len(upload_ops)} operazione/i)...")
    if not upload_asset(upload_ops, file_path):
        return False

    # 4. Commit
    print(f"      ✔️  Commit dello screenshot...")
    if not commit_screenshot(token, screenshot_id, md5):
        return False

    print(f"      ✅ Screenshot caricato con successo!")
    return True


# ── Main ──────────────────────────────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(
        description="Upload screenshot review IAP su App Store Connect"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Mostra cosa verrebbe fatto senza caricare",
    )
    args = parser.parse_args()

    print(f"\n{'=' * 60}")
    print(f"🏔️  Upload Screenshot Review IAP - App Store Connect")
    print(f"{'=' * 60}\n")

    # Verifica screenshot esistenti
    if not SCREENSHOT_DIR.exists():
        print(f"❌ Directory screenshot non trovata: {SCREENSHOT_DIR}")
        print(f"   Esegui prima: python3 tools/generate_iap_screenshots.py")
        sys.exit(1)

    # Verifica tutti i file
    all_ok = True
    for product_id, config in IAP_CONFIG.items():
        file_path = SCREENSHOT_DIR / config["screenshot_file"]
        exists = file_path.exists()
        size = f"({file_path.stat().st_size / 1024:.0f} KB)" if exists else ""
        status = "✅" if exists else "❌"
        print(
            f"   {status} {config['screenshot_file']} {size} → IAP {config['iap_id']}"
        )
        if not exists:
            all_ok = False

    if not all_ok:
        print(
            f"\n❌ Screenshot mancanti. Esegui: python3 tools/generate_iap_screenshots.py"
        )
        sys.exit(1)

    if args.dry_run:
        print(f"\n🔍 DRY RUN - nessun upload effettuato")
        return

    # Genera token
    print(f"\n🔑 Autenticazione...")
    token = generate_token()
    print(f"   ✅ Token JWT generato")

    # Upload screenshot per ogni IAP
    success_count = 0
    total = len(IAP_CONFIG)

    for product_id, config in IAP_CONFIG.items():
        file_path = SCREENSHOT_DIR / config["screenshot_file"]
        if upload_iap_screenshot(token, config["iap_id"], product_id, file_path):
            success_count += 1
        time.sleep(1)

    # Riepilogo
    print(f"\n{'=' * 60}")
    if success_count == total:
        print(
            f"✅ Tutti gli screenshot caricati con successo! ({success_count}/{total})"
        )
    else:
        print(f"⚠️  Upload parziale: {success_count}/{total} completati")
    print(f"\n📱 Verifica su App Store Connect:")
    print(f"   https://appstoreconnect.apple.com/apps/{APP_ID}/distribution/iaps")
    print(f"{'=' * 60}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Operazione interrotta")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Errore: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)
