// ignore_for_file: non_constant_identifier_names, file_names

import 'dart:math';

class Formulas {
  static double Hipotenusa(double cateto1, double cateto2) {
    return sqrt(pow(cateto1, 2) + pow(cateto2, 2));
  }

  static double calcularFuerza(double q1, double q2, double r) {
    const k = 8.99e9; // Constante de Coulomb
    return k * (q1 * q2) / pow(r, 2);
  }

  static double componentesX(double fuerza, double angulo) {
    double rad = angulo * (pi / 180);
    return fuerza * cos(rad);
  }

  static double componentesY(double fuerza, double angulo) {
    double rad = angulo * (pi / 180);
    return fuerza * sin(rad);
  }

  static double Fresultante(double componentex, double componentey) {
    double Ft = sqrt(pow(componentex, 2) + pow(componentey, 2));
    return Ft;
  }

  static double Fresultantecaso2(double fuerza1, double fuerza2) {
    double Ft = fuerza1 + fuerza2;
    return Ft;
  }

  static const Map<String, double> valoresPrefijos = {
    'n': 1e-9,
    'μ': 1e-6,
    'm': 1e-3,
    '': 1,
    'k': 1e3,
    'M': 1e6,
    'G': 1e9,
  };
}