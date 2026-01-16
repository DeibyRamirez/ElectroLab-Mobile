// ignore_for_file: unused_local_variable, file_names, library_private_types_in_public_api, non_constant_identifier_names, use_super_parameters

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:graficos_dinamicos/AR/AR.dart';
import 'package:graficos_dinamicos/AR/UtilidadesAr.dart';
import 'package:graficos_dinamicos/Anuncios/AdBannerWrapper.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/others/Informacion.dart';
import 'NotacionCientifica.dart';

class CalFuerzasRectangulo extends StatefulWidget {
  final int cargaTrabajo;
  final double carga1;
  final double carga2;
  final double carga3;
  final double distancia12;
  final double distancia23;
  final double distancia13;
  final String modelocarga1;
  final String modelocarga2;
  final String modelocarga3;
  final String combinacion3d;
  final String resultante3d;
  final double angulo;
  final double carga1convertida;
  final double carga2convertida;
  final double carga3convertida;

  const CalFuerzasRectangulo({
    Key? key,
    required this.cargaTrabajo,
    required this.carga1,
    required this.carga2,
    required this.carga3,
    required this.angulo,
    required this.distancia12,
    required this.distancia23,
    required this.distancia13,
    required this.combinacion3d,
    required this.modelocarga1,
    required this.modelocarga2,
    required this.modelocarga3,
    required this.resultante3d,
    required this.carga1convertida,
    required this.carga2convertida,
    required this.carga3convertida,
  }) : super(key: key);

  @override
  _CalFuerzasRectanguloState createState() => _CalFuerzasRectanguloState();
}

class _CalFuerzasRectanguloState extends State<CalFuerzasRectangulo> {
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

  String mensajeResultadoC1 = '';
  String mensajeResultadoC2 = '';
  String mensajeResultadoC3 = '';
  String mensajeComponentesC1 = '';

  String mensajeComponentesC3 = '';
  String mensajeFresultanteC1 = '';
  String mensajeFresultanteC2 = '';
  String mensajeFresultanteC3 = '';
  String mensajesumasC1 = '';
  String mensajesumasC2 = '';
  String mensajesumasC3 = '';
  bool estaPlay = false;
  bool resultPlay = false;
  bool mostrarResultante = false;

  int signoX1 = 1;
  int signoY1 = 1;
  int signoX2 = 1;
  int signoY2 = 1;
  int signo1 = 1;
  int signo2 = 1;

  late Flutter3DController _controller;
  late Flutter3DController _controllerResult;

  final notacioncientifica = Notacioncientifica();

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

    double f1componenteX = componentesX(fuerza12 * signoX1, widget.angulo);
    double f1componenteY = componentesY(fuerza12 * signoY1, widget.angulo);

    double f2componenteX = componentesX(fuerza13 * signoX2, widget.angulo);
    double f2componenteY = componentesY(fuerza13 * signoY2, widget.angulo);

    mensajeResultadoC1 =
        " Fuerza entre cargas 1 y 2:\n ${notacioncientifica.formatearNotacionCientifica(fuerza12, 2)} N\n\nFuerza entre cargas 1 y 3:\n ${notacioncientifica.formatearNotacionCientifica(fuerza13, 2)} N";

    // Esto nos sirve para saber caundo es posible que las fuerzas deban ser Negativas... en algunos casos
    if (widget.carga1convertida > 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida < 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida > 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida < 0) {
      fuerza13 = fuerza13 * -1;
    }
    if (widget.carga1convertida > 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida < 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida > 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida < 0) {
      fuerza12 = fuerza12 * -1;
    }
    mensajeComponentesC1 =
        " Componentes de la Fuerza (1,3): \nX = ${notacioncientifica.formatearNotacionCientifica(f2componenteX, 2)} N\nY = ${notacioncientifica.formatearNotacionCientifica(f2componenteY, 2)} N \n\nComponentes de la Fuerza (1,2): \nX = 0 N\nY = ${notacioncientifica.formatearNotacionCientifica(fuerza12, 2)} N";

