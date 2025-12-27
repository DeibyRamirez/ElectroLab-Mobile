// ignore_for_file: file_names

import 'dart:math';

class Notacioncientifica {
  String formatearNotacionCientifica(double numero, int decimales) {
    if (numero == 0) return '0.0';

    int exponente = (log(numero.abs()) / ln10).floor();
    double mantisa = numero / pow(10, exponente);

    return '${mantisa.toStringAsFixed(decimales)} × 10^$exponente';
  }
}
