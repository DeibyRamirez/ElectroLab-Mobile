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

      // Verificar si el correo del usuario es válido
      if (user.email == null) {
        await _auth.signOut();
        await GoogleSignIn().signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Correo no válido!"),
          ),
        );
        return;
      }

      final userRef = _db.collection("usuarios").doc(user.uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        await userRef.set({
          "nombre": user.displayName ?? "Sin nombre",
          "correo": user.email,
          "rol": "estudiante",
          "creadoEn": FieldValue.serverTimestamp(),
        });
      }

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
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de la universidad
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.1),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 5),
                      //   ),
                      // ],
                    ),
                    // padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      "assets/imagenes/ElectroLab_Icono_Azul_Fondo_Transparente.png",
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 0),

                  // Título
                  const Text(
                    "Bienvenido a la Plataforma",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 0),

                  const Text(
                    "ElectroLab",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      // color Oficil Azul: Color(0xFF0161AC)
                      color: Color.fromARGB(255, 1, 97, 172),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Descripción
                  const Text(
                    "Herramienta interactiva para aprender sobre fuerza eléctrica y campos eléctricos.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Botón Google
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.lightBlue),
                      ),
                      elevation: 5,
                    ),
                    onPressed: handleLogin,
                    icon: Image.asset(
                      "assets/imagenes/logo_google.png",
                      height: 24,
                    ),
                    label: const Text(
                      "Iniciar sesión con Google",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
