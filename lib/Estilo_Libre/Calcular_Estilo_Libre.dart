// ignore_for_file: prefer_const_constructors, avoid_print, file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/Estilo_Libre/Plano_Resultante.dart';
import 'package:graficos_dinamicos/calculation/Formulas.dart';

class CalcularEstiloLibre extends StatefulWidget {
  const CalcularEstiloLibre(
      {super.key, required this.cargas, required this.cargaBase});

  final List<Map<String, dynamic>> cargas;
  final int cargaBase;

  @override
  State<CalcularEstiloLibre> createState() => _CalcularEstiloLibreState();
}

class _CalcularEstiloLibreState extends State<CalcularEstiloLibre> {
  List<Map<String, dynamic>> resultadosCalculos = [];
  double fuerzaResultanteX = 0;
  double fuerzaResultanteY = 0;
  double magnitudResultante = 0;
  double anguloResultante = 0;
  bool calculosRealizados = false;

  // Anuncio
  BannerAd? _miBanner;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _realizarCalculos();

    // 1. Inicializar el banner usando tu clase
    _miBanner = CargarAnuncios.crearBanner("banner_estilo_libre")
      ..load().then((_) {
        setState(() {
          _isLoaded = true;
        });
      });
  }

  @override
  void dispose() {
    _miBanner?.dispose(); // 2. IMPORTANTE: Limpiar memoria
    super.dispose();
  }

  void _realizarCalculos() {
    // Debug: Imprimir datos recibidos
    print("DEBUG: Número de cargas recibidas: ${widget.cargas.length}");
    print("DEBUG: Carga base seleccionada: ${widget.cargaBase}");
    for (int i = 0; i < widget.cargas.length; i++) {
      print("DEBUG: Carga $i: ${widget.cargas[i]}");
    }

    if (widget.cargas.isEmpty ||
        widget.cargaBase < 1 ||
        widget.cargaBase > widget.cargas.length) {
      print(
          "DEBUG: Error en validación inicial - cargas vacías o carga base inválida");
      setState(() {
        calculosRealizados = true; // Mostrar mensaje de error
      });
      return;
    }

    resultadosCalculos.clear();
    fuerzaResultanteX = 0;
    fuerzaResultanteY = 0;

    // Obtener la carga base (la que está en el origen)
    var cargaBase = widget.cargas[widget.cargaBase - 1];

    // Verificar que todos los datos necesarios estén completos
    if (!_validarDatos(cargaBase)) {
      print("DEBUG: Error en validación de datos");
      setState(() {
        calculosRealizados = true; // Mostrar mensaje de error
      });
      return;
    }

    // Transformar coordenadas para poner la carga base en el origen
    List<Map<String, dynamic>> cargasTransformadas = _transformarCoordenadas();

    // Calcular fuerzas para cada carga con respecto a la carga base
    for (int i = 0; i < cargasTransformadas.length; i++) {
      if (i == widget.cargaBase - 1) continue; // Saltar la carga base

      var cargaActual = cargasTransformadas[i];
      var resultado = _calcularFuerzaEntreDosCargas(
        cargaBase,
        cargaActual,
        i + 1,
      );

      if (resultado != null) {
        resultadosCalculos.add(resultado);

        // Sumar componentes para la fuerza resultante
        fuerzaResultanteX += resultado['fx'];
        fuerzaResultanteY += resultado['fy'];
      }
    }

    // Calcular magnitud y ángulo de la fuerza resultante
    magnitudResultante =
        Formulas.Fresultante(fuerzaResultanteX, fuerzaResultanteY);
    anguloResultante = atan2(fuerzaResultanteY, fuerzaResultanteX) * (180 / pi);

    setState(() {
      calculosRealizados = true;
    });
  }

  List<Map<String, dynamic>> _transformarCoordenadas() {
    var cargaBase = widget.cargas[widget.cargaBase - 1];

    double xBase = double.tryParse(cargaBase['x']?.toString() ?? '') ?? 0.0;
    double yBase = double.tryParse(cargaBase['y']?.toString() ?? '') ?? 0.0;

    return widget.cargas.map((carga) {
      double x = double.tryParse(carga['x']?.toString() ?? '') ?? 0.0;
      double y = double.tryParse(carga['y']?.toString() ?? '') ?? 0.0;

      return {
        'valor': carga['valor'], // Mantener el valor original
        'x': x - xBase,
        'x_old': carga['x']?.toString() ?? '0',
        'y': y - yBase,
        'y_old': carga['y']?.toString() ?? '0',
        'prefijo': carga['prefijo'] ?? '',
      };
    }).toList();
  }

  bool _validarDatos(Map<String, dynamic> cargaBase) {
    // Verificar que la carga base tenga todos los datos necesarios
    if (cargaBase['valor'] == null ||
        cargaBase['x'] == null ||
        cargaBase['y'] == null) {
      return false;
    }

    // Verificar que todas las cargas tengan datos completos
    for (var carga in widget.cargas) {
      if (carga['valor'] == null || carga['x'] == null || carga['y'] == null) {
        return false;
      }
    }
    return true;
  }

  Map<String, dynamic>? _calcularFuerzaEntreDosCargas(
      Map<String, dynamic> cargaBase,
      Map<String, dynamic> cargaActual,
      int indiceCarga) {
    // Obtener coordenadas relativas
    double x = cargaActual['x'].toDouble();
    double y = cargaActual['y'].toDouble();

    // Evitar división por cero
    if (x == 0 && y == 0) {
      return null;
    }

    // Calcular distancia usando el teorema de Pitágoras
    double distancia = Formulas.Hipotenusa(x, y);

    if (distancia == 0) {
      return null;
    }

    // Convertir valores de carga aplicando prefijos
    double q1 = _aplicarPrefijo(cargaBase['valor'], cargaBase['prefijo'] ?? '');
    double q2 =
        _aplicarPrefijo(cargaActual['valor'], cargaActual['prefijo'] ?? '');

    // Calcular fuerza usando la Ley de Coulomb
    double fuerza = Formulas.calcularFuerza(q1, q2, distancia);

    // Determinar si es atracción o repulsión
    bool esRepulsion = (q1 * q2) > 0;
    String tipoFuerza = esRepulsion ? 'Repulsión' : 'Atracción';

    // Calcular ángulo en grados
    double angulo = atan2(y, x) * (180 / pi);

    // Si es atracción, la fuerza apunta hacia la otra carga
    // Si es repulsión, la fuerza apunta en dirección opuesta
    if (!esRepulsion) {
      // Para atracción, invertir la dirección
      angulo += 180;
      if (angulo > 180) angulo -= 360;
    }

    // Calcular componentes de la fuerza
    double fx = Formulas.componentesX(fuerza, angulo);
    double fy = Formulas.componentesY(fuerza, angulo);

    return {
      'indiceCarga': indiceCarga,
      'x': x,
      'y': y,
      // 👇 originales tal cual fueron ingresados (texto)
      'x_old': cargaActual['x_old'],
      'y_old': cargaActual['y_old'],
      'distancia': distancia,
      'q1': q1,
      'q2': q2,
      'fuerza': fuerza,
      'angulo': angulo,
      'fx': fx,
      'fy': fy,
      'tipoFuerza': tipoFuerza,
      'esRepulsion': esRepulsion,
    };
  }

  double _aplicarPrefijo(dynamic valor, String prefijo) {
    if (valor == null) return 0.0;

    double valorNum;

    if (valor is num) {
      // Si ya es int o double
      valorNum = valor.toDouble();
    } else if (valor is String) {
      // Si viene como texto, intentar convertir
      valorNum = double.tryParse(valor) ?? 0.0;
    } else {
      valorNum = 0.0;
    }

    // Prefijos disponibles
    const Map<String, double> prefijos = {
      'µC': 1e-6,
      'nC': 1e-9,
      'mC': 1e-3,
      'pC': 1e-12,
      '': 1.0,
    };

    double factorPrefijo = prefijos[prefijo] ?? 1.0;
    return valorNum * factorPrefijo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text('Cálculos de Fuerza Eléctrica',
            style: TextStyle(color: Colors.white)),
      ),
      body: calculosRealizados
          ? _buildResultados()
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Realizando cálculos...'),
                ],
              ),
            ),
      // 3. Mostrar el banner si ya cargó
      bottomNavigationBar: _isLoaded
          // ignore: sized_box_for_whitespace
          ? Container(
              height: _miBanner!.size.height.toDouble(),
              width: _miBanner!.size.width.toDouble(),
              child: AdWidget(ad: _miBanner!),
            )
          : null,
    );
  }

  Widget _buildResultados() {
    // Si no hay datos válidos, mostrar mensaje de error
    if (widget.cargas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'No se recibieron datos de cargas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Verifica que hayas ingresado los valores en la pantalla anterior',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Si no se pudieron realizar cálculos
    if (resultadosCalculos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron realizar los cálculos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Verifica que todas las cargas tengan:',
              style: TextStyle(fontSize: 14),
            ),
            const Text('• Valor numérico válido'),
            const Text('• Coordenadas X e Y'),
            const Text('• Prefijo seleccionado'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información general
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Carga de Referencia: Carga ${widget.cargaBase}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total de interacciones calculadas: ${resultadosCalculos.length}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detalles de cada cálculo
          const Text(
            'Cálculos Detallados:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...resultadosCalculos
              .map((resultado) => _buildCalculoDetallado(resultado)),

          const SizedBox(height: 24),

          // Fuerza resultante
          Card(
            elevation: 6,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FUERZA RESULTANTE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(),
                  Text(
                    'Componentes de la Fuerza Resultante: ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                      'Componente X: ${_formatearCientifico(fuerzaResultanteX)} N'),
                  Text(
                      'Componente Y: ${_formatearCientifico(fuerzaResultanteY)} N'),
                  const SizedBox(height: 8),
                  Text(
                    'Magnitud: ${_formatearCientifico(magnitudResultante)} N',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ángulo: ${anguloResultante.toStringAsFixed(2)}°',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  // Plano con Vector y Fuerza Resultante...

                  Card(
                    child: CustomPaint(
                      painter: PlanoFuerzaResultantePainter(
                        anguloResultante: anguloResultante,
                        magnitudResultante: magnitudResultante,
                        origenX: fuerzaResultanteX,
                        origenY: fuerzaResultanteY,
                      ),
                      size: Size(300, 300),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculoDetallado(Map<String, dynamic> resultado) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: Text(
          'Carga ${widget.cargaBase} ↔ Carga ${resultado['indiceCarga']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ' Fuerza eléctrica = ${_formatearCientifico(resultado['fuerza'])} N',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coordenadas ingresadas:'),
                // Mostrar los valores originales (sin transformar) formateados
                Builder(builder: (_) {
                  final xOrigStr = resultado['x_old']?.toString() ?? '0';
                  final yOrigStr = resultado['y_old']?.toString() ?? '0';
                  final xOrig = double.tryParse(xOrigStr) ?? 0.0;
                  final yOrig = double.tryParse(yOrigStr) ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('  x = ${xOrig.toStringAsFixed(2)} m'),
                      Text('  y = ${yOrig.toStringAsFixed(2)} m'),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Text('Distancia:'),
                Text('  r = ${resultado['distancia'].toStringAsFixed(2)} m'),
                const SizedBox(height: 8),
                Text('Cargas:'),
                Text('  q₁ = ${_formatearCientifico(resultado['q1'])} C'),
                Text('  q₂ = ${_formatearCientifico(resultado['q2'])} C'),
                const SizedBox(height: 8),
                Text('Resultados:'),
                Text(
                    '  |Fuerza eléctrica| = ${_formatearCientifico(resultado['fuerza'].abs())} N'),
                // Text('  Ángulo = ${resultado['angulo'].toStringAsFixed(2)}°'),
                SizedBox(height: 4),
                Text('  Componentes de la Fuerza Eléctrica: '),
                Text('  Fx = ${_formatearCientifico(resultado['fx'])} N'),
                Text('  Fy = ${_formatearCientifico(resultado['fy'])} N'),
                SizedBox(height: 4),
                Text('  Tipo: ${resultado['tipoFuerza']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearCientifico(double valor) {
    if (valor.abs() >= 1000 || (valor.abs() < 0.001 && valor != 0)) {
      return valor.toStringAsExponential(2);
    } else {
      return valor.toStringAsFixed(6);
    }
  }
}
