# Checklist Pubblicazione App Store - Rifugi e Bivacchi

## 📋 Panoramica

Questa checklist ti guida passo dopo passo nella pubblicazione di Rifugi e Bivacchi su App Store.

**Tempo stimato:** 2-4 settimane (inclusa revisione Apple)

---

## ✅ FASE 1: Preparazione Account e Certificati

### Account Sviluppatore Apple
- [ ] Account Apple Developer attivo ($99/anno)
- [ ] Contratti firmati in App Store Connect
- [ ] Informazioni fiscali completate
- [ ] Informazioni bancarie aggiunte (se usi In-App Purchase)

### Certificati e Provisioning
- [ ] Development Certificate creato
- [ ] Distribution Certificate creato
- [ ] App ID registrato (com.tuonome.rifugibivacchi)
- [ ] Provisioning Profile Development
- [ ] Provisioning Profile Distribution/App Store
- [ ] Push Notification entitlements (se necessario)
- [ ] Associated Domains configurati (se necessario)

**Strumenti:** Xcode → Preferences → Accounts → Manage Certificates

---

## ✅ FASE 2: Configurazione Progetto

### Xcode
- [ ] Bundle Identifier corretto
- [ ] Version Number: 1.0.0
- [ ] Build Number: 1
- [ ] Deployment Target: iOS 13.0 o superiore
- [ ] Device Orientation configurate
- [ ] Supported Devices: iPhone, iPad
- [ ] App Icons aggiunti (tutti i required sizes)
- [ ] Launch Screen configurato

### Info.plist
- [ ] Display Name: "Rifugi e Bivacchi"
- [ ] Privacy - Location When In Use Usage Description
- [ ] Privacy - Location Always Usage Description (se necessario)
- [ ] NSPhotoLibraryUsageDescription (se condividi immagini)
- [ ] URL Schemes (se necessario)

### Capabilities
- [ ] Maps capability abilitata
- [ ] Push Notifications (se usate)
- [ ] Sign in with Apple
- [ ] In-App Purchase

---

## ✅ FASE 3: Servizi Esterni

### Google Maps
- [ ] Account Google Cloud Platform creato
- [ ] Progetto creato
- [ ] Maps SDK for iOS abilitato
- [ ] API Key generata
- [ ] Restrizioni API Key configurate (Bundle ID)
- [ ] API Key aggiunta al progetto
- [ ] Billing attivato (richiesto per produzione)
- [ ] Quote monitoring configurato

**File:** `AppDelegate.swift` o equivalente con `GMSServices.provideAPIKey()`

### Firebase
- [ ] Progetto Firebase creato
- [ ] App iOS aggiunta al progetto
- [ ] `GoogleService-Info.plist` scaricato e aggiunto a Xcode
- [ ] Authentication abilitato (Email, Google, Apple)
- [ ] Firestore database creato
- [ ] Rules Firestore configurate per sicurezza
- [ ] Analytics abilitato
- [ ] Crashlytics configurato
- [ ] Firebase SDK nella versione corretta

**Verifica:** `firebase.json` e `firestore.rules` presenti

### In-App Purchase
- [ ] Agreed to Paid Applications Agreement
- [ ] Tax forms completati
- [ ] Banking information aggiunte
- [ ] Product IDs creati in App Store Connect:
  - [ ] `donation_coffee` (Consumable)
  - [ ] `donation_lunch` (Consumable)
  - [ ] `donation_generous` (Consumable)
- [ ] Prezzi configurati per ogni prodotto
- [ ] Localized titles e descriptions
- [ ] Screenshot prodotti (se richiesti)
- [ ] Review notes per prodotti

---

## ✅ FASE 4: Build e Testing

### Build Locale
- [ ] Build su dispositivo fisico riuscita
- [ ] Nessun errore di compilazione
- [ ] Nessun warning critico
- [ ] App funziona correttamente su iPhone
- [ ] App funziona correttamente su iPad
- [ ] Orientamento landscape/portrait OK
- [ ] Performance accettabili
- [ ] Memory leaks verificati (Instruments)

