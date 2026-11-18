import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Anillo de foco: trazo de 3 en foco/anillo, separado 2 del control
/// (margen de 5 por lado) y con radio = radio del control + 5.
///
/// Solo pinta; no ocupa espacio ni cambia el tamaño del control. Quien lo usa
/// decide [visible] (normalmente con `FocusableActionDetector.onShowFocusHighlight`,
/// que solo se activa al navegar con teclado o switch control, no con el toque).
class AnilloFoco extends StatelessWidget {
  const AnilloFoco({required this.visible, required this.radio, required this.child, super.key});

  /// Grosor del anillo.
  static const double grosor = 3;

  /// Separación entre el control y el anillo.
  static const double separacion = 2;

  /// Margen total por lado (grosor + separación).
  static const double margen = grosor + separacion;

  final bool visible;

  /// Radio de las esquinas del control envuelto.
  final double radio;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (visible)
          Positioned(
            left: -margen,
            top: -margen,
            right: -margen,
            bottom: -margen,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey('anillo-foco'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radio + margen),
                  border: Border.all(color: context.tokens.focoAnillo, width: grosor),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
