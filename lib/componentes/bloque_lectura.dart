import 'package:material_ui/material_ui.dart';

import 'anillo_foco.dart';

/// Bloque que se lee completo y recibe foco con teclado, aunque no haga nada
/// al activarlo (indicadores y comodines del juego; título, impacto y
/// explicación del panel de veredicto). Muestra el anillo de foco solo al
/// navegar con teclado.
class BloqueLectura extends StatefulWidget {
  const BloqueLectura({
    required this.child,
    this.etiqueta,
    this.encabezado = false,
    this.enVivo = false,
    this.excluirHijos = false,
    this.autofocus = false,
    this.radio = 16,
    this.nodoFoco,
    super.key,
  });

  final Widget child;

  /// Lo que se lee; con [excluirHijos] reemplaza a los textos del hijo.
  final String? etiqueta;
  final bool encabezado;

  /// Se anuncia al aparecer o cambiar.
  final bool enVivo;
  final bool excluirHijos;
  final bool autofocus;

  /// Radio del bloque (el anillo usa radio + 5).
  final double radio;

  /// Nodo de foco propio (para pedir el foco desde fuera).
  final FocusNode? nodoFoco;

  @override
  State<BloqueLectura> createState() => _BloqueLecturaState();
}

class _BloqueLecturaState extends State<BloqueLectura> {
  bool _foco = false;

  /// El foco que llega por [BloqueLectura.autofocus] no dibuja el anillo
  /// (solo lo hace cuando se llega navegando con teclado).
  late bool _focoInicial = widget.autofocus;

  @override
  Widget build(BuildContext context) {
    final contenido = FocusableActionDetector(
      autofocus: widget.autofocus,
      focusNode: widget.nodoFoco,
      onShowFocusHighlight: (valor) => setState(() => _foco = valor && !_focoInicial),
      onFocusChange: (enfocado) {
        if (!enfocado && _focoInicial) setState(() => _focoInicial = false);
      },
      child: AnilloFoco(visible: _foco, radio: widget.radio, child: widget.child),
    );
    if (widget.excluirHijos) {
      return Semantics(
        container: true,
        header: widget.encabezado,
        liveRegion: widget.enVivo,
        label: widget.etiqueta,
        excludeSemantics: true,
        child: contenido,
      );
    }
    return Semantics(
      container: true,
      header: widget.encabezado,
      liveRegion: widget.enVivo,
      label: widget.etiqueta,
      child: MergeSemantics(child: contenido),
    );
  }
}
