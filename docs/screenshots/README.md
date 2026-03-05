# Screenshot per App Store

Generazione automatica di screenshot professionali per App Store e Google Play tramite **golden tests** e **Fastlane**.

## Overview

Il sistema genera **30 screenshot** (5 schermate × 6 dimensioni App Store) con un singolo comando:

```bash
cd ios && bundle exec fastlane screenshots
```

### Pipeline

```
Golden Tests (Flutter)     →    Organizzazione    →    Overlay + Resize    →    Screenshot Finali
test/screenshots/              screenshots/raw/        Python tools/           screenshots/final/
30 PNG individuali             per-device dirs         titoli + resize         pronti per upload
(~4 secondi)                   (Fastlane helper)       (~10 secondi)
```

Nessun simulatore o device fisico necessario: i widget vengono renderizzati direttamente nel processo di test Flutter.

---

## Quick Start

### Prerequisiti

- **Flutter** (3.41.1+)
- **Python 3** con **Pillow**
- **Ruby** con **Bundler** e **Fastlane**

```bash
# Installa dipendenze Python
pip3 install Pillow

# Installa dipendenze Ruby (da ios/)
cd ios && bundle install
```

### Genera screenshot

```bash
# Pipeline completa: golden tests → organizza → overlay → resize
cd ios && bundle exec fastlane screenshots

# Solo overlay/resize (salta cattura golden tests)
cd ios && bundle exec fastlane screenshots skip_capture:true

# Solo cattura (salta overlay)
cd ios && bundle exec fastlane screenshots skip_overlay:true
```

### Upload su App Store Connect

```bash
cd ios && bundle exec fastlane upload_screenshots
# Con opzioni:
cd ios && bundle exec fastlane upload_screenshots version:1.1.0 locale:it-IT clean:true
```

---

## Come Funziona

### 1. Golden Tests

I golden tests (`test/screenshots/screenshot_golden_test.dart`) usano `golden_toolkit` per renderizzare le schermate dell'app come immagini PNG. Ogni test:

1. Costruisce un widget tree completo con `MultiProvider` + `MaterialApp`
2. Inietta dati fake (10 rifugi, 6 check-in, 5 preferiti, utente autenticato)
3. Usa `multiScreenGolden()` per generare un PNG per ogni dimensione device

Il test produce **30 file** nella directory `test/screenshots/goldens/screenshots/`:

```
01_lista_rifugi.iPhone_6_9.png
01_lista_rifugi.iPhone_6_7.png
01_lista_rifugi.iPhone_6_5.png
...
05_passaporto.iPad_Pro_12_9.png
```

#### Perché golden tests e non XCUITest/Flutter Driver?

- **Flutter renderizza la UI via Metal/OpenGL**, che XCUITest non può catturare (screenshot neri)
- **Nessun simulatore necessario** — rendering diretto nel processo di test
- **Velocissimo** — tutti e 30 gli screenshot in ~4 secondi
- **Deterministico** — sempre lo stesso output, nessun problema di timing
- **Tutte le dimensioni** — genera per ogni device size in un singolo run

### 2. Organizzazione (Fastlane)

L'helper `organize_golden_screenshots` nel Fastfile riorganizza l'output flat dei golden tests nella struttura per-device attesa dal tool Python:

```
# DA (golden output, flat):
test/screenshots/goldens/screenshots/01_lista_rifugi.iPhone_6_9.png

# A (per-device):
screenshots/raw/iPhone_6_9/01_lista_rifugi.png
```

### 3. Overlay e Resize (Python)

Lo script `tools/generate_screenshots.py --skip-test` applica a ogni screenshot:

- **Sfondo colorato** (deep teal RGB 44, 95, 93) nella parte superiore
- **Titolo** in bianco (es. "Scopri oltre 1000 rifugi")
- **Sottotitolo** in chiaro (es. "Database completo CAI con informazioni dettagliate")
- **Ridimensionamento** alla risoluzione esatta richiesta dall'App Store

Le dimensioni legacy (iPhone 5.5" e iPad Pro 12.9") vengono generate ridimensionando dal device nativo più vicino.

---

## Dimensioni Generate

| Device | Risoluzione | Density | Dimensione dp |
|---|---|---|---|
| iPhone 6.9" | 1320 × 2868 | 3x | 440 × 956 |
| iPhone 6.7" | 1290 × 2796 | 3x | 430 × 932 |
| iPhone 6.5" | 1242 × 2688 | 3x | 414 × 896 |
| iPhone 5.5" | 1242 × 2208 | 3x | 414 × 736 |
| iPad Pro 13" | 2064 × 2752 | 2x | 1032 × 1376 |
| iPad Pro 12.9" | 2048 × 2732 | 2x | 1024 × 1366 |

---

## Schermate Catturate

| # | Screenshot | Titolo | Sottotitolo |
|---|---|---|---|
| 1 | `01_lista_rifugi` | Scopri oltre 1000 rifugi | Database completo CAI con informazioni dettagliate |
| 2 | `02_mappa` | Mappa intelligente | Trova i rifugi più vicini con clustering avanzato |
| 3 | `03_dettaglio_rifugio` | Tutte le info che cerchi | Contatti, servizi, altitudine e foto |
| 4 | `04_profilo` | Il tuo profilo alpinista | Tieni traccia dei rifugi visitati e preferiti |
| 5 | `05_passaporto` | Passaporto dei Rifugi | Registra le tue visite e colleziona i timbri |

---

## Struttura Directory

