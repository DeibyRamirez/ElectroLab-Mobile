// ignore_for_file: file_names, use_super_parameters

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'CargarAnuncios.dart'; // Tu clase actual

class AdBannerWrapper extends StatefulWidget {
  final Widget child; // La pantalla que quieres mostrar

  const AdBannerWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<AdBannerWrapper> createState() => _AdBannerWrapperState();
}

class _AdBannerWrapperState extends State<AdBannerWrapper> {
  BannerAd? _miBanner;
  bool _isLoaded = false;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  void _initAd() {
    _miBanner = CargarAnuncios.crearBanner("banner_home")
      ..load().then((_) {
        if (mounted) setState(() => _isLoaded = true);
      });
  }

  @override
  void dispose() {
    _miBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) return widget.child;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("usuarios").doc(_uid).snapshots(),
      builder: (context, snapshot) {
        bool userHasAds = true;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userHasAds = !(data['quitarAnuncios'] ?? false);
        }

        return Scaffold(
          body: widget.child, // Aquí se muestra tu pantalla (ej. tabla_prefijos)
          bottomNavigationBar: (userHasAds && _isLoaded)
              ? Container(
                  height: _miBanner!.size.height.toDouble(),
                  width: _miBanner!.size.width.toDouble(),
                  child: AdWidget(ad: _miBanner!),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}