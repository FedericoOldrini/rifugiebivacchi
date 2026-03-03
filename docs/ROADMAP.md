# Rifugi e Bivacchi — Roadmap di Sviluppo

> Piano evolutivo dell'app, organizzato per priorità e rilascio.
> Ultimo aggiornamento: marzo 2026

---

## Legenda

| Simbolo | Significato |
|---------|-------------|
| 🔴 | Alta priorità — impatto diretto su UX o review Apple/Google |
| 🟡 | Media priorità — migliora significativamente l'esperienza |
| 🟢 | Bassa priorità — nice-to-have, espansioni future |
| ✅ | Completato |
| 🔲 | Da fare |
| 🚧 | In corso |

---

## v1.1 — Polish & Filtri (prossimo rilascio)

Obiettivo: correggere il debito tecnico della v1.0 e aggiungere le feature più richieste.

### 🔴 Ridurre visibilità card donazioni nella lista
- ✅ Rimosso gradiente rosa/viola e sostituito con sfondo `surfaceContainerLow` (si fonde con il background)
- ✅ Rimosso container icona con ombra, sostituito con icona outline discreta (`favorite_border`)
- ✅ Rimossa seconda riga di testo (`supportDevelopment`), tenuto solo il messaggio principale
- ✅ Tutti i colori ora usano il `colorScheme` del tema (funziona in light e dark mode)
- ✅ Elevazione rimossa, bordo sottile e tenue
- **File modificato**: `lista_rifugi_screen.dart`