    double fuerzaresultanteX = 0 + f2componenteX;
    double fuerzaresultanteY = fuerza12 + f2componenteY;

    mensajesumasC1 =
        " La suma de la fuerzas en X es: \n${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteX, 2)}  (i)\n\n La suma de la fuerzas en Y es: \n${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteY, 2)}   (j)";

    double fuerzaresultante = Fresultante(fuerzaresultanteX, fuerzaresultanteY);

    mensajeFresultanteC1 =
        " ${notacioncientifica.formatearNotacionCientifica(fuerzaresultante, 2)} N";
    ////////////////////////////////////////////

    double fuerza21 = calcularFuerza(
        widget.carga1convertida, widget.carga2convertida, widget.distancia12);
    double fuerza23 = calcularFuerza(
        widget.carga2convertida, widget.carga3convertida, widget.distancia23);

    double fuerza21signo = fuerza21 * signo1;
    double fuerza23signo = fuerza23 * signo2;

    mensajeResultadoC2 =
        " Fuerza entre cargas 2 y 1:\n ${notacioncientifica.formatearNotacionCientifica(fuerza21signo, 2)} N\n\n Fuerza entre cargas 2 y 3:\n ${notacioncientifica.formatearNotacionCientifica(fuerza23signo, 2)} N";

    mensajesumasC2 =
        "(${notacioncientifica.formatearNotacionCientifica(fuerza21signo, 2)} N)+(${notacioncientifica.formatearNotacionCientifica(fuerza23signo, 2)} N)";

    double fuerzaresultanteC2 = Fresultantecaso2(fuerza21signo, fuerza23signo);

    mensajeFresultanteC2 =
        " ${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteC2, 2)} N";

    /////////////////////////////////////////////

    double fuerza31 = calcularFuerza(
        widget.carga1convertida, widget.carga3convertida, widget.distancia13);
    double fuerza32 = calcularFuerza(
        widget.carga2convertida, widget.carga3convertida, widget.distancia23);

    double f1componenteXC3 = componentesX(fuerza31 * signoX1, widget.angulo);
    double f1componenteYC3 = componentesY(fuerza31 * signoY1, widget.angulo);

    mensajeResultadoC3 =
        " Fuerza entre cargas 3 y 1:\n ${notacioncientifica.formatearNotacionCientifica(fuerza31, 2)} N\n\nFuerza entre cargas 3 y 2:\n ${notacioncientifica.formatearNotacionCientifica(fuerza32, 2)} N";
    // Esto nos sirve para saber cuando es posible que las fuerzas deban ser Negativas... en algunos casos

    if (widget.carga1convertida > 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida < 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida < 0 ||
        widget.carga1convertida > 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida > 0) {
      fuerza31 = fuerza31 * -1;
    }
    if (widget.carga1convertida > 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida < 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida > 0 &&
            widget.carga2convertida < 0 &&
            widget.carga3convertida > 0 ||
        widget.carga1convertida < 0 &&
            widget.carga2convertida > 0 &&
            widget.carga3convertida < 0) {
      fuerza32 = fuerza32 * -1;
    }

    mensajeComponentesC3 =
        "Componentes de la Fuerza (3,1): \nX = ${notacioncientifica.formatearNotacionCientifica(f1componenteXC3, 2)} N \nY = ${notacioncientifica.formatearNotacionCientifica(f1componenteYC3, 2)} N \n\nComponentes de la Fuerza (3,2): \nX = ${notacioncientifica.formatearNotacionCientifica(fuerza32, 2)} N\nY = 0  N";

    double fuerzaresultanteXC3 = f1componenteXC3 + fuerza32;
    double fuerzaresultanteYC3 = f1componenteYC3 + 0;

    double fuerzaresultanteC3 =
        Fresultante(fuerzaresultanteXC3, fuerzaresultanteYC3);

    mensajesumasC3 =
        " La suma de la fuerzas en X es:\n ${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteXC3, 2)} (i)\n La suma de la fuerzas en Y es:\n ${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteYC3, 2)} (j)";

