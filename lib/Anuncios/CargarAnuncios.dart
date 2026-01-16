// ignore_for_file: avoid_print, file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class CargarAnuncios {
  // 1. DICCIONARIO DE IDS (Agrega aquí tus IDs reales de AdMob)
  static Map<String, String> get ids {
    if (Platform.isAndroid) {
      return {
        'banner_prefijos': 'ca-app-pub-1195123066634718/4895585448',
        'banner_principal': 'ca-app-pub-1195123066634718/2786822070',
        'banner_quiz': 'ca-app-pub-1195123066634718/6208667118',
        'banner_estilo_libre': 'ca-app-pub-1195123066634718/1877962875',
        'inter_ar': 'ca-app-pub-1195123066634718/5019708529',
        'inter_guardar': 'ca-app-pub-1195123066634718/6953120186',
        'inter_estilo_libre': 'ca-app-pub-1195123066634718/8251799536',
      };
    } else {
      // IDs para iOS
      return {
        'banner_home': 'ca-app-pub-1195123066634718/2786822070',
        'banner_perfil': 'ca-app-pub-1195123066634718/2786822070',
        'inter_login': 'ca-app-pub-1195123066634718/6953120186',
      };
    }
  }

  /// --- LÓGICA PARA BANNER ---
  /// Ahora acepta un [posicion] para saber qué ID usar
  static BannerAd crearBanner(String posicion) {
    return BannerAd(
      adUnitId: ids[posicion] ?? ids.values.first, // Usa uno por defecto si falla
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Error al cargar banner ($posicion): $error');
        },
      ),
    );
  }

  /// --- LÓGICA PARA INTERSTICIAL ---
  static Future<void> mostrarIntersticial(String posicion) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['quitarAnuncios'] ?? false) return;
        }
      }

      InterstitialAd.load(
        adUnitId: ids[posicion] ?? ids['inter_login']!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => ad.show(),
          onAdFailedToLoad: (error) => print('Error en $posicion: $error'),
        ),
      );
    } catch (e) {
      print("Error: $e");
    }
  }
}