```
rifugibivacchi/
├── test/
│   ├── flutter_test_config.dart                  # Carica font per golden tests
│   └── screenshots/
│       ├── screenshot_golden_test.dart            # 5 golden tests, dati fake, wrapper
│       └── goldens/
│           └── screenshots/                       # Output: 30 PNG (screen.device.png)
├── tools/
│   └── generate_screenshots.py                    # Overlay + resize (--skip-test)
├── screenshots/
│   ├── raw/                                       # Per-device raw (da golden output)
│   │   ├── iPhone_6_9/
│   │   ├── iPhone_6_7/
│   │   ├── iPhone_6_5/
│   │   ├── iPhone_5_5/
│   │   ├── iPad_Pro_13/
│   │   └── iPad_Pro_12_9/
│   └── final/                                     # Screenshot finali per App Store
│       ├── iPhone_6_9/
│       ├── iPhone_6_7/
│       ├── iPhone_6_5/
│       ├── iPhone_5_5/
│       ├── iPad_Pro_13/
│       └── iPad_Pro_12_9/
└── ios/
    └── fastlane/
        └── Fastfile                               # Lane: screenshots, upload_screenshots
```

---

## Personalizzazione

### Aggiungere una nuova schermata

1. **Aggiungi il golden test** in `test/screenshots/screenshot_golden_test.dart`:

```dart
testGoldens('06_nuova_schermata', (tester) async {
  await tester.pumpWidgetBuilder(
    _buildScreenWrapper(child: NuovaSchermataWidget()),
    surfaceSize: _devices.first.size,
  );
  await multiScreenGolden(
    tester,
    '06_nuova_schermata',
    devices: _devices,
  );
});
```

2. **Aggiungi la config overlay** in `tools/generate_screenshots.py`:

```python
SCREENSHOTS_CONFIG = {
    # ...existing...
    "06_nuova_schermata": {
        "title": "Titolo",
        "subtitle": "Sottotitolo descrittivo"
    }
}
```

3. **Rigenera**:

```bash
cd ios && bundle exec fastlane screenshots
```

### Modificare testi overlay

Edita `SCREENSHOTS_CONFIG` in `tools/generate_screenshots.py`. I colori e lo stile sono definiti nelle costanti dello stesso file.

### Modificare dati fake

I dati fake sono definiti nel file di test `screenshot_golden_test.dart`:
- `_fakeRifugi()` — 10 rifugi con dati realistici
- `_fakeCheckIns()` — 6 check-in per il passaporto
- `_fakePreferiti()` — 5 ID rifugi preferiti
- L'utente fake è configurato in `_buildScreenWrapper()` via `AuthProvider.setFakeUser()`

### Aggiungere una nuova dimensione device

1. Aggiungi il `Device` nella lista `_devices` del test Dart:

```dart
const Device(
  name: 'NuovoDevice',
  size: Size(430, 932),    // dimensione in dp
  devicePixelRatio: 3.0,    // density
),
```

2. Aggiungi il nome in `GOLDEN_DEVICE_NAMES` nel Fastfile
3. Aggiungi la dimensione target in `APP_STORE_SIZES` in `generate_screenshots.py`

---

## Fastlane Lanes

| Lane | Comando | Descrizione |
|---|---|---|
| `screenshots` | `bundle exec fastlane screenshots` | Pipeline completa: golden → organize → overlay |
| `upload_screenshots` | `bundle exec fastlane upload_screenshots` | Upload su App Store Connect |
| `full_release` | `bundle exec fastlane full_release` | Pipeline completa inclusi screenshot |

Opzioni per `screenshots`:
- `skip_capture:true` — salta golden tests, usa output esistente
- `skip_overlay:true` — salta overlay/resize

---

## Troubleshooting

### Golden test fallisce

```bash
# Rigenera i golden (--update-goldens forza la ricreazione)
cd /path/to/project
flutter test --update-goldens --tags=screenshots test/screenshots/
```

### Pillow non trovato

```bash
pip3 install Pillow
python3 -c "from PIL import Image; print('OK')"
```

### Font rendering diverso

I golden tests usano `loadAppFonts()` da `golden_toolkit` tramite `test/flutter_test_config.dart`. Se i font appaiono diversi, assicurati che `golden_toolkit: ^0.15.0` sia in `dev_dependencies` nel `pubspec.yaml`.

### Screenshot overlay disallineati

Verifica che le dimensioni in `_devices` (test Dart) corrispondano a `APP_STORE_SIZES` (Python). Il golden test genera alla risoluzione dp × devicePixelRatio, il tool Python ridimensiona al target finale.

---

## Best Practice

### Screenshot efficaci
- Usa dati realistici e in italiano nei fake data
- Mostra funzionalità chiave nella prima schermata (lista rifugi)
- L'ordine degli screenshot conta: il primo appare nelle ricerche

### Testi overlay
- Titoli brevi e d'impatto (4-6 parole)
- Sottotitoli descrittivi (8-12 parole)
- Evidenzia benefici, non solo funzionalità
- Usa verbi d'azione ("Scopri", "Trova", "Registra")

### Workflow per aggiornamenti
1. Modifica il test o i dati fake
2. Esegui `cd ios && bundle exec fastlane screenshots`
3. Verifica in `screenshots/final/`
4. Upload con `bundle exec fastlane upload_screenshots`

---

## Risorse

- [App Store Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [golden_toolkit](https://pub.dev/packages/golden_toolkit)
- [Fastlane Documentation](https://docs.fastlane.tools/)
