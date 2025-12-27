// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Firebase/service/quiz_service.dart';
import 'package:graficos_dinamicos/Quiz/QuizResponder.dart';

class QuizLobby extends StatefulWidget {
  final String sessionId;
  final String pin;

  const QuizLobby({super.key, required this.sessionId, required this.pin});

  @override
  State<QuizLobby> createState() => _QuizLobbyState();
}

class _QuizLobbyState extends State<QuizLobby>
    with SingleTickerProviderStateMixin {
  final QuizService _quizService = QuizService();
  

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    // Registrar jugador en Firestore + RTDB
    _quizService.unirseAlQuiz(widget.pin);

    _initializeAnimations();

    // 🔹 Detectar cierre de app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(onAppExit: () async {
          await _quizService.salirDelQuiz(widget.pin);
        }),
      );
    });
  }

  void _initializeAnimations() {
    // Controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animación de escala para el icono
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animación de color para el fondo
    _colorAnimation = ColorTween(
      begin: const Color(0xFF6A11CB),
      end: const Color(0xFF2575FC),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  //

  @override
  void dispose() {
    _quizService.salirDelQuiz(widget.pin);
    _animationController.dispose();
    super.dispose();
  }

  /// Registra al jugador en la sesión si no está ya agregado
  // Future<void> _registerPlayer() async {
  //   final user = _auth.currentUser;
  //   if (user == null) {
  //     Maneja si no hay usuario autenticado (ej: redirige a login)
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Debes iniciar sesión para unirte.")),
  //     );
  //     Navigator.pop(context);
  //     return;
  //   }

  //   final sessionSnap =
  //       await _db.collection("sessions").doc(widget.sessionId).get();
  //   if (!sessionSnap.exists) return;

  //   final data = sessionSnap.data() as Map<String, dynamic>;
  //   final players = List<Map<String, dynamic>>.from(
  //       data["players"] ?? []); // Ahora lista de maps

  //   Verifica si ya existe por UID
  //   final alreadyJoined = players.any((p) => p["uid"] == user.uid);
  //   if (!alreadyJoined) {
  //     await _db.collection("sessions").doc(widget.sessionId).update({
  //       "players": FieldValue.arrayUnion([
  //         {
  //           "uid": user.uid,
  //           "name": user.displayName, // Usa displayName de Auth
  //         }
  //       ]),
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _quizService.salirDelQuiz(widget.pin);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo animado con gradiente
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _colorAnimation.value!,
                        _colorAnimation.value!.withOpacity(0.7),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Partículas flotantes en el fondo
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlePainter(animation: _animationController),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _quizService.escucharSession(widget.sessionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        "Sesión no encontrada.",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final status = data["status"] ?? "lobby";
                  final players = (data["players"] as List?) ?? [];

                  // Si el estado es "active", navegar a la pantalla de responder quiz
                  if (status == "active") {
                    Future.microtask(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizResponder(
                              sessionId: widget.sessionId,
                              pin: widget.pin), // Cambiado: pasa sessionId
                        ),
                      );
                    });
                  }

                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tarjeta principal del lobby
                          Card(
                            margin: const EdgeInsets.all(20),
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Icono animado
                                  AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _scaleAnimation.value,
                                        child: const Icon(
                                          Icons.flash_on,
                                          size: 80,
                                          color: Color(0xFF2575FC),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  const Text(
                                    "Lobby del Quiz",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2575FC),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    "Esperando al docente...",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  // PIN con diseño especial
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2575FC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "PIN: ${widget.pin}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Contador de jugadores
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        color: Color(0xFF2575FC),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Jugadores: ${players.length}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  // Estado con indicador visual
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: status == "lobby"
                                              ? Colors.orange
                                              : Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Estado: ${status == "lobby" ? "Esperando" : "Iniciando..."}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: () async {
                              await _quizService.salirDelQuiz(widget.pin);
                              if (mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Salir del Quiz"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                          ),

                          // Lista de jugadores conectados
                          if (players.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Jugadores conectados",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2575FC),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: players.map<Widget>((player) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2575FC)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFF2575FC)
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          player["name"] ?? "Jugador",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor personalizado para las partículas del fondo
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  ParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Crear partículas en posiciones fijas pero con movimiento sutil
    final particles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.6, size.height * 0.9),
    ];

    // Aplicar movimiento oscilatorio a las partículas
    final offset = (animation.value - 0.5) * 10;

    for (final particle in particles) {
      canvas.drawCircle(
        Offset(particle.dx + offset, particle.dy + offset),
        15 + 5 * animation.value,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function() onAppExit;

  LifecycleEventHandler({required this.onAppExit});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      onAppExit();
    }
  }
}
