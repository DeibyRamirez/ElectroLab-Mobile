// ignore_for_file: use_super_parameters, sized_box_for_whitespace, camel_case_types, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Anuncios/AdBannerWrapper.dart';

// ignore: camel_case_types
class tabla_prefijos extends StatefulWidget {
  const tabla_prefijos({Key? key}) : super(key: key);

  @override
  State<tabla_prefijos> createState() => _tabla_prefijosState();
}

class _tabla_prefijosState extends State<tabla_prefijos> {
  @override
  Widget build(BuildContext context) {
    return AdBannerWrapper(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text("Tabla Prefijos",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)))),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueAccent),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Submúltiplo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Símbolo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Valor en Coulombs',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Microcoulomb'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('µC'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 µC = 1 × 10⁻⁶ C'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nanocoulomb'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('nC'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 nC = 1 × 10⁻⁹ C'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Milicoulomb'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('mC'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 mC = 1 × 10⁻³ C'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Picocoulomb'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('pC'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 pC = 1 × 10⁻¹² C'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                },
                children: const [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueAccent),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Unidad de Longitud',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Símbolo',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Valor en Metros',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Decímetro'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('dm'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 dm = 0.1 m'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Centímetro'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('cm'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 cm = 0.01 m'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Milímetro'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('mm'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 mm = 0.001 m'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Metro'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('m'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('1 m = 1 m'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
