// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> obtenerCreditosUsuario(String uid) async {
  print('📊 obtenerCreditosUsuario llamado con UID: $uid');
  
  if (uid.isEmpty) {
    print('❌ UID vacío en obtenerCreditosUsuario');
    return 0;
  }
  
  try {
    print('📊 Consultando Firestore...');
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    print('📊 Documento existe: ${doc.exists}');
    
    if (doc.exists) {
      final creditos = doc.data()?['creditos'] ?? 0;
      print('✅ Créditos encontrados: $creditos');
      return creditos;
    }
    
    print('⚠️ Documento no existe');
    return 0;
  } catch (e) {
    print('❌ Error al obtener créditos: $e');
    return 0;
  }
}

Future<void> actualizarCreditosUsuario(String uid, int nuevosCreditos) async {
  try {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'creditos': nuevosCreditos});
  } catch (e) {
    print('Error al actualizar créditos: $e');
  }
}

Future<void> descontarCreditosUsuario(String uid, int cantidad) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Usuario no encontrado");
      }

      final currentCredits = snapshot.data()?['creditos'] ?? 0;
      if (currentCredits < cantidad) {
        throw Exception("Créditos insuficientes");
      }

      final newCredits = currentCredits - cantidad;
      transaction.update(docRef, {'creditos': newCredits});
    });
  } catch (e) {
    print('Error al descontar créditos: $e');
  }
}

Stream<int> streamCreditosUsuario(String uid) {
  return FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data()?['creditos'] ?? 0);
}
