// ignore_for_file: file_names, non_constant_identifier_names, must_be_immutable, library_private_types_in_public_api, unnecessary_import, unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:graficos_dinamicos/AR/AR.dart';
import 'package:graficos_dinamicos/AR/UtilidadesAr.dart';
import 'package:graficos_dinamicos/Anuncios/AdBannerWrapper.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/others/Informacion.dart';
import 'NotacionCientifica.dart';

class CalcularFLineal3d extends StatefulWidget {
  final int cargaTrabajo;
  final double carga1;
  final double carga2;
  final double carga3;
  final double distancia12;
  final double distancia13;
  final double distancia23;
  final String modelocarga1;
  final String modelocarga2;
  final String modelocarga3;
  final String combinacion3d;

//Ahora para los calculos usaremos las cargas convertidas y para los modelos 3d las cargas normales...

//Falta entender que paso con los botones porque ahy mas botones y menos codigo
  final double carga1convertida;
  final double carga2convertida;
  final double carga3convertida;

  double fuerza12 = 0;
  double fuerza13 = 0;
  double fuerza23 = 0;
  CalcularFLineal3d({
    Key? key,
    required this.cargaTrabajo,
    required this.carga1,
    required this.carga2,
    required this.carga3,
    required this.distancia12,
    required this.distancia13,
    required this.distancia23,
    required this.modelocarga1,
    required this.modelocarga2,
    required this.modelocarga3,
    required this.combinacion3d,
    required this.carga1convertida,
    required this.carga2convertida,
    required this.carga3convertida,
  });

  @override
  _CalcularFLineal3dState createState() => _CalcularFLineal3dState();
}

class _CalcularFLineal3dState extends State<CalcularFLineal3d> {
  //Uso de listas para el manejo de mensajes y su uso en mapas...
  final List<String> mensajesSentidoC1 = [
    ' - Digite el sentido de la Fuerza (1 y 2)',
    ' - Digite el sentido de la Fuerza (1 y 3)'
  ];

  final List<String> mensajesSentidoC2 = [
    ' - Digite el sentido de la Fuerza (2 y 1)',
    ' - Digite el sentido de la Fuerza (2 y 3)'
  ];

  final List<String> mensajesSentidoC3 = [
    ' - Digite el sentido de la Fuerza (3 y 1)',
    ' - Digite el sentido de la Fuerza (3 y 2)'
  ];

  final notacionCientifica = Notacioncientifica();

  String mensajeResultadoC1 = '';
  String mensajeResultadoC2 = '';
  String mensajeResultadoC3 = '';
  String mensajesignoC1 = '';
  String mensajesignoC2 = '';
  String mensajesignoC3 = '';
  String mensajeFresultanteC1 = '';
  String mensajeFresultanteC2 = '';
  String mensajeFresultanteC3 = '';
  String mensajesumasC1 = '';
  String mensajesumasC2 = '';
  String mensajesumasC3 = '';
  double fuerza12 = 0.0;
  double fuerza13 = 0.0;
  double fuerza12signo = 0.0;
  double fuerza13signo = 0.0;
  bool estaPlay = false;
  bool resultPlay = false;
  bool mostrarResultante = false;

  int signo1 = 1;
  int signo2 = 1;

  late Flutter3DController _controller;
  late Flutter3DController _controllerResult;
  late String resultante3d = 'assets/Caso(+,+,+).glb';

  //Mapas usados para cada caso y nos ayudo a no crear abundante codigo repetitivo,
  //con un solo constructor y un build context podemos usar los datos guardados en cada Mapa
  late Map<String, Map<String, dynamic>> mapaCaso1;
  late Map<String, Map<String, dynamic>> mapaCaso2;
  late Map<String, Map<String, dynamic>> mapaCaso3;

