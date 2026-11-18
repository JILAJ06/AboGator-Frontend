import 'package:material_ui/material_ui.dart';

/// Efectos visuales del diseño que no son tokens de color de Figma.
abstract final class EfectosApp {
  /// Color de la sombra sólida de los botones: #0F294A al 18 % (0x2E).
  static const Color colorSombraSolida = Color(0x2E0F294A);

  /// Brillo de la barra de progreso: blanco al 35 % (0x59).
  static const Color brilloBarra = Color(0x59FFFFFF);

  /// Opacidad del fondo de los chips de impacto (13 %).
  static const double opacidadChipImpacto = 0.13;

  /// Sombra sólida inferior, sin desenfoque.
  static List<BoxShadow> sombraSolida(double desplazamiento) => [
    BoxShadow(color: colorSombraSolida, offset: Offset(0, desplazamiento)),
  ];

  /// Duración de las transiciones cortas. Con "reducir animaciones" es cero.
  static Duration duracion(BuildContext context, {int milisegundos = 120}) {
    return MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : Duration(milliseconds: milisegundos);
  }
}
