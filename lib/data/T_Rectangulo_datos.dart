// lib/T_Rectangulo_datos.dart

// ignore_for_file: avoid_print, camel_case_types, unused_element, use_build_context_synchronously, file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/Firebase/service/creditos_usuario.dart';
import 'package:graficos_dinamicos/auth/auth_helper.dart';
import 'package:graficos_dinamicos/calculation/CalcularF_TResctangulo3d.dart';
import 'package:graficos_dinamicos/calculation/tabla_prefijos.dart';
import 'package:graficos_dinamicos/Firebase/service/historial_service.dart';

class T_Rectangulo_datos extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final String? nombreGuardado;

  const T_Rectangulo_datos({
    super.key,
    this.initialData,
    this.nombreGuardado,
  });

  @override
  State<T_Rectangulo_datos> createState() => _T_Rectangulo_datosState();
}

class _T_Rectangulo_datosState extends State<T_Rectangulo_datos> {
  @override
  void initState() {
    super.initState();
    _cargarCreditos(); // Cargar creditos al iniciar.

    if (widget.initialData != null) {
      final data = widget.initialData!;

      // Función para mantener los números tal cual se guardaron
      String formatNumber(dynamic value) {
        if (value == null) return "";
        if (value is int) return value.toString(); // Entero puro
        if (value is double && value == value.roundToDouble()) {
          return value.toInt().toString(); // Ej: 4.0 -> "4"
        }
        return value.toString(); // Mantiene 4.5, 3.14, etc.
      }

      // Cargar los datos en los controladores con formato
      carga1Controller.text = formatNumber(data['carga1']);
      carga2Controller.text = formatNumber(data['carga2']);
      carga3Controller.text = formatNumber(data['carga3']);
      distancia12Controller.text = formatNumber(data['distancia12']);
      distancia23Controller.text = formatNumber(data['distancia23']);
      distancia13Controller.text = formatNumber(data['distancia13']);
      cargaTrabajoController.text = formatNumber(data['cargaTrabajo']);
      anguloController.text = formatNumber(data['angulo']);

      // Cargar prefijos (si existen)
      final prefijos = data['prefijos'] ?? {};
      prefijoseleccionadoCarga1 = prefijos['q1'];
      prefijoseleccionadoCarga2 = prefijos['q2'];
      prefijoseleccionadoCarga3 = prefijos['q3'];

      // Cargar nombre guardado (si viene)
      // if (widget.nombreGuardado != null) {
      //   nombreGuardadoController.text = widget.nombreGuardado!;
      // }

      // Activa el switch por defecto (para permitir volver a guardar si se desea)
      guardarHistorial = false;
    }
  }

  // Controladores
  final carga1Controller = TextEditingController();
  final carga2Controller = TextEditingController();
  final carga3Controller = TextEditingController();
  final distancia12Controller = TextEditingController();
  final distancia23Controller = TextEditingController();
  final distancia13Controller = TextEditingController();
  final cargaTrabajoController = TextEditingController();
  final anguloController = TextEditingController();
  final nombreGuardadoController = TextEditingController();

  // Switch para guardar en historial
  bool guardarHistorial = false;

  // Modelos y recursos
  late String modelocarga1 = 'assets/Carga_positiva.glb';
  late String modelocarga2 = 'assets/Carga_positiva.glb';
  late String modelocarga3 = 'assets/Carga_positiva.glb';
  late String combinacion3d = 'assets/Caso(+,+,+).glb';
  late String resultante3d =
      'assets/Resultante_Triangulo_EyR/Caso_Resul(+,+,+)_TR_respecto_C1.glb';

