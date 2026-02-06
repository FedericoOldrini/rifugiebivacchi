#!/usr/bin/env python3
"""
Script per caricare i rifugi da cai_app_data.json su Firebase Firestore.

Uso:
    python upload_rifugi_to_firestore.py

Richiede:
    - firebase-admin
    - Service Account JSON scaricato dalla Firebase Console
"""

import json
import sys
from pathlib import Path

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ Errore: firebase-admin non installato")
    print("Installalo con: pip install firebase-admin")
    sys.exit(1)


def initialize_firebase():
    """Inizializza Firebase Admin SDK."""
    service_account_path = Path("serviceAccountKey.json")
    
    if not service_account_path.exists():
        print("❌ Errore: serviceAccountKey.json non trovato")
        print("\nPer ottenerlo:")
        print("1. Vai su Firebase Console > Project Settings > Service Accounts")
        print("2. Clicca 'Generate new private key'")
        print("3. Salva il file come 'serviceAccountKey.json' in questa directory")
        sys.exit(1)
    
    cred = credentials.Certificate(str(service_account_path))
    firebase_admin.initialize_app(cred)
    return firestore.client()


def load_rifugi_data():
    """Carica i dati dei rifugi dal file JSON."""
    json_path = Path("cai_app_data.json")
    
    if not json_path.exists():
        print(f"❌ Errore: {json_path} non trovato")
        sys.exit(1)
    
    with open(json_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def clean_rifugio_data(rifugio):
    """Pulisce e prepara i dati del rifugio per Firestore."""
    # Firestore non supporta valori undefined/null in alcuni campi
    # Converte anche i numeri da stringhe se necessario
    
    cleaned = rifugio.copy()
    
    # Converti altitude da stringa a numero se presente
    if 'geo' in cleaned and 'altitude' in cleaned['geo']:
        try:
            if isinstance(cleaned['geo']['altitude'], str):
                cleaned['geo']['altitude'] = int(cleaned['geo']['altitude'])
        except (ValueError, TypeError):
            cleaned['geo']['altitude'] = 0
    
    # Aggiungi timestamp di creazione
    cleaned['createdAt'] = firestore.SERVER_TIMESTAMP
    cleaned['updatedAt'] = firestore.SERVER_TIMESTAMP
    
    return cleaned


def upload_rifugi(db, rifugi_data, batch_size=500):
    """
    Carica i rifugi su Firestore.
    
    Args:
        db: Client Firestore
        rifugi_data: Lista di rifugi da caricare
        batch_size: Numero di documenti per batch (max 500 per Firestore)
    """
    collection_ref = db.collection('rifugi')
    total = len(rifugi_data)
    uploaded = 0
    errors = 0
    
    print(f"\n📤 Inizio caricamento di {total} rifugi su Firestore...")
    print(f"   Collection: rifugi")
    print(f"   Batch size: {batch_size}\n")
    
    # Processa in batch per efficienza
    for i in range(0, total, batch_size):
        batch = db.batch()
        batch_data = rifugi_data[i:i + batch_size]
        
        for rifugio in batch_data:
            try:
                # Usa sourceId come document ID per evitare duplicati
                doc_id = rifugio.get('sourceId', None)
                
                if not doc_id:
                    print(f"⚠️  Saltato rifugio senza sourceId: {rifugio.get('name', 'Unknown')}")
                    errors += 1
                    continue
                
                doc_ref = collection_ref.document(doc_id)
                cleaned_data = clean_rifugio_data(rifugio)
                batch.set(doc_ref, cleaned_data, merge=True)
                
            except Exception as e:
                print(f"❌ Errore nel preparare {rifugio.get('name', 'Unknown')}: {e}")
                errors += 1
        
        try:
            batch.commit()
            uploaded += len(batch_data) - errors
            print(f"✅ Caricati {uploaded}/{total} rifugi...")
        except Exception as e:
            print(f"❌ Errore nel commit del batch: {e}")
            errors += len(batch_data)
    
    return uploaded, errors


def create_indexes_info():
    """Stampa le informazioni sugli indici necessari."""
    print("\n📋 Indici Firestore raccomandati:")
    print("   Per ottimizzare le query, crea questi indici composite:")
    print("   1. Collection: rifugi")
    print("      Fields: geo.region (Ascending), name (Ascending)")
    print("   2. Collection: rifugi")
    print("      Fields: geo.province (Ascending), name (Ascending)")
    print("\n   Gli indici si possono creare automaticamente quando l'app fa la prima query,")
    print("   oppure manualmente dalla Firebase Console > Firestore > Indexes")


def main():
    """Funzione principale."""
    print("=" * 60)
    print("🏔️  Upload Rifugi to Firestore")
    print("=" * 60)
    
    # Inizializza Firebase
    print("\n🔧 Inizializzazione Firebase...")
    try:
        db = initialize_firebase()
        print("✅ Firebase inizializzato correttamente")
    except Exception as e:
        print(f"❌ Errore nell'inizializzazione Firebase: {e}")
        sys.exit(1)
    
    # Carica i dati
    print("\n📖 Caricamento dati da cai_app_data.json...")
    try:
        rifugi_data = load_rifugi_data()
        print(f"✅ Caricati {len(rifugi_data)} rifugi dal file JSON")
    except Exception as e:
        print(f"❌ Errore nel caricamento del file JSON: {e}")
        sys.exit(1)
    
    # Conferma prima di procedere
    print(f"\n⚠️  Stai per caricare {len(rifugi_data)} rifugi su Firestore.")
    print("   Questa operazione sovrascriverà i dati esistenti (merge mode).")
    response = input("\n   Continuare? (s/n): ")
    
    if response.lower() not in ['s', 'si', 'y', 'yes']:
        print("\n❌ Operazione annullata dall'utente")
        sys.exit(0)
    
    # Upload
    try:
        uploaded, errors = upload_rifugi(db, rifugi_data)
        
        print("\n" + "=" * 60)
        print("📊 Riepilogo:")
        print(f"   ✅ Caricati con successo: {uploaded}")
        print(f"   ❌ Errori: {errors}")
        print(f"   📦 Totale: {len(rifugi_data)}")
        print("=" * 60)
        
        if uploaded > 0:
            create_indexes_info()
            print("\n✨ Upload completato!")
            print(f"   Verifica i dati su: https://console.firebase.google.com")
        
    except Exception as e:
        print(f"\n❌ Errore durante l'upload: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
