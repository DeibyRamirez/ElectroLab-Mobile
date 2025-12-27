import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/models/paquete.dart';


class PackageCard extends StatelessWidget {
  final Paquete paquete;
  final VoidCallback onBuy;

  const PackageCard({
    super.key,
    required this.paquete,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("${paquete.monedas} Monedas"),
        trailing: ElevatedButton(
          onPressed: onBuy,
          child: const Text("Comprar"),
        ),
      ),
    );
  }
}
