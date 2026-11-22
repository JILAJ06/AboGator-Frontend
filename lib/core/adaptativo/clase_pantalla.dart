import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:material_ui/material_ui.dart';

/// Clase de pantalla según el **ancho** (no según el tipo de dispositivo), así
/// sirve igual en web, en pantalla dividida y al rotar.
///
/// - [movil]: menos de [MedidasAdaptativas.minimoTablet] (600).
/// - [tablet]: de 600 a 959 (tablet en vertical o ventana angosta): riel y una
///   sola columna de contenido.
/// - [ancho]: 960 o más (tablet en horizontal): las composiciones de dos
///   columnas de Figma (lienzo de 1194 × 834).
enum ClasePantalla {
  movil,
  tablet,
  ancho;

  /// Clase que corresponde a un ancho disponible.
  static ClasePantalla deAncho(double ancho) {
    if (ancho >= MedidasAdaptativas.minimoAncho) return ClasePantalla.ancho;
    if (ancho >= MedidasAdaptativas.minimoTablet) return ClasePantalla.tablet;
    return ClasePantalla.movil;
  }

  /// `true` en [tablet] y en [ancho]: hay riel y no barra inferior.
  bool get esTablet => this != ClasePantalla.movil;

  /// `true` solo en [ancho]: composiciones de dos columnas.
  bool get esAncho => this == ClasePantalla.ancho;
}

/// Medidas de la rejilla de tablet (Figma "Reglas de adaptación", 106:10163).
abstract final class MedidasAdaptativas {
  /// Ancho a partir del cual se usa la composición de tablet.
  static const double minimoTablet = 600;

  /// Ancho a partir del cual se usan las dos columnas de Figma.
  static const double minimoAncho = 960;

  /// Margen exterior de la rejilla de 12 columnas.
  static const double margen = 32;

  /// Medianil entre columnas.
  static const double medianil = 24;

  /// Ancho del riel de navegación.
  static const double riel = 104;

  /// Columna de formularios y de las pantallas de resultado.
  static const double columnaFormulario = 470;

  /// Ancho de las hojas laterales (T-12c).
  static const double hojaLateral = 376;

  /// Ancho máximo del contenido en una sola columna (tablet entre 600 y 959).
  static const double contenidoUnaColumna = 640;
}

/// Clase de pantalla según el ancho de la **ventana**: la que publica
/// [AmbitoClasePantalla] en la raíz de la app o, si no hay ámbito (pruebas de
/// componentes), la del ancho de `MediaQuery`. Para decidir dentro de un panel
/// o una columna, usa [Adaptativo], que mira el ancho disponible.
extension ClasePantallaContexto on BuildContext {
  ClasePantalla get clasePantalla =>
      _ClaseHeredada.de(this) ?? ClasePantalla.deAncho(MediaQuery.sizeOf(this).width);
}

/// Publica la [ClasePantalla] del ancho real que recibe la app (sus
/// restricciones, no `MediaQuery`), para que `context.clasePantalla` funcione
/// igual en dispositivos, en web y en pruebas que cambian el tamaño de la
/// superficie. Va una sola vez, en el `builder` de `MaterialApp`.
class AmbitoClasePantalla extends StatelessWidget {
  const AmbitoClasePantalla({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.hasBoundedWidth
            ? restricciones.maxWidth
            : MediaQuery.sizeOf(context).width;
        return _ClaseHeredada(clase: ClasePantalla.deAncho(ancho), child: child);
      },
    );
  }
}

class _ClaseHeredada extends InheritedWidget {
  const _ClaseHeredada({required this.clase, required super.child});

  final ClasePantalla clase;

  static ClasePantalla? de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ClaseHeredada>()?.clase;

  @override
  bool updateShouldNotify(_ClaseHeredada anterior) => anterior.clase != clase;
}

/// Construye con la [ClasePantalla] del ancho **disponible** (no el de la
/// ventana), para que funcione igual dentro de paneles y columnas.
class Adaptativo extends StatelessWidget {
  const Adaptativo({required this.constructor, super.key});

  final Widget Function(BuildContext context, ClasePantalla clase) constructor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.hasBoundedWidth
            ? restricciones.maxWidth
            : MediaQuery.sizeOf(context).width;
        return constructor(context, ClasePantalla.deAncho(ancho));
      },
    );
  }
}

/// Orientaciones que permite la app según el **lado corto** del dispositivo
/// (en dp; no cambia al rotar). En el teléfono, solo vertical (el diseño
/// móvil es vertical); en la tablet (lado corto ≥ 600), todas: WCAG 1.3.4
/// pide no bloquear la orientación (T-13).
List<DeviceOrientation> orientacionesPermitidas(Size tamanoDispositivo) =>
    tamanoDispositivo.shortestSide >= MedidasAdaptativas.minimoTablet
    ? DeviceOrientation.values
    : const [DeviceOrientation.portraitUp];
