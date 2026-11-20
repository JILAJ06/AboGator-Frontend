import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../datos/modelos/ajustes.dart';

/// Reglas puras de los ajustes (pantalla 26).
abstract final class LogicaAjustes {
  /// Escala de texto efectiva: la del sistema × [porcentaje], con tope de
  /// [Ajustes.escalaMaxima]. Con 100 % se deja la del sistema tal cual, y el
  /// ajuste nunca la hace más chica.
  static double escalaEfectiva(double sistema, int porcentaje) {
    if (porcentaje == 100) return sistema;
    final escalada = sistema * porcentaje / 100;
    return math.max(sistema, math.min(Ajustes.escalaMaxima, escalada));
  }

  /// `true` si el modo efectivo es oscuro ([modo] o, con `system`, el brillo
  /// del sistema).
  static bool oscuroEfectivo(ThemeMode modo, Brightness sistema) => switch (modo) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => sistema == Brightness.dark,
  };

  /// Aplica los ajustes al [MediaQuery] de la app: escala de texto y
  /// "reducir animaciones" (sistema o ajuste).
  static MediaQueryData aplicar(MediaQueryData medios, Ajustes ajustes) {
    final sistema = medios.textScaler.scale(1);
    final escala = escalaEfectiva(sistema, ajustes.escalaTexto);
    return medios.copyWith(
      textScaler: escala == sistema ? medios.textScaler : TextScaler.linear(escala),
      disableAnimations: medios.disableAnimations || ajustes.reducirAnimaciones,
    );
  }
}
