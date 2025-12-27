import 'package:flutter/material.dart';

// Widget
import 'package:ar_flutter_plugin_2/widgets/ar_view.dart';

// Managers
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';

// Datatypes / Models
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_2/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_2/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_2/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_2/models/ar_node.dart';

import 'package:vector_math/vector_math_64.dart' hide Colors;

// ✅ tu utilidad
import 'package:graficos_dinamicos/AR/UtilidadesAr.dart';

class AR extends StatefulWidget {
  const AR({
    super.key,
    required this.modeloAR,
    required this.magnitudFuerzas,
    required this.sumatoriaFuerzas,
    required this.fuerzaResultante,
  });

  final String modeloAR;
  final String magnitudFuerzas;
  final String sumatoriaFuerzas;
  final String fuerzaResultante;

  @override
  State<AR> createState() => _ARState();
}

class _ARState extends State<AR> {
  ARSessionManager? gestorSesionAR;
  ARObjectManager? gestorObjetosAR;
  ARAnchorManager? gestorAnclajesAR;
  ARLocationManager? gestorUbicacionAR;

  ARPlaneAnchor? _anclajeActual;
  ARNode? _nodoActual;

  late String modeloSeleccionado;

  bool _mostrandoAyuda = true;
  bool _modeloCargado = false;
  bool _mostrarCardResultados = true;
  bool _modeloColocado = false;

  // ✅ ARView se crea UNA SOLA VEZ (evita recreación innecesaria)
  late final Widget _vistaAR;

  @override
  void initState() {
    super.initState();
    modeloSeleccionado = UtilidadesAR.normalizarRutaModelo(widget.modeloAR);

    _vistaAR = ARView(
      onARViewCreated: alCrearVistaAR,
      planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
    );
  }

  @override
  void dispose() {
    gestorSesionAR?.dispose();
    super.dispose();
  }

  void alCrearVistaAR(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    gestorSesionAR = sessionManager;
    gestorObjetosAR = objectManager;
    gestorAnclajesAR = anchorManager;
    gestorUbicacionAR = locationManager;

    gestorSesionAR?.onInitialize(
      showPlanes: true,
      showWorldOrigin: false,
      showFeaturePoints: false,
      handleTaps: true,
      handlePans: false,
      handleRotation: false,
    );

    // ✅ init del canal (algunos devices fallan si no se llama)
    try {
      gestorObjetosAR?.onInitialize();
    } catch (_) {}

    gestorSesionAR?.onPlaneOrPointTap = (List<ARHitTestResult> hits) async {
      if (hits.isEmpty) return;

      // 1) Si no hay modelo: colocar (solo si ya se “cargó”)
      if (!_modeloColocado) {
        if (!_modeloCargado) {
          gestorSesionAR?.onError?.call(
            "Primero toca “Cargar modelo seleccionado”.",
          );
          return;
        }

        await _colocarOReubicarModelo(hits, reubicar: false);

        if (_mostrandoAyuda && mounted) {
          setState(() => _mostrandoAyuda = false);
        }
        return;
      }

      // 2) Si ya hay modelo: tap mueve el modelo a otro punto
      await _colocarOReubicarModelo(hits, reubicar: true);

      if (_mostrandoAyuda && mounted) {
        setState(() => _mostrandoAyuda = false);
      }
    };
  }

  Future<void> _colocarOReubicarModelo(
    List<ARHitTestResult> hits, {
    required bool reubicar,
  }) async {
    if (gestorAnclajesAR == null || gestorObjetosAR == null) return;

    final hit = hits.firstWhere(
      (h) => h.type == ARHitTestResultType.plane,
      orElse: () => hits.first,
    );

    // Quitar anchor anterior
    if (_anclajeActual != null) {
      await gestorAnclajesAR!.removeAnchor(_anclajeActual!);
      _anclajeActual = null;
      _nodoActual = null;
    }

    final nuevoAnclaje = ARPlaneAnchor(transformation: hit.worldTransform);
    final okAnclaje = await gestorAnclajesAR!.addAnchor(nuevoAnclaje);
    if (okAnclaje != true) return;

    _anclajeActual = nuevoAnclaje;

    final okNodo = await _crearNodo(forzar: true);
    if (okNodo != true) return;

    if (mounted) {
      setState(() {
        _modeloColocado = true;
        _modeloCargado = false; // se “consume” la carga
      });
    }
  }

