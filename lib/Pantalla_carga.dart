// ignore_for_file: file_names, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Principal.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graficos_dinamicos/Firebase/login_screen.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga>
    with TickerProviderStateMixin {
  // Controladores de animación para diferentes elementos de la pantalla
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late AnimationController _progressController;
  late AnimationController _transitionController;

  // Animaciones que controlan el progreso de las animaciones
  late Animation<double> _backgroundAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _transitionAnimation;

  // Lista de partículas para efectos visuales
  final List<Particle> _particles = [];

  // Controlador para reproducir un video
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // Configura el modo de UI del sistema a inmersivo, ocultando la barra de estado y la barra de navegación.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Inicializa los controladores necesarios para la animación.
    _initializeControllers();

    // Inicializa las animaciones que se utilizarán en la pantalla.
    _initializeAnimations();

    // Genera partículas para efectos visuales.
    // Moved to didChangeDependencies

    // Inicializa el video que se mostrará en la pantalla.
    _initializeVideo();

    // Inicia la secuencia de animación.
    _startAnimationSequence();
  }

  void _initializeControllers() {
    // Controlador para la animación de fondo, con una duración de 2 segundos.
    _backgroundController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    // Controlador para la animación de partículas, con una duración de 10 segundos y que se repite indefinidamente.
    _particlesController =
        AnimationController(duration: const Duration(seconds: 5), vsync: this)
          ..repeat();

    // Controlador para la animación de progreso, con una duración de 5 segundos.
    _progressController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    // Controlador para la animación de transición, con una duración de 2 segundos.
    _transitionController =
        AnimationController(duration: const Duration(seconds: 0), vsync: this);
  }

  void _initializeAnimations() {
    // Inicializa las animaciones de fondo, progreso y transición con curvas específicas.
    _backgroundAnimation =
        CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut);
    _progressAnimation =
        CurvedAnimation(parent: _progressController, curve: Curves.easeInOut);
    _transitionAnimation = CurvedAnimation(
        parent: _transitionController, curve: Curves.easeInOutCubic);
  }

  void _generateParticles(Size screenSize) {
    // Genera numero de partículas y las añade a la lista _particles.
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(screenSize));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Genera partículas para efectos visuales.
    _generateParticles(MediaQuery.of(context).size);
  }

  void _initializeVideo() {
    // Inicializa el controlador de video con un archivo de video local y configura el video para que se reproduzca en bucle.
    _videoController = VideoPlayerController.asset(
        'assets/videos/ElectroLab_Logo_Animation_Fondo_Blanco.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  void _startAnimationSequence() {
    // Inicia las animaciones de fondo y progreso.
    _backgroundController.forward();
    _progressController.forward();

    // Inicia un temporizador que espera 5000 milisegundos (5 segundos) antes de ejecutar el código dentro de la función.
    Timer(const Duration(milliseconds: 3000), () {
      // Avanza el controlador de transición (_transitionController) para iniciar una animación.
      _transitionController.forward();
    });

    // Inicia un segundo temporizador que espera 6000 milisegundos (6 segundos) antes de ejecutar el código dentro de la función.
    Timer(const Duration(milliseconds: 3000), () {
      final user = FirebaseAuth.instance.currentUser;

      Widget nextPage;
      if (user != null) {
        // Usuario ya logueado
        nextPage = const Principal();
      } else {
        // Usuario no logueado
        nextPage = const LoginScreen();
      }
      // Navega a la pantalla principal (Principal) reemplazando la pantalla actual.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          // Define la pantalla de destino (Principal) y las animaciones de transición.
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Utiliza una transición de desvanecimiento (FadeTransition) para la animación.
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    // Restablece el modo de la interfaz de usuario del sistema a 'edgeToEdge'
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Libera los recursos utilizados por _backgroundController
    _backgroundController.dispose();

    // Libera los recursos utilizados por _particlesController
    _particlesController.dispose();

    // Libera los recursos utilizados por _progressController
    _progressController.dispose();

    // Libera los recursos utilizados por _transitionController
    _transitionController.dispose();

    // Libera los recursos utilizados por _videoController
    _videoController.dispose();

    // Llama al método dispose de la clase padre para realizar cualquier limpieza adicional
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final Size screenSize = MediaQuery.of(context).size;

    // Calcular el tamaño del círculo de carga
    final double circleRadius =
        min(screenSize.width, screenSize.height) / 2 - 40;

    // Calcular el tamaño del card para que sea cuadrado y proporcional al círculo
    // Usamos 0.7 para que el card ocupe el 70% del diámetro del círculo
    final double cardSize = circleRadius * 1.4;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo animado
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_backgroundAnimation.value),
                child: Container(),
              );
            },
          ),
          // Partículas animadas
          AnimatedBuilder(
            animation: _particlesController,
            builder: (context, child) {
              return CustomPaint(
                painter:
                    ParticlePainter(_particles, _particlesController.value),
                child: Container(),
              );
            },
          ),
          // Video del logo en Card
          // Video del logo en Card
          Center(
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: cardSize,
                height:
                    cardSize, // Ahora usamos el mismo valor para altura y anchura
                padding: EdgeInsets.all(cardSize * 0.05),
                child: _videoController.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ),
          // Barra de progreso personalizada
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ProgressPainter(
                      progress: _progressAnimation.value,
                      circleRadius: circleRadius),
                );
              },
            ),
          ),
          // Transición final
          AnimatedBuilder(
            // El AnimatedBuilder es un widget que reconstruye su hijo cada vez que cambia la animación.
            animation: _transitionAnimation,
            builder: (context, child) {
              // El builder define cómo se debe construir el widget en cada frame de la animación.
              return ShaderMask(
                // ShaderMask aplica un shader a su hijo, en este caso, un gradiente radial.
                shaderCallback: (rect) {
                  // shaderCallback define el shader que se aplicará.
                  return RadialGradient(
                    // RadialGradient crea un gradiente radial.
                    center: Alignment
                        .center, // El centro del gradiente está en el centro del contenedor.
                    radius: _transitionAnimation.value *
                        1.5, // El radio del gradiente cambia con la animación.
                    colors: const [
                      Colors.transparent,
                      Colors.white
                    ], // Los colores del gradiente.
                    stops: const [
                      0.0,
                      1.0
                    ], // Las posiciones de los colores en el gradiente.
                  ).createShader(
                      rect); // Crea el shader con el rectángulo del contenedor.
                },
                blendMode: BlendMode
                    .srcOut, // Define cómo se mezclan los colores del shader con el hijo.
                child: Container(
                  // El hijo del ShaderMask es un contenedor transparente.
                  color: Colors.transparent,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double progress;

  BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Crea un objeto Paint con estilo de relleno
    final paint = Paint()..style = PaintingStyle.fill;

    // Define un rectángulo que cubre todo el tamaño del canvas
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Crea un gradiente lineal que va de la esquina superior izquierda a la esquina inferior derecha
    // Los colores del gradiente cambian dependiendo del valor de 'progress'
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        // Interpola entre azul oscuro y azul claro según el progreso
        Color.lerp(Colors.blue[900], Colors.blue[300], progress)!,
        // Interpola entre azul medio y azul muy claro según el progreso
        Color.lerp(Colors.blue[500], Colors.blue[100], progress)!,
        // Interpola entre azul claro y blanco según el progreso
        Color.lerp(Colors.blue[100], Colors.white, progress)!,
      ],
      stops: const [
        0.0,
        0.5,
        1.0
      ], // Define las posiciones de los colores en el gradiente
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  late double x; // Coordenada x de la partícula
  late double y; // Coordenada y de la partícula
  late double speed; // Velocidad de la partícula
  late double radius; // Radio de la partícula
  late Color color; // Color de la partícula

  Particle(Size screenSize) {
    reset(screenSize); // Inicializa la partícula con valores aleatorios
    y = Random().nextDouble() *
        screenSize
            .height; // Asigna una posición y aleatoria en toda la pantalla
  }

  void reset(Size screenSize) {
    x = Random().nextDouble() *
        screenSize.width; // Asigna una posición x aleatoria en toda la pantalla
    y = 0; // Reinicia la posición y a 0
    speed = 1 +
        Random().nextDouble() * 3; // Asigna una velocidad aleatoria entre 1 y 5
    radius = 10 +
        Random().nextDouble() * 10; // Asigna un radio aleatorio entre 1 y 5
    color = Random().nextBool()
        ? Colors.red.withOpacity(0.6)
        : Colors.blue.withOpacity(0.6);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles; // Lista de partículas que se van a dibujar.
  final double
      animation; // Valor de animación que se usa para modificar el tamaño de las partículas.

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y += particle.speed;
      if (particle.y > size.height) {
        particle.reset(size);
      }

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      // Dibujamos un círculo con un borde más claro para simular un efecto de brillo
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius * (0.8 + 0.2 * sin(animation * 2 * pi)),
        paint,
      );

      // Añadimos un borde más claro
      final borderPaint = Paint()
        ..color = particle.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.radius * (0.8 + 0.2 * sin(animation * 2 * pi)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      true; // Indica que siempre se debe repintar.
}

// Modificar la clase ProgressPainter para aceptar el radio del círculo
class ProgressPainter extends CustomPainter {
  final double progress;
  final double circleRadius;

  ProgressPainter({
    required this.progress,
    required this.circleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, circleRadius, paint);

    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final progressRect = Rect.fromCircle(center: center, radius: circleRadius);
    canvas.drawArc(
        progressRect, -pi / 2, 2 * pi * progress, false, progressPaint);

    // Efecto de brillo
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawArc(progressRect, -pi / 2, 2 * pi * progress, false, glowPaint);

    // Puntos de progreso
    const totalPoints = 20;
    for (int i = 0; i < totalPoints; i++) {
      final angle = 2 * pi * (i / totalPoints) - (pi / 2);
      final pointProgress = (progress * totalPoints).floor();

      final pointPaint = Paint()
        ..color =
            i <= pointProgress ? Colors.white : Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final pointCenter = Offset(
        center.dx + (circleRadius + 15) * cos(angle),
        center.dy + (circleRadius + 15) * sin(angle),
      );

      canvas.drawCircle(pointCenter, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
