import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';
import 'indicadores_startup.dart';

/// Fila "Impacto:" que aparece tras un veredicto, con un chip por cada
/// indicador que cambia. El cambio se comunica con signo y color.
class ImpactoStartup extends StatelessWidget {
  const ImpactoStartup({required this.cambios, super.key});

  /// Cambio de cada indicador. Los que valen 0 no se muestran.
  final Map<IndicadorStartup, int> cambios;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final visibles = [
      for (final indicador in IndicadorStartup.values)
        if ((cambios[indicador] ?? 0) != 0) (indicador, cambios[indicador]!),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          Textos.impacto,
          style: context.estilos.etiqueta.copyWith(color: tokens.textoSecundario),
        ),
        for (final (indicador, cambio) in visibles)
          _ChipImpacto(indicador: indicador, cambio: cambio),
      ],
    );
  }
}

class _ChipImpacto extends StatelessWidget {
  const _ChipImpacto({required this.indicador, required this.cambio});

  final IndicadorStartup indicador;
  final int cambio;

  @override
  Widget build(BuildContext context) {
    final color = indicador.color(context.tokens);
    return Semantics(
      label: Textos.impactoSemantica(indicador.nombre, cambio),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 8, top: 3, bottom: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: EfectosApp.opacidadChipImpacto),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(indicador.icono, tamano: 12, color: color),
            const SizedBox(width: 3),
            Text(
              Textos.impactoValor(cambio),
              style: context.estilos.etiqueta.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
