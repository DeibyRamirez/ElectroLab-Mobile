import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  static User? get user => FirebaseAuth.instance.currentUser;
  static String get uid => user?.uid ?? '';
}
