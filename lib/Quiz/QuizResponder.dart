// ignore_for_file: use_build_context_synchronously, file_names, deprecated_member_use, unused_element, unused_local_variable, unnecessary_cast, curly_braces_in_flow_control_structures
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Quiz/Podio.dart';

class QuizResponder extends StatefulWidget {
  final String pin;

  const QuizResponder(
      {super.key, required this.pin, required String sessionId});

  @override
  State<QuizResponder> createState() => _QuizResponderState();
}

class _QuizResponderState extends State<QuizResponder> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? session;
  List<Map<String, dynamic>> questions = [];
  Map<String, dynamic>? currentQuestion;
  int currentQuestionIndex = 0;
  int timeLeft = 0;
  bool answered = false;
  bool? isCorrect;
  int totalScore = 0;
  String? selectedOption;
  Timer? timer;
  final TextEditingController _numericalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listenSession();
  }

  /// 🔹 Escuchar los cambios en la sesión
  void _listenSession() {
    _db.collection("sessions").doc(widget.pin).snapshots().listen((snap) {
      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sesión no encontrada.")),
        );
        Navigator.pop(context);
        return;
      }

      session = snap.data();
      final newIndex = (session?["currentQuestion"] ?? 0).toInt();

      if (session?["status"] == "ended") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Podio(sessionId: widget.pin)),
        );
      } else {
        setState(() => currentQuestionIndex = newIndex);
        _loadQuestions();
      }
    });
  }

  /// 🔹 Cargar preguntas
  Future<void> _loadQuestions() async {
    if (session == null || session?["quizId"] == null) return;

    final qSnap = await _db
        .collection("questions")
        .where("quizId", isEqualTo: session!["quizId"])
        .orderBy("createdAt")
        .get();

    questions = qSnap.docs
        .map((d) => {
              'id':
                  d.id, // Añadido: ID del documento para coincidir en análisis
              ...d.data() as Map<String, dynamic>,
            })
        .toList();

    if (questions.isNotEmpty) {
      _setCurrentQuestion();
    }
  }

  /// 🔹 Actualizar pregunta actual
  void _setCurrentQuestion() {
    if (currentQuestionIndex < 0 || currentQuestionIndex >= questions.length)
      return;

    final question = questions[currentQuestionIndex];
    setState(() {
      currentQuestion = question;
      timeLeft = (question["timeLimit"] ?? 30);
      answered = false;
      isCorrect = null;
      selectedOption = null;
      _numericalController.clear();
    });

    _startTimer();
  }

  /// 🔹 Temporizador
  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        if (!answered) {
          _sendAnswer(""); // Respuesta vacía por tiempo
        }
      }
    });
  }

  /// 🔹 Enviar respuesta
  Future<void> _sendAnswer(String answerId) async {
    final user = _auth.currentUser;
    if (user == null || currentQuestion == null) return;

    setState(() {
      answered = true;
      selectedOption = answerId;
    });

    bool correct = false;
    String answerText = answerId;

    final questionType = currentQuestion!["questionType"];

    if (questionType == "multiple-choice" || questionType == "true-false") {
      final options = currentQuestion!["options"] ?? [];
      final selectedOptionObj = options.firstWhere(
        (opt) => opt["id"] == answerId,
        orElse: () => {},
      );
      answerText = selectedOptionObj["text"] ?? answerId;
      correct = currentQuestion!["correctOption"] == answerId;
    } else if (questionType == "numerical") {
      final correctValue =
          double.tryParse(currentQuestion!["correctValue"].toString()) ?? 0;
      final userValue = double.tryParse(answerId) ?? 0;
      correct = userValue == correctValue;
    }

    setState(() => isCorrect = correct);

    // const int maxPoints = 1000;
    // final int timeLimit = currentQuestion!["timeLimit"] ?? 30;
    // final int pointsEarned =
    //     correct ? ((timeLeft / timeLimit) * maxPoints).round() : 0;
    final int maxPoints = currentQuestion?["points"] ?? 1000;
    final int timeLimit = currentQuestion!["timeLimit"] ?? 30;
    final int pointsEarned =
        correct ? ((timeLeft / timeLimit) * maxPoints).round() : 0;

    totalScore += pointsEarned;

    final answerData = {
      "questionId": currentQuestion!["id"],
      "question": currentQuestion!["question"],
      "answerId": answerId,
      "answerText": answerText,
      "correctOptionId": currentQuestion!["correctOption"],
      "correct": correct,
      "pointsEarned": pointsEarned,
      "answeredAt": DateTime.now(),
      "timeLeft": timeLeft,
    };

    await _db
        .collection("sessions")
        .doc(widget.pin)
        .collection("userAnswers")
        .doc(user.uid)
        .set({
      "playerId": user.uid,
      "playerName": user.displayName,
      "answers": FieldValue.arrayUnion([answerData]),
      "totalScore": totalScore,
      "lastUpdated": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Obtener color según el tiempo restante
  Color _getTimerColor() {
    final totalTime = currentQuestion!["timeLimit"] ?? 30;
    final ratio = timeLeft / totalTime;

    if (ratio > 0.6) return Colors.green;
    if (ratio > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    timer?.cancel();
    _numericalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                "Cargando pregunta...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isNumerical = currentQuestion!["questionType"] == "numerical";
    final totalQuestions = questions.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pregunta ${currentQuestionIndex + 1}/$totalQuestions",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "PIN: ${widget.pin}",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información
            _buildQuestionHeader(),
            const SizedBox(height: 24),

            // Pregunta
            _buildQuestionCard(),
            const SizedBox(height: 24),

            // Opciones de respuesta
            _buildAnswerSection(isNumerical),
            const SizedBox(height: 24),

            // Temporizador
            _buildTimerSection(),
            const SizedBox(height: 24),

            // Resultado
            if (answered) _buildResultSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.quiz, color: Colors.blue[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Puntuación Actual",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    "$totalScore puntos",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 4),
                  Text(
                    "${currentQuestion!["timeLimit"] ?? 30}s",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentQuestion!["questionType"] == "numerical"
                        ? Icons.numbers
                        : Icons.help_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  currentQuestion!["questionType"] == "numerical"
                      ? "Pregunta Numérica"
                      : "Opción Múltiple",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion!["question"] ?? "Pregunta sin texto",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(bool isNumerical) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNumerical ? "Tu respuesta:" : "Selecciona una opción:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (isNumerical)
              _buildNumericalInput()
            else
              _buildMultipleChoiceOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericalInput() {
    return Column(
      children: [
        TextField(
          controller: _numericalController,
          decoration: InputDecoration(
            labelText: "Ingresa tu respuesta",
            hintText: "Ej: 42, 3.14, etc.",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: Icon(Icons.calculate, color: Colors.blue[700]),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          enabled: !answered,
          onChanged: (val) => selectedOption = val,
        ),
        const SizedBox(height: 16),
        if (!answered)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedOption?.isNotEmpty == true
                  ? () => _sendAnswer(selectedOption!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Enviar Respuesta",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultipleChoiceOptions() {
    final options = currentQuestion!["options"] ?? [];
    final isTrueFalse = currentQuestion!["questionType"] == "true-false";

    return Column(
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final isSelected = selectedOption == opt["id"];

        Color getButtonColor() {
          if (!answered) {
            return isSelected ? Colors.blue[700]! : Colors.grey[200]!;
          }
          if (opt["id"] == currentQuestion!["correctOption"]) {
            return Colors.green;
          }
          if (isSelected && opt["id"] != currentQuestion!["correctOption"]) {
            return Colors.red;
          }
          return Colors.grey[200]!;
        }

        Color getTextColor() {
          if (!answered) {
            return isSelected ? Colors.white : Colors.black87;
          }
          if (opt["id"] == currentQuestion!["correctOption"] || isSelected) {
            return Colors.white;
          }
          return Colors.black87;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: getButtonColor(),
              foregroundColor: getTextColor(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: answered ? null : () => _sendAnswer(opt["id"]),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: getTextColor().withOpacity(0.5)),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 18, color: getTextColor())
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    opt["text"] ?? "Sin texto",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (answered && opt["id"] == currentQuestion!["correctOption"])
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimerSection() {
    final totalTime = currentQuestion!["timeLimit"] ?? 30;
    final progress = timeLeft / totalTime;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tiempo restante",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "$timeLeft segundos",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getTimerColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: _getTimerColor(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    // Calcular los puntos ganados en esta pregunta
    final int pointsEarned = isCorrect!
        ? ((timeLeft / (currentQuestion!["timeLimit"] ?? 30)) * 1000).round()
        : 0;

    return Card(
      color: isCorrect! ? Colors.green[50] : Colors.red[50],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCorrect! ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isCorrect! ? Icons.check_circle : Icons.error,
                  color: isCorrect! ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect!
                            ? "¡Respuesta Correcta!"
                            : "Respuesta Incorrecta",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCorrect! ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   "Ganaste $pointsEarned puntos", // Usar variable fija
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[700],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Puntuación Total: $totalScore puntos",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCorrectAnswerText() {
    if (currentQuestion!["questionType"] == "numerical") {
      return currentQuestion!["correctValue"].toString();
    } else {
      final options = currentQuestion!["options"] ?? [];
      final correctOption = options.firstWhere(
        (opt) => opt["id"] == currentQuestion!["correctOption"],
        orElse: () => {"text": "No disponible"},
      );
      return correctOption["text"];
    }
  }
}