  late Map<String, Map<String, dynamic>> mapaseleccionado;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _controllerResult = Flutter3DController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void actualizarMensajes() {
    double fuerza12 = calcularFuerza(
        widget.carga1convertida, widget.carga2convertida, widget.distancia12);
    double fuerza13 = calcularFuerza(
        widget.carga1convertida, widget.carga3convertida, widget.distancia13);

    double fuerza12signo = fuerza12 * signo1;
    double fuerza13signo = fuerza13 * signo2;

    mensajeResultadoC1 =
        " Fuerza entre cargas 1 y 2:\n ${notacionCientifica.formatearNotacionCientifica(fuerza12, 2)} N\n\n Fuerza entre cargas 1 y 3:\n ${notacionCientifica.formatearNotacionCientifica(fuerza13, 2)} N";

    mensajesignoC1 =
        " Fuerza(1,2): ${notacionCientifica.formatearNotacionCientifica(fuerza12signo, 2)} N \n\nFuerza(1,3): ${notacionCientifica.formatearNotacionCientifica(fuerza13signo, 2)} N ";

    mensajesumasC1 =
        "(${notacionCientifica.formatearNotacionCientifica(fuerza12signo, 2)} N) + (${notacionCientifica.formatearNotacionCientifica(fuerza13signo, 2)} N)";

    late double fuerzaresultanteC1 = Fresultante(fuerza12signo, fuerza13signo);

    mensajeFresultanteC1 =
        "\n${notacionCientifica.formatearNotacionCientifica(fuerzaresultanteC1, 2)} N";

    ////////////////////////////////////////////

    double fuerza21 = calcularFuerza(
        widget.carga2convertida, widget.carga1convertida, widget.distancia12);
    double fuerza23 = calcularFuerza(
        widget.carga2convertida, widget.carga3convertida, widget.distancia23);

    double fuerza21signo = fuerza21 * signo1;
    double fuerza23signo = fuerza23 * signo2;

    mensajeResultadoC2 =
        " Fuerza entre cargas 2 y 1: ${notacionCientifica.formatearNotacionCientifica(fuerza21, 2)} N\n\n Fuerza entre cargas 2 y 3: ${notacionCientifica.formatearNotacionCientifica(fuerza23, 2)} N";

    mensajesignoC2 =
        " Fuerza(2,1) = ${notacionCientifica.formatearNotacionCientifica(fuerza21signo, 2)} \n\nFuerza(2,3) = ${notacionCientifica.formatearNotacionCientifica(fuerza23signo, 2)} ";

    mensajesumasC2 =
        "(${notacionCientifica.formatearNotacionCientifica(fuerza21signo, 2)} N) + (${notacionCientifica.formatearNotacionCientifica(fuerza23signo, 2)} N)";

    double fuerzaresultanteC2 = Fresultante(fuerza21signo, fuerza23signo);

    mensajeFresultanteC2 =
        "${notacionCientifica.formatearNotacionCientifica(fuerzaresultanteC2, 2)} N";

    /////////////////////////////////////////////

    double fuerza31 = calcularFuerza(
        widget.carga3convertida, widget.carga1convertida, widget.distancia13);
    double fuerza32 = calcularFuerza(
        widget.carga3convertida, widget.carga2convertida, widget.distancia23);

    double fuerza31signo = fuerza31 * signo1;
    double fuerza32signo = fuerza32 * signo2;

    mensajeResultadoC3 =
        " Fuerza entre cargas 3 y 1: ${notacionCientifica.formatearNotacionCientifica(fuerza31, 2)} N\n\n Fuerza entre cargas 3 y 2: ${notacionCientifica.formatearNotacionCientifica(fuerza32, 2)} N";

    mensajesignoC3 =
        " Fuerza(3,1):  = ${notacionCientifica.formatearNotacionCientifica(fuerza31signo, 2)} N\n\nFuerza(3,2): = ${notacionCientifica.formatearNotacionCientifica(fuerza32signo, 2)} N";

    mensajesumasC3 =
        "(${notacionCientifica.formatearNotacionCientifica(fuerza31signo, 2)} N) + (${notacionCientifica.formatearNotacionCientifica(fuerza32signo, 2)} N)";

    double fuerzaresultanteC3 = Fresultante(fuerza32signo, fuerza31signo);

    mensajeFresultanteC3 =
        "${notacionCientifica.formatearNotacionCientifica(fuerzaresultanteC3, 2)} N";

    modelo3d(widget.carga1, widget.carga2, widget.carga3, widget.cargaTrabajo,
        fuerzaresultanteC1, fuerzaresultanteC2, fuerzaresultanteC3);
  }

  double calcularFuerza(double q1, double q2, double r) {
    const k = 8990000000; // Constante de Coulomb en Nm²/C²
    q2 = q2.abs();
    q1 = q1.abs();
    return k * (q1 * q2) / pow(r, 2); // Fórmula de Coulomb
  }

  double Fresultante(double fuerza1, double fuerza2) {
    double Ft = fuerza1 + fuerza2;
    return Ft;
  }

