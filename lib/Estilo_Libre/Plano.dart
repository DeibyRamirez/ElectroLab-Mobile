// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

// ---------------- PINTOR DEL PLANO ----------------
class PlanoPainter extends CustomPainter {
  final List<Map<String, dynamic>> cargas;
  final int? cargaSeleccionada;

  PlanoPainter(this.cargas, {this.cargaSeleccionada});

  // Función auxiliar: convierte null/int/double/string (con ',' o '.') a double
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    // permitir coma decimal
    final normalized = s.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double scale = size.width / 60.0; // px por unidad (double)

    final paintBackground = Paint()..color = const Color(0xFFFAFAFA);
    canvas.drawRect(Offset.zero & size, paintBackground);

    final paintMajorGrid = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;

    final paintMinorGrid = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 0.5;

    for (int i = -30; i <= 30; i += 5) {
      if (i % 5 != 0) {
        final dx = center.dx + i * scale;
        final dy = center.dy + i * scale;
        if (dx >= 0 && dx <= size.width) {
          canvas.drawLine(
              Offset(dx, 0), Offset(dx, size.height), paintMinorGrid);
        }
        if (dy >= 0 && dy <= size.height) {
          canvas.drawLine(
              Offset(0, dy), Offset(size.width, dy), paintMinorGrid);
        }
      }
    }

    for (int i = -30; i <= 30; i += 5) {
      final dx = center.dx + i * scale;
      final dy = center.dy + i * scale;
      if (dx >= 0 && dx <= size.width) {
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paintMajorGrid);
      }
      if (dy >= 0 && dy <= size.height) {
        canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paintMajorGrid);
      }
    }

    final paintAxis = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 2.0;

    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), paintAxis);
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), paintAxis);

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = -25; i <= 25; i += 5) {
      if (i != 0) {
        final xPos = center.dx + i * scale;
        if (xPos >= 0 && xPos <= size.width) {
          textPainter.text = TextSpan(
            text: "$i",
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(xPos - textPainter.width / 2, center.dy + 8));
        }

        final yPos = center.dy - i * scale;
        if (yPos >= 0 && yPos <= size.height) {
          textPainter.text = TextSpan(
            text: "$i",
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          );
          textPainter.layout();
          textPainter.paint(
              canvas, Offset(center.dx + 8, yPos - textPainter.height / 2));
        }
      }
    }

    for (int i = 0; i < cargas.length; i++) {
      var carga = cargas[i];

      // ahora soportamos decimales y strings con coma
      final double x = _toDouble(carga['x']);
      final double y = _toDouble(carga['y']);
      final double valor = _toDouble(carga['valor']);

      final Offset pos = Offset(center.dx + x * scale, center.dy - y * scale);

      if (pos.dx >= -20 &&
          pos.dx <= size.width + 20 &&
          pos.dy >= -20 &&
          pos.dy <= size.height + 20) {
        final color =
            valor >= 0 ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
        final isSelected = (i + 1 == cargaSeleccionada);

        if (isSelected) {
          final paintSelection = Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 18, paintSelection);

          final paintSelectionBorder = Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(pos, 18, paintSelectionBorder);
        }

        final paintCarga = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final paintBorder = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        double radio = isSelected ? 12 : 10;
        canvas.drawCircle(pos, radio, paintCarga);
        canvas.drawCircle(pos, radio, paintBorder);

        textPainter.text = TextSpan(
          text: valor >= 0 ? "+" : "−",
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
            canvas,
            Offset(pos.dx - textPainter.width / 2,
                pos.dy - textPainter.height / 2));

        final etiqueta = "q${i + 1}";

        textPainter.text = TextSpan(
          text: etiqueta,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.white70,
                blurRadius: 2,
              ),
            ],
          ),
        );
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + radio + 6));
      }
    }

    final paintOrigin = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, paintOrigin);

    textPainter.text = const TextSpan(
      text: "O",
      style: TextStyle(
        color: Color(0xFF374151),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + 12, center.dy + 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
