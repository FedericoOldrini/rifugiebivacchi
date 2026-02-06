import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rifugio_checkin.dart';

class PassaportoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Salva un check-in (permette check-in multipli per lo stesso rifugio)
  Future<void> saveCheckIn(String userId, RifugioCheckIn checkIn) async {
    try {
      // Genera un ID univoco basato su timestamp se non presente
      final checkInId = checkIn.id ?? '${checkIn.rifugioId}_${DateTime.now().millisecondsSinceEpoch}';
      final checkInWithId = checkIn.copyWith(id: checkInId);
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .doc(checkInId)
          .set(checkInWithId.toMap());
    } catch (e) {
      throw Exception('Errore nel salvare il check-in: $e');
    }
  }

  // Recupera tutti i check-in di un utente
  Stream<List<RifugioCheckIn>> getCheckIns(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('checkins')
        .orderBy('dataVisita', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RifugioCheckIn.fromMap(doc.data()))
            .toList());
  }

  // Verifica se un rifugio è già stato visitato
  Future<bool> hasVisited(String userId, String rifugioId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .where('rifugioId', isEqualTo: rifugioId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Conta il numero di visite a un rifugio specifico
  Future<int> getRifugioVisitCount(String userId, String rifugioId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .where('rifugioId', isEqualTo: rifugioId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
  
  // Verifica se c'è un check-in oggi per questo rifugio
  Future<bool> hasCheckedInToday(String userId, String rifugioId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .where('rifugioId', isEqualTo: rifugioId)
          .get();
      
      // Verifica se almeno uno è di oggi
      return snapshot.docs.any((doc) {
        final data = doc.data();
        final dataVisita = DateTime.parse(data['dataVisita']);
        return dataVisita.isAfter(startOfDay) && dataVisita.isBefore(endOfDay);
      });
    } catch (e) {
      return false;
    }
  }

  // Ottieni il check-in di un rifugio specifico
  Future<RifugioCheckIn?> getCheckIn(String userId, String rifugioId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .doc(rifugioId)
          .get();
      
      if (doc.exists) {
        return RifugioCheckIn.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Abilita/disabilita la funzione passaporto per un utente
  Future<void> setPassaportoEnabled(String userId, bool enabled) async {
    try {
      // Verifica autenticazione
      final currentUser = _auth.currentUser;
      print('🔐 Current user: ${currentUser?.uid}');
      print('🔐 Trying to write as: $userId');
      print('🔐 User authenticated: ${currentUser != null}');
      print('🔐 UIDs match: ${currentUser?.uid == userId}');
      
      if (currentUser == null) {
        throw Exception('Utente non autenticato');
      }
      
      if (currentUser.uid != userId) {
        throw Exception('UID mismatch: current=${currentUser.uid}, requested=$userId');
      }
      
      print('📝 Setting passaporto enabled for user $userId to $enabled');
      await _firestore
          .collection('users')
          .doc(userId)
          .set({'passaportoEnabled': enabled}, SetOptions(merge: true));
      print('✅ Firestore write successful');
    } catch (e) {
      print('❌ Firestore write error: $e');
      throw Exception('Errore nell\'aggiornare le impostazioni: $e');
    }
  }

  // Verifica se la funzione passaporto è abilitata
  Future<bool> isPassaportoEnabled(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['passaportoEnabled'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Stream per lo stato del passaporto
  Stream<bool> passaportoEnabledStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['passaportoEnabled'] ?? false);
  }

  // Conta il numero di rifugi visitati
  Future<int> getVisitCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Elimina un check-in
  Future<void> deleteCheckIn(String userId, String rifugioId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('checkins')
          .doc(rifugioId)
          .delete();
    } catch (e) {
      throw Exception('Errore nell\'eliminare il check-in: $e');
    }
  }
}
