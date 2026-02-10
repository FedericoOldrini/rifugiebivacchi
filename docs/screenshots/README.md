# 📸 Screenshot Tools per App Store

Strumenti automatizzati per generare screenshot professionali per la pubblicazione su App Store.

## 🎯 Overview

Abbiamo 2 approcci per creare screenshot:

1. **Metodo Automatico** con Flutter Driver - Cattura screenshot automaticamente navigando l'app
2. **Metodo Manuale** con Simulatore - Maggiore controllo, cattura manuale delle schermate

Entrambi utilizzano script Python per aggiungere overlay professionali con titoli e sottotitoli.

---

## 📦 Requisiti

### Software Necessario
- **Python 3.7+** 
- **Pillow** (libreria Python per elaborazione immagini)
- **Xcode** e simulatori iOS
- **Flutter** e l'app compilata

### Installazione Dipendenze

```bash
# Installa Pillow per elaborazione immagini
pip3 install Pillow

# Verifica installazione
python3 -c "from PIL import Image; print('✅ Pillow installato')"
```

---

## 🚀 Metodo 1: Screenshot Automatici (Flutter Driver)

### Vantaggi
- ✅ Completamente automatico
- ✅ Screenshot consistenti e ripetibili
- ✅ Veloce per aggiornamenti

### Step by Step

#### 1. Aggiungi Keys alle Widget

Per permettere a Flutter Driver di trovare le widget, aggiungi Key ai componenti importanti:

```dart
// Esempio in home_screen.dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      key: ValueKey('list_tab'),  // ← Aggiungi key
      icon: Icon(Icons.list),
      label: 'Rifugi',
    ),
    BottomNavigationBarItem(
      key: ValueKey('map_tab'),   // ← Aggiungi key
      icon: Icon(Icons.map),
      label: 'Mappa',
    ),
  ],
)
```

#### 2. Avvia l'App con Driver

```bash
# Terminal 1: Avvia app in modalità profile
flutter run --profile -t test_driver/app.dart
```

#### 3. Esegui Test Screenshot

```bash
# Terminal 2: Esegui driver test
flutter drive --driver=test_driver/screenshot_test.dart
```

Gli screenshot verranno salvati in `test_driver/screenshots/`

#### 4. Aggiungi Overlay

```bash
# Aggiungi titoli e sottotitoli
python3 tools/add_overlays.py

# O con ridimensionamento per App Store
python3 tools/add_overlays.py --resize
```

Gli screenshot finali saranno in `screenshots/final/`

---

## 🎨 Metodo 2: Screenshot Manuali (Interattivo)

### Vantaggi
- ✅ Controllo completo su ogni screenshot
- ✅ Perfetto per schermate complesse
- ✅ Nessuna configurazione di keys necessaria

### Step by Step

#### 1. Compila l'App per Simulatore

```bash
flutter build ios --simulator
```

#### 2. Esegui Script Interattivo

```bash
python3 tools/generate_screenshots.py
```

#### 3. Segui le Istruzioni

Lo script:
1. Avvia automaticamente i simulatori
2. Installa l'app
3. Ti chiede di navigare alle schermate da catturare
4. Cattura screenshot quando premi INVIO
5. Aggiunge automaticamente overlay
6. Ridimensiona per tutte le dimensioni App Store

---

## 📐 Dimensioni Screenshot Generate

Lo script genera automaticamente screenshot per tutte le dimensioni richieste da App Store:

| Dispositivo | Risoluzione | Utilizzo |
|-------------|-------------|----------|
| iPhone 6.7" | 1290 × 2796 | iPhone 14/15 Pro Max (Richiesto) |
| iPhone 6.5" | 1242 × 2688 | iPhone 11 Pro Max, XS Max (Richiesto) |
| iPhone 5.5" | 1242 × 2208 | iPhone 8 Plus (Opzionale) |
| iPad Pro 12.9" | 2048 × 2732 | iPad Pro 12.9" (Richiesto) |

---

## 🎯 Screenshot Creati

Lo strumento genera automaticamente 5 screenshot:

1. **Lista Rifugi** - "Scopri oltre 1000 rifugi"
2. **Mappa** - "Mappa intelligente" 
3. **Dettaglio Rifugio** - "Tutte le info che cerchi"
4. **Ricerca/Filtri** - "Ricerca avanzata"
5. **Passaporto** - "Passaporto dei Rifugi"

---

## 🎨 Personalizzazione

### Modificare Testi Overlay

Edita il file `tools/add_overlays.py`:

```python
SCREENSHOTS_CONFIG = {
    "01_lista_rifugi": {
        "title": "Il tuo titolo qui",
        "subtitle": "Il tuo sottotitolo qui"
    },
    # ...
}
```

### Modificare Colori

Nel file `tools/add_overlays.py`:

```python
BG_COLOR = (46, 125, 50)      # RGB per sfondo
TEXT_COLOR = (255, 255, 255)  # RGB per titolo
SUBTITLE_COLOR = (220, 240, 220)  # RGB per sottotitolo
```

### Aggiungere Nuovi Screenshot

