import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';

/// Opción de justificación (Figma 10:161): fondo/superficie, borde 1.5
/// borde/default, radio 16, relleno 16×14, separación 12; círculo de
/// selección de 24 con borde 2 borde/control y texto Cuerpo/Base. Se lee como
/// opción de un grupo excluyente ("Opción 1 de 2: …").
///
/// Dos modos:
/// - sin [seleccionada] (micro-pregunta, T-06): elegirla la confirma;
/// - con [seleccionada] (justificación, 18): elegirla solo la selecciona. La
///   Seleccionada (Figma 10:164) lleva borde 2.5 accion/secundaria y el
///   círculo relleno, y se anuncia "seleccionada".
class OpcionJustificacion extends StatelessWidget {
  const OpcionJustificacion({
    required this.texto,
    required this.posicion,
    required this.total,
    required this.alElegir,
    this.seleccionada,
    super.key,
  });

  static const double radio = 16;
  static const double tamanoCirculo = 24;

  final String texto;

  /// 1 a [total], para la semántica.
  final int posicion;
  final int total;
  final VoidCallback? alElegir;

  /// `null`: elegir confirma. `true` o `false`: modo selección.
  final bool? seleccionada;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final elegida = seleccionada ?? false;
    final modoSeleccion = seleccionada != null;
    return AccionEnfocable(
      alPresionar: alElegir,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        inMutuallyExclusiveGroup: true,
        checked: elegida,
        selected: elegida,
        enabled: alElegir != null,
        label: modoSeleccion
            ? Textos.opcionSeleccionSemantica(texto, posicion, total, seleccionada: elegida)
            : Textos.opcionSemantica(texto, posicion, total),
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
          border: elegida
              ? Border.all(color: tokens.accionSecundaria, width: 2.5)
              : Border.all(color: tokens.bordeDefault, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              key: const ValueKey('circulo-opcion'),
              width: tamanoCirculo,
              height: tamanoCirculo,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: elegida ? tokens.accionSecundaria : tokens.bordeControl,
                  width: 2,
                ),
              ),
              child: elegida
                  ? Center(
                      child: Container(
                        key: const ValueKey('punto-opcion'),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: tokens.accionSecundaria,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
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