  @override
  Widget build(BuildContext context) {
    mapaCaso1 = {
      'mensajes': {
        'resultado': mensajeResultadoC1,
        'sentidoF1': mensajesSentidoC1[0],
        'sentidoF2': mensajesSentidoC1[1],
        'signos': mensajesignoC1,
        'sumas': mensajesumasC1,
      },
      'resultados': {
        'fuerzaResultante': mensajeFresultanteC1,
      },
    };

    mapaCaso2 = {
      'mensajes': {
        'resultado': mensajeResultadoC2,
        'sentidoF1': mensajesSentidoC2[0],
        'sentidoF2': mensajesSentidoC2[1],
        'signos': mensajesignoC2,
        'sumas': mensajesumasC2,
      },
      'resultados': {
        'fuerzaResultante': mensajeFresultanteC2,
      },
    };

    mapaCaso3 = {
      'mensajes': {
        'resultado': mensajeResultadoC3,
        'sentidoF1': mensajesSentidoC3[0],
        'sentidoF2': mensajesSentidoC3[1],
        'signos': mensajesignoC3,
        'sumas': mensajesumasC3,
      },
      'resultados': {
        'fuerzaResultante': mensajeFresultanteC3,
      },
    };

    if (widget.cargaTrabajo == 1) {
      mapaseleccionado = mapaCaso1;
    } else if (widget.cargaTrabajo == 2) {
      mapaseleccionado = mapaCaso2;
    } else if (widget.cargaTrabajo == 3) {
      mapaseleccionado = mapaCaso3;
    } else if (widget.cargaTrabajo != 1 ||
        widget.cargaTrabajo != 2 ||
        widget.cargaTrabajo != 3) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Fuerza Eléctrica"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Carga de trabajo no válida',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      body: buildMapaSeleccionado(mapaseleccionado),
    );
  }

  Widget buildMapaSeleccionado(
      Map<String, Map<String, dynamic>> mapaseleccionado) {
    return AdBannerWrapper(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            "Fuerza Eléctrica",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Informacion(),
                    ));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                const Text(
                                  "Carga N1",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 160,
                                  width: 100,
                                  child: Flutter3DViewer(
                                    controller: _controller,
                                    src: widget.modelocarga1,
                                    progressBarColor: Colors.blue,
                                    activeGestureInterceptor: true,
                                    enableTouch: true,
                                    onProgress: (double progressValue) {
                                      debugPrint(
                                          'Carga del Modelo en Proceso : $progressValue');
                                    },
                                    onLoad: (String modelAddress) {
                                      debugPrint(
                                          'Modelo Cargando : $modelAddress');
                                    },
                                    onError: (String error) {
                                      debugPrint(
                                          'Modelo Fallo al Cargar : $error');
                                    },
                                  ),
                                ),
                                Text(
                                  ' ${widget.carga1.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                const Text(
                                  "Carga N2",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 160,
                                  width: 100,
                                  child: Flutter3DViewer(
                                    controller: _controller,
                                    src: widget.modelocarga2,
                                    progressBarColor: Colors.blue,
                                    activeGestureInterceptor: true,
                                    enableTouch: true,
                                    onProgress: (double progressValue) {
                                      debugPrint(
                                          'Carga del Modelo en Proceso : $progressValue');
                                    },
                                    onLoad: (String modelAddress) {
                                      debugPrint(
                                          'Modelo Cargando : $modelAddress');
                                    },
                                    onError: (String error) {
                                      debugPrint(
                                          'Modelo Fallo al Cargar : $error');
                                    },
                                  ),
                                ),
                                Text(
                                  ' ${widget.carga2.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                const Text(
                                  "Carga N3",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 160,
                                  width: 100,
                                  child: Flutter3DViewer(
                                    controller: _controller,
                                    src: widget.modelocarga3,
                                    progressBarColor: Colors.blue,
                                    activeGestureInterceptor: true,
                                    enableTouch: true,
                                    onProgress: (double progressValue) {
                                      debugPrint(
                                          'Carga del Modelo en Proceso : $progressValue');
                                    },
                                    onLoad: (String modelAddress) {
                                      debugPrint(
                                          'Modelo Cargando : $modelAddress');
                                    },
                                    onError: (String error) {
                                      debugPrint(
                                          'Modelo Fallo al Cargar : $error');
                                    },
                                  ),
                                ),
                                Text(
                                  ' ${widget.carga3.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    "Sentido de las Fuerzas",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // BotonAR(),
                                ]),
                            SizedBox(
                              height: 300,
                              width: 400,
                              child: Flutter3DViewer(
                                controller: _controller,
                                src: widget.combinacion3d,
                                progressBarColor: Colors.blue,
                                activeGestureInterceptor: true,
                                enableTouch: true,
                                onProgress: (double progressValue) {
                                  debugPrint(
                                      'Carga del Modelo en Proceso : $progressValue');
                                },
                                onLoad: (String modelAddress) {
                                  debugPrint('Modelo Cargando : $modelAddress');
                                },
                                onError: (String error) {
                                  debugPrint('Modelo Fallo al Cargar : $error');
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          estaPlay = !estaPlay;

                                          if (estaPlay) {
                                            _controller.playAnimation();
                                          } else {
                                            _controller.pauseAnimation();
                                          }
                                        });
                                      },
                                      child: Icon(estaPlay
                                          ? Icons.pause_outlined
                                          : Icons.play_arrow_rounded)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(children: [
                              const Text("Digite el sentido de las Fuerzas",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              Text(mapaseleccionado['mensajes']?['sentidoF1']),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        signo1 = -1;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: signo1 == -1
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    child: const Text(
                                      " Izquierda ( - )",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          signo1 = 1;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: signo1 == 1
                                            ? Colors.blue
                                            : Colors.white,
                                      ),
                                      child: const Text(
                                        " Derecha ( + )",
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(mapaseleccionado['mensajes']?['sentidoF2']),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        signo2 = -1;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: signo2 == -1
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    child: const Text(" Izquierda ( - )",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  const SizedBox(width: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        signo2 = 1;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: signo2 == 1
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                    child: const Text(" Derecha ( + )",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ]),
                          )),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            actualizarMensajes();
                            mostrarResultante = true;
                          });
                        },
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(10),
                          backgroundColor:
                              const WidgetStatePropertyAll(Colors.blue),
                        ),
                        child: const Text(
                          "Ingresar los Signos",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 400,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Magnitud de las Fuerzas",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                    width: 400,
                                  ),
                                  Text(
                                    mapaseleccionado['mensajes']?['resultado'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Fuerzas con Dirección",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                    width: 400,
                                  ),
                                  Text(
                                    mapaseleccionado['mensajes']?['signos'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 10),
                      Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Sumatoria de Fuerzas",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    mapaseleccionado['mensajes']?['sumas'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    "Fuerza Resultante",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // BotonAR(mostrarResultante: true),
                                ],
                              ),
                              Text(
                                mapaseleccionado['resultados']
                                    ?['fuerzaResultante'],
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              if (mostrarResultante)
                                SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Flutter3DViewer(
                                      controller: _controllerResult,
                                      src: resultante3d,
                                      progressBarColor: Colors.blue,
                                      activeGestureInterceptor: true,
                                      enableTouch: true,
                                      onProgress: (double progressValue) {
                                        debugPrint(
                                            'Carga del Modelo en Proceso : $progressValue');
                                      },
                                      onLoad: (String modelAddress) {
                                        debugPrint(
                                            'Modelo Cargando : $modelAddress');
                                      },
                                      onError: (String error) {
                                        debugPrint(
                                            'Modelo Fallo al Cargar : $error');
                                      },
                                    ),
                                  ),
                                ),
                              if (mostrarResultante)
                                Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              resultPlay = !resultPlay;

                                              if (resultPlay) {
                                                _controllerResult
                                                    .playAnimation();
                                              } else {
                                                _controllerResult
                                                    .pauseAnimation();
                                              }
                                            });
                                          },
                                          child: Icon(resultPlay
                                              ? Icons.pause_outlined
                                              : Icons.play_arrow_rounded)),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      )
                    ]))),
      ),
    );
  }

  void modelo3d(
      double carga1,
      double carga2,
      double carga3,
      int cargaTrabajar,
      double fuerzaresultanteC1,
      double fuerzaresultanteC2,
      double fuerzaresultanteC3) {
    try {
      setState(() {
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 1) {
          resultante3d = 'assets/Caso(-,+,+)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          resultante3d = 'assets/Caso(-,+,+)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC3 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,+,+)_respecto_C3.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,+,+)_respecto_C3.glb';
          }
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC1 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,-,+)_respecto_C1.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,-,+)_respecto_C1.glb';
          }
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          resultante3d = 'assets/Caso(-,-,+)_respecto_C2.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          resultante3d = 'assets/Caso(-,-,+)_respecto_C3.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          resultante3d = 'assets/Caso(-,-,-)_respecto_C1.glb';
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC2 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,-,-)_respecto_C2.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,-,-)_respecto_C2.glb';
          }
        }
        if (carga1 < 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          resultante3d = 'assets/Caso(-,-,-)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 1) {
          resultante3d = 'assets/Caso(+,+,+)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 2) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC2 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,+,+)_respecto_C2.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,+,+)_respecto_C2.glb';
          }
        }
        if (carga1 > 0 && carga2 > 0 && carga3 > 0 && cargaTrabajar == 3) {
          resultante3d = 'assets/Caso(+,+,+)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC1 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,+,-)_respecto_C1.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,+,-)_respecto_C1.glb';
          }
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          resultante3d = 'assets/Caso(+,+,-)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          resultante3d = 'assets/Caso(+,+,-)_respecto_C3.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 1) {
          resultante3d = 'assets/Caso(+,-,-)_respecto_C1.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 2) {
          resultante3d = 'assets/Caso(+,-,-)_respecto_C2.glb';
        }
        if (carga1 > 0 && carga2 < 0 && carga3 < 0 && cargaTrabajar == 3) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC3 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,-,-)_respecto_C3.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,-,-)_respecto_C3.glb';
          }
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 1) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC1 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,+,-)_respecto_C1.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,+,-)_respecto_C1.glb';
          }
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 2) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC2 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,+,-)_respecto_C2.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,+,-)_respecto_C2.glb';
          }
        }
        if (carga1 < 0 && carga2 > 0 && carga3 < 0 && cargaTrabajar == 3) {
          if (carga1 < carga2 && carga3 > carga2 && fuerzaresultanteC3 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(-,+,-)_respecto_C3.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(-,+,-)_respecto_C3.glb';
          }
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 1) {
          if (carga1 > carga2 && carga1 > carga3 && fuerzaresultanteC1 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,-,+)_respecto_C1.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,-,+)_respecto_C1.glb';
          }
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 2) {
          if (carga1 < carga2 && carga3 > carga1 && fuerzaresultanteC2 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,-,+)_respecto_C2.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,-,+)_respecto_C2.glb';
          }
        }
        if (carga1 > 0 && carga2 < 0 && carga3 > 0 && cargaTrabajar == 3) {
          if (carga1 > carga2 && carga1 > carga3 && fuerzaresultanteC3 > 0) {
            resultante3d = 'assets/Caso_Resul_(+)_(+,-,+)_respecto_C3.glb';
          } else {
            resultante3d = 'assets/Caso_Resul_(-)_(+,-,+)_respecto_C3.glb';
          }
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error al cargar modelos 3D: $e");
    }
  }

  // Definir el modeloAR para ser usado en la próxima pantalla AR
  String get modeloAR => widget.combinacion3d;
  String get modeloARResultante => resultante3d;
  String get magnitudFuerzas =>
      mapaseleccionado['resultados']?['fuerzaResultante'];
  String get sumatoriaFuerzas => mapaseleccionado['mensajes']?['sumas'];
  String get fuerzaResultante =>
      mapaseleccionado['resultados']?['fuerzaResultante'];

  // Widget BotonAR({bool mostrarResultante = false}) {
  //   // Selecciona el modelo a mostrar en AR según la condición
  //   final String modeloSeleccionado =
  //       mostrarResultante ? modeloARResultante : modeloAR;

  //   final String modeloFinal =
  //       UtilidadesAR.normalizarRutaModelo(modeloSeleccionado);

  //   return ElevatedButton(
  //     onPressed: () {

  //       // Cargar anuncio
  //       CargarAnuncios.mostrarIntersticial();

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => AR(
  //               modeloAR: modeloSeleccionado,
  //               magnitudFuerzas: mapaseleccionado['mensajes']?['resultado'],
  //               sumatoriaFuerzas: mapaseleccionado['mensajes']?['sumas'],
  //               fuerzaResultante: mapaseleccionado['resultados']
  //                   ?['fuerzaResultante']),
  //         ),
  //       );
  //     },
  //     child: const Icon(Icons.view_in_ar),
  //   );
  // }
}
