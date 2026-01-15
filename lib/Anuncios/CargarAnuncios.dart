// ignore_for_file: avoid_print, file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class CargarAnuncios {
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/6300978111';

  /// --- LÓGICA PARA BANNER ---
  static BannerAd crearBanner() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Error al cargar banner: $error');
        },
      ),
    );
  }

  /// --- LÓGICA PARA INTERSTICIAL CON VERIFICACIÓN DE PAGO ---
  static Future<void> mostrarIntersticial() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // 1. Si no hay usuario, por seguridad podrías mostrar anuncio o no. 
      // Aquí verificamos si tiene el beneficio:
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          bool quitarAnuncios = data['quitarAnuncios'] ?? false;

          // 2. SI EL USUARIO PAGÓ, SALIMOS DE LA FUNCIÓN Y NO HACEMOS NADA
          if (quitarAnuncios) {
            print("Usuario con Premium: Intersticial omitido.");
            return;
          }
        }
      }

      // 3. SI NO HA PAGADO (O NO HAY DATOS), CARGAMOS Y MOSTRAMOS
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.show();
          },
          onAdFailedToLoad: (error) {
            print('Error al cargar intersticial: $error');
          },
        ),
      );
    } catch (e) {
      print("Error verificando estatus de anuncios: $e");
    }
  }
}