// ignore_for_file: file_names

class UtilidadesAR {
  /// Normaliza un nombre/ruta de modelo a una ruta de asset válida.
  /// Acepta:
  /// - "assets/Caso(-,-,-)_respecto_C1.glb"
  /// - "Caso(-,-,-)_respecto_C1.glb"
  /// - "Resultantes_Triangulo_EyR/Caso_Resul(+,-,+)_TE_respecto_C1.glb"
  static String normalizarRutaModelo(String modelo) {
    final m = modelo.trim();

    if (m.isEmpty) {
      return "assets/Carga_negativa.glb";
    }

    // Si ya viene con assets/, se respeta
    if (m.startsWith("assets/")) return m;

    // Si viene como subcarpeta relativa (ej: Resultantes_Triangulo_EyR/xxx.glb)
    if (m.contains("/") || m.contains(r"\")) {
      final limpio = m.replaceAll(r"\", "/");
      return "assets/$limpio";
    }

    // Si viene solo el nombre del archivo
    return "assets/$m";
  }
}
