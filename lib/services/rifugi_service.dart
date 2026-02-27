import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/rifugio.dart';

/// Servizio per gestire i rifugi con supporto offline-first.
///
/// Strategia:
/// 1. Prima carica dai dati locali (SQLite) per funzionamento offline
/// 2. Poi sincronizza con Firestore in background quando disponibile
/// 3. Aggiorna il DB locale con i dati più recenti da Firestore
class RifugiService {
  static Database? _database;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tableName = 'rifugi';
  static const String _dbName = 'rifugi.db';
  static const int _dbVersion = 3; // Incrementato per schema completo

  /// Ottiene l'istanza del database SQLite
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inizializza il database SQLite
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea le tabelle del database
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        tipo TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitudine REAL,
        regione TEXT,
        provincia TEXT,
        comune TEXT,
        valle TEXT,
        descrizione TEXT,
        telefono TEXT,
        email TEXT,
        website TEXT,
        postiLetto INTEGER,
        operatore TEXT,
        immagini TEXT,
        source TEXT,
        locality TEXT,
        siteDescription TEXT,
        owner TEXT,
        status TEXT,
        regionalType TEXT,
        buildYear INTEGER,
        wifi INTEGER,
        elettricita INTEGER,
        ristorante INTEGER,
        postiTotali INTEGER,
        pagamentoPos INTEGER,
        defibrillatore INTEGER,
        hotWater INTEGER,
        showers INTEGER,
        insideWater INTEGER,
        restaurantSeats INTEGER,
        disabledAccess INTEGER,
        disabledWc INTEGER,
        familiesChildrenAccess INTEGER,
        carAccess INTEGER,
        mountainBikeAccess INTEGER,
        petAccess INTEGER,
        secondaryPhone TEXT,
        websiteProperty TEXT,
        emailProperty TEXT,
        propertyName TEXT,
        createdAt INTEGER,
        updatedAt INTEGER,
        syncedAt INTEGER
      )
    ''');

    // Crea indici per query veloci
    await db.execute('CREATE INDEX idx_regione ON $_tableName(regione)');
    await db.execute('CREATE INDEX idx_provincia ON $_tableName(provincia)');
    await db.execute('CREATE INDEX idx_nome ON $_tableName(nome)');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 3) {
      // Aggiorna schema: ricostruisci con tutti i campi del modello
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  /// Inizializza il database con i dati dal JSON locale
  static Future<void> initializeWithLocalData() async {
    final db = await database;

    // Controlla se il DB è già popolato
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    if (count != null && count > 0) {
      return;
    }

    try {
      // Carica il JSON dagli assets
      final String jsonString = await rootBundle.loadString(
        'cai_app_data.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      final batch = db.batch();
      for (var json in jsonList) {
        try {
          final rifugio = Rifugio.fromJson(json as Map<String, dynamic>);
          if (rifugio.nome.isEmpty) continue;

          batch.insert(
            _tableName,
            _rifugioToMap(rifugio),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        } catch (e) {
          debugPrint('Errore inserimento rifugio: $e');
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Errore nel popolamento database: $e');
      rethrow;
    }
  }

  /// Carica tutti i rifugi dal database locale
  static Future<List<Rifugio>> loadRifugiLocal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'nome ASC',
    );

    return maps.map((map) => _mapToRifugio(map)).toList();
  }

  /// Sincronizza i rifugi da Firestore
  static Future<void> syncFromFirestore() async {
    try {
      final db = await database;
      final querySnapshot = await _firestore
          .collection('rifugi')
          .orderBy('name')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      final batch = db.batch();
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final rifugio = Rifugio.fromJson(data);

          batch.insert(_tableName, {
            ..._rifugioToMap(rifugio),
            'syncedAt': DateTime.now().millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        } catch (e) {
          debugPrint('Errore sincronizzazione ${doc.id}: $e');
        }
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Errore sincronizzazione: $e');
      // Non propaghiamo l'errore - l'app funziona offline
    }
  }

  /// Cerca rifugi per nome
  static Future<List<Rifugio>> searchByName(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'nome LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nome ASC',
    );

    return maps.map((map) => _mapToRifugio(map)).toList();
  }

  /// Filtra rifugi per regione
  static Future<List<Rifugio>> filterByRegion(String region) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'regione = ?',
      whereArgs: [region],
      orderBy: 'nome ASC',
    );

    return maps.map((map) => _mapToRifugio(map)).toList();
  }

  /// Ottiene tutte le regioni disponibili
  static Future<List<String>> getRegions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT regione FROM $_tableName WHERE regione IS NOT NULL ORDER BY regione',
    );

    return maps.map((map) => map['regione'] as String).toList();
  }

  /// Ottiene tutte le province disponibili
  static Future<List<String>> getProvinces() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT provincia FROM $_tableName WHERE provincia IS NOT NULL ORDER BY provincia',
    );

    return maps.map((map) => map['provincia'] as String).toList();
  }

  /// Ottiene il range di altitudine (min, max) presente nel database
  static Future<({double min, double max})> getAltitudeRange() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT MIN(altitudine) as minAlt, MAX(altitudine) as maxAlt FROM $_tableName WHERE altitudine IS NOT NULL',
    );

    final minAlt = (maps.first['minAlt'] as num?)?.toDouble() ?? 0;
    final maxAlt = (maps.first['maxAlt'] as num?)?.toDouble() ?? 4000;

    return (min: minAlt, max: maxAlt);
  }

  /// Ottiene tutti i tipi distinti presenti nel database
  static Future<List<String>> getTypes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT tipo FROM $_tableName WHERE tipo IS NOT NULL ORDER BY tipo',
    );

    return maps.map((map) => map['tipo'] as String).toList();
  }

  /// Converte un Rifugio in Map per SQLite
  static Map<String, dynamic> _rifugioToMap(Rifugio rifugio) {
    return {
      'id': rifugio.id,
      'nome': rifugio.nome,
      'tipo': rifugio.tipo,
      'latitude': rifugio.latitudine,
      'longitude': rifugio.longitudine,
      'altitudine': rifugio.altitudine,
      'regione': rifugio.region,
      'provincia': rifugio.province,
      'comune': rifugio.municipality,
      'valle': rifugio.valley,
      'descrizione': rifugio.descrizione,
      'telefono': rifugio.telefono,
      'email': rifugio.email,
      'website': rifugio.sitoWeb,
      'postiLetto': rifugio.postiLetto,
      'operatore': rifugio.operatore,
      'immagini': json.encode(rifugio.imageUrls ?? []),
      'source': rifugio.source,
      'locality': rifugio.locality,
      'siteDescription': rifugio.siteDescription,
      'owner': rifugio.owner,
      'status': rifugio.status,
      'regionalType': rifugio.regionalType,
      'buildYear': rifugio.buildYear,
      'wifi': rifugio.wifi == true ? 1 : (rifugio.wifi == false ? 0 : null),
      'elettricita': rifugio.elettricita == true
          ? 1
          : (rifugio.elettricita == false ? 0 : null),
      'ristorante': rifugio.ristorante == true
          ? 1
          : (rifugio.ristorante == false ? 0 : null),
      'postiTotali': rifugio.postiTotali,
      'pagamentoPos': rifugio.pagamentoPos == true
          ? 1
          : (rifugio.pagamentoPos == false ? 0 : null),
      'defibrillatore': rifugio.defibrillatore == true
          ? 1
          : (rifugio.defibrillatore == false ? 0 : null),
      'hotWater': rifugio.hotWater == true
          ? 1
          : (rifugio.hotWater == false ? 0 : null),
      'showers': rifugio.showers == true
          ? 1
          : (rifugio.showers == false ? 0 : null),
      'insideWater': rifugio.insideWater == true
          ? 1
          : (rifugio.insideWater == false ? 0 : null),
      'restaurantSeats': rifugio.restaurantSeats,
      'disabledAccess': rifugio.disabledAccess == true
          ? 1
          : (rifugio.disabledAccess == false ? 0 : null),
      'disabledWc': rifugio.disabledWc == true
          ? 1
          : (rifugio.disabledWc == false ? 0 : null),
      'familiesChildrenAccess': rifugio.familiesChildrenAccess == true
          ? 1
          : (rifugio.familiesChildrenAccess == false ? 0 : null),
      'carAccess': rifugio.carAccess == true
          ? 1
          : (rifugio.carAccess == false ? 0 : null),
      'mountainBikeAccess': rifugio.mountainBikeAccess == true
          ? 1
          : (rifugio.mountainBikeAccess == false ? 0 : null),
      'petAccess': rifugio.petAccess == true
          ? 1
          : (rifugio.petAccess == false ? 0 : null),
      'secondaryPhone': rifugio.secondaryPhone,
      'websiteProperty': rifugio.websiteProperty,
      'emailProperty': rifugio.emailProperty,
      'propertyName': rifugio.propertyName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Converte una Map da SQLite in Rifugio
  static Rifugio _mapToRifugio(Map<String, dynamic> map) {
    List<String> immagini = [];

    try {
      if (map['immagini'] != null) {
        final decoded = json.decode(map['immagini'] as String);
        if (decoded is List) {
          immagini = decoded.cast<String>();
        }
      }
    } catch (_) {}

    bool? intToBool(dynamic value) {
      if (value == null) return null;
      return value == 1;
    }

    return Rifugio(
      id: map['id'] as String? ?? map['nome'].toString().hashCode.toString(),
      nome: map['nome'] as String,
      tipo: map['tipo'] as String? ?? 'rifugio',
      latitudine: (map['latitude'] as num).toDouble(),
      longitudine: (map['longitude'] as num).toDouble(),
      altitudine: (map['altitudine'] as num?)?.toDouble(),
      region: map['regione'] as String?,
      province: map['provincia'] as String?,
      municipality: map['comune'] as String?,
      valley: map['valle'] as String?,
      descrizione: map['descrizione'] as String?,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
      sitoWeb: map['website'] as String?,
      postiLetto: map['postiLetto'] as int?,
      operatore: map['operatore'] as String?,
      immagine: immagini.isNotEmpty ? immagini.first : null,
      imageUrls: immagini,
      source: map['source'] as String?,
      locality: map['locality'] as String?,
      siteDescription: map['siteDescription'] as String?,
      owner: map['owner'] as String?,
      status: map['status'] as String?,
      regionalType: map['regionalType'] as String?,
      buildYear: map['buildYear'] as int?,
      wifi: intToBool(map['wifi']),
      elettricita: intToBool(map['elettricita']),
      ristorante: intToBool(map['ristorante']),
      postiTotali: map['postiTotali'] as int?,
      pagamentoPos: intToBool(map['pagamentoPos']),
      defibrillatore: intToBool(map['defibrillatore']),
      hotWater: intToBool(map['hotWater']),
      showers: intToBool(map['showers']),
      insideWater: intToBool(map['insideWater']),
      restaurantSeats: map['restaurantSeats'] as int?,
      disabledAccess: intToBool(map['disabledAccess']),
      disabledWc: intToBool(map['disabledWc']),
      familiesChildrenAccess: intToBool(map['familiesChildrenAccess']),
      carAccess: intToBool(map['carAccess']),
      mountainBikeAccess: intToBool(map['mountainBikeAccess']),
      petAccess: intToBool(map['petAccess']),
      secondaryPhone: map['secondaryPhone'] as String?,
      websiteProperty: map['websiteProperty'] as String?,
      emailProperty: map['emailProperty'] as String?,
      propertyName: map['propertyName'] as String?,
    );
  }

  /// Forza una sincronizzazione completa
  static Future<void> forceSyncFromFirestore() async {
    await syncFromFirestore();
  }

  /// Pulisce il database (per testing)
  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Ottiene info sullo stato della sincronizzazione
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final db = await database;

    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    final syncedCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE syncedAt IS NOT NULL',
      ),
    );

    final lastSync = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MAX(syncedAt) FROM $_tableName'),
    );

    return {
      'total': totalCount ?? 0,
      'synced': syncedCount ?? 0,
      'lastSyncTime': lastSync != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSync)
          : null,
    };
  }
}
