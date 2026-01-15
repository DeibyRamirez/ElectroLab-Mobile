// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/billing/billig_manager.dart';
import 'package:graficos_dinamicos/billing/products.dart';
import 'package:graficos_dinamicos/repositories/coins_repository.dart';
import 'package:graficos_dinamicos/widgets/package_card.dart';

class Recargar extends StatefulWidget {
  final String uid;
  const Recargar({super.key, required this.uid});

  @override
  State<Recargar> createState() => _RecargarState();
}

class _RecargarState extends State<Recargar> {
  late BillingManager billingManager;

  final productos = Products.all.toList();

  @override
  void initState() {
    super.initState();

    billingManager = BillingManager(
      onPurchaseSuccess: _onPurchaseSuccess,
    );

    billingManager.start();
  }

  Future<void> _onPurchaseSuccess(String productId) async {
    final product = Products.byId(productId);

    if (product.consumable) {
      await CoinsRepository.addCoins(widget.uid, product.coins);
    }

    // Lógica específica para el producto de anuncios
    if (productId == "anuncios") {
      await CoinsRepository.desactivarAnuncios(widget.uid);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Compra exitosa!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    billingManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Fondo azul claro para contraste
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Recargar Monedas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Paquetes disponibles",
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final product = productos[index];

                // Efecto visual para destacar productos populares
                bool isPopular =
                    index == 1 || index == 2; // Ajusta según tus necesidades

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(isPopular ? 0.15 : 0.1),
                        blurRadius: isPopular ? 12 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      PackageCard(
                        creditos: product.coins,
                        onBuy: () => billingManager.buy(product.id),
                        product: product,
                      ),
                      if (isPopular)
                        Positioned(
                          top: -8,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "POPULAR",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Footer informativo
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.blue[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "Pago seguro y encriptado",
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
