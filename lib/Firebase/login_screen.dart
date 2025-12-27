// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Principal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception("Inicio cancelado por el usuario");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Esta es la credencial del servicio de autenticación.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> handleLogin() async {
    try {
      UserCredential userCred = await signInWithGoogle();
      final user = userCred.user;

      if (user == null) return;

      // Verificar correo institucional
      if (!user.email!.endsWith("@uniautonoma.edu.co")) {
        await _auth.signOut();
        await GoogleSignIn().signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Usa tu correo institucional @uniautonoma.edu.co!"),
          ),
        );
        return;
      }

      // Verificar si el usuario existe en Firestore
      final userRef = _db.collection("usuarios").doc(user.uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        // Si no existe, lo creamos
        await userRef.set({
          "nombre": user.displayName ?? "Sin nombre",
          "correo": user.email,
          "rol": "estudiante",
          "creadoEn": FieldValue.serverTimestamp(),
        });
      }

      // Redirigir según rol (aquí solo manejamos estudiante por ahora)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Principal()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la universidad
              Image.asset(
                "assets/imagenes/logo_universidad.png",
                height: 120,
              ),
              const SizedBox(height: 40),

              // Botón Google
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: handleLogin,
                icon: Image.asset(
                  "assets/imagenes/logo_google.png",
                  height: 24,
                ),
                label: const Text("Iniciar sesión con Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