1. Aggiungi configurazione in `tools/add_overlays.py`:

```python
"06_nuovo_screenshot": {
    "title": "Titolo",
    "subtitle": "Sottotitolo"
}
```

2. Se usi Flutter Driver, aggiungi test in `test_driver/screenshot_test.dart`:

```dart
test('Screenshot 6: Nuovo', () async {
  // Naviga alla schermata
  // Cattura screenshot
  await takeScreenshot('06_nuovo_screenshot');
});
```

---

## 📁 Struttura Directory

```
rifugibivacchi/
├── tools/
│   ├── generate_screenshots.py   # Script manuale interattivo
│   └── add_overlays.py           # Aggiunge overlay
├── test_driver/
│   ├── app.dart                  # Entry point Flutter Driver
│   ├── screenshot_test.dart      # Test automatici
│   └── screenshots/              # Screenshot raw da driver
└── screenshots/
    ├── raw/                      # Screenshot originali (manuale)
    ├── with_overlay/             # Con overlay (intermedio)
    └── final/                    # Screenshot finali per App Store ✅
        ├── iPhone_6_7/
        ├── iPhone_6_5/
        ├── iPhone_5_5/
        └── iPad_Pro_12_9/
```

---

## 🔧 Troubleshooting

### "Pillow non trovato"
```bash
pip3 install Pillow
# Se hai problemi, prova:
pip3 install --upgrade Pillow
```

### "App non compilata per simulatore"
```bash
flutter clean
flutter build ios --simulator
```

### "Simulatore non trovato"
Verifica simulatori disponibili:
```bash
xcrun simctl list devices available
```

Installa simulatori mancanti da Xcode → Settings → Platforms

### "Flutter Driver timeout"
- Assicurati che l'app sia in esecuzione con `flutter run -t test_driver/app.dart`
- Verifica che le Key siano corrette nelle widget
- Aumenta i timeout in `screenshot_test.dart`

### Font non trovati
Lo script usa Helvetica di macOS. Se hai errori, vengono usati font di default.

### Screenshot sfocati
Assicurati di usare simulatori con Scale: 100% (Cmd+1 nel Simulator)

---

## 💡 Best Practices

### Screenshot di Qualità
- ✅ Usa sempre dati reali (no Lorem Ipsum)
- ✅ Mostra funzionalità chiave
- ✅ Evita barre di stato con notifiche
- ✅ Usa modalità chiara per coerenza
- ✅ Testa su device fisico prima

### Testi Overlay
- ✅ Titoli brevi e d'impatto (4-6 parole)
- ✅ Sottotitoli descrittivi (8-12 parole)
- ✅ Evidenzia benefici, non solo funzionalità
- ✅ Usa verbi d'azione

### Workflow Consigliato
1. Compila app e testa su dispositivo fisico
2. Genera screenshot automaticamente con Driver
3. Verifica qualità
4. Se necessario, ricrea manualmente screenshot problematici
5. Aggiungi overlay
6. Rivedi e ottimizza
7. Carica su App Store Connect

---

## 📤 Upload su App Store Connect

1. Vai su [App Store Connect](https://appstoreconnect.apple.com)
2. Seleziona la tua app
3. Vai a **App Store** → **Screenshot**
4. Per ogni device size, carica gli screenshot da `screenshots/final/[device_size]/`
5. Ordina gli screenshot (il primo è il più importante!)

### Ordine Consigliato
1. Lista rifugi (first impression)
2. Mappa (feature distintiva)
3. Dettaglio (informazioni complete)
4. Ricerca (utility)
5. Passaporto (engagement)

---

## 🎬 Workflow Veloce

```bash
# Quick Start - Metodo Automatico
flutter run --profile -t test_driver/app.dart
# In altro terminale:
flutter drive --driver=test_driver/screenshot_test.dart
python3 tools/add_overlays.py --resize

# Quick Start - Metodo Manuale  
flutter build ios --simulator
python3 tools/generate_screenshots.py
# Segui le istruzioni interattive
```

---

## 📚 Risorse

- [App Store Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Flutter Driver Documentation](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Pillow Documentation](https://pillow.readthedocs.io/)

---

## 🆘 Supporto

Per problemi o domande:
- Controlla le FAQ in `FAQ.md`
- Vedi esempi in `APP_STORE_ASSETS_GUIDELINES.md`
- Email: dev@rifugibivacchi.app

---

## ✅ Checklist Finale

Prima di caricare screenshot su App Store:

- [ ] Screenshot per iPhone 6.7" (almeno 3)
- [ ] Screenshot per iPhone 6.5" (almeno 3)
- [ ] Screenshot per iPad Pro 12.9" (almeno 3)
- [ ] Tutti gli screenshot hanno overlay chiari
- [ ] Nessuna informazione personale visibile
- [ ] Nessuna notifica nella status bar
- [ ] Screenshot in ordine logico
- [ ] Dimensioni corrette verificate
- [ ] Qualità immagine alta (PNG)
- [ ] Testato caricamento su App Store Connect

---

**Buona fortuna con la pubblicazione! 🏔️📱**
