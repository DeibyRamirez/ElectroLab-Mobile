// ignore_for_file: camel_case_types, library_private_types_in_public_api, use_super_parameters, file_names, avoid_print, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/Firebase/service/creditos_usuario.dart';
import 'package:graficos_dinamicos/auth/auth_helper.dart';
import 'package:graficos_dinamicos/calculation/CalcularFLineal3d.dart';
import 'package:graficos_dinamicos/calculation/tabla_prefijos.dart';
import 'package:graficos_dinamicos/Firebase/service/historial_service.dart';

class Lineal_datos extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? nombreGuardado;
  final String? uidUsuario;

  const Lineal_datos({
    Key? key,
    this.initialData,
    this.nombreGuardado,
    this.uidUsuario,
  }) : super(key: key);

  @override
  _Lineal_datosState createState() => _Lineal_datosState();
}

class _Lineal_datosState extends State<Lineal_datos> {
  final TextEditingController carga1Controller = TextEditingController();
  final TextEditingController carga2Controller = TextEditingController();
  final TextEditingController carga3Controller = TextEditingController();
  final TextEditingController distancia12Controller = TextEditingController();
  final TextEditingController distancia23Controller = TextEditingController();
  final TextEditingController distancia13Controller = TextEditingController();
  final TextEditingController cargaTrabajoController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();

  late String modelocarga1 = 'assets/Carga_positiva.glb';
  late String modelocarga2 = 'assets/Carga_positiva.glb';
  late String modelocarga3 = 'assets/Carga_positiva.glb';
  late String combinacion3d = 'assets/Caso(+,+,+).glb';

  static const prefijos = <String>['µC', 'nC', 'mC', 'pC'];
  String? prefijoseleccionadoCarga1;
  String? prefijoseleccionadoCarga2;
  String? prefijoseleccionadoCarga3;

  bool guardarEnHistorial = false;

  static final Map<String, double> valoresPrefijos = {
    'µC': pow(10, -6).toDouble(),
    'nC': pow(10, -9).toDouble(),
    'mC': pow(10, -3).toDouble(),
    'pC': pow(10, -12).toDouble(),
  };

  final uid = AuthHelper.uid;
  int creditosUsuario = 0; // ✅ Inicializar en 0
  bool cargandoCreditos = true; // ✅ Estado de carga

