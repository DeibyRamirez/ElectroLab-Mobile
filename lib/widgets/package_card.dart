import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/billing/products.dart';

class PackageCard extends StatelessWidget {
  final int creditos;
  final VoidCallback onBuy;
  final AppProduct product;

  const PackageCard({
    super.key,
    required this.creditos,
    required this.onBuy,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(product.title),
        subtitle: Text(product.description),
        trailing: ElevatedButton(
          onPressed: onBuy,
          child: const Text("Comprar"),
        ),
      ),
    );
  }
}
