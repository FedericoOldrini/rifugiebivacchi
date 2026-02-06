import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/rifugio.dart';

class RifugiData {
  static List<Rifugio>? _rifugi;

  /// Carica i rifugi dal file JSON
  static Future<List<Rifugio>> loadRifugi() async {
    if (_rifugi != null) {
      return _rifugi!;
    }

    try {
      // Carica il file JSON dagli assets - usando il nuovo file CAI
      final String jsonString = await rootBundle.loadString('cai_app_data.json');
      
      // Decodifica il JSON
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Converte in lista di oggetti Rifugio
      _rifugi = jsonList
          .map((json) => Rifugio.fromJson(json as Map<String, dynamic>))
          .where((rifugio) => rifugio.nome.isNotEmpty) // Filtra rifugi senza nome
          .toList();
      
      return _rifugi!;
    } catch (e) {
      print('Errore nel caricamento dei rifugi: $e');
      return [];
    }
  }

  /// Ottiene i rifugi già caricati (sincrono)
  static List<Rifugio> get rifugi => _rifugi ?? [];

  /// Reset della cache (utile per testing)
  static void clearCache() {
    _rifugi = null;
  }
}