  // ✅ Método para cargar créditos
  Future<void> _cargarCreditos() async {
    print('🔵 Iniciando carga de créditos...');
    print('🔵 UID: $uid');
    print('🔵 UID está vacío: ${uid.isEmpty}');

    if (uid.isEmpty) {
      print('❌ ERROR: UID está vacío');
      if (mounted) {
        setState(() {
          creditosUsuario = 0;
          cargandoCreditos = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      print('🔵 Llamando a obtenerCreditosUsuario...');
      final creditos = await obtenerCreditosUsuario(uid);
      print('✅ Créditos obtenidos: $creditos');
      print('🔵 Widget montado: $mounted'); // ⬅️ NUEVO LOG

      if (mounted) {
        print('🔵 Actualizando estado...'); // ⬅️ NUEVO LOG
        setState(() {
          creditosUsuario = creditos;
          cargandoCreditos = false;
        });
        print('✅ Estado actualizado'); // ⬅️ NUEVO LOG
      } else {
        print('❌ Widget no montado, no se puede actualizar estado');
      }
    } catch (e) {
      print('❌ Error al cargar créditos: $e');
      if (mounted) {
        setState(() {
          creditosUsuario = 0;
          cargandoCreditos = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarCreditos(); // ✅ Cargar créditos al iniciar
    if (widget.initialData != null) {
      final data = widget.initialData!;
      String formatNumber(num? value) {
        if (value == null) return "";
        if (value is int || value == value.roundToDouble()) {
          return value.toInt().toString(); // Ej: 4.0 -> "4"
        }
        return value.toString(); // Si es 4.5 se queda "4.5"
      }

      // 🔹 Autorelleno de números
      carga1Controller.text = formatNumber(data["carga1"]);
      carga2Controller.text = formatNumber(data["carga2"]);
      carga3Controller.text = formatNumber(data["carga3"]);
      distancia12Controller.text = formatNumber(data["distancia12"]);
      distancia23Controller.text = formatNumber(data["distancia23"]);
      distancia13Controller.text = formatNumber(data["distancia13"]);
      cargaTrabajoController.text = formatNumber(data["cargaTrabajo"]);

      // 🔹 Autorelleno de prefijos
      prefijoseleccionadoCarga1 = data["prefijo1"] as String?;
      prefijoseleccionadoCarga2 = data["prefijo2"] as String?;
      prefijoseleccionadoCarga3 = data["prefijo3"] as String?;
    }
  }

  @override
Widget build(BuildContext context) {
  print('🏗️ BUILD Lineal_datos - cargandoCreditos: $cargandoCreditos, creditosUsuario: $creditosUsuario');
  
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const tabla_prefijos(),
                  ));
            },
            icon: const Icon(Icons.wysiwyg))
      ],
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: const Text(
        "Lineal",
        style: TextStyle(color: Colors.white),
      ),
    ),
    body: Stack(
      children: [
        // ✅ Contenido principal (siempre visible)
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Indicador de carga de créditos (pequeño, arriba)
                if (cargandoCreditos)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Cargando créditos...'),
                      ],
                    ),
                  ),
                Image.asset('assets/Lineal.jpg'),
                const SizedBox(height: 20),
                const Text(
                  "Digite los valores de las cargas con signo, Coulombs (C):",
                  style: TextStyle(fontSize: 18),
                ),
                // ... resto de tu formulario (sin cambios)
                const SizedBox(height: 20),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Seleccione un prefijo (q1)"),
                  value: prefijoseleccionadoCarga1,
                  items: prefijos.map((String prefijo) {
                    return DropdownMenuItem<String>(
                      value: prefijo,
                      child: Text(prefijo),
                    );
                  }).toList(),
                  onChanged: (String? nuevoValor) {
                    setState(() {
                      prefijoseleccionadoCarga1 = nuevoValor;
                    });
                  },
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: carga1Controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carga 1 (q1)',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Seleccione un prefijo (q2)"),
                value: prefijoseleccionadoCarga2,
                items: prefijos.map((String prefijo) {
                  return DropdownMenuItem<String>(
                    value: prefijo,
                    child: Text(prefijo),
                  );
                }).toList(),
                onChanged: (String? nuevoValor) {
                  setState(() {
                    prefijoseleccionadoCarga2 = nuevoValor;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: carga2Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga 2 (q2)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Seleccione un prefijo (q3)"),
                value: prefijoseleccionadoCarga3,
                items: prefijos.map((String prefijo) {
                  return DropdownMenuItem<String>(
                    value: prefijo,
                    child: Text(prefijo),
                  );
                }).toList(),
                onChanged: (String? nuevoValor) {
                  setState(() {
                    prefijoseleccionadoCarga3 = nuevoValor;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: carga3Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga 3 (q3)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Digite el valor de la distancia en metros (m):",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: distancia12Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'De (q1) a (q2)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: distancia23Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'De (q2) a (q3)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: distancia13Controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'De (q1) a (q3)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "Digite la carga (q) a trabajar:",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: cargaTrabajoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'q1? q2? q3?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text("Guardar en historial"),
                value: guardarEnHistorial,
                onChanged: (val) {
                  setState(() {
                    guardarEnHistorial = val;
                  });
                },
              ),
              if (guardarEnHistorial) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cálculo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _calcular,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    "Calcular",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
  ]
  ),
  );
  }

  void _calcular() async {
    if (carga1Controller.text.isEmpty ||
        carga2Controller.text.isEmpty ||
        carga3Controller.text.isEmpty ||
        distancia12Controller.text.isEmpty ||
        distancia23Controller.text.isEmpty ||
        distancia13Controller.text.isEmpty ||
        cargaTrabajoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor complete todos los campos antes de calcular.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Validar que los prefijos estén seleccionados
    if (prefijoseleccionadoCarga1 == null ||
        prefijoseleccionadoCarga2 == null ||
        prefijoseleccionadoCarga3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar los prefijos de las cargas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double carga1 = double.tryParse(carga1Controller.text) ?? 0;
    final double carga2 = double.tryParse(carga2Controller.text) ?? 0;
    final double carga3 = double.tryParse(carga3Controller.text) ?? 0;

    double carga1Convertida =
        carga1 * valoresPrefijos[prefijoseleccionadoCarga1]!;
    double carga2Convertida =
        carga2 * valoresPrefijos[prefijoseleccionadoCarga2]!;
    double carga3Convertida =
        carga3 * valoresPrefijos[prefijoseleccionadoCarga3]!;

    final double distancia12 = double.parse(distancia12Controller.text);
    final double distancia23 = double.parse(distancia23Controller.text);
    final double distancia13 = double.parse(distancia13Controller.text);
    final cargaTrabajo = int.tryParse(cargaTrabajoController.text) ?? 0;

    if (guardarEnHistorial && nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debe ingresar un nombre para guardar en historial'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (guardarEnHistorial) {
      await HistorialService().guardarEntrada(
        datos: {
          "carga1": carga1,
          "carga2": carga2,
          "carga3": carga3,
          "distancia12": distancia12,
          "distancia23": distancia23,
          "distancia13": distancia13,
          "cargaTrabajo": cargaTrabajo,
          "prefijo1": prefijoseleccionadoCarga1,
          "prefijo2": prefijoseleccionadoCarga2,
          "prefijo3": prefijoseleccionadoCarga3,
        },
        nombre: nombreController.text,
        ejemplo: "lineal",
      );

      // Cargar anuncio
      CargarAnuncios.mostrarIntersticial("inter_guardar");
    }

// Validar que las cargas sean números enteros
    if (carga1 % 1 != 0 || carga2 % 1 != 0 || carga3 % 1 != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las cargas deben ser números enteros, sin decimales.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (carga1 == 0 || carga2 == 0 || carga3 == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las cargas no deben ser iguales a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

// Validar que distancias sean mayores a 0
    if (distancia12 <= 0 || distancia23 <= 0 || distancia13 <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las distancias deben ser mayores a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

// Validar que la carga de trabajo esté entre 1 y 3
    if (cargaTrabajo < 1 || cargaTrabajo > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La carga a trabajar debe ser 1, 2 o 3.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    modelo3d(carga1, carga2, carga3, cargaTrabajo, distancia13, distancia23,
        distancia12);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalcularFLineal3d(
          carga1: carga1,
          carga2: carga2,
          carga3: carga3,
          distancia12: distancia12,
          distancia23: distancia23,
          distancia13: distancia13,
          cargaTrabajo: cargaTrabajo,
          modelocarga1: modelocarga1,
          modelocarga2: modelocarga2,
          modelocarga3: modelocarga3,
          combinacion3d: combinacion3d,
          carga1convertida: carga1Convertida,
          carga2convertida: carga2Convertida,
          carga3convertida: carga3Convertida,
          creditosUsuario: creditosUsuario,
        ),
      ),
    );
  }

  void modelo3d(double carga1, double carga2, double carga3, int cargaTrabajar,
      double distancia12, double distancia23, double distancia13) {
    try {
      setState(() {
        modelocarga1 = carga1 < 0
            ? 'assets/Carga_negativa.glb'
            : 'assets/Carga_positiva.glb';
        modelocarga2 = carga2 < 0
            ? 'assets/Carga_negativa.glb'
            : 'assets/Carga_positiva.glb';
        modelocarga3 = carga3 < 0
            ? 'assets/Carga_negativa.glb'
            : 'assets/Carga_positiva.glb';

        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,+,+)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,+,+)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,+,+)_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,-,+)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,-,+)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,-,+)_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,-,-)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,-,-)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,-,-)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,+,+)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,+,+)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,+,+)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,+,-)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,+,-)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,+,-)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,-,-)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,-,-)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,-,-)_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,+,-)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,+,-)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,+,-)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,-,+)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,-,+)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,-,+)_respecto_C3.glb';
        }
      });
    } catch (e) {
      print("Error al cargar modelos 3D: $e");
    }
  }
}