### Testing Funzionale
- [ ] Login/Signup funzionante
- [ ] Lista rifugi carica correttamente
- [ ] Mappa visualizza markers
- [ ] Ricerca funziona
- [ ] Filtri applicano correttamente
- [ ] Dettaglio rifugio completo
- [ ] Preferiti salvano/rimuovono
- [ ] Passaporto registra visite
- [ ] Condivisione funziona
- [ ] Chiamata telefonica apre dialer
- [ ] Link esterni aprono browser/app
- [ ] Deep links funzionano (se implementati)
- [ ] In-App Purchase (in Sandbox):
  - [ ] Prodotti caricano
  - [ ] Acquisto completa
  - [ ] Restore funziona (iOS)
  
### Testing su Dispositivi Multipli
- [ ] iPhone SE / modelli piccoli
- [ ] iPhone standard (13, 14, 15)
- [ ] iPhone Pro Max / modelli grandi
- [ ] iPad standard
- [ ] iPad Pro
- [ ] iOS 13.x (deployment target)
- [ ] iOS 14.x
- [ ] iOS 15.x
- [ ] iOS 16.x
- [ ] iOS 17.x (ultima versione)

### Testing Permessi
- [ ] Location: Denied → App funziona
- [ ] Location: While Using → Funziona correttamente
- [ ] Notifications: Denied → Nessun crash

### TestFlight (Beta Testing)
- [ ] Build caricata su App Store Connect
- [ ] Internal Testing funzionante
- [ ] External Testing (opzionale):
  - [ ] Gruppo beta creato
  - [ ] Inviti inviati
  - [ ] Feedback raccolto
  - [ ] Bug critici risolti

---

## ✅ FASE 5: Assets Grafici

### App Icon
- [ ] 1024x1024 px PNG (App Store)
- [ ] Nessuna trasparenza
- [ ] Nessun arrotondamento angoli
- [ ] Design chiaro e riconoscibile
- [ ] Rispetta linee guida Apple
- [ ] Testato a diverse dimensioni

### Screenshot iPhone
**iPhone 6.7" (1290 x 2796)**
- [ ] Screenshot 1: Home/Lista rifugi
- [ ] Screenshot 2: Mappa interattiva
- [ ] Screenshot 3: Dettaglio rifugio
- [ ] Screenshot 4: Ricerca/Filtri
- [ ] Screenshot 5: Passaporto
- [ ] Testi overlay aggiunti
- [ ] Qualità ottimale

**iPhone 6.5" (1242 x 2688)**
- [ ] 5 screenshot principali

**iPhone 5.5" (1242 x 2208) - Opzionale**
- [ ] 5 screenshot principali

### Screenshot iPad
**iPad Pro 12.9" (2048 x 2732)**
- [ ] 5 screenshot ottimizzati per iPad

### App Preview Video (Opzionale)
- [ ] Video 15-30 secondi
- [ ] Risoluzione corretta per device
- [ ] Audio/musica appropriata
- [ ] Sottotitoli chiari
- [ ] No informazioni personali
- [ ] Rispetta linee guida

---

## ✅ FASE 6: Contenuti App Store Connect

### Informazioni App
- [ ] **Nome:** Rifugi e Bivacchi
- [ ] **Sottotitolo:** (30 caratteri) "Rifugi alpini vicino a te"
- [ ] **Categoria Primaria:** Viaggi
- [ ] **Categoria Secondaria:** Navigazione
- [ ] **Content Rights:** Hai i diritti sui contenuti
- [ ] **Age Rating:** 4+
- [ ] **Price:** Gratuita

### Descrizione
- [ ] **Testo promozionale** (170 caratteri)
- [ ] **Descrizione** (4000 caratteri)
- [ ] **Keywords** (100 caratteri separati da virgole)
- [ ] **Support URL:** https://rifugibivacchi.app/support
- [ ] **Marketing URL:** https://rifugibivacchi.app (opzionale)

