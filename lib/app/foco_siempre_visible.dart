import 'package:material_ui/material_ui.dart';

/// Al navegar con teclado, desplaza la vista para que el control enfocado se
/// vea completo (WCAG 2.4.7 y 2.4.11; T-13).
///
/// Flutter ya lo hace al avanzar con Tab, pero al dar la vuelta (del último
/// control al primero, o al revés con Shift+Tab) usa la política del extremo
/// contrario y deja el control fuera de la vista. Este vigilante lo corrige en
/// toda la app. No actúa con toques (modo de resaltado táctil).
class FocoSiempreVisible extends StatefulWidget {
  const FocoSiempreVisible({required this.child, super.key});

  final Widget child;

  @override
  State<FocoSiempreVisible> createState() => _FocoSiempreVisibleState();
}

class _FocoSiempreVisibleState extends State<FocoSiempreVisible> {
  FocusNode? _ultimo;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_alCambiarFoco);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_alCambiarFoco);
    super.dispose();
  }

  void _alCambiarFoco() {
    final nodo = FocusManager.instance.primaryFocus;
    if (nodo == null || identical(nodo, _ultimo)) return;
    _ultimo = nodo;
    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrar(nodo));
  }

  void _mostrar(FocusNode nodo) {
    final contexto = nodo.context;
    if (contexto == null || !contexto.mounted || !nodo.hasPrimaryFocus) return;
    if (Scrollable.maybeOf(contexto) == null) return;
    // Primero por abajo y luego por arriba: si el control es más alto que la
    // vista, gana su borde superior.
    Scrollable.ensureVisible(
      contexto,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    Scrollable.ensureVisible(
      contexto,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
