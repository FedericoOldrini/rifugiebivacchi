# Google Play Console — Setup Fastlane

Guida per configurare l'autenticazione API necessaria a Fastlane per caricare build e metadata su Google Play Console.

## Prerequisiti

- Account Google Play Console con accesso da sviluppatore
- App `it.federicooldrini.rifugiebivacchi` già creata sulla console
- Progetto Google Cloud associato (creato automaticamente da Play Console)

## 1. Creare un Service Account

### 1.1 Dalla Google Play Console

1. Vai su [Google Play Console](https://play.google.com/console) → **Setup** → **API access**
2. Se non hai ancora un progetto Google Cloud collegato, segui le istruzioni per crearne uno
3. Nella sezione **Service accounts**, clicca **Create new service account**
4. Si aprirà un link alla Google Cloud Console

### 1.2 Dalla Google Cloud Console

1. Vai su [Google Cloud Console → IAM → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Seleziona il progetto collegato a Play Console
3. Clicca **+ Create Service Account**:
   - **Nome**: `fastlane-play-store`
   - **ID**: `fastlane-play-store` (generato automaticamente)
   - **Descrizione**: `Service account per Fastlane deploy su Google Play`
4. Clicca **Create and Continue**
5. **NON** assegnare ruoli IAM (i permessi si gestiscono da Play Console)
6. Clicca **Done**

### 1.3 Genera la chiave JSON

1. Nella lista dei service account, clicca sui tre puntini → **Manage keys**
2. **Add key** → **Create new key** → **JSON**
3. Scarica il file JSON
4. **Rinomina** il file in `play-store-key.json`
5. **Spostalo** nella directory del progetto Android:
   ```bash
   mv ~/Downloads/NOME_ORIGINALE.json android/play-store-key.json
   ```

### 1.4 Assegna i permessi su Play Console

1. Torna su [Google Play Console](https://play.google.com/console) → **Setup** → **API access**
2. Trova il service account appena creato nella lista
3. Clicca **Grant access**
4. Nella scheda **App permissions**, seleziona l'app `Rifugi e Bivacchi`
5. Nella scheda **Account permissions**, abilita:
   - ✅ **Manage production releases** (per upload su production)
   - ✅ **Manage testing track releases** (per upload su internal/alpha/beta)
   - ✅ **Manage store presence** (per metadata e screenshot)
6. Clicca **Invite user** → **Send invite**

> ⚠️ **Nota**: I permessi possono richiedere fino a 24 ore per propagarsi, ma di solito sono attivi entro pochi minuti.

## 2. Verificare la configurazione

```bash
# Dalla directory android/
cd android
bundle exec fastlane run validate_play_store_json_key json_key:play-store-key.json
```

Se tutto è configurato correttamente vedrai un messaggio di successo con i dettagli dell'app.

## 3. Sicurezza

Il file `play-store-key.json` contiene credenziali sensibili.

- ✅ È già nel `.gitignore` di Android (`play-store-key.json`)
- ❌ **NON committarlo MAI** nel repository
- 🔒 Conserva un backup sicuro (es. 1Password, Bitwarden)

### File coinvolti

| File | Scopo | Nel repo? |
|---|---|---|
| `android/play-store-key.json` | Credenziali service account | ❌ .gitignore |
| `android/key.properties` | Password keystore signing | ❌ .gitignore |
| `android/fastlane/Appfile` | Riferimento al JSON key | ✅ |

## 4. Struttura Fastlane Android

```
android/
├── fastlane/
│   ├── Appfile                          # Package name + path al JSON key
│   ├── Fastfile                         # Lane definitions
│   └── metadata/
│       └── android/
│           ├── it-IT/
│           │   ├── title.txt            # max 30 char
│           │   ├── short_description.txt # max 80 char
│           │   ├── full_description.txt  # max 4000 char
│           │   ├── changelogs/
│           │   │   └── <versionCode>.txt # max 500 char
│           │   └── images/
│           │       ├── phoneScreenshots/
│           │       ├── icon.png          # 512x512
│           │       └── featureGraphic.png # 1024x500
│           ├── en-US/
│           ├── de-DE/
│           └── fr-FR/
├── Gemfile
├── play-store-key.json                  # ❌ NON nel repo
└── key.properties                       # ❌ NON nel repo
```

## 5. Lane disponibili

```bash
cd android

# Verifica pre-release
bundle exec fastlane preflight

# Build AAB senza upload
bundle exec fastlane build

# Upload su Internal Testing
bundle exec fastlane beta

# Upload completo su production (draft)
bundle exec fastlane release

# Pipeline completa (bump + notes + build + upload + tag)
bundle exec fastlane full_release bump:patch

# Promuovi da internal a production
bundle exec fastlane promote from:internal to:production

# Rollout graduale
bundle exec fastlane release rollout:0.1
bundle exec fastlane update_rollout rollout:0.5
bundle exec fastlane update_rollout rollout:1.0
```

## 6. Prima release

Per la prima release su Google Play, devi:

1. **Upload manuale del primo AAB** dalla Google Play Console (requisito Google)
2. Successivamente, Fastlane potrà gestire tutti gli upload automaticamente

```bash
# Build l'AAB
flutter build appbundle --release

# Il file sarà in: build/app/outputs/bundle/release/app-release.aab
# Caricalo manualmente dalla Play Console → Production → Create new release
```

Dopo il primo upload manuale, tutti i successivi possono essere automatizzati con Fastlane.
