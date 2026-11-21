import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';

/// Hoja lateral de tablet (T-12c, Figma T12 `97:1869`, T14, T16, T18 y T10c):
/// los paneles del juego (veredicto, bonus, evidencia, justificación y Abogado
/// Senior) se muestran a la derecha, de 376 de ancho, a 24 del borde derecho y
/// 22 del inferior, con el alto de su contenido (hasta [margenSuperior] del
/// borde de arriba, y se desplazan por dentro si no caben).
///
/// No cambia el contenido: solo lo aloja. Los paneles leen [enHoja] para
/// dibujar las cuatro esquinas redondeadas y el borde de 1 en lugar de la
/// forma de hoja inferior del móvil. Se anuncia como un contenedor con
/// [etiqueta] ("Retroalimentación", "Evidencia"…).
class HojaLateral extends StatelessWidget {
  const HojaLateral({required this.etiqueta, required this.child, super.key});

  static const double ancho = MedidasAdaptativas.hojaLateral;
  static const double margenDerecho = 24;
  static const double margenInferior = 22;

  /// La hoja no sube más allá del panel lateral (Figma: y 88 sin la barra).
  static const double margenSuperior = 88;

  static const double radio = 28;

  final String etiqueta;
  final Widget child;

  /// `true` si [context] está dentro de una hoja lateral.
  static bool enHoja(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AmbitoHoja>() != null;

  /// Esquinas del panel: las cuatro en la hoja lateral; solo las de arriba en
  /// la hoja inferior del móvil.
  static BorderRadius radioDe(BuildContext context, double radio) => enHoja(context)
      ? BorderRadius.circular(radio)
      : BorderRadius.vertical(top: Radius.circular(radio));

  /// Borde de la hoja lateral (1 en [color]); ninguno en el móvil.
  static Border? bordeDe(BuildContext context, Color color) =>
      enHoja(context) ? Border.all(color: color) : null;

  /// Relleno inferior del panel: 34 y, en el móvil, la zona segura inferior.
  static double rellenoInferior(BuildContext context) =>
      34 + (enHoja(context) ? 0 : MediaQuery.paddingOf(context).bottom);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: margenSuperior,
          right: margenDerecho,
          bottom: margenInferior,
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            key: const ValueKey('hoja-lateral'),
            width: ancho,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: true,
              label: etiqueta,
              child: _AmbitoHoja(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbitoHoja extends InheritedWidget {
  const _AmbitoHoja({required super.child});

  @override
  bool updateShouldNotify(_AmbitoHoja anterior) => false;
}
