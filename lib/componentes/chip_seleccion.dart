import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';

/// Chip de selección única (por ejemplo, el perfil del registro).
///
/// Píldora con relleno 12×10 y texto Etiqueta. Seleccionado: fondo y borde
/// 1.5 accion/primaria, texto en texto/en-primario. No seleccionado: fondo
/// fondo/superficie, borde 1.5 borde/default. La zona táctil mide ≥ 48 de
/// alto sin cambiar el aspecto.
class ChipSeleccion extends StatelessWidget {
  const ChipSeleccion({
    required this.texto,
    required this.etiquetaSemantica,
    required this.seleccionado,
    required this.alPresionar,
    this.nodoFoco,
    super.key,
  });

  /// Texto visible (puede llevar un emoji decorativo).
  final String texto;

  /// Lo que anuncia el lector, sin emoji (por ejemplo "Perfil Legal, 3 de 3").
  final String etiquetaSemantica;
  final bool seleccionado;
  final VoidCallback? alPresionar;
  final FocusNode? nodoFoco;

  static const double _radio = 999;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pildora = Container(
      key: const ValueKey('pildora-chip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: seleccionado ? tokens.accionPrimaria : tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(_radio),
        border: Border.all(
          color: seleccionado ? tokens.accionPrimaria : tokens.bordeDefault,
          width: 1.5,
        ),
      ),
      child: Text(
        texto,
        style: context.estilos.etiqueta.copyWith(
          color: seleccionado ? tokens.textoEnPrimario : tokens.textoPrimario,
        ),
      ),
    );

    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: 24,
      nodoFoco: nodoFoco,
      semantica: (hijo) => Semantics(
        button: true,
        selected: seleccionado,
        inMutuallyExclusiveGroup: true,
        label: etiquetaSemantica,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(widthFactor: 1, heightFactor: 1, child: pildora),
      ),
    );
  }
}
