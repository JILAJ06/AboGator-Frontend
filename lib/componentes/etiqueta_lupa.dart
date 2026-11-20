import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Etiqueta de la Lupa activa (Figma 38:5058): píldora accion/acento con
/// relleno 10/12/6/6, separación 6, `search` de 14 y "Lupa de Auditor:
/// palabras trampa resaltadas" (Etiqueta, texto/en-primario). Flota sobre el
/// borde superior de la tarjeta; se anuncia al aparecer y no recibe foco.
class EtiquetaLupa extends StatelessWidget {
  const EtiquetaLupa({super.key});

  /// Posición respecto a la tarjeta (Figma: (41, 150) con la tarjeta en
  /// (24, 164)).
  static const Offset posicion = Offset(17, -14);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      liveRegion: true,
      label: Textos.lupaActiva,
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('etiqueta-lupa'),
        padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
        decoration: BoxDecoration(
          color: tokens.accionAcento,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(IconosApp.search, tamano: 14, color: tokens.textoEnPrimario),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                Textos.lupaActiva,
                style: context.estilos.etiqueta.copyWith(color: tokens.textoEnPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
