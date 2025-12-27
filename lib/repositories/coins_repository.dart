import 'package:firebase_database/firebase_database.dart';

class CoinsRepository {
  static DatabaseReference _userRef(String uid) =>
      FirebaseDatabase.instance.ref("usuarios/$uid");

  static Future<int> getCoins(String uid) async {
    final snapshot = await _userRef(uid).child("monedas").get();
    return snapshot.value as int? ?? 0;
  }

  static Future<void> addCoins(String uid, int amount) async {
    final current = await getCoins(uid);
    await _userRef(uid).child("monedas").set(current + amount);
  }

  static Future<bool> subtractCoins(String uid, int amount) async {
    final current = await getCoins(uid);
    if (current < amount) return false;
    await _userRef(uid).child("monedas").set(current - amount);
    return true;
  }
}
