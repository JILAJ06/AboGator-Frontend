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
  }) : etiquetaBoton = null,
       habilitado = null,
       seleccionado = null,
       enlace = null,
       expandido = null;

  /// Control que se anuncia como botón con [etiqueta] (T-15e): arma
  /// `Semantics(button: true, label, onTap: alPresionar, excludeSemantics: true)`
  /// y pasa tal cual las banderas opcionales ([habilitado], [seleccionado],
  /// [enlace] y [expandido]).
  const AccionEnfocable.boton({
    required this.alPresionar,
    required this.radio,
    required this.child,
    required String etiqueta,
    this.nodoFoco,
    this.habilitado,
    this.seleccionado,
    this.enlace,
    this.expandido,
    super.key,
  }) : etiquetaBoton = etiqueta,
       semantica = null;

  final VoidCallback? alPresionar;

  /// Radio del control (el anillo usa radio + 5).
  final double radio;
  final Widget child;
  final FocusNode? nodoFoco;

  /// Envuelve el control con su `Semantics` (recibe el hijo ya armado).
  final Widget Function(Widget hijo)? semantica;

  /// Etiqueta de botón de [AccionEnfocable.boton].
  final String? etiquetaBoton;
  final bool? habilitado;
  final bool? seleccionado;
  final bool? enlace;
  final bool? expandido;

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
    final etiqueta = widget.etiquetaBoton;
    if (etiqueta != null) {
      return Semantics(
        button: true,
        enabled: widget.habilitado,
        selected: widget.seleccionado,
        link: widget.enlace,
        expanded: widget.expandido,
        label: etiqueta,
        onTap: widget.alPresionar,
        excludeSemantics: true,
        child: control,
      );
    }
    return widget.semantica?.call(control) ?? control;
  }
}
