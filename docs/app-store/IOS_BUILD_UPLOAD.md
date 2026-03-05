# Guida Operativa: Build e Upload iOS

Istruzioni tecniche per compilare e caricare una nuova build iOS su App Store Connect.

**Complementa:** [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) (checklist completa pre-pubblicazione)

---

## Prerequisiti

### Account e Credenziali
- **Apple Developer Account:** Federico Oldrini, Team ID `7GU8UCZX25`
- **Bundle ID:** `it.federicooldrini.rifugiebivacchi`
- **App Store Connect API Key:**
  - Issuer ID: `d2d23ddf-c15d-44d4-9a56-705cbab0f2dc`
  - Key ID: `M6WVD946N7` (role: Administration)
  - Key file: `~/private_keys/AuthKey_M6WVD946N7.p8`

### Strumenti Richiesti
- Xcode (ultima versione stabile)
- Flutter SDK (^3.10.7)
- `xcrun altool` (incluso con Xcode Command Line Tools)

---

## Procedura Rapida (Aggiornamento)

Per pubblicare una nuova build quando non ci sono modifiche strutturali:

### Con Fastlane (consigliato)

```bash
cd ios

# Beta su TestFlight
bundle exec fastlane beta

# Oppure: release completa (bump + build + upload App Store)
bundle exec fastlane full_release bump:patch
```

### Manuale (alternativa)

```bash
# 1. Incrementa il build number in pubspec.yaml
#    Modifica la riga: version: 1.0.0+N  (incrementa N)

# 2. Build IPA
flutter build ipa --release

# 3. Upload su App Store Connect
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/rifugi_bivacchi.ipa \
  --apiKey M6WVD946N7 \
  --apiIssuer d2d23ddf-c15d-44d4-9a56-705cbab0f2dc
```

---

## Fastlane

