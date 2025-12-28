// ignore_for_file: file_names, use_super_parameters, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/billing/products.dart';
import 'package:graficos_dinamicos/Quiz/Quiz.dart';
import 'package:graficos_dinamicos/others/Creadores.dart';
import 'package:graficos_dinamicos/Estilo_Libre/Estilo_Libre.dart';
import 'package:graficos_dinamicos/data/Lineal_datos.dart';
import 'package:graficos_dinamicos/data/T_Equilatero_datos.dart';
import 'package:graficos_dinamicos/data/T_Rectangulo_datos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

import 'Firebase/login_screen.dart';
import 'Firebase/pages/historial_page.dart';

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BannerAd? _miBanner;
  bool _isLoaded = false;

  // Variables para controlar el gesto de deslizamiento mejorado
  double _dragStartX = 0.0;
  double _currentDragX = 0.0;
  bool _isDragging = false;

  // Constantes para configurar la sensibilidad del gesto
  static const double _minDragDistance = 50.0; // Distancia mínima para activar
  static const double _maxStartPosition =
      100.0; // Máximo desde el borde izquierdo
  static const double _velocityThreshold =
      200.0; // Velocidad mínima para activación rápida

  // ✅ Video del AppBar
  late final VideoPlayerController _controladorLogo;
  bool _logoListo = false;

  final List<Map<String, dynamic>> ejemplos = [
    {
      'nombre': 'Lineal',
      'imagen': 'assets/Lineal.jpg',
      'widget': const Lineal_datos(),
    },
    {
      'nombre': 'Triángulo Rectángulo',
      'imagen': 'assets/Triangulo_Rectangulo.jpg',
      'widget': const T_Rectangulo_datos(),
    },
    {
      'nombre': 'Triángulo Equilátero',
      'imagen': 'assets/Equilatero.jpg',
      'widget': const T_Equilatero_datos(),
    },
    {
      'nombre': 'Estilo Libre',
      'imagen': 'assets/plano-cartesiano-v2.jpg',
      'widget': const Estilo_Libre(),
    }
  ];

  Future<void> _cerrarSesion() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _openExample(Map<String, dynamic> ejemplo) {
    final Widget destino = ejemplo['widget'] as Widget;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destino),
    );
  }

  void _mostrarPerfilPopup(BuildContext context) {
    final RenderBox appBarBox =
        context.findRenderObject() as RenderBox; // Posición AppBar
    final Offset offset = appBarBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent, // sin fondo oscuro
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: offset.dy + kToolbarHeight,
              right: 10, // Margen derecho desde el borde de la pantalla
              width: MediaQuery.of(context).size.width * 0.45, // Ancho ajustado
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.displayName ?? 'Usuario',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _cerrarSesion,
                        icon: const Icon(Icons.logout),
                        label: const Text("Cerrar sesión"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Función mejorada para manejar el inicio del gesto horizontal
  void _handlePanStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _currentDragX = _dragStartX;
    _isDragging = true;
  }

  // Función mejorada para manejar la actualización del gesto horizontal
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _currentDragX = details.globalPosition.dx;
    final double dragDistance = _currentDragX - _dragStartX;

    if (_dragStartX <= _maxStartPosition || dragDistance > _minDragDistance) {
      if (dragDistance > 0) {
        if (dragDistance >= _minDragDistance) {
          _openDrawerSmoothly();
          _isDragging = false;
        }
      }
    }
  }

  // Función mejorada para manejar el final del gesto horizontal
  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final double dragDistance = _currentDragX - _dragStartX;
    final double velocity = details.velocity.pixelsPerSecond.dx;

    if ((dragDistance >= _minDragDistance) ||
        (velocity >= _velocityThreshold && dragDistance > 20) ||
        (_dragStartX <= _maxStartPosition && dragDistance > 30)) {
      _openDrawerSmoothly();
    }

    _isDragging = false;
    _dragStartX = 0.0;
    _currentDragX = 0.0;
  }

  void _openDrawerSmoothly() {
    if (_scaffoldKey.currentState?.isDrawerOpen == false) {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  void initState() {
    super.initState();

    // 1) Banner ads
    _miBanner = CargarAnuncios.crearBanner()
      ..load().then((_) {
        if (!mounted) return;
        setState(() => _isLoaded = true);
      });

    // 2) Video AppBar
    _controladorLogo = VideoPlayerController.asset(
        'assets/videos/ElectroLab_Logo_Animation_Fondo_Azul.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _logoListo = true);
        _controladorLogo.play();
      });
  }

  @override
  void dispose() {
    _miBanner?.dispose();
    _controladorLogo.dispose();
    super.dispose();
  }

  Widget _tituloAppBar() {
    // Alto “bonito” dentro de AppBar
    final double alto = kToolbarHeight * 1.2;

    if (!_logoListo) {
      // Fallback mientras carga (opcional)
      return Image.asset(
        'assets/imagenes/ElectroLab_Logo_Azul_Fondo_Transparente.png',
        height: alto,
        fit: BoxFit.contain,
      );
    }

    return SizedBox(
      height: alto,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _controladorLogo.value.size.width,
          height: _controladorLogo.value.size.height,
          child: VideoPlayer(_controladorLogo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 260,
                        height: 84,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          //Imagen del Panel Lateral
                          image: const DecorationImage(
                            image: AssetImage(
                                'assets/imagenes/ElectroLab_Logo_Azul_Fondo_Transparente.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón Historial
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historial'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistorialPage()),
                    );
                  },
                ),

                // Botón Unirse a quiz
                ListTile(
                  leading: const Icon(Icons.computer),
                  title: const Text('Quiz'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Quiz()),
                    );
                  },
                ),

                // Botón Recargar Creditos
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined),
                  title: const Text('Recargar'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Recargar()),
                    );
                  },
                ),

                // Botón Creadores
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sobre'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Creadores()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  tooltip: "Perfil",
                  onPressed: () => _mostrarPerfilPopup(context),
                  icon: CircleAvatar(
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                );
              },
            ),
          ],
          title: _tituloAppBar(),
          centerTitle: true,
          backgroundColor: const Color(0xFF2196F3),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Selecciona el Diagrama de tu ejercicio",
                  style: TextStyle(fontSize: 19),
                ),
                const SizedBox(height: 10),
                Column(
                  children: ejemplos.map((ejemplo) {
                    return EjemploCard(
                      nombre: ejemplo['nombre'] as String,
                      imagen: ejemplo['imagen'] as String,
                      onTap: () => _openExample(ejemplo),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _isLoaded
            ? Container(
                height: _miBanner!.size.height.toDouble(),
                width: _miBanner!.size.width.toDouble(),
                child: AdWidget(ad: _miBanner!),
              )
            : null,
      ),
    );
  }
}

class EjemploCard extends StatelessWidget {
  final String nombre;
  final String imagen;
  final VoidCallback? onTap;

  const EjemploCard({
    Key? key,
    required this.nombre,
    required this.imagen,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(imagen),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child:
                  const Text('Ingresar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
