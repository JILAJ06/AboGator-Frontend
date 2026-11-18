import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Cálculo de contraste según WCAG 2.1.
abstract final class Contraste {
  /// Luminancia relativa (0 = negro, 1 = blanco).
  static double luminancia(Color color) {
    double canal(double c) =>
        c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * canal(color.r) + 0.7152 * canal(color.g) + 0.0722 * canal(color.b);
  }

  /// Razón de contraste entre dos colores (1 a 21).
  static double razon(Color a, Color b) {
    final la = luminancia(a);
    final lb = luminancia(b);
    final mayor = math.max(la, lb);
    final menor = math.min(la, lb);
    return (mayor + 0.05) / (menor + 0.05);
  }

  /// Mínimo para texto normal y colores de estado.
  static const double minimoTexto = 4.5;

  /// Mínimo para bordes, íconos y anillos de foco.
  static const double minimoNoTexto = 3;
}