  Future<bool?> _crearNodo({bool forzar = false}) async {
    if (gestorObjetosAR == null || _anclajeActual == null) return false;

    // quitar nodo anterior
    if (_nodoActual != null) {
      try {
        await gestorObjetosAR!.removeNode(_nodoActual!);
      } catch (_) {}
      _nodoActual = null;
    }

    final nodoNuevo = ARNode(
      type: NodeType.localGLTF2,
      uri: modeloSeleccionado,
      scale: Vector3(0.15, 0.15, 0.15),
      position: Vector3(0, 0, 0),
      // ✅ rotación neutra (sin joystick por ahora)
      rotation: Vector4(1, 0, 0, 0),
    );

    final ok = await gestorObjetosAR!.addNode(
      nodoNuevo,
      planeAnchor: _anclajeActual!,
    );

    if (ok == true) {
      _nodoActual = nodoNuevo;
      return true;
    }

    gestorSesionAR?.onError?.call("No se pudo cargar: $modeloSeleccionado");
    return false;
  }

  Future<void> _limpiarEscena() async {
    if (gestorAnclajesAR != null && _anclajeActual != null) {
      await gestorAnclajesAR!.removeAnchor(_anclajeActual!);
      _anclajeActual = null;
    }
    _nodoActual = null;

    if (mounted) {
      setState(() {
        _modeloColocado = false;
        _modeloCargado = false;
        _mostrandoAyuda = true;
      });
    }
  }

  void _cargarModeloSeleccionado() {
    setState(() {
      _modeloCargado = true;
      _mostrandoAyuda = true;
    });

    gestorSesionAR?.onError?.call(
      "Modelo cargado. Ahora toca el plano para colocarlo.",
    );
  }

  Widget _superiorResultadosYAyuda() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              if (_mostrarCardResultados)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.78),
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Resultados",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Modelo: ${modeloSeleccionado.split('/').last}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Magnitud: ${widget.magnitudFuerzas}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Sumatoria: ${widget.sumatoriaFuerzas}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Resultante: ${widget.fuerzaResultante}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            tooltip: "Ocultar resultados",
                            onPressed: () =>
                                setState(() => _mostrarCardResultados = false),
                            icon: const Icon(Icons.visibility_off),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white.withOpacity(0.78),
                      child: IconButton(
                        tooltip: "Mostrar resultados",
                        onPressed: () =>
                            setState(() => _mostrarCardResultados = true),
                        icon: const Icon(Icons.visibility),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (_mostrandoAyuda)
                IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.40),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      child: Text(
                        _modeloColocado
                            ? "Toca otro punto del plano para mover el modelo."
                            : "Mueve el celular para detectar el plano.\nLuego toca el piso/mesa para colocar el modelo.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelInferior() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Card(
        color: Colors.white.withOpacity(0.90),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Modelo seleccionado: ${modeloSeleccionado.split('/').last}",
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _cargarModeloSeleccionado,
                  icon: Icon(
                    _modeloCargado ? Icons.check_circle : Icons.download,
                  ),
                  label: Text(
                    _modeloCargado
                        ? "Modelo cargado. Toca el plano para colocarlo"
                        : "Cargar modelo seleccionado",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _limpiarEscena,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Limpiar"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Volver"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _vistaAR,
          _superiorResultadosYAyuda(),
          _panelInferior(),
        ],
      ),
    );
  }
}
