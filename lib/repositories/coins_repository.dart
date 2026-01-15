import 'package:cloud_firestore/cloud_firestore.dart';

class CoinsRepository {
  // Definimos _db correctamente para Firestore
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referencia al documento del usuario
  static DocumentReference _userDoc(String uid) =>
      _db.collection("usuarios").doc(uid);

  // Obtener monedas
  static Future<int> getCoins(String uid) async {
    final snapshot = await _userDoc(uid).get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data["creditos"] as int? ?? 0;
    }
    return 0;
  }

  // Agregar monedas (Consumibles)
  static Future<void> addCoins(String uid, int amount) async {
    await _userDoc(uid).update({
      "creditos": FieldValue.increment(amount),
    });
  }

  // Restar monedas
  static Future<bool> subtractCoins(String uid, int amount) async {
    final current = await getCoins(uid);
    if (current < amount) return false;
    
    await _userDoc(uid).update({
      "creditos": FieldValue.increment(-amount),
    });
    return true;
  }

  // NUEVO: Desactivar anuncios (No Consumible)
  static Future<void> desactivarAnuncios(String uid) async {
    await _userDoc(uid).update({
      "quitarAnuncios": true,
    });
  }
}