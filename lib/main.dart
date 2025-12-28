import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:graficos_dinamicos/Pantalla_carga.dart';
import 'Firebase/config/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase aquí
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PantallaCarga(),
        // routes: {
        //   '/login': (context) => LoginScreen(), // tu pantalla de login
        //   '/principal': (context) => Principal(), // opcional
        // },
      ),
    );
  }
}