### Note di Rilascio
- [ ] **Versione 1.0.0:** Testo "What's New"

### Privacy
- [ ] **Privacy Policy URL:** Pubblicata e accessibile
- [ ] **Privacy Choices:** Configurate in App Store Connect
- [ ] Dichiarazione raccolta dati completata:
  - [ ] Location data
  - [ ] User ID
  - [ ] Email address
  - [ ] Purchase history

### App Store Information
- [ ] Copyright: "© 2026 Rifugi e Bivacchi"
- [ ] Contact Information: Email visibile
- [ ] Demo Account (se necessario):
  - Username: test@rifugibivacchi.app
  - Password: [password sicura]

---

## ✅ FASE 7: Localizzazione

### Lingua Primaria: Italiano
- [ ] Nome app
- [ ] Sottotitolo
- [ ] Descrizione
- [ ] Keywords
- [ ] Screenshot con testi italiani
- [ ] Note rilascio

### Lingue Aggiuntive (Opzionale)
- [ ] Inglese
- [ ] Tedesco
- [ ] Francese

---

## ✅ FASE 7.5: ASO e Verifica Metadata (Pre-Release)

> Questa fase deve essere completata PRIMA di ogni release per garantire che il listing
> sia ottimizzato per la discoverability e non contenga errori che causano reject.

### Limiti Caratteri (tutti i 4 locali: it, en-US, de-DE, fr-FR)
- [ ] **Keywords** ≤ 100 caratteri per ogni locale (virgola come separatore, NESSUNO spazio)
- [ ] **Subtitle** ≤ 30 caratteri per ogni locale
- [ ] **Promotional text** ≤ 170 caratteri per ogni locale
- [ ] **Description** ≤ 4000 caratteri per ogni locale
- [ ] **Name** ≤ 30 caratteri per ogni locale

### Contenuto Descrizioni
- [ ] Nessun emoji nelle description (App Store Connect li rifiuta)
- [ ] Nessun emoji nei promotional text
- [ ] Prima riga della description contiene USP principali (gratuita, offline, conteggio strutture)
- [ ] Fonti dati menzionate (CAI, OpenStreetMap, Wikidata, Refuges.info)
- [ ] "Gratuita" / "Free" / "Kostenlos" / "Gratuit" menzionato esplicitamente
- [ ] Conteggio strutture aggiornato e coerente con i dati reali
- [ ] Formattazione numeri corretta per locale (IT: 5.600, EN: 5,600, DE: 5.600, FR: 5 600)

### Keywords ASO
- [ ] Keywords non duplicano parole gia presenti in Name o Subtitle
- [ ] Keywords includono termini ad alto volume di ricerca
- [ ] Keywords includono varianti linguistiche rilevanti (es. hiking + trekking)
- [ ] Nessun keyword ripetuto all'interno dello stesso locale

### Coerenza Cross-Locale
- [ ] Stesso conteggio strutture in tutti i locali
- [ ] Release notes tradotte in tutti e 4 i locali
- [ ] Promotional text coerente in tutti i locali (stesse USP)

### Coerenza con Website e Docs
- [ ] Conteggio strutture allineato su site/index.html
- [ ] Conteggio strutture allineato su site/support.html
- [ ] APP_STORE_LISTING.md aggiornato con metadata attuali
- [ ] Privacy policy e Terms of Service senza placeholder

### Verifica Automatica (Fastlane)
Eseguire prima dell'upload:
```bash
# Verifica limiti caratteri metadata
cd ios && bundle exec fastlane run validate_metadata
```

---

## ✅ FASE 8: Build Upload

### Preparazione Build
- [ ] Versione finale testata
- [ ] Nessun codice debug attivo
- [ ] Logs puliti (nessun print eccessivo)
- [ ] Bundle ID corretto
- [ ] Version e Build Number incrementati
- [ ] Signing: Release/Distribution
- [ ] Build Configuration: Release
- [ ] Optimization: Speed (a meno di problemi)

