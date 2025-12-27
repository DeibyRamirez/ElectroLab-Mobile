// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/billing/billig_manager.dart';
import 'package:graficos_dinamicos/models/paquete.dart';
import 'package:graficos_dinamicos/repositories/coins_repository.dart';
import 'package:graficos_dinamicos/widgets/package_card.dart';


class Recarga extends StatefulWidget {
  final String uid;

  const Recarga({super.key, required this.uid});

  @override
  State<Recarga> createState() => _RecargaState();
}

class _RecargaState extends State<Recarga> {
  late BillingManager billingManager;

  final paquetes = [
    Paquete(100, "coins_100"),
    Paquete(250, "coins_250"),
    Paquete(500, "coins_500"),
    Paquete(1200, "coins_1200"),
  ];

  @override
  void initState() {
    super.initState();

    billingManager = BillingManager(
      onPurchaseSuccess: (productId) async {
        switch (productId) {
          case "coins_100":
            await CoinsRepository.addCoins(widget.uid, 100);
            break;
          case "coins_250":
            await CoinsRepository.addCoins(widget.uid, 250);
            break;
          case "coins_500":
            await CoinsRepository.addCoins(widget.uid, 500);
            break;
          case "coins_1200":
            await CoinsRepository.addCoins(widget.uid, 1200);
            break;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Compra exitosa")),
          );
        }
      },
    );

    billingManager.start();
  }

  @override
  void dispose() {
    billingManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recargar monedas")),
      body: ListView(
        children: paquetes
            .map(
              (p) => PackageCard(
                paquete: p,
                onBuy: () => billingManager.buy(p.productoId),
              ),
            )
            .toList(),
      ),
    );
  }
}
