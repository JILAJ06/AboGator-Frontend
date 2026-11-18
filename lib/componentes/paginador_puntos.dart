import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Paginador de puntos: alto 8, hueco 8. Inactivo 8×8 en borde/control;
/// activo píldora de 28×8 en accion/primaria.
class PaginadorPuntos extends StatelessWidget {
  const PaginadorPuntos({required this.total, required this.actual, super.key});

  final int total;

  /// Índice de la página actual (empieza en 0).
  final int actual;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duracion = EfectosApp.duracion(context, milisegundos: 200);
    return Semantics(
      label: Textos.paginador(actual + 1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AnimatedContainer(
              duration: duracion,
              width: i == actual ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == actual ? tokens.accionPrimaria : tokens.bordeControl,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