### Archive e Upload
- [ ] Xcode → Product → Archive
- [ ] Archive riuscita senza errori
- [ ] Validate App prima di upload
- [ ] Upload to App Store Connect
- [ ] Processing completato (15-30 min)
- [ ] Build appare in App Store Connect

### Post-Upload
- [ ] Build associata alla versione app
- [ ] Export Compliance: Configurato
  - Usa encryption: Sì (HTTPS)
  - Exempt from export compliance: Sì (standard encryption)
- [ ] Rivedere tutti i dettagli una volta finale

---

## ✅ FASE 9: Informazioni per Revisione

### App Review Information
- [ ] **First Name:** [Tuo nome]
- [ ] **Last Name:** [Tuo cognome]
- [ ] **Phone Number:** [Numero telefono]
- [ ] **Email:** review@rifugibivacchi.app

### Demo Account (se richiesto)
- [ ] Username: test@rifugibivacchi.app
- [ ] Password: [Password sicura]
- [ ] Note aggiuntive per login

### Notes for Reviewer
```
Rifugi e Bivacchi è un'app informativa sui rifugi alpini italiani.

FUNZIONALITÀ PRINCIPALI:
- Database 5.600+ rifugi e bivacchi (dati CAI, OSM, Wikidata)
- Mappa con Google Maps
- Ricerca e filtri
- Preferiti e Passaporto

TESTING:
1. L'app può essere usata senza account
2. Per testare account: credenziali sopra
3. Location: opzionale, l'app funziona senza
4. In-App Purchase: donazioni volontarie (nessuna funzionalità bloccata)

NOTE TECNICHE:
- Google Maps API key configurata
- Firebase per auth e database
- Tutte API attive e funzionanti

CONTATTO EMERGENZE:
- Email: review@rifugibivacchi.app
- Disponibile per chiarimenti

Grazie per la revisione!
```

