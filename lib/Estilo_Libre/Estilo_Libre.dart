// lib/Estilo_Libre.dart

// ignore_for_file: camel_case_types, deprecated_member_use, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:graficos_dinamicos/Anuncios/CargarAnuncios.dart';
import 'package:graficos_dinamicos/Estilo_Libre/Plano.dart';
import 'package:graficos_dinamicos/Estilo_libre/Calcular_Estilo_libre.dart';
import 'package:graficos_dinamicos/others/Informacion.dart';
import 'package:graficos_dinamicos/Firebase/service/historial_service.dart';

class Estilo_Libre extends StatefulWidget {
  final Map<String, dynamic>? initialData; // 👈 NUEVO: recibe datos guardados

  final String? nombreGuardado;

  const Estilo_Libre({
    super.key,
    this.initialData,
    this.nombreGuardado,
  });

  @override
  State<Estilo_Libre> createState() => _Estilo_LibreState();
}

class _Estilo_LibreState extends State<Estilo_Libre>
    with SingleTickerProviderStateMixin {
  int cantidadCargas = 3;
  List<Map<String, dynamic>> cargas = [];
  int cargaSeleccionada = 1;
  bool _allowTabScroll = true;
  late TabController _tabController;

  // Limite máximo de cargas
  static const int maxCargas = 10;

  // Controladores
  List<TextEditingController> valorControllers = [];
  List<TextEditingController> xControllers = [];
  List<TextEditingController> yControllers = [];
  List<TextEditingController> prefijoControllers = [];

  // Variables para zoom
  final TransformationController _transformController1 =
      TransformationController();
  final TransformationController _transformController2 =
      TransformationController();

  // 👇 _minScale a 1 (zoom out máximo más amplio, equivalente al gesto de pellizco)
  static const double _minScale = 1;
  static const double _maxScale = 4.0;
  static const double _initialScale = 1.2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _inicializarZoom();

    // 👇 Si viene del historial, reconstruye las cargas guardadas
    if (widget.initialData != null && widget.initialData!['cargas'] != null) {
      final data = widget.initialData!;
      setState(() {
        cantidadCargas = data['cantidadCargas'] ?? data['cargas'].length;
        cargas = List<Map<String, dynamic>>.from(data['cargas']);
      });
      _inicializarControladoresDesdeDatos();
    } else {
      // Si no viene nada, inicializa vacío
      _inicializarCargas();
    }
  }

  void _inicializarControladoresDesdeDatos() {
    valorControllers = List.generate(cantidadCargas,
        (i) => TextEditingController(text: cargas[i]['valor'] ?? ''));
    xControllers = List.generate(cantidadCargas,
        (i) => TextEditingController(text: cargas[i]['x'] ?? ''));
    yControllers = List.generate(cantidadCargas,
        (i) => TextEditingController(text: cargas[i]['y'] ?? ''));
    prefijoControllers = List.generate(cantidadCargas,
        (i) => TextEditingController(text: cargas[i]['prefijo'] ?? ''));
  }

  void _inicializarCargas() {
    cargas = List.generate(cantidadCargas, (index) {
      return {'valor': '', 'x': '', 'y': '', 'prefijo': ''};
    });
    valorControllers =
        List.generate(cantidadCargas, (_) => TextEditingController());
    xControllers =
        List.generate(cantidadCargas, (_) => TextEditingController());
    yControllers =
        List.generate(cantidadCargas, (_) => TextEditingController());
    prefijoControllers =
        List.generate(cantidadCargas, (_) => TextEditingController());
  }

  void _inicializarZoom() {
    final matrix = Matrix4.identity()..scale(_initialScale);
    _transformController1.value = matrix;
    _transformController2.value = matrix;
  }

  void _zoomOut(TransformationController controller) {
    final matrix = Matrix4.identity()..scale(_minScale);
    controller.value = matrix;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transformController1.dispose();
    _transformController2.dispose();
    for (var c in valorControllers) {
      c.dispose();
    }
    for (var c in xControllers) {
      c.dispose();
    }
    for (var c in yControllers) {
      c.dispose();
    }
    for (var c in prefijoControllers) {
      c.dispose();
    }
    super.dispose();
  }

  static const prefijos = <String>['µC', 'nC', 'mC', 'pC'];

  // Guardar datos actuales de los controladores en la lista cargas (como string)
  void _guardarDatos() {
    for (int i = 0; i < cantidadCargas; i++) {
      cargas[i]['valor'] = valorControllers[i].text;
      cargas[i]['x'] = xControllers[i].text;
      cargas[i]['y'] = yControllers[i].text;
      // IMPORTANTE: NO tocar 'prefijo' aquí. El prefijo se actualiza
      // directamente desde el Dropdown (pantalla 2) y se mantiene en `cargas`.
      //cargas[i]['prefijo'] = prefijoControllers[i].text;
    }
  }

  void _actualizarCantidad(int nuevaCantidad) {
    if (nuevaCantidad < 3) return;

    // Guardar lo escrito antes de cambiar cantidad
    _guardarDatos();

    setState(() {
      if (nuevaCantidad < cantidadCargas) {
        // Reducir: liberar controladores y recortar listas
        for (int i = nuevaCantidad; i < cantidadCargas; i++) {
          valorControllers[i].dispose();
          xControllers[i].dispose();
          yControllers[i].dispose();
          prefijoControllers[i].dispose();
        }
        valorControllers = valorControllers.sublist(0, nuevaCantidad);
        xControllers = xControllers.sublist(0, nuevaCantidad);
        yControllers = yControllers.sublist(0, nuevaCantidad);
        prefijoControllers = prefijoControllers.sublist(0, nuevaCantidad);
        cargas = cargas.sublist(0, nuevaCantidad);

        if (cargaSeleccionada > nuevaCantidad) cargaSeleccionada = 1;
      } else {
        // Aumentar: agregar nuevas entradas y controladores
        for (int i = cantidadCargas; i < nuevaCantidad; i++) {
          cargas.add({
            'valor': '',
            'x': '',
            'y': '',
            'prefijo': '',
          });
          valorControllers.add(TextEditingController());
          xControllers.add(TextEditingController());
          yControllers.add(TextEditingController());
          prefijoControllers.add(TextEditingController());
        }
      }

      cantidadCargas = nuevaCantidad;

      // Actualizar textos en controladores desde la lista cargas
      _restaurarDatos();
    });
  }

  // Restaurar datos desde la lista cargas a los controladores (todo como texto)
  void _restaurarDatos() {
    for (int i = 0; i < cantidadCargas; i++) {
      valorControllers[i].text = (cargas[i]['valor'] ?? '').toString();
      xControllers[i].text = (cargas[i]['x'] ?? '').toString();
      yControllers[i].text = (cargas[i]['y'] ?? '').toString();
      // Sincronizar prefijoController si se está usando
      if (i < prefijoControllers.length) {
        prefijoControllers[i].text = (cargas[i]['prefijo'] ?? '').toString();
      }
    }
  }

  // void _resetZoom(TransformationController controller) {
  //   final matrix = Matrix4.identity();
  //   matrix.scale(_initialScale);
  //   controller.value = matrix;
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => (const Informacion())));
                },
                icon: const Icon(Icons.question_mark, color: Colors.white))
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 0.5],
              ),
            ),
          ),
          title:
              const Text("Estilo Libre", style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            controller: _tabController,
            physics: _allowTabScroll
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(
                icon: Icon(Icons.edit, size: 40, color: Colors.black),
              ),
              Tab(
                icon: Icon(Icons.visibility, size: 50, color: Colors.black),
              ),
            ],
          ),
        ),
        body: Stack(
          // 👈 CAMBIO: Envuelve en Stack
          children: [
            TabBarView(
              controller: _tabController,
              physics: _allowTabScroll
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              children: [
                _pantalla1(),
                _pantalla2(),
              ],
            ),

            // Flechas de navegación
            AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                final currentIndex = _tabController.index;
                return Stack(
                  children: [
                    // Flecha derecha en pantalla 1 (índice 0)
                    if (currentIndex == 0)
                      Positioned(
                        // 👇 CAMBIO: Bajada la flecha (menor valor de bottom para posicionarla más abajo en la pantalla)
                        bottom: 28,
                        right: 20,
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(1),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    // Flecha izquierda en pantalla 2 (índice 1)
                    if (currentIndex == 1)
                      Positioned(
                        // 👇 CAMBIO: Bajada la flecha (menor valor de bottom para posicionarla más abajo en la pantalla)
                        bottom: 28,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            // 👇 Indicador optimizado (sin NotificationListener)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, _) {
                  double page = _tabController.animation!.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      double selectedness =
                          (1.0 - (page - index).abs()).clamp(0.0, 1.0);
                      double width = 8 + (16 * selectedness);
                      Color color = Color.lerp(
                          Colors.grey.shade400, Colors.blue, selectedness)!;

                      return Container(
                        // 👈 Cambié AnimatedContainer por Container
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: width,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> get datosParaGuardar {
    _guardarDatos();
    return {
      'cantidadCargas': cantidadCargas,
      'cargas': cargas,
    };
  }

  // Variables nuevas al inicio del _Estilo_LibreState:
  bool guardarHistorial = false;
  final TextEditingController nombreEjercicioController =
      TextEditingController();

  // ---------------- PANTALLA 1 ----------------
  Widget _pantalla1() {
    return Column(
      children: [
        // Plano cartesiano mejorado (flex para su tamaño)
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: (_) =>
                        setState(() => _allowTabScroll = false),
                    onPointerUp: (_) =>
                        Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) setState(() => _allowTabScroll = true);
                    }),
                    child: InteractiveViewer(
                      transformationController: _transformController1,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: _minScale,
                      maxScale: _maxScale,
                      panEnabled: true,
                      scaleEnabled: true,
                      clipBehavior: Clip.hardEdge,
                      constrained: true,
                      child: SizedBox(
                        width: 800,
                        height: 800,
                        child: CustomPaint(
                          painter: PlanoPainter(cargas,
                              cargaSeleccionada: cargaSeleccionada),
                          size: const Size(800, 800),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => _zoomOut(_transformController1),
                      child: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        const Text("Cantidad de Cargas",
            style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _actualizarCantidad(cantidadCargas - 1),
              icon: const Icon(Icons.remove_circle, color: Colors.red),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                textAlign: TextAlign.center,
                controller:
                    TextEditingController(text: cantidadCargas.toString()),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (value) {
                  int? nuevaCantidad = int.tryParse(value);
                  if (nuevaCantidad == null || nuevaCantidad < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Debes ingresar un número mayor o igual a 3."),
                      backgroundColor: Colors.red,
                    ));
                    _actualizarCantidad(3);
                  } else if (nuevaCantidad > maxCargas) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("No puedes agregar más de $maxCargas cargas."),
                      backgroundColor: Colors.red,
                    ));
                    _actualizarCantidad(maxCargas);
                  } else {
                    _actualizarCantidad(nuevaCantidad);
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                if (cantidadCargas < maxCargas) {
                  _actualizarCantidad(cantidadCargas + 1);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text("No puedes agregar más de $maxCargas cargas."),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              icon: const Icon(Icons.add_circle, color: Colors.green),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Carga a trabajar: ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: cargaSeleccionada,
              items: List.generate(cantidadCargas, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text("Carga ${index + 1}"),
                );
              }),
              onChanged: (val) {
                setState(() {
                  cargaSeleccionada = val!;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cantidadCargas,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text("Carga ${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: valorControllers[index],
                        decoration: const InputDecoration(
                          labelText: "Valor (con signo)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        onChanged: (v) {
                          setState(() {
                            // Guardar como String — convertiremos luego
                            cargas[index]['valor'] = v;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: xControllers[index],
                              decoration: const InputDecoration(
                                labelText: "x",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                              onChanged: (v) {
                                setState(() {
                                  cargas[index]['x'] = v;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: yControllers[index],
                              decoration: const InputDecoration(
                                labelText: "y",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      signed: true, decimal: false),
                              onChanged: (v) {
                                setState(() {
                                  cargas[index]['y'] = v;
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------- PANTALLA 2 ----------------
  Widget _pantalla2() {
    // Sin transformación relativa: usar posiciones absolutas
    List<Map<String, dynamic>> cargasTransformadas = cargas;

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Listener(
                    onPointerDown: (_) =>
                        setState(() => _allowTabScroll = false),
                    onPointerUp: (_) =>
                        Future.delayed(const Duration(milliseconds: 200), () {
                      if (mounted) setState(() => _allowTabScroll = true);
                    }),
                    child: InteractiveViewer(
                      transformationController: _transformController2,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: _minScale,
                      maxScale: _maxScale,
                      panEnabled: true,
                      scaleEnabled: true,
                      clipBehavior: Clip.hardEdge,
                      constrained: true,
                      child: SizedBox(
                        width: 800,
                        height: 800,
                        child: CustomPaint(
                          painter: PlanoPainter(cargasTransformadas,
                              cargaSeleccionada: cargaSeleccionada),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => _zoomOut(_transformController2),
                      child: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 150,
                    right: 16,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          // child: IconButton(
                          //   icon: const Icon(Icons.center_focus_strong,
                          //       color: Color(0xFF10B981)),
                          //   onPressed: () => _resetZoom(_transformController1),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Carga a trabajar: ",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: cargaSeleccionada,
              items: List.generate(cantidadCargas, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text("Carga ${index + 1}"),
                );
              }),
              onChanged: (val) {
                setState(() {
                  cargaSeleccionada = val!;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cantidadCargas,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("Carga ${index + 1}"),
                  subtitle: Text("Valor: ${cargas[index]['valor'] ?? 'N/A'}"
                      "\nPosición: (${cargas[index]['x'] ?? 'N/A'}, ${cargas[index]['y'] ?? 'N/A'})"),
                  trailing: SizedBox(
                    width: 190,
                    child: DropdownButton<String>(
                      hint: const Text("Seleccione un prefijo",
                          style: TextStyle(fontSize: 13)),
                      value: (cargas[index]['prefijo'] ?? '').toString().isEmpty
                          ? null
                          : cargas[index]['prefijo'],
                      items: prefijos.map((String prefijo) {
                        return DropdownMenuItem<String>(
                          value: prefijo,
                          child: Text(prefijo),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() {
                          // Guardar el prefijo en la lista de cargas
                          cargas[index]['prefijo'] = v ?? '';
                          // Mantener el prefijo también en el controller (por si usas _guardarDatos o _restaurarDatos)
                          if (index < prefijoControllers.length) {
                            prefijoControllers[index].text = v ?? '';
                          }
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Guardar en historial",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: guardarHistorial,
                    onChanged: (v) {
                      setState(() {
                        guardarHistorial = v;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
              if (guardarHistorial)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: nombreEjercicioController,
                    decoration: const InputDecoration(
                      labelText: "Nombre del ejercicio",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () async {
                    // Validación de datos
                    _guardarDatos();
                    bool datosValidos = cargas.every((c) =>
                        c['valor'] != '' &&
                        c['x'] != '' &&
                        c['y'] != '' &&
                        c['prefijo'] != '');

                    // Validación extra: valor no debe ser 0 ni decimal, solo entero
                    bool valoresValidos = cargas.every((c) {
                      final valorStr = c['valor']?.toString() ?? '';
                      final valorInt = int.tryParse(valorStr);
                      // Debe ser entero, distinto de 0, y no contener punto decimal
                      return valorInt != null &&
                          valorInt != 0 &&
                          !valorStr.contains('.');
                    });

                    if (!datosValidos) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Por favor completa todos los campos antes de continuar"),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }

                    if (!valoresValidos) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "El valor de cada carga debe ser un número entero distinto de 0 (sin decimales)"),
                        backgroundColor: Colors.red,
                      ));
                      return;
                    }

                    // 💾 Guardar en Firebase si el switch está activado
                    if (guardarHistorial) {
                      if (nombreEjercicioController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Debes ingresar un nombre para guardar el ejercicio"),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      }

                      try {
                        final nombre = nombreEjercicioController.text.trim();

                        await HistorialService().guardarEntrada(
                          datos: datosParaGuardar,
                          nombre: nombre,
                          ejemplo:
                              "Estilo Libre", // usamos el campo tipo para identificarlo
                        );

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Ejercicio guardado exitosamente ✅"),
                          backgroundColor: Colors.green,
                        ));

                        // Cargar anuncio
                        CargarAnuncios.mostrarIntersticial();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error al guardar: $e"),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalcularEstiloLibre(
                          cargas: cargas,
                          cargaBase: cargaSeleccionada,
                        ),
                      ),
                    );
                  },
                  child: const Text("Calcular",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
