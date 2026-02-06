import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const int _dbVersion = 2; // Incrementato per aggiornare schema

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

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Aggiorna da v1 a v2: aggiungi colonna tipo, rimuovi colonne non utilizzate
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
      print('📦 Database già popolato con $count rifugi');
      return;
    }

    print('📦 Popolamento database locale da JSON...');

    try {
      // Carica il JSON dagli assets
      final String jsonString = await rootBundle.loadString('cai_app_data.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final batch = db.batch();
      int inserted = 0;

      for (var json in jsonList) {
        try {
          final rifugio = Rifugio.fromJson(json as Map<String, dynamic>);
          if (rifugio.nome.isEmpty) continue;

          batch.insert(
            _tableName,
            _rifugioToMap(rifugio),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          inserted++;
        } catch (e) {
          print('⚠️  Errore nell\'inserimento rifugio: $e');
        }
      }

      await batch.commit(noResult: true);
      print('✅ Inseriti $inserted rifugi nel database locale');
    } catch (e) {
      print('❌ Errore nel popolamento database: $e');
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
      print('🔄 Inizio sincronizzazione con Firestore...');
      
      final db = await database;
      final querySnapshot = await _firestore
          .collection('rifugi')
          .orderBy('name')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('ℹ️  Nessun rifugio trovato su Firestore');
        return;
      }

      final batch = db.batch();
      int synced = 0;

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final rifugio = Rifugio.fromJson(data);
          
          batch.insert(
            _tableName,
            {
              ..._rifugioToMap(rifugio),
              'syncedAt': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          synced++;
        } catch (e) {
          print('⚠️  Errore nella sincronizzazione di ${doc.id}: $e');
        }
      }

      await batch.commit(noResult: true);
      print('✅ Sincronizzati $synced rifugi da Firestore');
    } catch (e) {
      print('❌ Errore nella sincronizzazione: $e');
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
    } catch (e) {
      print('⚠️  Errore nel parsing immagini: $e');
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
    );
  }

  /// Forza una sincronizzazione completa
  static Future<void> forceSyncFromFirestore() async {
    print('🔄 Sincronizzazione forzata da Firestore...');
    await syncFromFirestore();
  }

  /// Pulisce il database (per testing)
  static Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(_tableName);
    print('🗑️  Database pulito');
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
