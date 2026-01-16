// lib/Quiz/Quiz.dart

// ignore_for_file: deprecated_member_use, file_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Anuncios/AdBannerWrapper.dart';
import 'package:graficos_dinamicos/Quiz/Quiz_lobby.dart';
import 'package:graficos_dinamicos/Firebase/service/quiz_service.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final TextEditingController pinController = TextEditingController();
  final QuizService _quizService = QuizService();
  bool _isLoading = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _unirseAlQuiz() async {
    final pin = pinController.text.trim();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Debes ingresar un PIN")),
      );
      return;
    }

    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ El PIN debe tener 6 dígitos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sessionDoc = await _quizService.buscarSessionPorPin(pin);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (sessionDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("❌ No se encontró ninguna sesión con ese PIN")),
        );
        return;
      }

      final sessionId = sessionDoc.id;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizLobby(sessionId: sessionId, pin: pin),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al buscar el Quiz: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: AdBannerWrapper(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text(
              "Electro Quiz",
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          body: Center(
            child: SizedBox(
              width: 350,
              height: 440,
              child: Card(
                shadowColor: Colors.black,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.supervised_user_circle_rounded,
                          size: 60),
                      const SizedBox(height: 20),
                      const Text(
                        "Unirse a un Quiz",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Ingresa el PIN proporcionado por tu docente",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: pinController,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: 'Ingrese el PIN de 6 dígitos',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () => _unirseAlQuiz(),
                              style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.blue),
                              ),
                              child: const Text(
                                "Unirse al Quiz",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
