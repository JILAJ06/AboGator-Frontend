import 'package:material_ui/material_ui.dart';

import 'anillo_foco.dart';

/// Punto de regreso del foco (T-13): envuelve un bloque (la tarjeta de un
/// artículo de la Tienda) para que, al cerrar el diálogo que abrió, el foco
/// vuelva a él aunque su botón haya quedado deshabilitado.
///
/// Usa un [FocusNode] con `skipTraversal` (lo crea [nodoRetorno]), así Tab no
/// se detiene en él: desde aquí, Tab sigue con los controles de dentro. El
/// anillo se dibuja solo al navegar con teclado.
class FocoRetorno extends StatefulWidget {
  const FocoRetorno({required this.nodoFoco, required this.radio, required this.child, super.key});

  /// Nodo de foco para [FocoRetorno]: no es parada de Tab.
  static FocusNode nodoRetorno(String etiqueta) =>
      FocusNode(debugLabel: etiqueta, skipTraversal: true);

  final FocusNode nodoFoco;

  /// Radio del bloque (el anillo usa radio + 5).
  final double radio;
  final Widget child;

  @override
  State<FocoRetorno> createState() => _FocoRetornoState();
}

class _FocoRetornoState extends State<FocoRetorno> {
  bool _foco = false;

  @override
  Widget build(BuildContext context) => FocusableActionDetector(
    focusNode: widget.nodoFoco,
    // Sin nodo semántico propio: la tarjeta se sigue leyendo como antes.
    includeFocusSemantics: false,
    onShowFocusHighlight: (valor) => setState(() => _foco = valor),
    child: AnilloFoco(visible: _foco, radio: widget.radio, child: widget.child),
  );
}

/// Pide el foco para [nodo] cuando termine el cuadro actual (tras cerrar un
/// diálogo o una hoja, la ruta de abajo ya recuperó su alcance de foco).
void devolverFoco(FocusNode nodo) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (nodo.context != null && nodo.canRequestFocus) nodo.requestFocus();
  });
}