### Attachment (Opzionale)
- [ ] Video dimostrativo (se aiuta a spiegare l'app)
- [ ] Documento con screenshots aggiuntivi

---

## ✅ FASE 10: Submit for Review

### Pre-Submit Checklist Finale
- [ ] Tutti i campi obbligatori completati
- [ ] Screenshot caricati per tutti i device type richiesti
- [ ] Privacy policy URL valido e accessibile
- [ ] Support URL valido e accessibile
- [ ] Build selezionata per la versione
- [ ] Rating content corretto
- [ ] Export Compliance completato
- [ ] Demo account funzionante (testato)
- [ ] In-App Purchase configurations complete

### Submit
- [ ] **Revisione finale** di tutti i contenuti
- [ ] **Click "Submit for Review"**
- [ ] Conferma status: "Waiting for Review"
- [ ] Email di conferma ricevuta

### Tempi Attesi
- **In Review:** 24-48 ore dopo submission
- **Revisione:** 1-3 giorni (media)
- **Totale:** 2-7 giorni tipicamente

---

## ✅ FASE 11: Post-Submission

### Monitoring
- [ ] Controllare App Store Connect daily
- [ ] Verificare email per update da Apple
- [ ] Rispondere prontamente a richieste Apple

### Se Rejettata
- [ ] Leggere attentamente motivo rifiuto
- [ ] Risolvere issues identificate
- [ ] Rispondere nel Resolution Center (se possibile)
- [ ] Risubmit dopo fix

Common rejection reasons:
- Missing/broken features
- Crash o bug
- Privacy policy insufficiente
- Metadata poco chiaro
- In-App Purchase issues

### Se Approvata
- [ ] Verifica status: "Ready for Sale"
- [ ] App visibile su App Store (entro ore)
- [ ] Testare download da store
- [ ] Verificare tutte le funzionalità in produzione
- [ ] Verificare In-App Purchase in produzione

---

## ✅ FASE 12: Lancio e Promozione

### Preparazione Lancio
- [ ] Sito web live: https://rifugibivacchi.app
- [ ] Landing page con link App Store
- [ ] Privacy Policy accessibile online
- [ ] Terms of Service accessibili online
- [ ] Support page con FAQ
- [ ] Comunicato stampa preparato
- [ ] Post social media pronti
- [ ] Email list (se esistente) pronta

### Social Media
- [ ] Account Instagram creato/attivo
- [ ] Account Facebook creato/attivo
- [ ] Account Twitter/X creato/attivo
- [ ] Post di lancio schedulati
- [ ] Hashtag strategy definita
- [ ] Immagini promo create

### Outreach
- [ ] Contattare blog/siti montagna
- [ ] Inviare comunicato stampa
- [ ] Contattare CAI locale/nazionale
- [ ] Forum escursionismo
- [ ] Gruppi Facebook rilevanti
- [ ] Reddit communities

### App Store Optimization (ASO)
- [ ] Verifica FASE 7.5 completata per questa release
- [ ] Keywords ottimizzate e validate (≤100 chars)
- [ ] Descrizione compelling con USP in prima riga
- [ ] Screenshots con testi overlay aggiornati
- [ ] Review e rating monitoring attivo
- [ ] Rispondere alle recensioni

---

## ✅ FASE 13: Post-Lancio

### Monitoring (Primi 7 giorni)
- [ ] Download count
- [ ] Crash reports (Firebase Crashlytics)
- [ ] User reviews e ratings
- [ ] Analytics: retention, session length
- [ ] In-App Purchase conversions
- [ ] API usage e costi (Google Maps, Firebase)

### User Support
- [ ] Email supporto attiva: supporto@rifugibivacchi.app
- [ ] Tempi risposta: <48 ore
- [ ] FAQ aggiornate con question comuni
- [ ] Bug tracker per segnalazioni

### Metriche da Tracciare
- [ ] Downloads giornalieri
- [ ] Active users (DAU, WAU, MAU)
- [ ] Retention rate (Day 1, 7, 30)
- [ ] Session duration media
- [ ] Conversion rate donazioni
- [ ] Rating medio App Store
- [ ] Crash-free rate (target: >99%)

---

## ✅ FASE 14: Iterazione

### Feedback Collection
- [ ] Analytics review settimanale
- [ ] User reviews monitoring
- [ ] Email feedback raccolto
- [ ] Feature requests logged
- [ ] Bug reports prioritized

### Prossimi Update
- [ ] Bug fixes critici: ASAP
- [ ] Minor improvements: ogni 2-4 settimane
- [ ] Major features: ogni 2-3 mesi
- [ ] Version numbering strategy

### Aggiornamento Dati
- [ ] Database rifugi: mensile
- [ ] Verifiche informazioni: trimestrale
- [ ] Nuovi rifugi aggiunti
- [ ] Rifugi chiusi/rimossi

---

## 📞 Contatti Utili

### Apple
- **Developer Support:** https://developer.apple.com/support/
- **App Review:** https://developer.apple.com/contact/app-store/
- **App Store Connect:** https://appstoreconnect.apple.com

### Google
- **Maps Platform Support:** https://developers.google.com/maps/support
- **Firebase Support:** https://firebase.google.com/support

### Community
- **Stack Overflow:** flutter, ios, app-store-connect tags
- **Reddit:** r/iOSProgramming, r/FlutterDev
- **Discord:** Flutter developers community

---

## 🎉 Pubblicazione Completata!

Congratulazioni! Se hai completato tutti questi step, la tua app è live su App Store!

**Prossimi passi:**
1. Festeggia! 🎊
2. Monitora metriche
3. Rispondi agli utenti
4. Pianifica update
5. Continua a migliorare

**Remember:**
> "Shipped is better than perfect. Iterate and improve!"

Buona fortuna con Rifugi e Bivacchi! 🏔️

---

**Documento creato:** 9 febbraio 2026
**Ultimo aggiornamento:** 8 marzo 2026
**Versione Checklist:** 1.1
**Per:** Rifugi e Bivacchi v1.1.1+

© 2026 Federico Oldrini
