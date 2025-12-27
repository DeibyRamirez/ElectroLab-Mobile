// lib/Firebase/service/quiz_service.dart

// ignore_for_file: unnecessary_cast, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;

  /// 🔹 Busca una sesión por su PIN (solo una vez)
  Future<DocumentSnapshot?> buscarSessionPorPin(String pin) async {
    int? pinInt = int.tryParse(pin);

    QuerySnapshot query;

    if (pinInt != null) {
      // Buscar tanto como número como texto (por compatibilidad)
      query = await _db
          .collection("sessions")
          .where("pin", isEqualTo: pinInt)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Si no lo encontró como número, buscar como texto
        query = await _db
            .collection("sessions")
            .where("pin", isEqualTo: pin)
            .limit(1)
            .get();
      }
    } else {
      // Solo buscar como texto
      query = await _db
          .collection("sessions")
          .where("pin", isEqualTo: pin)
          .limit(1)
          .get();
    }

    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  /// 🔹 Escucha los cambios en una sesión específica en tiempo real (Firestore)
  Stream<DocumentSnapshot> escucharSession(String sessionId) {
    return _db.collection("sessions").doc(sessionId).snapshots();
  }

  /// 🔹 Unirse a un quiz (Firestore + Realtime Database)
  Future<void> unirseAlQuiz(String pin) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    // Buscar sesión por pin
    final query = await _db
        .collection("sessions")
        .where("pin", isEqualTo: pin)
        .limit(1)
        .get();

    if (query.docs.isEmpty) throw Exception("PIN no válido");

    final sessionRef = query.docs.first.reference;
    final data = query.docs.first.data() as Map<String, dynamic>;

    if (data["status"] != "lobby") {
      throw Exception("La sesión ya ha comenzado");
    }

    final playerData = {
      "uid": user.uid,
      "name": user.displayName ?? "Jugador",
      "score": 0,
    };

    // ✅ 1. Agregar jugador al array de Firestore
    await sessionRef.update({
      "players": FieldValue.arrayUnion([playerData]),
    });

    // ✅ 2. Crear marca de conexión en Realtime Database
    final playerRef = _rtdb.ref("realtime-sessions/$pin/players/${user.uid}");

    // Registrar desconexión automática
    await playerRef.onDisconnect().remove();
    await playerRef.set(true);
  }

  /// 🔹 Salir del quiz (Firestore + Realtime Database)
  Future<void> salirDelQuiz(String pin) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 🔹 Referencia a Firestore (sessions/pin)
      final sessionRef = _db.collection("sessions").doc(pin);

      final sessionSnap = await sessionRef.get();
      if (!sessionSnap.exists) return;

      final data = sessionSnap.data() as Map<String, dynamic>? ?? {};
      final players = List<Map<String, dynamic>>.from(data["players"] ?? []);

      // 🔹 Remover jugador por UID
      final updatedPlayers =
          players.where((p) => p["uid"] != user.uid).toList();

      // 🔹 Actualizar Firestore
      await sessionRef.update({
        "players": updatedPlayers,
      });

      // 🔹 Eliminar del RTDB
      final playerRef = _rtdb.ref("realtime-sessions/$pin/players/${user.uid}");
      await playerRef.remove();

      print("✅ Jugador eliminado correctamente al salir del quiz");
    } catch (e) {
      print("❌ Error al eliminar jugador del quiz: $e");
    }
  }
}
