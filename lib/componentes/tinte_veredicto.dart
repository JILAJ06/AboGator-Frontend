import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'boton_veredicto.dart';

/// Tinte de pantalla completa en el color del veredicto, de 0 (reposo) a
/// 0.10 (umbral). Va detrás de la tarjeta y delante del fondo. Decorativo.
class TinteVeredicto extends StatelessWidget {
  const TinteVeredicto({required this.veredicto, required this.opacidad, super.key});

  final Veredicto? veredicto;

  /// Opacidad final del color (0 a 0.10).
  final double opacidad;

  @override
  Widget build(BuildContext context) {
    final v = veredicto;
    if (v == null || opacidad <= 0) return const SizedBox.expand();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ColoredBox(
          key: ValueKey('tinte-${v.name}'),
          color: BotonVeredicto.color(v, context.tokens).withValues(alpha: opacidad),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
