# Configurazione In-App Purchases

Questa guida spiega come configurare i prodotti in-app per iOS e Android.

## Prodotti Configurati

L'app utilizza tre prodotti consumabili per le donazioni:

| ID Prodotto | Tipo | Descrizione | Prezzo Suggerito |
|-------------|------|-------------|------------------|
| `rifugi_donation_coffee` | Consumabile | Offrimi un caffè | €2.99 |
| `rifugi_donation_lunch` | Consumabile | Offrimi un pranzo | €9.99 |
| `rifugi_donation_generous` | Consumabile | Donazione generosa | €19.99 |

## iOS - App Store Connect

### 1. Crea l'App su App Store Connect

1. Vai su [App Store Connect](https://appstoreconnect.apple.com)
2. Vai su **My Apps** e seleziona la tua app (o creala se non esiste)
3. Assicurati di avere un **App Bundle ID** configurato

### 2. Configura i Prodotti In-App

1. Nella pagina dell'app, vai alla sezione **Features** > **In-App Purchases**
2. Clicca sul pulsante **+** per creare un nuovo prodotto
3. Seleziona **Consumable** come tipo di prodotto

#### Per ogni prodotto:

**Prodotto 1: Caffè**
- **Reference Name**: Donation Coffee
- **Product ID**: `rifugi_donation_coffee` (DEVE corrispondere esattamente al codice)
- **Cleared for Sale**: Attivato
- **Price**: €2.99 (o equivalente nella tua valuta)

**Localizzazioni** (almeno una richiesta):
- **Display Name (IT)**: Offrimi un caffè
- **Description (IT)**: Supporta lo sviluppo dell'app offrendomi un caffè

**Prodotto 2: Pranzo**
- **Reference Name**: Donation Lunch  
- **Product ID**: `rifugi_donation_lunch`
- **Cleared for Sale**: Attivato
- **Price**: €9.99

**Localizzazioni**:
- **Display Name (IT)**: Offrimi un pranzo
- **Description (IT)**: Supporta lo sviluppo dell'app offrendomi un pranzo

**Prodotto 3: Donazione Generosa**
- **Reference Name**: Donation Generous
- **Product ID**: `rifugi_donation_generous`
- **Cleared for Sale**: Attivato
- **Price**: €19.99

**Localizzazioni**:
- **Display Name (IT)**: Donazione generosa
- **Description (IT)**: Una donazione generosa per supportare lo sviluppo

### 3. Carica Screenshot di Review (opzionale ma raccomandato)

Nella sezione **Review Information** di ogni prodotto, carica uno screenshot dell'acquisto in-app per accelerare la review.

### 4. Testing con Sandbox

1. Vai su **Users and Access** > **Sandbox Testers**
2. Crea un nuovo tester con email e password
3. Sul tuo dispositivo iOS, vai su **Settings** > **App Store** > **Sandbox Account**
4. Effettua il login con il tester sandbox
5. Gli acquisti saranno gratuiti in modalità sandbox

## Android - Google Play Console

### 1. Crea l'App su Google Play Console

1. Vai su [Google Play Console](https://play.google.com/console)
2. Crea una nuova app o seleziona l'app esistente
3. Assicurati di avere un **Application ID** configurato (nel file `android/app/build.gradle`)

### 2. Configura i Prodotti In-App

1. Nella dashboard dell'app, vai su **Monetization** > **In-app products**
2. Clicca su **Create product** per ogni donazione

#### Per ogni prodotto:

**Prodotto 1: Caffè**
- **Product ID**: `rifugi_donation_coffee` (DEVE corrispondere esattamente al codice)
- **Name**: Offrimi un caffè
- **Description**: Supporta lo sviluppo dell'app offrendomi un caffè
- **Status**: Active
- **Price**: €2.99

**Prodotto 2: Pranzo**
- **Product ID**: `rifugi_donation_lunch`
- **Name**: Offrimi un pranzo
- **Description**: Supporta lo sviluppo dell'app offrendomi un pranzo
- **Status**: Active
- **Price**: €9.99

**Prodotto 3: Donazione Generosa**
- **Product ID**: `rifugi_donation_generous`
- **Name**: Donazione generosa
- **Description**: Una donazione generosa per supportare lo sviluppo
- **Status**: Active
- **Price**: €19.99

### 3. Pubblica i Prodotti

I prodotti devono essere **Active** per essere disponibili nell'app, anche per il testing.

### 4. Testing

Per testare gli acquisti su Android:

1. **Test Account**: Aggiungi il tuo account Google come tester in **Settings** > **License testing**
2. **Test Tracks**: Crea una track di test (internal, closed, open alpha/beta) e carica l'APK/AAB
3. Gli account tester configurati possono testare gli acquisti gratuitamente

### Opzioni di Testing:
- **License testers**: Possono testare senza pagare
- **Test purchases**: Gli acquisti vengono annullati automaticamente dopo pochi minuti

## Configurazione Codice

### iOS: Info.plist

Nessuna configurazione aggiuntiva necessaria per `in_app_purchase`.

### Android: Permessi

Il package `in_app_purchase` gestisce automaticamente i permessi necessari.

Verifica che `android/app/build.gradle` abbia:
```gradle
defaultConfig {
    applicationId "com.example.rifugi_bivacchi" // Il tuo ID univoco
    minSdkVersion 21
    targetSdkVersion 34
}
```

## Verifica della Configurazione

### Test Checklist

- [ ] I Product ID nel codice corrispondono esattamente a quelli su App Store Connect / Play Console
- [ ] I prodotti sono attivi/disponibili sugli store
- [ ] Hai creato account di test (Sandbox per iOS, License testing per Android)
- [ ] L'app è stata firmata correttamente e ha gli identifier giusti
- [ ] Per iOS: hai testato in Sandbox
- [ ] Per Android: hai caricato l'app in una test track

### Troubleshooting

**I prodotti non vengono caricati:**
- Verifica che i Product ID corrispondano esattamente
- Assicurati che i prodotti siano attivi
- Per iOS: controlla di essere loggato con un Sandbox account
- Per Android: verifica che l'app sia in una test track e il tuo account sia un tester

**L'acquisto fallisce:**
- iOS: verifica di usare un Sandbox Tester, non il tuo account Apple ID normale
- Android: assicurati che il tuo account sia in License testing
- Controlla i log per messaggi di errore specifici

**Gli acquisti richiedono troppo tempo:**
- Questo è normale, specialmente la prima volta
- Non testare troppo velocemente (limiti anti-frode)

## Documentazione Ufficiale

- [Flutter in_app_purchase package](https://pub.dev/packages/in_app_purchase)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Google Play Console Guide](https://support.google.com/googleplay/android-developer/)
- [iOS In-App Purchase Testing](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [Android In-App Purchases Testing](https://developer.android.com/google/play/billing/test)

## Note Importanti

1. **Consumabili vs Non-Consumabili**: Le donazioni sono configurate come consumables (possono essere acquistate infinite volte)
2. **Tasse**: Apple e Google prendono una commissione del 15-30% sugli acquisti
3. **Privacy**: Assicurati di avere una privacy policy che menzioni gli acquisti in-app
4. **Compliance**: Rispetta le linee guida degli store per le donazioni/acquisti

## Passaggi Post-Configurazione

Dopo aver configurato i prodotti:

1. Testa accuratamente con account sandbox/test
2. Prepara screenshot per la review
3. Submetti l'app per review
4. Monitora gli analytics degli acquisti dopo il rilascio
