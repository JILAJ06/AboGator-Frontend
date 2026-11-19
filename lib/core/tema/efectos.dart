import 'package:material_ui/material_ui.dart';

/// Efectos visuales del diseño que no son tokens de color de Figma.
abstract final class EfectosApp {
  /// Color de la sombra sólida de los botones: #0F294A al 18 % (0x2E).
  static const Color colorSombraSolida = Color(0x2E0F294A);

  /// Brillo de la barra de progreso: blanco al 35 % (0x59).
  static const Color brilloBarra = Color(0x59FFFFFF);

  /// Opacidad del fondo de los chips de impacto (13 %).
  static const double opacidadChipImpacto = 0.13;

  /// Sombra del botón de veredicto: (0, 8), desenfoque 24, #0F294A al 14 % (0x24).
  static const List<BoxShadow> sombraVeredicto = [
    BoxShadow(color: Color(0x240F294A), offset: Offset(0, 8), blurRadius: 24),
  ];

  /// Sombra de la tarjeta de caso: (0, 10), desenfoque 12, #0F294A al 22 % (0x38).
  static const List<BoxShadow> sombraTarjeta = [
    BoxShadow(color: Color(0x380F294A), offset: Offset(0, 10), blurRadius: 12),
  ];

  /// Sombra de la tarjeta héroe: (0, 8), desenfoque 24, #0F294A al 14 %.
  static const List<BoxShadow> sombraHeroe = sombraVeredicto;

  /// Sombra de la tarjeta de módulo: (0, 8), desenfoque 12, #0F294A al 14 %.
  static const List<BoxShadow> sombraModulo = [
    BoxShadow(color: Color(0x240F294A), offset: Offset(0, 8), blurRadius: 12),
  ];

  /// Sombra del botón Buzón: (0, 16), desenfoque 40, #0F294A al 22 % (0x38).
  static const List<BoxShadow> sombraBuzon = [
    BoxShadow(color: Color(0x380F294A), offset: Offset(0, 16), blurRadius: 40),
  ];

  /// Elipse decorativa de la tarjeta héroe: blanco al 8 % (más clara que el verde
  /// en ambos modos, como en Figma 07 y 07b).
  static const Color elipseHeroe = Color(0x14FFFFFF);

  /// Ícono sobre el color de un módulo: blanco fijo (los colores de módulo son
  /// de marca y no cambian con el modo).
  static const Color iconoSobreModulo = Color(0xFFFFFFFF);

  /// Opacidad de la etiqueta de la tarjeta de caso (14 %).
  static const double opacidadEtiquetaCaso = 0.14;

  /// Opacidad de los puntos de carga inactivos del Splash (40 %).
  static const double opacidadPuntoInactivo = 0.4;

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
