// lib/historial_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graficos_dinamicos/data/T_Equilatero_datos.dart';
import '../service/historial_service.dart';
import '../../data/Lineal_datos.dart';
import '../../data/T_Rectangulo_datos.dart';
import '../../Estilo_Libre/Estilo_Libre.dart';

class HistorialPage extends StatelessWidget {
  final HistorialService _histService = HistorialService();

  HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historial de Ejercicios",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _histService.obtenerHistorial(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar historial"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay historial guardado"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final nombre = data["nombre"] ?? "Sin nombre";
              final ejemplo = (data["ejemplo"] ?? "").toString().toLowerCase();
              final datos = Map<String, dynamic>.from(data["datos"] ?? {});
              final fecha = data["fecha"]?.toDate() ?? DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("Ejemplo: $ejemplo"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${fecha.day}/${fecha.month}/${fecha.year}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    switch (ejemplo) {
                      case "lineal":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Lineal_datos(
                              initialData: datos,
                              nombreGuardado: nombre,
                            ),
                          ),
                        );
                        break;

                      case "rectángulo":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => T_Rectangulo_datos(
                              initialData: datos,
                              nombreGuardado: nombre,
                            ),
                          ),
                        );
                        break;

                      case "equilatero":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => T_Equilatero_datos(
                              initialData: datos,
                              nombreGuardado: nombre,
                            ),
                          ),
                        );
                        break;

                      case "estilo libre":
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Estilo_Libre(
                              initialData: datos,
                              nombreGuardado: nombre,
                            ),
                          ),
                        );

                      default:
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Aún no se ha implementado la vista para '$ejemplo'",
                            ),
                          ),
                        );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
