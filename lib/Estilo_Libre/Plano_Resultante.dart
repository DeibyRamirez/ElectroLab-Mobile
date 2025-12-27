// ignore_for_file: prefer_const_constructors, file_names, unused_element, curly_braces_in_flow_control_structures
import 'dart:math';
import 'package:flutter/material.dart';

class PlanoFuerzaResultantePainter extends CustomPainter {
  final double anguloResultante; // en grados
  final double magnitudResultante; // en N
  // Origen del vector en coordenadas (usar las componentes de la fuerza resultante)
  final double origenX;
  final double origenY;

  PlanoFuerzaResultantePainter({
    required this.anguloResultante,
    required this.magnitudResultante,
    this.origenX = 0.0,
    this.origenY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 60;

    // Fondo
    final paintBackground = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Offset.zero & size, paintBackground);

    // Cuadrícula
    final paintMinorGrid = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 0.5;
    final paintMajorGrid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;

    for (int i = -30; i <= 30; i++) {
      final dx = center.dx + i * scale;
      final dy = center.dy + i * scale;
      if (i % 5 != 0) {
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paintMinorGrid);
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paintMinorGrid);
      } else {
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paintMajorGrid);
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paintMajorGrid);
      }
    }

    // Ejes
    final paintAxis = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), paintAxis);
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), paintAxis);

    // Calcular dirección del vector
    final double rad = anguloResultante * pi / 180;

    // Longitud estándar de la línea (visual)
    double longitudLinea = 77;

    // Escala del plano para convertir unidades lógicas a píxeles
    // (ya definido arriba como 'scale')

    // Calcular el punto de inicio del vector usando las componentes proporcionadas
    // originRaw en unidades dadas por origenX/origenY
    final double rawX = origenX;
    final double rawY = origenY;

    // Convertir directamente a píxeles
    final Offset pixelFromRaw = Offset(
      center.dx + rawX * scale,
      center.dy - rawY * scale,
    );

    // Formateador simple: usa notación científica si hace falta
    String fmtNum(double v) {
      final av = v.abs();
      if (av != 0 && (av < 0.001 || av >= 1000))
        return v.toStringAsExponential(2);
      return v.toStringAsFixed(4);
    }

    // Si la posición calculada queda fuera del canvas, aplicamos un escalado
    // proporcional para que el punto quede visible manteniendo la relación entre X/Y.
    const double margin = 8.0;
    final double maxAllowedX = size.width / 2 - margin;
    final double maxAllowedY = size.height / 2 - margin;

    final double maxComp = max(rawX.abs(), rawY.abs());

    Offset visibleOrigin;
    if (maxComp == 0) {
      visibleOrigin = center;
    } else {
      // tamaño en píxeles del mayor componente
      final double maxCompPixels = maxComp * scale;
      if (maxCompPixels <= max(maxAllowedX, maxAllowedY)) {
        // cabe en el canvas sin escalar
        visibleOrigin = pixelFromRaw;
      } else {
        // escalamos proporcionalmente para que el mayor componente quede en el borde
        final double factor = (max(maxAllowedX, maxAllowedY) / maxCompPixels) *
            0.95; // margen extra
        visibleOrigin = Offset(
          center.dx + rawX * scale * factor,
          center.dy - rawY * scale * factor,
        );
      }
    }

    // Punto final del vector basado en la dirección y longitud visual
    final Offset lineEnd = Offset(
      visibleOrigin.dx + longitudLinea * cos(rad),
      visibleOrigin.dy - longitudLinea * sin(rad),
    );

    // --- DEBUG: mostrar datos de origen y posiciones en pantalla ---
    // final debugStyle = const TextStyle(color: Colors.white, fontSize: 10);
    // final debugBg = Paint()..color = Colors.black.withOpacity(0.6);
    // String debugText =
    //     'raw:(${fmtNum(rawX)}, ${fmtNum(rawY)})\npix:(${pixelFromRaw.dx.toStringAsFixed(1)}, ${pixelFromRaw.dy.toStringAsFixed(1)})\nvisible:(${visibleOrigin.dx.toStringAsFixed(1)}, ${visibleOrigin.dy.toStringAsFixed(1)})';
    // final debugPainter = TextPainter(
    //   text: TextSpan(text: debugText, style: debugStyle),
    //   textDirection: TextDirection.ltr,
    // );
    // debugPainter.layout(maxWidth: size.width * 0.6);
    // // fondo del recuadro
    // final rectPadding = 6.0;
    // final rect = Rect.fromLTWH(
    //   8,
    //   8,
    //   debugPainter.width + rectPadding * 2,
    //   debugPainter.height + rectPadding * 2,
    // );
    // canvas.drawRRect(
    //     RRect.fromRectAndRadius(rect, const Radius.circular(6)), debugBg);
    // debugPainter.paint(canvas, Offset(8 + rectPadding, 8 + rectPadding / 2));

    // Línea principal del vector
    final Paint lineaPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(visibleOrigin, lineEnd, lineaPaint);

    // 🔺 Flecha (punta del vector)
    const double flechaTam = 20; // tamaño del triángulo
    final Path flecha = Path();
    flecha.moveTo(lineEnd.dx, lineEnd.dy);
    flecha.lineTo(
      lineEnd.dx - flechaTam * cos(rad - pi / 8),
      lineEnd.dy + flechaTam * sin(rad - pi / 8),
    );
    flecha.lineTo(
      lineEnd.dx - flechaTam * cos(rad + pi / 8),
      lineEnd.dy + flechaTam * sin(rad + pi / 8),
    );
    flecha.close();

    final Paint flechaPaint = Paint()
      ..color = Colors.blue.shade900
      ..style = PaintingStyle.fill;
    canvas.drawPath(flecha, flechaPaint);

    // Indicador morado en el origen del vector (usando las componentes como coordenadas)
    // Removimos el círculo rojo en 0,0 y el '+' del centro.
    final paintIndicador = Paint()
      ..color = const Color.fromARGB(255, 38, 0, 255)
      ..style = PaintingStyle.fill;
    final paintIndicadorBorde = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double radioIndicador = 6;
    // Si el originOffset queda fuera del canvas, lo dejamos tal cual (posible ajuste posterior).
    canvas.drawCircle(visibleOrigin, radioIndicador, paintIndicador);
    canvas.drawCircle(visibleOrigin, radioIndicador, paintIndicadorBorde);

    // Preparar TextPainter para etiquetas y para la etiqueta de coordenadas
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Mostrar etiqueta con las coordenadas (Fx, Fy) cerca del indicador
    // textPainter.text = TextSpan(
    //   text: "(${fmtNum(origenX)}, ${fmtNum(origenY)})",
    //   style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
    // );
    // textPainter.layout();
    // // Posicionar la etiqueta a la derecha y ligeramente hacia arriba del indicador
    // final labelOffset = Offset(visibleOrigin.dx + radioIndicador + 4,
    //     visibleOrigin.dy - textPainter.height / 2 - radioIndicador / 2);
    // // Asegurar que la etiqueta no salga del canvas
    // final dxLabel = labelOffset.dx.clamp(0.0, size.width - textPainter.width);
    // final dyLabel = labelOffset.dy.clamp(0.0, size.height - textPainter.height);
    // textPainter.paint(canvas, Offset(dxLabel, dyLabel));

    // 📏 Etiquetas de los ejes (numeracion)

    for (int i = -25; i <= 25; i += 5) {
      if (i != 0) {
        final xPos = center.dx + i * scale;
        final yPos = center.dy - i * scale;

        if (xPos >= 0 && xPos <= size.width) {
          textPainter.text = TextSpan(
            text: "$i",
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 8),
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(xPos - textPainter.width / 2, center.dy + 8));
        }

        if (yPos >= 0 && yPos <= size.height) {
          textPainter.text = TextSpan(
            text: "$i",
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 8),
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(center.dx + 8, yPos - textPainter.height / 2));
        }
      }
    }

    // Signo +
    // final textPainter = TextPainter(
    //   textAlign: TextAlign.center,
    //   textDirection: TextDirection.ltr,
    // );
    // Ya no dibujamos el '+' en el centro
  }

  @override
  bool shouldRepaint(covariant PlanoFuerzaResultantePainter oldDelegate) =>
      oldDelegate.anguloResultante != anguloResultante ||
      oldDelegate.magnitudResultante != magnitudResultante ||
      oldDelegate.origenX != origenX ||
      oldDelegate.origenY != origenY;
}
