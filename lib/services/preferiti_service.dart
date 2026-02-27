import 'package:cloud_firestore/cloud_firestore.dart';

class PreferitiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Aggiungi un rifugio ai preferiti
  Future<void> addPreferito(String userId, String rifugioId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferiti')
          .doc(rifugioId)
          .set({
            'rifugioId': rifugioId,
            'aggiuntoIl': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('add_preferito_error:$e');
    }
  }

  // Rimuovi un rifugio dai preferiti
  Future<void> removePreferito(String userId, String rifugioId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferiti')
          .doc(rifugioId)
          .delete();
    } catch (e) {
      throw Exception('remove_preferito_error:$e');
    }
  }

  // Stream dei preferiti
  Stream<List<String>> getPreferitiStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('preferiti')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Verifica se un rifugio è preferito
  Future<bool> isPreferito(String userId, String rifugioId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferiti')
          .doc(rifugioId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
