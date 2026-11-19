import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Reto diario: 342×60 en fondo/destacado, radio 18, relleno 14×12 y
/// separación 12. Ícono flame de 24, dos líneas de texto y el progreso "1/3".
///
/// Solo presentación (no se puede tocar); se lee como un único bloque.
class TarjetaRetoDiario extends StatelessWidget {
  const TarjetaRetoDiario({
    required this.titulo,
    required this.subtitulo,
    required this.actual,
    required this.total,
    super.key,
  });

  final String titulo;
  final String subtitulo;
  final int actual;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Semantics(
      container: true,
      label: '$titulo. $subtitulo. ${Textos.retoSemantica(actual, total)}',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('tarjeta-reto'),
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tokens.fondoDestacado,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            IconoApp(IconosApp.flame, color: tokens.accionAcento),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario)),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Textos.retoProgreso(actual, total),
              style: estilos.etiqueta.copyWith(color: tokens.textoAcento),
            ),
          ],
        ),
      ),
    );
  }
}
