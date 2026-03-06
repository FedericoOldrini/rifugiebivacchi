/// Dati fake condivisi per screenshot dell'App Store.
///
/// Usato sia dal golden test (`test/screenshots/screenshot_golden_test.dart`)
/// sia dall'entry point integration test (`lib/main_screenshot.dart`).
///
/// I 10 rifugi sono stati selezionati dal dataset reale CAI per varietà
/// di tipo, regione, altitudine e servizi disponibili.
library;

import '../models/rifugio.dart';
import '../models/rifugio_checkin.dart';

// ============================================================
// Asset prefix per immagini locali
// ============================================================

const String _img = 'asset:assets/screenshots_images';

// ============================================================
// 10 rifugi reali dal dataset CAI
// ============================================================

List<Rifugio> fakeRifugi() => [
  // 1. Capanna Margherita — il rifugio più alto d'Europa
  Rifugio(
    id: 'rif001',
    nome: 'Capanna Margherita',
    descrizione:
        'Il rifugio più alto d\'Europa, sulla cima della Punta Gnifetti '
        'nel massiccio del Monte Rosa. Costruito nel 1893, ospita anche '
        'un laboratorio scientifico di ricerca ad alta quota.',
    latitudine: 45.927106,
    longitudine: 7.876792,
    altitudine: 4554,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Varallo',
    telefono: '+39 0163 91039',
    email: 'info@rifugimonterosa.it',
    sitoWeb: 'https://www.rifugimonterosa.it',
    postiLetto: 70,
    ristorante: true,
    wifi: false,
    elettricita: true,
    pagamentoPos: false,
    defibrillatore: true,
    region: 'Piemonte',
    province: 'Vercelli',
    municipality: 'Alagna Valsesia',
    valley: 'Valsesia',
    status: 'aperto',
    familiesChildrenAccess: false,
    immagine: '$_img/capanna_margherita.jpg',
    imageUrls: ['$_img/capanna_margherita.jpg'],
  ),

  // 2. Rifugio Nuvolau — terrazza panoramica sulle Dolomiti
  Rifugio(
    id: 'rif002',
    nome: 'Rifugio Nuvolau',
    descrizione:
        'Storico rifugio del 1883 sulla vetta del Monte Nuvolau, '
        'con vista panoramica a 360° sulle Dolomiti ampezzane. '
        'Uno dei rifugi più antichi delle Dolomiti.',
    latitudine: 46.507042,
    longitudine: 12.054683,
    altitudine: 2576,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Cortina',
    telefono: '+39 0436 5051',
    postiLetto: 24,
    ristorante: true,
    wifi: false,
    elettricita: true,
    region: 'Veneto',
    province: 'Belluno',
    municipality: 'Cortina d\'Ampezzo',
    status: 'aperto',
    familiesChildrenAccess: true,
    immagine: '$_img/nuvolau.jpg',
    imageUrls: ['$_img/nuvolau.jpg'],
  ),

  // 3. Rifugio Antermoia — nel cuore del Catinaccio
  Rifugio(
    id: 'rif003',
    nome: 'Rifugio Antermoia',
    descrizione:
        'Situato sulle rive del lago Antermoia nel gruppo del Catinaccio, '
        'è punto di partenza per l\'Alta Via n. 4 delle Dolomiti. '
        'Circondato da un paesaggio lunare di rara bellezza.',
    latitudine: 46.436928,
    longitudine: 11.624722,
    altitudine: 2496,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Bolzano',
    telefono: '+39 0462 602272',
    email: 'info@rifugioantermoia.com',
    postiLetto: 54,
    ristorante: true,
    wifi: false,
    elettricita: true,
    hotWater: true,
    showers: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    municipality: 'Campitello di Fassa',
    valley: 'Val di Fassa',
    status: 'aperto',
    immagine: '$_img/antermoia.jpg',
    imageUrls: ['$_img/antermoia.jpg'],
  ),

  // 4. Rifugio Coldai — vista sulla Civetta
  Rifugio(
    id: 'rif004',
    nome: 'Rifugio Coldai',
    descrizione:
        'Affacciato sulla parete nord-ovest della Civetta, '
        'offre un panorama mozzafiato sulle Dolomiti Agordine. '
        'Tappa dell\'Alta Via n. 1 delle Dolomiti.',
    latitudine: 46.378889,
    longitudine: 12.053056,
    altitudine: 2135,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Agordo',
    telefono: '+39 0437 789160',
    postiLetto: 60,
    ristorante: true,
    wifi: false,
    elettricita: true,
    region: 'Veneto',
    province: 'Belluno',
    municipality: 'Alleghe',
    valley: 'Val di Zoldo',
    status: 'aperto',
    familiesChildrenAccess: true,
    immagine: '$_img/coldai.jpg',
    imageUrls: ['$_img/coldai.jpg'],
  ),

  // 5. Rifugio Boè — sulla cima del Piz Boè
  Rifugio(
    id: 'rif005',
    nome: 'Rifugio Boè',
    descrizione:
        'Il rifugio più alto del gruppo del Sella, sotto la cima '
        'del Piz Boè. Punto panoramico straordinario tra Marmolada, '
        'Sassolungo e le valli dolomitiche.',
    latitudine: 46.505556,
    longitudine: 11.841944,
    altitudine: 2873,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Trento',
    telefono: '+39 0462 601190',
    postiLetto: 40,
    ristorante: true,
    wifi: false,
    elettricita: true,
    pagamentoPos: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    municipality: 'Canazei',
    valley: 'Val di Fassa',
    status: 'aperto',
    immagine: '$_img/boe.jpg',
    imageUrls: ['$_img/boe.jpg'],
  ),

  // 6. Rifugio Tosa Pedrotti — cuore delle Dolomiti di Brenta
  Rifugio(
    id: 'rif006',
    nome: 'Rifugio Tosa Pedrotti',
    descrizione:
        'Storico rifugio nel cuore delle Dolomiti di Brenta, '
        'punto di partenza per le celebri Bocchette. '
        'Uno dei più grandi e attrezzati rifugi del Trentino.',
    latitudine: 46.179280,
    longitudine: 10.887230,
    altitudine: 2491,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'SAT Trento',
    telefono: '+39 0461 948115',
    email: 'info@rifugiotosapedrotti.it',
    postiLetto: 120,
    ristorante: true,
    wifi: true,
    elettricita: true,
    pagamentoPos: true,
    defibrillatore: true,
    hotWater: true,
    showers: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    municipality: 'San Lorenzo Dorsino',
    valley: 'Val di Brenta',
    status: 'aperto',
    familiesChildrenAccess: true,
    immagine: '$_img/tosa_pedrotti.jpg',
    imageUrls: ['$_img/tosa_pedrotti.jpg'],
  ),

  // 7. Rifugio Torino — porta del Monte Bianco
  Rifugio(
    id: 'rif007',
    nome: 'Rifugio Torino',
    descrizione:
        'Raggiungibile dalla funivia di Punta Helbronner, '
        'si trova alla base del Dente del Gigante. Base di partenza '
        'per la traversata del Monte Bianco verso Chamonix.',
    latitudine: 45.847800,
    longitudine: 6.930300,
    altitudine: 3375,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Torino',
    telefono: '+39 0165 844034',
    email: 'info@rifugiotorino.com',
    sitoWeb: 'https://www.rifugiotorino.com',
    postiLetto: 150,
    ristorante: true,
    wifi: true,
    elettricita: true,
    pagamentoPos: true,
    hotWater: true,
    showers: true,
    region: 'Valle d\'Aosta',
    province: 'Aosta',
    municipality: 'Courmayeur',
    valley: 'Val Veny',
    status: 'aperto',
    familiesChildrenAccess: true,
    carAccess: false,
    immagine: '$_img/torino.jpg',
    imageUrls: ['$_img/torino.jpg'],
  ),

  // 8. Bivacco Regondi-Gavazzi — alta quota spartana
  Rifugio(
    id: 'rif008',
    nome: 'Bivacco Regondi-Gavazzi',
    descrizione:
        'Piccolo bivacco incustodito situato nel vallone di Clusaz, '
        'ai piedi del Grand Tournalin. Essenziale e spartano, '
        'ideale per alpinisti esperti.',
    latitudine: 45.875600,
    longitudine: 7.606400,
    altitudine: 2590,
    tipo: 'bivacco',
    country: 'IT',
    source: 'CAI',
    postiLetto: 9,
    ristorante: false,
    wifi: false,
    elettricita: false,
    region: 'Valle d\'Aosta',
    province: 'Aosta',
    municipality: 'Antey-Saint-André',
    valley: 'Valtournenche',
    status: 'aperto',
    immagine: '$_img/regondi_gavazzi.jpg',
    imageUrls: ['$_img/regondi_gavazzi.jpg'],
  ),

  // 9. Rifugio Cavazza al Pisciadù — sopra il Passo Gardena
  Rifugio(
    id: 'rif009',
    nome: 'Rifugio Cavazza al Pisciadù',
    descrizione:
        'Situato sulle rive del lago del Pisciadù nel gruppo del Sella, '
        'raggiungibile con una breve ma impegnativa ferrata. '
        'Panorama unico sulle Dolomiti della Val Badia.',
    latitudine: 46.510000,
    longitudine: 11.810000,
    altitudine: 2587,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI Bologna',
    telefono: '+39 0471 836292',
    postiLetto: 30,
    ristorante: true,
    wifi: false,
    elettricita: true,
    region: 'Trentino-Alto Adige',
    province: 'Bolzano',
    municipality: 'Corvara in Badia',
    valley: 'Val Badia',
    status: 'aperto',
    immagine: '$_img/pisciadu.jpg',
    imageUrls: ['$_img/pisciadu.jpg'],
  ),

  // 10. Rifugio Duca degli Abruzzi — Gran Sasso d'Italia
  Rifugio(
    id: 'rif010',
    nome: 'Rifugio Duca degli Abruzzi',
    descrizione:
        'Situato a Campo Imperatore nel cuore del Gran Sasso, '
        'è il punto di partenza per la salita al Corno Grande. '
        'Noto anche come "rifugio del Centenario" per la fondazione '
        'nel centenario del CAI.',
    latitudine: 42.445000,
    longitudine: 13.567000,
    altitudine: 2388,
    tipo: 'rifugio',
    country: 'IT',
    source: 'CAI',
    operatore: 'CAI L\'Aquila',
    telefono: '+39 0862 400000',
    postiLetto: 30,
    ristorante: true,
    wifi: false,
    elettricita: true,
    region: 'Abruzzo',
    province: 'L\'Aquila',
    municipality: 'L\'Aquila',
    valley: 'Campo Imperatore',
    status: 'aperto',
    familiesChildrenAccess: true,
    immagine: '$_img/duca_abruzzi.jpg',
    imageUrls: ['$_img/duca_abruzzi.jpg'],
  ),
];