  // Prefijos
  static const prefijos = <String>['µC', 'nC', 'mC', 'pC'];
  String? prefijoseleccionadoCarga1;
  String? prefijoseleccionadoCarga2;
  String? prefijoseleccionadoCarga3;

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
  void dispose() {
    carga1Controller.dispose();
    carga2Controller.dispose();
    carga3Controller.dispose();
    distancia12Controller.dispose();
    distancia23Controller.dispose();
    distancia13Controller.dispose();
    cargaTrabajoController.dispose();
    anguloController.dispose();
    nombreGuardadoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                ),
              );
            },
            icon: const Icon(Icons.wysiwyg),
          )
        ],
        backgroundColor: Colors.blue,
        title: const Text(
          "Triángulo Rectángulo",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/Triangulo_Rectangulo.jpg'),
              const SizedBox(height: 20),
              const Text(
                "Digite los valores de las cargas con signo, Coulombs (C):",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              _buildPrefijoCampo("q1", prefijoseleccionadoCarga1, (v) {
                setState(() => prefijoseleccionadoCarga1 = v);
              }, carga1Controller),
              const SizedBox(height: 20),
              _buildPrefijoCampo("q2", prefijoseleccionadoCarga2, (v) {
                setState(() => prefijoseleccionadoCarga2 = v);
              }, carga2Controller),
              const SizedBox(height: 20),
              _buildPrefijoCampo("q3", prefijoseleccionadoCarga3, (v) {
                setState(() => prefijoseleccionadoCarga3 = v);
              }, carga3Controller),
              const SizedBox(height: 40),
              const Text(
                "Digite las distancias en metros (m):",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              _buildCampo(
                  "De (q1) a (q2), Lado opuesto", distancia12Controller),
              const SizedBox(height: 10),
              _buildCampo(
                  "De (q2) a (q3), Lado adyacente", distancia23Controller),
              const SizedBox(height: 10),
              _buildCampo(
                  "De (q1) a (q3), Usa Pitágoras...", distancia13Controller),
              const SizedBox(height: 40),
              _buildCampo(
                  "Carga (q) a trabajar: q1? q2? q3?", cargaTrabajoController),
              const SizedBox(height: 10),
              _buildCampo(
                  "Ángulo (usa tan^-1(opuesto/adyacente))", anguloController),
              const SizedBox(height: 30),
              SwitchListTile(
                title: const Text("Guardar en historial"),
                value: guardarHistorial,
                onChanged: (value) {
                  setState(() => guardarHistorial = value);
                },
              ),
              if (guardarHistorial)
                TextField(
                  controller: nombreGuardadoController,
                  decoration: const InputDecoration(
                    labelText: "Nombre del cálculo",
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: calcular,
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  ),
                  child: const Text("Calcular",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
    );
  }

  Widget _buildPrefijoCampo(String etiqueta, String? valor,
      Function(String?) onChanged, TextEditingController controller) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text("Seleccione un prefijo ($etiqueta)"),
            value: valor,
            items: prefijos.map((String prefijo) {
              return DropdownMenuItem<String>(
                value: prefijo,
                child: Text(prefijo),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 5),
        _buildCampo("Carga $etiqueta", controller),
      ],
    );
  }

  Future<void> calcular() async {
    double carga1 = double.tryParse(carga1Controller.text) ?? 0;
    double carga2 = double.tryParse(carga2Controller.text) ?? 0;
    double carga3 = double.tryParse(carga3Controller.text) ?? 0;
    double distancia12 = double.tryParse(distancia12Controller.text) ?? 0;
    double distancia23 = double.tryParse(distancia23Controller.text) ?? 0;
    double distancia13 = double.tryParse(distancia13Controller.text) ?? 0;
    int cargaTrabajo = int.tryParse(cargaTrabajoController.text) ?? 0;
    double angulo = double.tryParse(anguloController.text) ?? 0;

    // Validaciones
    if (carga1Controller.text.isEmpty ||
        carga2Controller.text.isEmpty ||
        carga3Controller.text.isEmpty ||
        distancia12Controller.text.isEmpty ||
        distancia23Controller.text.isEmpty ||
        distancia13Controller.text.isEmpty ||
        cargaTrabajoController.text.isEmpty ||
        anguloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor complete todos los campos antes de calcular.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
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

    if (distancia12 <= 0 || distancia23 <= 0 || distancia13 <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las distancias deben ser mayores a 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cargaTrabajo < 1 || cargaTrabajo > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La carga a trabajar debe ser 1, 2 o 3.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // El angulo debe ser mayor a 0 y no puede estar vacio
    if (angulo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El ángulo debe ser mayor a 0.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debes colocar un nombre si activas el switch
    if (guardarHistorial && nombreGuardadoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Debe ingresar un nombre para guardar en historial'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    //Convertir la carga usando el prefijo selecionado...
    double carga1Convertida =
        carga1 * valoresPrefijos[prefijoseleccionadoCarga1]!;
    double carga2Convertida =
        carga2 * valoresPrefijos[prefijoseleccionadoCarga2]!;
    double carga3Convertida =
        carga3 * valoresPrefijos[prefijoseleccionadoCarga3]!;

    modelo3d(carga1, carga2, carga3, cargaTrabajo);

    // 🔹 Guardar en historial si se activó el switch
    if (guardarHistorial) {
      final nombre = nombreGuardadoController.text.trim().isEmpty
          ? "Cálculo Rectángulo"
          : nombreGuardadoController.text.trim();

      final datos = {
        "carga1": carga1,
        "carga2": carga2,
        "carga3": carga3,
        "distancia12": distancia12,
        "distancia23": distancia23,
        "distancia13": distancia13,
        "cargaTrabajo": cargaTrabajo,
        "angulo": angulo,
        "prefijos": {
          "q1": prefijoseleccionadoCarga1,
          "q2": prefijoseleccionadoCarga2,
          "q3": prefijoseleccionadoCarga3,
        },
      };

      await HistorialService().guardarEntrada(
        datos: datos,
        nombre: nombre,
        ejemplo: "rectángulo",
      );

      // Cargar anuncio
      CargarAnuncios.mostrarIntersticial("inter_guardar");
    }

    // 🔹 Ir al resultado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalFuerzasRectangulo(
          carga1: carga1,
          carga2: carga2,
          carga3: carga3,
          distancia12: distancia12,
          distancia23: distancia23,
          distancia13: distancia13,
          cargaTrabajo: cargaTrabajo,
          angulo: angulo,
          combinacion3d: combinacion3d,
          modelocarga1: modelocarga1,
          modelocarga2: modelocarga2,
          modelocarga3: modelocarga3,
          resultante3d: resultante3d,
          carga1convertida: carga1Convertida,
          carga2convertida: carga2Convertida,
          carga3convertida: carga3Convertida,
          creditosUsuario: creditosUsuario,
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

//   void modelo3d(double carga1, double carga2, double carga3, int cargaTrabajar) {
//     // Tu lógica original intacta (no la toqué)
//     try {
//       setState(() {
//         modelocarga1 = carga1 < 0
//             ? 'assets/Carga_negativa.glb'
//             : 'assets/Carga_positiva.glb';
//         modelocarga2 = carga2 < 0
//             ? 'assets/Carga_negativa.glb'
//             : 'assets/Carga_positiva.glb';
//         modelocarga3 = carga3 < 0
//             ? 'assets/Carga_negativa.glb'
//             : 'assets/Carga_positiva.glb';
//         // ... (resto de tus condiciones originales)
//       });
//     } catch (e) {
//       print("Error al cargar modelos 3D: $e");
//     }
//   }
// }

  void modelo3d(
      double carga1, double carga2, double carga3, int cargaTrabajar) {
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
          combinacion3d = 'assets/Caso(-,+,+)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,+)_TR_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,+,+)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,+)_TR_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,+,+)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,+)_TR_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,-,+)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,+)_TR_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,-,+)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,+)_TR_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,-,+)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,+)_TR_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,-,-)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,-)_TR_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,-,-)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,-)_TR_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,-,-)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,-,-)_TR_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,+,+)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,+)_TR_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,+,+)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,+)_TR_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,+,+)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,+)_TR_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,+,-)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,-)_TR_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,+,-)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,-)_TR_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,+,-)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,+,-)_TR_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,-,-)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,-)_TR_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,-,-)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,-)_TR_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,-,-)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,-)_TR_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(-,+,-)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,-)_TR_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(-,+,-)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,-)_TR_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(-,+,-)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(-,+,-)_TR_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          combinacion3d = 'assets/Caso(+,-,+)_TR_respecto_C1.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,+)_TR_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          combinacion3d = 'assets/Caso(+,-,+)_TR_respecto_C2.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,+)_TR_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          combinacion3d = 'assets/Caso(+,-,+)_TR_respecto_C3.glb';
          resultante3d =
              'assets/Resultantes_Triangulo_EyR/Caso_Resul(+,-,+)_TR_respecto_C3.glb';
        }
      });
    } catch (e) {
      print("Error al cargar modelos 3D: $e");
    }
  }
}
