// ignore_for_file: avoid_print, file_names

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class CargarAnuncios {
  // IDs de prueba de Google (Cámbialos por los tuyos en producción)
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

  /// --- LÓGICA PARA INTERSTICIAL (Pantalla Completa) ---
  static void mostrarIntersticial() {
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
  }
}