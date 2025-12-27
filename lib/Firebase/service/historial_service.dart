// lib/historial_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> guardarEntrada({
    required Map<String, dynamic> datos,
    required String nombre,
    required String ejemplo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    await _db
        .collection("usuarios")
        .doc(user.uid)
        .collection("historial")
        .add({
      "nombre": nombre,
      "ejemplo": ejemplo,
      "datos": datos,
      "fecha": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerHistorial() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }
    return _db
        .collection("usuarios")
        .doc(user.uid)
        .collection("historial")
        .orderBy("fecha", descending: true)
        .snapshots();
  }
}