### 🔴 Audit colori e tema scuro
- ✅ Revisione **completa di tutti gli screen** in dark mode: verificato contrasto testi, icone, bordi, sfondi e divisori
- ✅ Sostituiti colori hardcoded (`Colors.white`, `Colors.black`, `Color(0xFF...)`, `Colors.grey[*]`, `Colors.green[*]`, `Colors.blue[*]`, ecc.) con riferimenti al tema (`Theme.of(context).colorScheme`)
- ✅ Verificate card, chip, bottoni e dialog in dark mode
- ✅ Marker mappa mantenuti con colori semantici (blu=rifugi, arancione=bivacchi, verde=malghe) — scelta intenzionale
- ✅ Galleria immagini e placeholder aggiornati per dark mode
- ✅ Onboarding e schermata donazioni aggiornati per dark mode
- ✅ Elementi branded (share card, passaporto, mountain pattern) lasciati intenzionali — hanno sfondi gradient custom
- 🔲 Testare su dispositivo fisico sia light che dark (i colori su schermo reale differiscono dall'emulatore)
- **File modificati**: `main.dart`, `lista_rifugi_screen.dart`, `settings_screen.dart`, `profilo_screen.dart`, `donations_screen.dart`, `onboarding_screen.dart`, `dettaglio_rifugio_screen.dart`, `offline_map_screen.dart`, `weather_widget.dart`, `rifugio_card.dart`, `image_gallery.dart`, `rifugio_image.dart`, `checkin_section.dart`, `contacts_section.dart`, `header_section.dart`, `map_section.dart`
- **File esclusi** (design branded intenzionale): `share_checkin_card.dart`, `share_dialog.dart`, `mountain_pattern_painter.dart`, `passaporto_screen.dart`

### ✅ Audit stringhe hardcoded e localizzazione
- ✅ Scansione sistematica di tutti i file in `lib/` alla ricerca di stringhe in italiano non passate per `AppLocalizations`
- ✅ Estratte tutte le stringhe hardcoded trovate verso i file ARB (`app_it.arb` come template)
- ✅ Localizzati: `passaporto_screen.dart`, `weather.dart` (18 descrizioni meteo WMO), `share_checkin_card.dart`, `map_section.dart`, `dettaglio_rifugio_screen.dart`
- ✅ Provider con error codes al posto di stringhe italiane: `auth_provider.dart`, `passaporto_provider.dart`, `rifugi_provider.dart`
- ✅ Service con error codes: `in_app_purchase_service.dart`, `preferiti_service.dart`, `passaporto_service.dart`
- ✅ Error resolver in tutti gli screen consumer: `profilo_screen.dart`, `onboarding_screen.dart`, `lista_rifugi_screen.dart`, `donations_screen.dart`, `dettaglio_rifugio_screen.dart`
- ✅ Placeholder e parametri con sintassi ICU corretta nei file ARB
- ✅ Completate traduzioni EN, DE, FR per ~50 nuove chiavi
- ✅ `flutter gen-l10n` eseguito, compilazione pulita (0 errori, 0 warning)
- 🔲 Testare l'app con locale forzato a EN, DE, FR per verificare che non compaiano stringhe in italiano
- **File coinvolti**: 4 ARB + 5 ARB generati, `weather.dart`, `rifugio.dart`, `weather_widget.dart`, `share_checkin_card.dart`, `map_section.dart`, `auth_provider.dart`, `passaporto_provider.dart`, `rifugi_provider.dart`, `in_app_purchase_service.dart`, `preferiti_service.dart`, `passaporto_service.dart`, `dettaglio_rifugio_screen.dart`, `passaporto_screen.dart`, `profilo_screen.dart`, `onboarding_screen.dart`, `lista_rifugi_screen.dart`, `donations_screen.dart`

### ✅ Filtri avanzati
- ✅ Filtro per **tipo**: rifugio, bivacco, malga (chip selezionabili)
- ✅ Filtro per **regione** (multi-select con lista regioni)
- ✅ Filtro per **range di altitudine** (slider min-max)
- ✅ Filtro per **servizi disponibili**: Wi-Fi, ristorante, docce, acqua calda, POS, defibrillatore
- ✅ Filtro per **accessibilità**: accesso disabili, famiglie, auto, MTB, animali
- ✅ Filtro per **posti letto** (min)
- ✅ UI: bottom sheet filtri dedicato (`FiltriSheet`) con chip attivi
- ✅ Persistenza filtri con `SharedPreferences`
- **File coinvolti**: `filtro_provider.dart`, `rifugi_provider.dart`, `lista_rifugi_screen.dart`, `filtri_sheet.dart`

### ✅ Ordinamento lista
- ✅ Ordinamento per **distanza** (default), **altitudine**, **nome A-Z**, **posti letto**
- ✅ UI: sezione ordinamento nel bottom sheet filtri
- **File coinvolti**: `rifugi_provider.dart`, `lista_rifugi_screen.dart`, `filtri_sheet.dart`

### 🔴 Migrazione UIScene (iOS)
- ✅ Aggiornamento `AppDelegate.swift` con `FlutterImplicitEngineDelegate`
- ✅ Aggiornamento `Info.plist` con `UIApplicationSceneManifest` e `FlutterSceneDelegate`
- ✅ Rimosso `UISceneStoryboardFile` dalla scene configuration (non necessario con UIScene lifecycle)
- ✅ Rimosso `Main.storyboard` e tutti i riferimenti dal progetto Xcode (`project.pbxproj`)
- ✅ Verificato build iOS release funzionante
- **Motivo**: obbligatorio per iOS post-26, warning risolto

### ✅ Tema stagionale
- ✅ Architettura `ThemeProvider` con `AppSeason` enum (auto, primavera, estate, autunno, inverno) + `ThemeMode` (system, light, dark)
- ✅ Persistenza preferenze con `SharedPreferences` (chiavi `theme_season`, `theme_mode`)
- ✅ Modalità **auto** che rileva la stagione corrente dal mese (emisfero nord)
- ✅ Refactoring completo `AppTheme` con 4 palette stagionali: 🌸 Primavera (verde prato + rosa rododendro + azzurro cielo), ☀️ Estate (teal/slate — palette originale), 🍂 Autunno (sienna/oro/marrone), ❄️ Inverno (blu ghiaccio/grigio freddo/bianco neve)
- ✅ Ogni stagione genera `ThemeData` completo con `ColorScheme` light e dark
- ✅ Component theme condiviso: AppBar, Card, FAB, NavigationBar, InputDecoration, Buttons, Chips, Dialogs, SnackBar
- ✅ `MaterialApp` wrappato con `Consumer<ThemeProvider>` per reattività immediata
- ✅ UI in `settings_screen.dart`: sezione "Aspetto" con selettore stagione (bottom sheet con icone 🌸☀️🍂❄️) e selettore modalità tema (chiaro/scuro/sistema)
- ✅ Localizzazione completa in 4 lingue (IT, EN, DE, FR): 12 nuove chiavi ARB
- ✅ Costante `AppTheme.deepTeal` mantenuta per elementi branded (passaporto, share card)
- **File creati**: `lib/providers/theme_provider.dart`
- **File modificati**: `lib/theme/app_theme.dart`, `lib/main.dart`, `lib/main_screenshot.dart`, `lib/screens/settings_screen.dart`, 4 file ARB

### ✅ Debito tecnico
- ✅ Spezzato `dettaglio_rifugio_screen.dart` (1452→~260 righe) in 8 widget separati in `lib/widgets/dettaglio/`
- ✅ Estratto `MountainPatternPainter` duplicato in widget condiviso `lib/widgets/mountain_pattern_painter.dart`
- ✅ Versione app dinamica con `package_info_plus` in `settings_screen.dart`
- ✅ Configurato `appStoreId: '6740241514'` per `in_app_review`
- ✅ Creato `AnalyticsService` con 12 custom event Firebase Analytics
- ✅ Ripristinato submodule `site/` con `.gitmodules` corretto

### ✅ Campo `country` nel modello dati
- ✅ Aggiungere campo `country` (codice ISO 3166-1 alpha-2, es. `IT`) al modello `Rifugio` in `rifugio.dart`
- ✅ Impostare `country: 'IT'` per tutti i rifugi esistenti (dati CAI) — default nel modello, nel JSON parsing e nella migrazione SQLite
- ✅ Aggiornare schema SQLite locale e migrazione DB (v3 → v4: `ALTER TABLE` + indice `idx_country`)
- ✅ Aggiornare `rifugi_service.dart` per leggere/scrivere il campo `country` + metodo `getCountries()`
- ✅ Preparare l'infrastruttura per il supporto multi-paese: `FiltroProvider` con `selectedCountries`, `RifugiProvider` con filtro country, script upload aggiornato
- **File coinvolti**: `rifugio.dart`, `rifugi_service.dart`, `filtro_provider.dart`, `rifugi_provider.dart`, `upload_rifugi_to_firestore.py`

### ✅ Nuove fonti dati Italia — Pipeline multi-source

Obiettivo: arricchire e verificare i dati CAI esistenti con fonti complementari, creando un'infrastruttura dati scalabile per futuri ampliamenti (copertura internazionale v2.0).

**Risultati**: da 756 strutture CAI → **10.085 strutture** nel dataset unificato (+2070 duplicati risolti, 837 record arricchiti, 2120 con immagini). Copertura: Italia + Svizzera (Ticino).

Dopo post-merge dedup (4 passate): **5.656 strutture** nel dataset finale (3.632 record Wikidata non-rifugi rimossi, 20 record generici senza nome rimossi, 777 duplicati eliminati). Tutti i 755 record CAI unici preservati.

#### Infrastruttura pipeline
- ✅ Modulo `scripts/shared.py`: formato `UnifiedShelter`, deduplicazione (haversine ≤200m + Levenshtein ≥0.8), trust hierarchy, normalizzazione nomi/tipi, I/O JSON
- ✅ Script `scripts/merge_sources.py`: orchestratore che carica tutte le fonti, applica deduplicazione cross-source, risolve conflitti via trust hierarchy, produce dataset unificato
- ✅ Deduplicazione: coordinate matching (distanza ≤200m) + fuzzy name matching (Levenshtein similarity ≥0.8)
- ✅ Trust hierarchy per conflitti: gestore verificato > CAI > dati regionali > OSM > Refuges.info > Wikidata
- 🔲 Campo `source` del modello `Rifugio` → evolve a `sources: List<String>` con storico fonti per ogni struttura
- 🔲 Nuovo campo `sourceIds: Map<String, String>` — mappa ogni fonte al suo ID nativo (es. `{"cai": "R123", "osm": "node/456"}`)
- 🔲 Nuovo campo `lastSourceSync: DateTime` — data ultima sincronizzazione dati
- 🔲 Aggiornare `rifugio.dart`, `rifugi_service.dart` e schema SQLite per i nuovi campi
- **File creati**: `scripts/shared.py`, `scripts/merge_sources.py`, `scripts/import_osm.py`, `scripts/import_wikidata.py`, `scripts/import_refuges_info.py`, `scripts/import_capanneti.py`, `scripts/import_opendata.py`
- **Output**: `cai_app_data_enriched.json` (10.085 strutture), `scripts/data/merge_log.json`

#### ✅ Fonte 1 — OpenStreetMap (Overpass API)
- ✅ Script `scripts/import_osm.py`: query Overpass per `tourism=alpine_hut` e `tourism=wilderness_hut` nel bounding box Italia
- ✅ Mapping campi OSM → `UnifiedShelter` (name, ele, capacity, operator, phone, website, wikimedia_commons, restaurant, electricity, shower)
- ✅ Dedup interna OSM (node/way <50m + nome ≥0.85): 41 duplicati rimossi
- ✅ Rilevamento paese da coordinate (IT/CH/AT/FR/SI)
- ✅ Risultato: **5929 strutture** (4639 IT, 778 AT, 333 CH, 93 FR, 86 SI) — 4334 alpine_hut + 2050 wilderness_hut raw → 4115 rifugi + 1814 bivacchi
- **Licenza**: ODbL — richiede attribuzione "© OpenStreetMap contributors"

#### ✅ Fonte 2 — Open Data regionali (enrichment)
- ✅ Script `scripts/import_opendata.py`: importa il CSV della Provincia Autonoma di Bolzano con elenco rifugi alpini
- ✅ Dati estratti: 103 rifugi con nome IT/DE, altitudine, comune, proprietario, telefono, email, website
- ✅ Enrichment name-based nel merge: **81/103 match trovati** per nome (Levenshtein ≥0.75 + conferma altitudine), **67 record arricchiti** con contatti (telefono/email/website) e proprietario
- ⚠️ Il CSV NON contiene coordinate GPS — usabile solo per enrichment, non come fonte geospaziale standalone
- 🔲 Esplorare altri portali regionali (Trentino, Lombardia, Piemonte, Valle d'Aosta, Veneto, FVG, Liguria) — finora non trovati dataset utili di rifugi
- **Licenza**: CC BY (Provincia Autonoma di Bolzano)

#### ✅ Fonte 3 — Wikidata + Wikimedia Commons
- ✅ Script `scripts/import_wikidata.py`: query SPARQL per tipo (Q182676 rifugio alpino, Q22698 bivacco, Q3947 capanna, Q2948402 bivacco fisso, Q106589819 rifugio escursionistico)
- ✅ Arricchimento: **3052 immagini** da Wikimedia Commons per 3007 strutture
- ✅ Split in 5 query separate per evitare timeout SPARQL (eliminata ricorsione P279*)
- ✅ Risultato: **7024 strutture** (4014 IT, 1690 CH, 738 AT, 338 SI, 244 FR)
- **Licenza**: CC0 (dati Wikidata), licenze varie per immagini Commons (quasi tutte CC BY-SA)

#### ✅ Fonte 4 — Refuges.info
- ✅ Script `scripts/import_refuges_info.py`: API REST bbox per 8 zone alpine di confine (Mont Blanc, Gran Paradiso, Pennine, Lepontine, Retiche, Marittime, Alto Adige, Giulie)
- ✅ Mapping: tipo struttura (refuge gardé/cabane/gîte/abri), coordinate, altitudine, posti letto, servizi da suffissi icona (feu/eau/cle), stato (aperto/chiuso/distrutto)
- ✅ Dedup interna per zone sovrapposte + esclusione strutture distrutte
- ✅ Risultato: **668 strutture** (633 IT, 30 FR, 3 CH, 2 AT) — altitudine 99%, posti letto 64%
- **Licenza**: CC BY-SA — richiede attribuzione

#### ✅ Fonte 5 — Capanneti.ch (CAS Ticino e Moesano)
- ✅ Script `scripts/import_capanneti.py`: scraping pagina HTML `capanneti.ch/it/capanne` con regex su attributi `data-*` di ogni card
- ✅ Dati estratti: nome, coordinate (WGS84), immagine, stato (Custodita/Non custodita), capacità (posti letto), località (regione, valle), link dettaglio
- ✅ Decodifica entità HTML (`&#252;` → ü, `&#232;` → è), validazione coordinate per bounding box Ticino
- ✅ 1 record scartato (Tremorgio: coordinate nel sistema svizzero CH1903 anziché WGS84)
- ✅ Risultato: **87 strutture** (43 rifugi custoditi, 44 bivacchi) — tutte con immagine, 86/87 con posti letto, 0 con altitudine (non presente nella pagina lista)
- ✅ Nel merge: 57 duplicati risolti (match con OSM/Wikidata), **30 nuove strutture** aggiunte al dataset
- **Licenza**: da verificare — sito non-profit CAS, contattare per permesso

#### Regole di qualità
- ✅ Ogni struttura deve avere almeno: nome, coordinate valide, tipo (rifugio/bivacco/malga) — 0 violazioni nel dataset finale
- ✅ Nessun duplicato ammesso: 2070 duplicati cross-source individuati e risolti
- 🔲 Mostrare fonte dati nel dettaglio rifugio: "Dati: CAI, OpenStreetMap" — trasparenza verso l'utente
- ✅ Log di merge con statistiche: `scripts/data/merge_log.json` (strutture per fonte, duplicati trovati, conflitti risolti, arricchimenti)

#### ✅ Post-merge dedup e pulizia Wikidata
- ✅ Script `scripts/post_merge_dedup.py`: deduplicazione di secondo livello sul dataset unificato (10.085 → 5.744 strutture, in due passate)
- ✅ **Fase 1 — Filtro Wikidata non-rifugi**: identificati 3.622 su 4.118 record Wikidata (88%) come non-rifugi (case, palazzi, parchi, chiese, teatri). Criteri di validazione: nome contiene keyword rifugio (rifugio, bivacco, hütte, refuge, capanna, etc.) OPPURE altitudine ≥500m. Mantenuti 496 record Wikidata legittimi
- ✅ **Fase 2 — Dedup coordinate** (≤30m): clustering con spatial grid + union-find, validazione pairwise con `should_merge()`, risoluzione cluster con sub-grouping per evitare merge transitivi errati
- ✅ Check altitudine universale (>100m diff = strutture distinte, sia same-source che cross-source)
- ✅ Sub-group splitting in cluster con record same-source incompatibili (es. Rifugio Omio + Bivacco Saglio bridgiati da un record OSM)
- ✅ Trust-based winner selection + enrichment: il record con trust più alta vince, ma assorbe immagini e campi mancanti dai perdenti
- ✅ **Passata 1**: 10.085 → 5.755 (3.622 Wikidata junk + 708 duplicati coordinate)
- ✅ **Passata 2 — Name similarity migliorata**: risolti 11 duplicati residui grazie a:
  - Rilevamento **toponimi condivisi** (es. "SAC Waldweid" vs "SAC-Hütte Waldweid" → toponym "waldweid" riconosciuto)
  - Gestione **nomi generici** (es. "Refuge" generico accanto a "Refuge de Tighiettu" → merge corretto)
  - **Equivalenza numeri** ("quattro province" = "4 province")
  - Soglia **adattiva per distanza**: same-source ≤20m usa threshold 0.5 (rilassato), >20m usa 0.7 (conservativo)
  - Eccezione **altitudine errata cross-source**: merge ammesso se ≤5m + name_sim ≥0.5 nonostante alt_diff >100m (es. Lampugnani CAI 3582m vs refuges.info 3852m a 0.7m di distanza)
  - Eccezione **altitudine sospetta**: merge ammesso se ≤15m + name_sim ≥0.7 e un record ha alt ≤10m (es. Bontadini CAI 2552m vs Wikidata 2m)
  - Lista **type words** escluse dal toponym matching per evitare falsi positivi ("cuile", "almhutte", "house" non sono toponimi)
- ✅ **Passata 3 — Raggio esteso 200m**: 52 duplicati rimossi grazie a regole adattive per distanza:
  - **Threshold adattivi**: same-source (≤20m sim≥0.5, 20-50m sim≥0.85, >50m mai), cross-source (≤5m sempre, 5-30m a meno di evidenze contrarie, 30-100m name_sim≥0.65 o containment+toponym, 100-200m name_sim≥0.85 o containment+toponym)
  - **Protezione tipo same-source**: record dalla stessa fonte con tipi strutturali diversi (es. "Capanna sociale" vs "Bivacco") NON unificati, usando mapping `shelter_groups` (managed/unmanaged/bivacco)
  - **Pattern "Vecchio/Nuovo"**: nomi che differiscono solo per "vecchio", "nuovo", "old", "new", "ancien", "hiver", "d'hiver" trattati come strutture distinte quando alt_diff >20m (es. "Rifugio Torino" 3375m vs "Rifugio Torino Vecchio" 3329m, 84.3m)
  - **Rilevamento punti d'acqua**: record "Fontaine ..." sempre acqua; "Source ..." acqua a meno di keyword rifugio. Punti d'acqua vs non-acqua mai unificati a 30-200m (es. "Fontaine Le Crest" protetta da merge con "Rifugio Vieux Crest")
  - Distribuzione distanze: 30-50m (24), 50-75m (6), 75-100m (12), 100-150m (6), 150-200m (5)
  - Combinazioni fonti: CAI←OSM (16), OSM←Wikidata (14), CAI←Wikidata (11), CAI←refuges.info (3), OSM←OSM (2), OSM←refuges.info (2), CAI←CAI (1), capanneti.ch←OSM (1), capanneti.ch←Wikidata (1)
- ✅ **Passata 4 — Raggio esteso 500m + pulizia avanzata**: 36 strutture rimosse in più (5.692 → 5.656) grazie a:
  - **Threshold esteso a 500m** con regole rigide per la fascia 200-500m: nome identico normalizzato → merge sempre; similarity ≥0.90 → merge; name containment + toponimo condiviso → merge; similarity ≥0.85 + toponimo condiviso → merge
  - **Eccezione same-source nomi identici (50-300m)**: cattura duplicati OSM way (es. due "Rifugio Monte Curcio" a 221m dalla stessa fonte)
  - **Fase 1.5 — Rimozione junk generico**: nuova fase tra Fase 1 e Fase 2 che elimina record con nomi tipo bare type-word ("Rifugio", "Refuge", "Capanna", "Berghaus") e richness ≤3 → **20 record OSM inutili rimossi**
  - **Miglioramento junk Wikidata**: aggiunta frozenset `WIKIDATA_JUNK_IDS` (6 Wikidata ID noti come "House") e `WIKIDATA_JUNK_NAMES` (house, casa, palazzo, etc.) per rigettare nomi non-rifugio → **10 record junk in più rimossi** rispetto a Passata 3
  - **Rilevamento nomi invertiti**: nuova funzione `_uninvert_parenthetical()` che converte "Fora (Alp di)" → "alp di fora" per matching con "Alp di Fora" (es. merge corretto a 283m)
  - **Protezione strutture distinte**: aggiunte keyword "bergerie", "caserma forestale", "caserma", "pastorale", "alpeggio" che impediscono il merge con rifugi vicini (es. "Cabane pastorale de Grauson Dessus" protetta dal merge con "Rifugio Grauson" a 290m, ma correttamente unificata con "Alpeggio di Grauson Dessus" a 1.6m)
  - **18 merge nella fascia estesa 200-500m** tutti verificati: Monte Rosa Hütte (201m), Dötra/Capanna Dötra (203m), Fonte Vetica (210m), Fora/Alp di Fora (283m, nome invertito), Albagno/Capanna Albagno (329m), Paoluccio (405m), Fraccaroli (472m), Monte Curcio (221m, same-source identico), e altri
- ✅ Risultato finale: **5.656 strutture** (5.190 IT, 466 CH) — 755 CAI + 4.352 OSM + 290 Refuges.info + 229 Wikidata + 30 Capanneti.ch
- ✅ 0 sourceId duplicati, 755 record CAI unici preservati (1 vero duplicato CAI "Bivacco Fiorio" 920000114 correttamente unificato in 920000113)
- ✅ DB version bumped da 5 a 6 in `rifugi_service.dart` per forzare re-import del dataset aggiornato
- **File**: `scripts/post_merge_dedup.py`, `scripts/scan_wider_duplicates.py`, `scripts/data/post_merge_dedup_log.json`

---

## v1.2 — Esplorazione & Scoperta

Obiettivo: rendere l'app più utile per pianificare escursioni e scoprire nuovi rifugi.

### 🟡 Note e foto nei check-in
- 🔲 Aggiungere campo **nota** al UI del check-in (il modello `RifugioCheckin` ha già il campo `note`)
- 🔲 Aggiungere possibilità di **scattare/allegare una foto** al check-in (campo `fotoUrl` già nel modello)
- 🔲 Upload foto su Firebase Storage
- 🔲 Mostrare nota e foto nella vista passaporto e nella card di condivisione
- **File coinvolti**: `dettaglio_rifugio_screen.dart`, `passaporto_screen.dart`, `passaporto_provider.dart`, `passaporto_service.dart`, `share_checkin_card.dart`

### 🟡 Rifugi nelle vicinanze
- 🔲 Sezione "Rifugi vicini" nel dettaglio di ogni rifugio (calcolo distanza geodetica)
- 🔲 Card orizzontali scrollabili con distanza e dislivello
- 🔲 Filtro sulla mappa: "Mostra rifugi nel raggio di X km"

### 🟡 Esplorazione per zona
- 🔲 Schermata **"Esplora"** con regioni/gruppi montuosi come card illustrate
- 🔲 Tap su regione → lista filtrata per quella zona
- 🔲 Possibilità di esplorare per: Dolomiti, Monte Bianco, Gran Paradiso, Appennini, ecc.
- 🔲 Raggruppamento basato su campo `valley` o coordinate geografiche

### 🟡 Statistiche personali
- 🔲 Dashboard nel profilo: numero rifugi visitati, altitudine massima raggiunta, regioni coperte
- 🔲 Grafico visite nel tempo (mensile/annuale)
- 🔲 Badge/traguardi: "10 rifugi visitati", "Sopra i 3000m", "Tutte le regioni alpine"
- 🔲 Condivisione statistiche come immagine social
- **Dipendenze**: potrebbe servire `fl_chart` o simile per grafici

### 🟢 Gestione mappe offline
- 🔲 UI per selezionare e **scaricare regioni** di mappa offline (il caching FMTC è già integrato)
- 🔲 Mostrare spazio occupato per regione
- 🔲 Possibilità di cancellare cache per regione
- **File coinvolti**: `offline_map_screen.dart`, nuovo `offline_maps_manager_screen.dart`

---

## v1.3 — Social & Community

Obiettivo: aggiungere elementi social per aumentare engagement e retention.

### 🟡 Recensioni e valutazioni
- 🔲 Sistema di **valutazione** (1-5 stelle) per ogni rifugio
- 🔲 **Recensioni testuali** degli utenti
- 🔲 Voto medio e numero recensioni visibili nella card e nel dettaglio
- 🔲 Moderazione base (segnalazione contenuti inappropriati)
- **Backend**: nuova collection Firestore `rifugi/{id}/reviews`

### 🟡 Condivisione rifugio
- 🔲 Deep link per condividere un rifugio specifico (Universal Links iOS + App Links Android)
- 🔲 Anteprima social (Open Graph) per link condivisi su WhatsApp/Telegram/social
- 🔲 Bottone "Condividi rifugio" nel dettaglio (già c'è share check-in, manca share rifugio generico)
- **Dipendenze**: `firebase_dynamic_links` o custom URL scheme

### 🟢 Liste personalizzate
- 🔲 Creare **liste tematiche** di rifugi (es. "Weekend in Dolomiti", "Rifugi con ristorante")
- 🔲 Aggiungere/rimuovere rifugi dalle liste
- 🔲 Condividere liste con altri utenti
- **Backend**: nuova collection Firestore `users/{uid}/lists`

### 🟢 Foto della community
- 🔲 Permettere agli utenti di **caricare foto** dei rifugi
- 🔲 Galleria community nel dettaglio rifugio (separata dalle foto ufficiali)
- 🔲 Moderazione e segnalazione
- **Backend**: Firebase Storage + collection `rifugi/{id}/communityPhotos`

### 🟡 Segnalazioni gestori rifugio (Fase 1)
- 🔲 Bottone **"Sei il gestore? Segnala una modifica"** nel dettaglio rifugio
- 🔲 Form di segnalazione: nome gestore, ruolo, campi da modificare (contatti, orari, servizi, descrizione, foto), nota libera
- 🔲 Invio segnalazione salvata su Firestore come richiesta pending
- 🔲 Notifica via email all'admin (Cloud Functions trigger su nuova segnalazione)
- 🔲 Pannello admin minimale (web o sezione nascosta in-app) per approvare/rifiutare le segnalazioni
- 🔲 Tracking stato segnalazione: pending → approvata / rifiutata, con feedback al gestore
- **Backend**: nuova collection Firestore `changeRequests/{id}` con campi: `rifugioId`, `requesterId`, `requesterName`, `requesterRole`, `changes` (mappa chiave→valore), `note`, `status`, `createdAt`, `reviewedAt`, `reviewedBy`
- **Dipendenze**: `firebase_messaging` o email per notifiche, Cloud Functions per trigger
- **File coinvolti**: nuovo `segnalazione_gestore_screen.dart`, `dettaglio_rifugio_screen.dart` (bottone), nuove Firestore rules

### 🟡 Badge "Rifugio Verificato"
- 🔲 Concetto di **rifugio verificato**: le informazioni sono state confermate o aggiornate direttamente dal gestore
- 🔲 **Badge visivo** (icona ✓ con tooltip) visibile ovunque appaia il rifugio: card nella lista, dettaglio, mappa (marker differenziato), passaporto
- 🔲 **Sezione nel dettaglio**: "Informazioni verificate dal gestore" con data ultima verifica
- 🔲 Un rifugio diventa verificato quando una segnalazione del gestore viene approvata (Fase 1) o quando il gestore conferma i dati dalla dashboard (Fase 2)
- 🔲 **Scadenza verifica**: il badge ha una validità temporale (es. 12 mesi); dopo la scadenza il rifugio torna "non verificato" e il gestore riceve un promemoria per riconfermare i dati
- 🔲 Filtro **"Solo rifugi verificati"** nella ricerca
- 🔲 Ordinamento con priorità ai rifugi verificati (opzionale, a scelta dell'utente)
- **Backend**: nuovi campi nel documento `rifugi/{id}`: `verified` (bool), `verifiedAt` (timestamp), `verifiedBy` (uid gestore), `verificationExpiresAt` (timestamp). Cloud Function schedulata per reset scadenze
- **Modello dati**: aggiornare `Rifugio` in `rifugio.dart` con campi `verified`, `verifiedAt`, `verifiedBy`
- **File coinvolti**: `rifugio.dart`, `rifugio_card.dart`, `dettaglio_rifugio_screen.dart`, `filtro_provider.dart`, `rifugi_provider.dart`, nuovo widget `verified_badge.dart`

---

## v1.4 — Trekking & Percorsi

Obiettivo: trasformare l'app da semplice catalogo a strumento di pianificazione escursioni.

### 🟡 Itinerari
- 🔲 Implementare la sezione **"I miei itinerari"** (placeholder già presente in `profilo_screen.dart`)
- 🔲 Creare itinerari collegando più rifugi in sequenza
- 🔲 Visualizzare itinerario sulla mappa con linea di collegamento
- 🔲 Calcolo distanza totale e dislivello cumulativo
- 🔲 Condivisione itinerario

### 🟢 Import/Export GPX
- 🔲 Importare tracce GPX da file
- 🔲 Mostrare rifugi lungo un percorso GPX importato
- 🔲 Esportare posizione rifugi come waypoint GPX
- **Dipendenze**: `gpx` o `xml` package per parsing

### 🟢 Profilo altimetrico
- 🔲 Mostrare profilo altimetrico tra posizione utente e rifugio
- 🔲 Dati elevazione da API esterne (Open-Elevation o Mapbox)
- **Dipendenze**: `fl_chart` per rendering profilo

### 🟢 Tracciamento percorso live
- 🔲 Registrazione GPS del percorso durante un'escursione
- 🔲 Salvataggio locale della traccia
- 🔲 Statistiche percorso: distanza, dislivello, tempo
- **Dipendenze**: `geolocator` (già presente), `background_locator` o simile per tracking in background

---

## v2.0 — Espansione & Monetizzazione

Obiettivo: espandere l'app oltre i confini attuali e creare sostenibilità.

### 🟢 Dati ampliati
- 🔲 Aggiungere **periodi di apertura/chiusura** stagionali (il campo `status` esiste ma non è dettagliato)
- 🔲 Integrazione con **bollettino valanghe** (API AINEVA)
- 🔲 Condizioni sentiero in tempo reale (crowdsourced)
- 🔲 Link a webcam vicine

### 🟡 Copertura internazionale — Arco Alpino Europeo

Obiettivo: espandere l'app a tutto l'arco alpino, trasformandola nel riferimento per rifugi e bivacchi delle Alpi europee. L'infrastruttura multi-source della v1.2 è il prerequisito tecnico.

#### Adattamenti modello dati
- 🔲 Aggiungere campo `country` (codice ISO 3166-1 alpha-2: `IT`, `AT`, `CH`, `FR`, `DE`, `SI`, `LI`) al modello `Rifugio`
- 🔲 Estendere filtri e UI per supportare selezione per paese
- 🔲 Gestire nomi multilingua: campo `nameLocalized: Map<String, String>` (es. `{"de": "Berliner Hütte", "it": "Rifugio Berlino"}`)
- 🔲 Adattare normalizzazione tipi per terminologia locale (Hütte, Biwak, Refuge, Cabane, Koča, ecc.)
- 🔲 Estendere localizzazione app con terminologia specifica per paese
- **File coinvolti**: `rifugio.dart`, `rifugi_provider.dart`, `filtro_provider.dart`, `rifugi_service.dart`, file ARB

#### 🇦🇹 Austria — Alpenverein (ÖAV + DAV condivisi)
- 🔲 **Fonte primaria**: alpenvereinaktiv.com — piattaforma condivisa ÖAV/DAV con API pubblica per POI
- 🔲 **Fonte secondaria**: OSM (`tourism=alpine_hut` nel bounding box Austria)
- 🔲 **Fonte terziaria**: Wikidata (entità rifugi austriaci con immagini Commons)
- **Strutture stimate**: ~500 Hütten ÖAV + ~200 private + ~100 Biwak
- **Dati disponibili**: nome, coordinate, altitudine, posti letto, periodo apertura, gestore, contatti, foto
- **Lingua dati**: tedesco (DE)
- **Licenza**: da verificare per alpenvereinaktiv; OSM (ODbL), Wikidata (CC0)
- **Note**: l'Austria ha la più alta densità di rifugi alpini — impatto molto alto

#### 🇨🇭 Svizzera — SAC/CAS + Capanne Ticino
- 🔲 **Fonte primaria**: sac-cas.ch — il Club Alpino Svizzero gestisce ~150 rifugi custoditi; verificare disponibilità API o dataset scaricabile
- 🔲 **Fonte regionale Ticino**: capanneti.ch — portale dedicato alle **88 capanne del Ticino e Moesano** (Canton Ticino + Val Mesolcina, Grigioni italiani). Dati estremamente dettagliati e in italiano:
  - Struttura: tipo (custodita/non custodita), posti letto, suddivisione camere, anno costruzione/ristrutturazione, refettori
  - Contatti: telefono capanna, email, sito web, guardiano (nome, recapiti), responsabile, proprietario (sezione CAS)
  - Servizi: acqua, docce, riscaldamento, illuminazione, WiFi, presa 220V, POS, essicatoio, cucina
  - Accessibilità: famiglie/bambini, animali ammessi (con dettaglio spazi)
  - Stagionalità: calendario **mese per mese** di presenza guardiano e apertura porta, posti letto invernali, infrastrutture invernali
  - Vie di accesso: ore, dislivello, difficoltà (scala SAC), percorsi estate/inverno con link a schweizmobil
  - Collegamenti con altre capanne vicine
  - Galleria fotografica (esterno, interno, regione)
  - Prenotazione: link a alpsonline.org, telefono, email, note
  - Webcam collegate
  - Disponibile in IT e DE
- 🔲 **Fonte secondaria**: map.schweizmobil.ch — portale escursionismo svizzero con POI rifugi
- 🔲 **Fonte terziaria**: OSM (ottima copertura in Svizzera, dati di alta qualità)
- 🔲 **Fonte aggiuntiva**: Wikidata + refuges.info (copre anche versante svizzero)
- **Strutture stimate**: ~150 SAC + ~88 capanne ticinesi (parziale overlap con SAC) + ~200 privati + ~100 bivacchi
- **Dati disponibili**: nome (DE/FR/IT a seconda del cantone), coordinate, altitudine, posti letto, custode, telefono, stato apertura
- **Lingua dati**: tedesco/francese/italiano (per cantone); capanneti.ch in IT e DE
- **Licenza**: SAC da verificare; capanneti.ch da verificare (sito non-profit, contattare per permesso); OSM (ODbL); schweizmobil (da verificare)
- **Note**: capanneti.ch è la fonte con il **livello di dettaglio più alto** tra tutte quelle individuate — include dati stagionali mese per mese, infrastrutture invernali e vie di accesso. Ideale come modello di riferimento per la qualità dati target. La Svizzera ha tre lingue nazionali — i dati sono spesso già multilingua, ottimo per la localizzazione. Import via web scraping (no API pubblica nota): script `import_capanneti.py`

#### 🇫🇷 Francia — FFCAM (ex-CAF)
- 🔲 **Fonte primaria**: refuges.info — database collaborativo completo di rifugi, bivacchi e abris in Francia e confini; API REST pubblica già usata come Fonte 4 per l'Italia; estendere la query a tutta la Francia
- 🔲 **Fonte secondaria**: ffcam.fr — la Fédération Française des Clubs Alpins et de Montagne gestisce ~130 rifugi; verificare API/dataset
- 🔲 **Fonte terziaria**: OSM + Wikidata
- **Strutture stimate**: ~130 FFCAM + ~400 privati/comunali + ~300 abris/bivouacs (refuges.info ne lista ~2500 in totale)
- **Dati disponibili**: nome, coordinate, altitudine, posti, acqua, coperte, stato, tipo (refuge gardé, refuge non gardé, bivouac, cabane, gîte)
- **Lingua dati**: francese (FR)
- **Licenza**: refuges.info (CC BY-SA), FFCAM (da verificare), OSM (ODbL)
- **Note**: refuges.info è la fonte più completa e già integrata nella pipeline — minimo effort per espansione

#### 🇩🇪 Germania — DAV (Alpenverein tedesco)
- 🔲 **Fonte primaria**: alpenvereinaktiv.com — condiviso con ÖAV, copre anche le Alpi bavaresi
- 🔲 **Fonte secondaria**: OSM + Wikidata
- **Strutture stimate**: ~320 Hütten DAV (molte in Austria/Svizzera/Italia) + ~50 nelle Alpi bavaresi propriamente tedesche
- **Dati disponibili**: nome, coordinate, altitudine, posti letto, periodo apertura, gestore
- **Lingua dati**: tedesco (DE)
- **Licenza**: alpenvereinaktiv (da verificare), OSM (ODbL)
- **Note**: molte Hütten DAV sono fisicamente in Austria o Italia — attenzione alla deduplicazione cross-country

#### 🇸🇮 Slovenia — PZS (Planinska zveza Slovenije)
- 🔲 **Fonte primaria**: pzs.si — l'Associazione Alpinistica Slovena gestisce ~170 rifugi (koče); verificare API o dataset
- 🔲 **Fonte secondaria**: hribi.net — portale escursionistico sloveno con database rifugi dettagliato
- 🔲 **Fonte terziaria**: OSM (buona copertura in Slovenia)
- **Strutture stimate**: ~170 koče PZS + ~80 bivacchi + ~50 strutture private
- **Dati disponibili**: nome, coordinate, altitudine, posti, contatti, periodo apertura
- **Lingua dati**: sloveno (SL) — aggiungere localizzazione app
- **Licenza**: da verificare per tutte le fonti
- **Note**: le Alpi Giulie slovene confinano con il Friuli — collegamento naturale con i dati italiani

#### 🇱🇮 Liechtenstein
- 🔲 Poche strutture (~5–10), recuperabili interamente da OSM + Wikidata
- **Note**: copertura minima ma completa il quadro dell'arco alpino

#### Strategia di rollout internazionale
- 🔲 **Fase 1**: Austria + Svizzera (alto impatto, buone fonti dati, area alpina di riferimento)
- 🔲 **Fase 2**: Francia (refuges.info già integrato, estensione naturale)
- 🔲 **Fase 3**: Germania + Slovenia + Liechtenstein (completamento arco alpino)
- 🔲 Per ogni paese: un script `import_{country}.py` che alimenta la pipeline `merge_sources.py` esistente
- 🔲 UI: nuovo filtro "Paese" nella ricerca, bandierine nella card rifugio, mappa che si estende all'arco alpino
- 🔲 Aggiornare titolo e descrizione store: "Rifugi e Bivacchi — Alpi" → posizionamento europeo
- 🔲 Valutare se rinominare l'app o mantenere il nome italiano con sottotitolo multilingua

#### Fonti trasversali (tutti i paesi)
- **OpenStreetMap**: base universale, ottima per colmare gap delle fonti ufficiali in ogni paese
- **Wikidata + Wikimedia Commons**: immagini libere e dati multilingua per i rifugi più noti
- **Refuges.info**: copre tutto l'arco alpino occidentale (FR, CH, IT confine)
- **Open-Meteo**: già integrato, funziona ovunque nel mondo — nessun adattamento necessario per il meteo

### 🟢 Widget iOS / Android
- 🔲 Widget "Rifugio del giorno" per home screen
- 🔲 Widget "Meteo rifugio preferito"
- **Dipendenze**: `home_widget` package

### 🟢 Apple Watch / Wear OS
- 🔲 Complicazione con rifugio più vicino
- 🔲 Navigazione base al rifugio dal polso

### 🟢 Notifiche push
- 🔲 Reminder per rifugi preferiti vicini (geofencing)
- 🔲 Notifica apertura stagionale di un rifugio preferito
- 🔲 Notifica meteo avverso per rifugi in lista
- **Dipendenze**: `firebase_messaging`, Cloud Functions

### 🟡 Pannello gestori rifugio (Fase 2)
- 🔲 Ruolo **"gestore"** nel sistema: utenti verificati associati a uno o più rifugi
- 🔲 Flusso di **verifica gestore**: richiesta claim rifugio → verifica manuale (email/telefono al rifugio) → approvazione
- 🔲 **Dashboard gestore** in-app: modifica diretta dei dati del proprio rifugio (contatti, servizi, orari, descrizione, foto, periodi apertura) senza approvazione admin
- 🔲 **Conferma periodica dati**: pulsante "Confermo che i dati sono aggiornati" che rinnova il badge verificato senza dover modificare nulla
- 🔲 Storico modifiche con versioning (chi ha modificato cosa e quando)
- 🔲 Possibilità per il gestore di rispondere alle recensioni degli utenti (dipende da v1.3 Recensioni)
- 🔲 Notifiche al gestore: nuove recensioni, nuovi check-in al proprio rifugio, **promemoria rinnovo verifica** in prossimità della scadenza
- 🔲 Statistiche per il gestore: visualizzazioni del rifugio, check-in, preferiti, **stato verifica e storico**
- **Backend**: campo `role` in `users/{uid}` (`user` | `gestore` | `admin`), collection `gestori/{uid}` con `rifugiIds[]` e `verifiedAt`, Firestore rules con write condizionato al ruolo, Cloud Functions per verifica, notifiche e scadenza badge
- **File coinvolti**: nuovo `gestore_dashboard_screen.dart`, `auth_provider.dart` (ruoli), `auth_service.dart` (claims), nuove Firestore rules avanzate
- **Note**: valutare Firebase Custom Claims per ruoli server-side vs campo Firestore; Custom Claims è più sicuro ma richiede Cloud Functions per l'assegnazione

### 🟢 Monetizzazione avanzata
- 🔲 Versione **Premium** (subscription) con: mappe offline illimitate, niente pubblicità, filtri avanzati, export GPX
- 🔲 Oppure: mantenere tutto gratuito con solo donazioni (modello attuale)

---

## Backlog — Idee a lungo termine

| Idea | Note |
|------|------|
| Modalità escursione con schermo always-on | Utile in montagna, mostra bussola + distanza rifugio |
| Integrazione HealthKit/Google Fit | Registrare dislivello e calorie |
| AR (Realtà Aumentata) | Puntare fotocamera per vedere rifugi in direzione |
| Chatbot / AI assistant | "Consigliami un rifugio per famiglie in Trentino con ristorante" |
| Prenotazione diretta | Integrazione con sistemi di prenotazione rifugi (se disponibili) |
| Portale web gestori | Dashboard web (Flutter web o React) per gestori che preferiscono lavorare da desktop |
| Gestione collaborativa multi-gestore | Più gestori per lo stesso rifugio con ruoli (proprietario, collaboratore) |
| Segnalazione problemi sentieri | Community-driven trail conditions |
| Integrazione Komoot/Strava | Import percorsi da altre piattaforme |
| Dark sky / osservazione stellare | Mappa inquinamento luminoso per bivacchi |

---

## Note tecniche trasversali

### Accessibilità (a11y)
- 🔲 Aggiungere `Semantics` labels a tutti i widget interattivi
- 🔲 Testare con VoiceOver (iOS) e TalkBack (Android)
- 🔲 Assicurare contrasto colori WCAG AA in entrambi i temi

### Performance
- 🔲 Lazy loading immagini nella lista (già `CachedNetworkImage`, verificare placeholder)
- 🔲 Paginazione lista rifugi per dataset grandi
- 🔲 Ottimizzare query SQLite con indici su campi filtro

### Testing
- 🔲 Unit test per providers e services
- 🔲 Widget test per schermate principali
- 🔲 Integration test per flussi critici (login → check-in → share)
- 🔲 Golden test per UI consistency

### CI/CD
- 🔲 GitHub Actions per build automatico su push
- 🔲 Fastlane per deploy automatico su TestFlight e Play Console
- 🔲 Distribuzione beta con Firebase App Distribution
