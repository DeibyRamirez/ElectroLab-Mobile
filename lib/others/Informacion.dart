// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Informacion extends StatefulWidget {
  const Informacion({super.key});

  @override
  State<Informacion> createState() => _InformacionState();
}

class _InformacionState extends State<Informacion> {
  late Flutter3DController _controller;
  bool estaPlay = false;
  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Información',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'CARGAS ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                        child: Column(
                      children: [
                        const Text(' POSITIVAS ', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        SizedBox(
                          height: 160,
                          width: 100,
                          child: Flutter3DViewer(
                            controller: _controller,
                            src: 'assets/Carga_positiva.glb',
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
                      ],
                    )),
                    const SizedBox(width: 50),
                    Card(
                      child: Column(
                        children: [
                          const Text(' NEGATIVAS ', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          SizedBox(
                            height: 160,
                            width: 100,
                            child: Flutter3DViewer(
                              controller: _controller,
                              src: 'assets/Carga_negativa.glb',
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
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'GRÁFICA MODELO 3D',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 280,
                        child: Flutter3DViewer(
                          controller: _controller,
                          src: 'assets/Caso(-,-,-)_respecto_C1.glb',
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
                      ),
                      const Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '1. El modelo 3d indica la posición de cada carga.'),
                            SizedBox(height: 10),
                            Text(
                                '2. La flecha bajo la carga es el vector, el cual nos indica la carga que se esta trabajando.'),
                            SizedBox(height: 10),
                            Text(
                                '3. El modelo 3d nos brinda una animación sobre las fuerzas ejercidas por las cargas.'),
                            SizedBox(height: 10),
                            Text(
                                '4. El boton play nos permite reproducir la animación.'),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
                const SizedBox(height: 20),
                const Text(
                  'MOSTRAR LOS CÁLCULOS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          'Debes usar el boton para ingresar los datos en pantalla y mostrar sus resultados.',
                        ),
                        const SizedBox(height: 20),
                        Image.asset('assets/plano-cartesiano.jpg'),
                        const SizedBox(height: 10),
                        const Text(
                          'Debes tener en cuenta los cuadrantes de un plano cartesiano, para saber si las fuerzas tienen sentido positivo o negativo.',
                        ),
                        const SizedBox(height: 10),
                        const Text(
                            'Siempre teniendo en cuenta que las cargas que se encuentra acompañadas del vector, estan en el punto de origen del plano.'),
                        const SizedBox(height: 10),
                        const ElevatedButton(
                          onPressed: null,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.blue)),
                          child: Text(
                            "Ingresar los Sentidos de las Fuerzas",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )),
                )
              ],
            ),
          ),
        ));
  }
}