    mensajeFresultanteC3 =
        " ${notacioncientifica.formatearNotacionCientifica(fuerzaresultanteC3, 2)} N";
  }

  double calcularFuerza(double q1, double q2, double r) {
    const k = 8990000000; // Constante de Coulomb en Nm²/C²
    q2 = q2.abs();
    q1 = q1.abs();
    return k * (q1 * q2) / pow(r, 2); // Fórmula de Coulomb
  }

  double componentesX(double fuerza, double angulo) {
    double anguloRadianes = angulo * (pi / 180); // Convertir a radianes
    double componenteX = fuerza * cos(anguloRadianes);
    return componenteX; // Retorna la componente X
  }

  double componentesY(double fuerza, double angulo) {
    double anguloRadianes = angulo * (pi / 180); // Convertir a radianes
    double componenteY = fuerza * sin(anguloRadianes); // Utiliza la función sin
    return componenteY; // Retorna la componente Y
  }

  double Fresultante(double componentex, double componentey) {
    double Ft = sqrt(pow(componentex, 2) + pow(componentey, 2));
    return Ft;
  }

  double Fresultantecaso2(double fuerza1, double fuerza2) {
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

    switch (widget.cargaTrabajo) {
      case 1:
        return _buildCase1();
      case 2:
        return _buildCase2();
      case 3:
        return _buildCase3();
      default:
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
  }

  Widget _buildCase1() {
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Informacion()));
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga1.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga2.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga3.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Sentido de las Fuerzas",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            BotonAR(),
                          ]),
                      SizedBox(
                        height: 280,
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
                            borderRadius: BorderRadius.all(Radius.circular(5))),
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
                const Text(
                  "Digite el sentido de las componentes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildForceComponent(
                    "Sentido de la Fuerza (1 y 3)", signoX2, signoY2,
                    (newX, newY) {
                  setState(() {
                    signoX2 = newX;
                    signoY2 = newY;
                  });
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      actualizarMensajes();
                      mostrarResultante = true;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                    elevation: WidgetStateProperty.all(10),
                  ),
                  child: const Text(
                    "Ingresar los signos",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeResultadoC1,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                            "Fuerzas con Dirección y Componentes",
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeComponentesC1,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                            "Sumas de las Fuerzas",
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajesumasC1,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                "Magnitud de la F. Resultante",
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              BotonAR(mostrarResultante: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeFresultanteC1,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          if (mostrarResultante)
                            SizedBox(
                              height: 280,
                              child: Flutter3DViewer(
                                controller: _controllerResult,
                                src: widget.resultante3d,
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
                                            _controllerResult.playAnimation();
                                          } else {
                                            _controllerResult.pauseAnimation();
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////

  Widget _buildCase2() {
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
                                      fontSize: 20, fontWeight: FontWeight.bold),
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
                                      fontSize: 16, fontWeight: FontWeight.bold),
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
                                      fontSize: 20, fontWeight: FontWeight.bold),
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
                                      fontSize: 16, fontWeight: FontWeight.bold),
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
                                      fontSize: 20, fontWeight: FontWeight.bold),
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
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    "Sentido de las Fuerzas",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  BotonAR(),
                                ]),
                            SizedBox(
                              height: 280,
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
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              const Text(
                                "Sentido de la Fuerza (2 y 1)",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                      "Positivo (+)",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
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
                                      "Negativo (-)",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Sentido de la Fuerza (2 y 3)",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                    child: const Text(
                                      "Poitivo (+)",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
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
                                    child: const Text(
                                      "Negativo (-)",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ]),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            actualizarMensajes();
                            mostrarResultante = true;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.blue),
                          elevation: WidgetStateProperty.all(10),
                        ),
                        child: const Text(
                          "Ingresar los signos",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                                      fontSize: 19, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  mensajeResultadoC2,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
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
                                    "Sumas",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    mensajesumasC2,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 20),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      "Magnitud de la F. Resultante",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    BotonAR(mostrarResultante: true),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  mensajeFresultanteC2,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                if (mostrarResultante)
                                  SizedBox(
                                    height: 280,
                                    child: Flutter3DViewer(
                                      controller: _controllerResult,
                                      src: widget.resultante3d,
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
                        ),
                      )
                    ]))),
      ),
    );
  }
  ///////////////

  Widget _buildCase3() {
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Informacion()));
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga1.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga2.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 20, fontWeight: FontWeight.bold),
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
                                debugPrint('Modelo Cargando : $modelAddress');
                              },
                              onError: (String error) {
                                debugPrint('Modelo Fallo al Cargar : $error');
                              },
                            ),
                          ),
                          Text(
                            ' ${widget.carga3.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Sentido de las Fuerzas",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            BotonAR(),
                          ]),
                      SizedBox(
                        height: 280,
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
                            borderRadius: BorderRadius.all(Radius.circular(5))),
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
                const Text(
                  "Digite el sentido de las componentes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildForceComponent(
                    "Sentido de la Fuerza (3 y 1)", signoX1, signoY1,
                    (newX, newY) {
                  setState(() {
                    signoX1 = newX;
                    signoY1 = newY;
                  });
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      actualizarMensajes();
                      mostrarResultante = true;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                    elevation: WidgetStateProperty.all(10),
                  ),
                  child: const Text(
                    "Ingresar los signos",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeResultadoC3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                            "Fuerzas con Dirección y Componentes",
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeComponentesC3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                            "Sumas de las Fuerzas",
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajesumasC3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                "Magnitud de la F. Resultante",
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              BotonAR(mostrarResultante: true),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeFresultanteC3,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          if (mostrarResultante)
                            SizedBox(
                              height: 280,
                              child: Flutter3DViewer(
                                controller: _controllerResult,
                                src: widget.resultante3d,
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
                                            _controllerResult.playAnimation();
                                          } else {
                                            _controllerResult.pauseAnimation();
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget constructor de los signos se usa en el caso 1 y en el 3...

  Widget _buildForceComponent(
      String title, int signoX, int signoY, Function(int, int) onSignoChanged) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(" - Componente X: "),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onSignoChanged(1, signoY);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signoX == 1 ? Colors.blue : Colors.white,
                  ),
                  child: const Text(
                    "Positivo (+)",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    onSignoChanged(-1, signoY);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signoX == -1 ? Colors.blue : Colors.white,
                  ),
                  child: const Text(
                    "Negativo (-)",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(" - Componente Y: "),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onSignoChanged(signoX, 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signoY == 1 ? Colors.blue : Colors.white,
                  ),
                  child: const Text(
                    "Positivo (+)",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    onSignoChanged(signoX, -1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signoY == -1 ? Colors.blue : Colors.white,
                  ),
                  child: const Text(
                    "Negativo (-)",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Definir el modeloAR para ser usado en la próxima pantalla AR
  String get modeloAR => widget.combinacion3d;
  String get modeloARResultante => widget.resultante3d;
  String get magnitudFuerzas =>
      mapaseleccionado['resultados']?['fuerzaResultante'];
  String get fuerzasDireccion => mapaseleccionado['mensajes']?['signos'];
  String get sumatoriaFuerzas => mapaseleccionado['mensajes']?['sumas'];
  String get fuerzaResultante =>
      mapaseleccionado['resultados']?['fuerzaResultante'];

  Widget BotonAR({bool mostrarResultante = false}) {
    // Selecciona el modelo a mostrar en AR según la condición
    final String modeloSeleccionado =
        mostrarResultante ? modeloARResultante : modeloAR;

    final String modeloFinal =
        UtilidadesAR.normalizarRutaModelo(modeloSeleccionado);

    return ElevatedButton(
      onPressed: () {
        // Cargar anuncio
        CargarAnuncios.mostrarIntersticial("inter_ar");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AR(
                modeloAR: modeloSeleccionado,
                magnitudFuerzas: mapaseleccionado['mensajes']?['resultado'],
                sumatoriaFuerzas: mapaseleccionado['mensajes']?['sumas'],
                fuerzaResultante: mapaseleccionado['resultados']
                    ?['fuerzaResultante']),
          ),
        );
      },
      child: const Icon(Icons.view_in_ar),
    );
  }
}