Il progetto utilizza [Fastlane](https://fastlane.tools) per automatizzare build, upload e screenshot iOS. La configurazione si trova in `ios/fastlane/`.

### Setup iniziale

```bash
cd ios
bundle install    # Installa Fastlane e dipendenze Ruby
```

### Lane disponibili

| Comando | Descrizione |
|---|---|
| `bundle exec fastlane version` | Mostra versione corrente da pubspec.yaml |
| `bundle exec fastlane preflight` | Verifica pre-release: API key, file, flutter analyze |
| `bundle exec fastlane bump_version` | Incrementa build number |
| `bundle exec fastlane bump_version bump:patch` | Incrementa patch (es. 1.1.0 → 1.1.1) |
| `bundle exec fastlane bump_version bump:minor` | Incrementa minor (es. 1.1.0 → 1.2.0) |
| `bundle exec fastlane bump_version version:2.0.0` | Imposta versione specifica |
| `bundle exec fastlane build` | Solo build IPA (no upload) |
| `bundle exec fastlane beta` | Build + upload su TestFlight |
| `bundle exec fastlane beta skip_build:true` | Solo upload (se IPA già generato) |
| `bundle exec fastlane beta changelog:"Note release"` | Beta con changelog personalizzato |
| `bundle exec fastlane release` | Build + upload su App Store Connect |
| `bundle exec fastlane release submit:true` | Build + upload + invio per review |
| `bundle exec fastlane screenshots` | Cattura screenshot + overlay |
| `bundle exec fastlane upload_screenshots` | Upload screenshot su ASC |
| `bundle exec fastlane full_release bump:patch` | Pipeline completa: bump → build → upload → git tag |
| `bundle exec fastlane full_release bump:minor skip_screenshots:true` | Release senza screenshot |

### Pipeline completa (`full_release`)

La lane `full_release` esegue tutti gli step in sequenza:

1. **Bump version** — Incrementa versione e/o build number in `pubspec.yaml`
2. **Screenshot** — Cattura via Flutter Driver + overlay con Python (opzionale con `skip_screenshots:true`)
3. **Build IPA** — `flutter clean` + `flutter pub get` + `flutter build ipa --release`
4. **Upload** — Carica IPA su App Store Connect
5. **Git tag** — Commit version bump + tag `vX.Y.Z`

Dopo il `full_release`, ricorda di pushare:

```bash
git push origin main && git push origin vX.Y.Z
```

### Autenticazione

L'autenticazione con App Store Connect avviene tramite API Key (non username/password):

- **Key ID:** `M6WVD946N7`
- **Issuer ID:** `d2d23ddf-c15d-44d4-9a56-705cbab0f2dc`
- **Key file:** `~/private_keys/AuthKey_M6WVD946N7.p8`

La chiave `.p8` **non è inclusa nel repository** per sicurezza. Deve essere presente nella home directory.

### File Fastlane

```
ios/
├── Gemfile              # Dipendenze Ruby (fastlane, cocoapods)
├── Gemfile.lock         # Lock file generato
└── fastlane/
    ├── Appfile          # Credenziali Apple (bundle ID, team ID)
    └── Fastfile         # Definizione di tutte le lane
```

---

## Procedura Dettagliata

### 1. Verifica pre-build

```bash
# Assicurati di essere nella directory del progetto
cd ~/rifugibivacchi

# Controlla lo stato del codice
flutter analyze
flutter test

# Verifica le dipendenze
flutter pub get
```

### 2. Incrementa il Build Number

Modifica `pubspec.yaml`, riga `version`:

```yaml
# Formato: major.minor.patch+buildNumber
# Incrementa SOLO il build number per fix/rebuild della stessa versione
# Incrementa version per nuove release
version: 1.0.0+5   # esempio: da +4 a +5
```

> **Nota:** App Store Connect rifiuta build con lo stesso build number di una gia caricata.
> Il build number deve essere sempre maggiore dell'ultimo caricato.

### 3. Build Release iOS

```bash
flutter build ipa --release
```

Output atteso:
- IPA generato in `build/ios/ipa/rifugi_bivacchi.ipa`
- Dimensione tipica: ~55-60 MB

**Troubleshooting build:**
- Se fallisce il signing, apri `ios/Runner.xcworkspace` in Xcode e verifica il team di signing in Signing & Capabilities
- Se servono CocoaPods: `cd ios && pod install && cd ..`
- Per pulire build precedenti: `flutter clean && flutter pub get`

### 4. Upload su App Store Connect

```bash
xcrun altool --upload-app --type ios \
  -f build/ios/ipa/rifugi_bivacchi.ipa \
  --apiKey M6WVD946N7 \
  --apiIssuer d2d23ddf-c15d-44d4-9a56-705cbab0f2dc
```

L'upload richiede qualche minuto. Output di successo:

```
No errors uploading 'build/ios/ipa/rifugi_bivacchi.ipa'
```

> **Nota:** Dopo l'upload, Apple impiega 15-30 minuti per processare la build.
> Riceverai un'email quando il processing e completato.

### 5. Associa la Build in App Store Connect

1. Vai su [App Store Connect](https://appstoreconnect.apple.com)
2. Seleziona **Rifugi e Bivacchi**
3. Nella sezione **Build**, seleziona la nuova build processata
4. Compila l'**Export Compliance** (standard encryption = Yes, exempt = Yes per HTTPS)
5. Salva

---

## Aggiornamento Icona App

Quando serve aggiornare l'icona dell'app:

### 1. Prepara le immagini sorgente

- `assets/icon/app_icon.png` - Icona principale 1024x1024 PNG **senza alpha** (RGB)
- `assets/icon/app_icon_foreground.png` - Foreground per Android adaptive icon, 1024x1024 PNG **con alpha** (RGBA)

> **iOS richiede** che l'icona non abbia canale alpha/trasparenza.
> Per rimuovere l'alpha da un PNG con Pillow:
> ```python
> from PIL import Image
> img = Image.open("app_icon.png").convert("RGB")
> img.save("app_icon.png")
> ```

### 2. Configura flutter_launcher_icons

In `pubspec.yaml`, sezione `flutter_launcher_icons`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#2F6F55"    # Colore di sfondo estratto dall'icona
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icon/app_icon.png"
    background_color: "#2F6F55"
    theme_color: "#2F6F55"
  macos:
    generate: true
    image_path: "assets/icon/app_icon.png"
  windows:
    generate: true
    image_path: "assets/icon/app_icon.png"
    icon_size: 256
```

### 3. Genera le icone

```bash
dart run flutter_launcher_icons
```

Icone generate per tutte le piattaforme configurate:
- **Android:** `mipmap-mdpi` fino a `mipmap-xxxhdpi` + adaptive icon
- **iOS:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (21 file PNG)
- **Web:** `web/favicon.png` + `web/icons/`
- **macOS:** `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Windows:** `windows/runner/resources/app_icon.ico`

---

## Warning Noti

Questi warning appaiono durante il build ma **non bloccano** la pubblicazione:

1. **"Launch image is set to the default placeholder icon"** - La launch image usa il placeholder di default. Si puo risolvere configurando `ios/Runner/Assets.xcassets/LaunchImage.imageset/` o migrando a uno Storyboard launch screen.

2. **"UIScene lifecycle migration"** - Migrazione richiesta per future versioni iOS. Non urgente per iOS 17/18.

---

## Riferimenti

- [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) - Checklist completa 14 fasi
- [LISTING.md](LISTING.md) - Testi e metadata per App Store
- [ASSETS_GUIDELINES.md](ASSETS_GUIDELINES.md) - Linee guida screenshot e asset grafici
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer](https://developer.apple.com)

---

**Ultimo aggiornamento:** 5 marzo 2026
**Versione:** 2.0 (aggiunto Fastlane)
