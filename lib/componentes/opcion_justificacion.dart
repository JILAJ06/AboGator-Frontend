import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';

/// Opción de justificación (Figma 10:161): fondo/superficie, borde 1.5
/// borde/default, radio 16, relleno 16×14, separación 12; círculo de
/// selección de 24 con borde 2 borde/control y texto Cuerpo/Base. Se lee como
/// opción de un grupo excluyente ("Opción 1 de 2: …"); elegirla la confirma.
class OpcionJustificacion extends StatelessWidget {
  const OpcionJustificacion({
    required this.texto,
    required this.posicion,
    required this.total,
    required this.alElegir,
    super.key,
  });

  static const double radio = 16;
  static const double tamanoCirculo = 24;

  final String texto;

  /// 1 a [total], para la semántica.
  final int posicion;
  final int total;
  final VoidCallback? alElegir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      alPresionar: alElegir,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        inMutuallyExclusiveGroup: true,
        checked: false,
        enabled: alElegir != null,
        label: Textos.opcionSemantica(texto, posicion, total),
        onTap: alElegir,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        key: ValueKey('opcion-$posicion'),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              key: const ValueKey('circulo-opcion'),
              width: tamanoCirculo,
              height: tamanoCirculo,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: tokens.bordeControl, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: context.estilos.cuerpoBase.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