// ============================================================
// Check-in fake (6 visite a 5 rifugi diversi)
// ============================================================

List<RifugioCheckIn> fakeCheckIns() => [
  RifugioCheckIn(
    id: 'ci001',
    rifugioId: 'rif001',
    rifugioNome: 'Capanna Margherita',
    rifugioLat: 45.927106,
    rifugioLng: 7.876792,
    altitudine: 4554,
    dataVisita: DateTime(2025, 8, 15),
    note: 'Alba indimenticabile a 4554 m!',
  ),
  RifugioCheckIn(
    id: 'ci002',
    rifugioId: 'rif003',
    rifugioNome: 'Rifugio Antermoia',
    rifugioLat: 46.436928,
    rifugioLng: 11.624722,
    altitudine: 2496,
    dataVisita: DateTime(2025, 8, 16),
  ),
  RifugioCheckIn(
    id: 'ci003',
    rifugioId: 'rif006',
    rifugioNome: 'Rifugio Tosa Pedrotti',
    rifugioLat: 46.179280,
    rifugioLng: 10.887230,
    altitudine: 2491,
    dataVisita: DateTime(2025, 7, 22),
  ),
  RifugioCheckIn(
    id: 'ci004',
    rifugioId: 'rif008',
    rifugioNome: 'Bivacco Regondi-Gavazzi',
    rifugioLat: 45.875600,
    rifugioLng: 7.606400,
    altitudine: 2590,
    dataVisita: DateTime(2025, 9, 3),
    note: 'Notte in bivacco con cielo stellato',
  ),
  RifugioCheckIn(
    id: 'ci005',
    rifugioId: 'rif001',
    rifugioNome: 'Capanna Margherita',
    rifugioLat: 45.927106,
    rifugioLng: 7.876792,
    altitudine: 4554,
    dataVisita: DateTime(2025, 9, 10),
    note: 'Seconda visita, giornata stupenda!',
  ),
  RifugioCheckIn(
    id: 'ci006',
    rifugioId: 'rif010',
    rifugioNome: 'Rifugio Duca degli Abruzzi',
    rifugioLat: 42.445000,
    rifugioLng: 13.567000,
    altitudine: 2388,
    dataVisita: DateTime(2025, 7, 28),
  ),
];

// ============================================================
// Preferiti fake (5 rifugi)
// ============================================================

List<String> fakePreferiti() => [
  'rif001', // Capanna Margherita
  'rif002', // Rifugio Nuvolau
  'rif006', // Rifugio Tosa Pedrotti
  'rif007', // Rifugio Torino
  'rif010', // Rifugio Duca degli Abruzzi
];
