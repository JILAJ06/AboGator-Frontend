import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'barra_progreso.dart';
import 'boton_cerrar.dart';
import 'chip_hud.dart';

/// Barra de juego (Figma 11:244): alto 56, relleno horizontal 20, separación
/// 14. Botón Salir de 48, columna con "Sprint N · Tarjeta k de n" (Leyenda
/// texto/secundario) y `BarraProgreso`, y el chip de vidas.
class BarraJuego extends StatelessWidget {
  const BarraJuego({
    required this.numeroSprint,
    required this.actual,
    required this.total,
    required this.vidas,
    required this.alSalir,
    super.key,
  });

  static const double alto = 56;

  final int numeroSprint;

  /// Tarjeta actual (1 a [total]).
  final int actual;
  final int total;
  final int vidas;
  final VoidCallback? alSalir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: alto),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            BotonCerrar(alPresionar: alSalir, etiqueta: Textos.salir),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      Textos.juegoPaso(numeroSprint, actual, total),
                      style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BarraProgreso(
                    valor: total == 0 ? 0 : actual / total,
                    etiquetaSemantica: Textos.juegoPaso(numeroSprint, actual, total),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            ChipHud.vidas(vidas),
          ],
        ),
      ),
    );
  }
}
