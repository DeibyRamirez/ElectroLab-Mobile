// Podio.dart actualizado con fixes:
// 1. No cambia código para análisis, ya que el fix está en QuizResponder. Pero agregué chequeo de tipos en filter.
// 2. Quité botón "Volver", override back button, y WillPopScope para gestos sistema.
// 3. Para responsive: En _buildStatCard, Text(title) con maxLines: 2, softWrap: true, textAlign: center.
//    Ajusté childAspectRatio: 1.2 en GridView para más altura.

// ignore_for_file: file_names, avoid_types_as_parameter_names, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Quiz/Quiz.dart'; // Importa Quiz para redirección

class Podio extends StatefulWidget {
  final String sessionId;

  const Podio({super.key, required this.sessionId});

  @override
  State<Podio> createState() => _PodioState();
}

class _PodioState extends State<Podio> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic>? quiz;
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic> results = {
    'totalParticipants': 0,
    'averageScore': 0,
    'topStudents': [],
    'questions': [],
  };
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => loading = true);
    try {
      // 1. Obtener sesión
      final sessionRef = _db.collection("sessions").doc(widget.sessionId);
      final sessionSnap = await sessionRef.get();
      if (!sessionSnap.exists) {
        _redirectToQuiz();
        return;
      }
      final sessionData = sessionSnap.data()!;

      // 2. Obtener datos del quiz
      final quizRef = _db.collection("quizzes").doc(sessionData["quizId"]);
      final quizSnap = await quizRef.get();
      if (quizSnap.exists) {
        setState(() => quiz = quizSnap.data());
      }

      // 3. Cargar preguntas
      final q = _db
          .collection("questions")
          .where("quizId", isEqualTo: sessionData["quizId"]);
      final questionsSnap = await q.get();
      final questionsData = questionsSnap.docs.map((d) {
        return {
          'id': d.id,
          'question': d.data()["question"] ?? "",
          ...d.data(),
        };
      }).toList();
      setState(() => questions = questionsData);

      // 4. Obtener respuestas de usuarios
      final userAnswersRef = sessionRef.collection("userAnswers");
      final userAnswersSnap = await userAnswersRef.get();
      if (userAnswersSnap.docs.isEmpty) {
        setState(() => loading = false);
        return;
      }

      final userResults = <Map<String, dynamic>>[];
      List<Map<String, dynamic>> allAnswers = [];

      for (var docSnap in userAnswersSnap.docs) {
        final data = docSnap.data();
        userResults.add({
          'name': data["playerName"],
          'totalScore': data["totalScore"] ?? 0,
          'answers': data["answers"] ?? [],
        });
        allAnswers
            .addAll(List<Map<String, dynamic>>.from(data["answers"] ?? []));
      }

      // 5. Estadísticas globales
      final totalParticipants = userResults.length;
      final totalScoreSum =
          userResults.fold(0, (sum, u) => sum + (u['totalScore'] as int));
      final averageScore = totalParticipants > 0
          ? (totalScoreSum / totalParticipants).round()
          : 0;
      final topStudents = [...userResults]
        ..sort((a, b) =>
            (b['totalScore'] as int).compareTo(a['totalScore'] as int))
        ..take(3);

      // 6. Análisis por pregunta (agregado chequeo si 'correct' no es bool)
      final questionStats = questionsData.map((q) {
        final questionAnswers =
            allAnswers.where((a) => a["questionId"] == q['id']).toList();
        final totalAnswers = questionAnswers.length;
        final correctAnswers = questionAnswers.where((a) {
          final correctVal = a["correct"];
          return correctVal == true ||
              correctVal == 'true'; // Chequeo extra por si es string
        }).length;
        final correctPercentage = totalAnswers > 0
            ? ((correctAnswers / totalAnswers) * 100).round()
            : 0;

        return {
          'id': q['id'],
          'question': q['question'],
          'totalAnswers': totalAnswers,
          'correctAnswers': correctAnswers,
          'correctPercentage': correctPercentage,
        };
      }).toList();

      // 7. Guardar resultados
      setState(() {
        results = {
          'totalParticipants': totalParticipants,
          'averageScore': averageScore,
          'topStudents': topStudents,
          'questions': questionStats,
        };
        loading = false;
      });
    } catch (err) {
      print("Error cargando resultados: $err");
      setState(() => loading = false);
    }
  }

  void _redirectToQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Quiz()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _redirectToQuiz();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title:  const Text("Resultados del Quiz", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _redirectToQuiz,
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : results['totalParticipants'] == 0
                ? Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("No hay resultados disponibles",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text("Nadie respondió este quiz."),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _redirectToQuiz,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text("Volver al inicio"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(quiz?["title"] ?? "Quiz sin título",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Código: ${widget.sessionId}",
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 32),

                          // Podio de Ganadores
                            if ((results['topStudents'] as List)
                                .isNotEmpty) ...[
                              const Text(
                                "Podio de Ganadores",
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 220, // altura del carrusel
                                child: PageView.builder(
                                  itemCount: (results['topStudents'] as List)
                                      .length
                                      .clamp(0, 3), // máx. 3
                                  controller:
                                      PageController(viewportFraction: 0.8),
                                  itemBuilder: (context, index) {
                                    final student = (results['topStudents']
                                        as List<Map<String, dynamic>>)[index];
                                    final position = "${index + 1}°";
                                    Color color;
                                    IconData icon;

                                    if (index == 0) {
                                      color = Colors.yellow[700]!;
                                      icon = Icons.emoji_events_outlined;
                                    } else if (index == 1) {
                                      color = Colors.grey;
                                      icon = Icons.emoji_events;
                                    } else {
                                      color = Colors.orange;
                                      icon = Icons.emoji_events;
                                    }

                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: _buildPodiumItem(
                                        icon: icon,
                                        color: color,
                                        position: position,
                                        name: student['name'],
                                        score: student['totalScore'],
                                        isFirst: index == 0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  "Desliza para ver los puestos →",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                          // Estadísticas globales
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                1.2, // Ajustado para más altura y evitar overflow
                            children: [
                              _buildStatCard(
                                title: "Participantes",
                                value: "${results['totalParticipants']}",
                                icon: Icons.people,
                              ),
                              _buildStatCard(
                                title: "Promedio de Puntaje",
                                value: "${results['averageScore']}",
                                icon: Icons.check_circle,
                              ),
                              _buildStatCard(
                                title: "Preguntas Totales",
                                value: "${questions.length}",
                                icon: Icons.timer,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Análisis por pregunta
                          // Card(
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(16.0),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         const Text("Análisis por Pregunta",
                          //             style: TextStyle(
                          //                 fontSize: 20,
                          //                 fontWeight: FontWeight.bold)),
                          //         const SizedBox(height: 8),
                          //         const Text("Porcentaje de aciertos",
                          //             style: TextStyle(color: Colors.grey)),
                          //         const SizedBox(height: 16),
                          //         ...((results['questions']
                          //                 as List<Map<String, dynamic>>)
                          //             .map((q) {
                          //           final percentage =
                          //               q['correctPercentage'] as int;
                          //           Color badgeColor = percentage >= 80
                          //               ? Colors.green
                          //               : percentage >= 50
                          //                   ? Colors.blue
                          //                   : Colors.red;
                          //           return Padding(
                          //             padding:
                          //                 const EdgeInsets.only(bottom: 16.0),
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 Row(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.spaceBetween,
                          //                   children: [
                          //                     Expanded(
                          //                       child: Column(
                          //                         crossAxisAlignment:
                          //                             CrossAxisAlignment.start,
                          //                         children: [
                          //                           Text(
                          //                             q['question'],
                          //                             style: const TextStyle(
                          //                                 fontWeight:
                          //                                     FontWeight.w500),
                          //                           ),
                          //                           Text(
                          //                             "${q['correctAnswers']}/${q['totalAnswers']} correctas",
                          //                             style: const TextStyle(
                          //                                 color: Colors.grey,
                          //                                 fontSize: 12),
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ),
                          //                     Chip(
                          //                       label: Text("$percentage%"),
                          //                       backgroundColor: badgeColor,
                          //                     ),
                          //                   ],
                          //                 ),
                          //                 const SizedBox(height: 4),
                          //                 LinearProgressIndicator(
                          //                     value: percentage / 100),
                          //               ],
                          //             ),
                          //           );
                          //         })),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required IconData icon,
    required Color color,
    required String position,
    required String name,
    required int score,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: isFirst ? 80 : 60,
            height: isFirst ? 80 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white, size: isFirst ? 40 : 30),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(position,
                      style: TextStyle(
                          fontSize: isFirst ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("$score pts",
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
