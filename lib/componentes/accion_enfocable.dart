import 'package:material_ui/material_ui.dart';

import 'anillo_foco.dart';

/// Base de los controles tocables propios: activa con toque, Enter o
/// Espacio, muestra el anillo de foco solo al navegar con teclado y deja la
/// semántica a cargo de quien lo usa ([semantica]).
class AccionEnfocable extends StatefulWidget {
  const AccionEnfocable({
    required this.alPresionar,
    required this.radio,
    required this.child,
    this.nodoFoco,
    this.semantica,
    super.key,
  });

  final VoidCallback? alPresionar;

  /// Radio del control (el anillo usa radio + 5).
  final double radio;
  final Widget child;
  final FocusNode? nodoFoco;

  /// Envuelve el control con su `Semantics` (recibe el hijo ya armado).
  final Widget Function(Widget hijo)? semantica;

  @override
  State<AccionEnfocable> createState() => _AccionEnfocableState();
}

class _AccionEnfocableState extends State<AccionEnfocable> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) {
    final habilitado = widget.alPresionar != null;
    final control = FocusableActionDetector(
      enabled: habilitado,
      focusNode: widget.nodoFoco,
      mouseCursor: habilitado ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onShowFocusHighlight: (valor) => setState(() => _foco = valor),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.alPresionar?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.alPresionar,
        child: AnilloFoco(visible: _foco, radio: widget.radio, child: widget.child),
      ),
    );
    return widget.semantica?.call(control) ?? control;
  }
}
