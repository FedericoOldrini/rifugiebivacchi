#!/usr/bin/env python3
import json

# Leggi il file JSON
with open('app_data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Aggiungi immagini placeholder ai primi 5 rifugi
for i in range(min(5, len(data))):
    data[i]['image'] = f'https://picsum.photos/400/300?random={i}'
    print(f"Aggiunta immagine a: {data[i]['name']}")

# Salva il file
with open('app_data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

print(f"\n✅ Aggiunte {min(5, len(data))} immagini di esempio")
