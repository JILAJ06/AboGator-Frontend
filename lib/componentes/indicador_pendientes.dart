import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Respuestas guardadas en el dispositivo (Figma 23): `refresh` de 14 y "N
/// respuestas guardadas en el dispositivo (SQLite)" (Leyenda texto/acento,
/// hueco 6), centrado. Ocupa el lugar de la barra de comodines.
class IndicadorPendientes extends StatelessWidget {
  const IndicadorPendientes({required this.cantidad, super.key});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.textoAcento;
    return Semantics(
      liveRegion: true,
      label: Textos.respuestasGuardadasSemantica(cantidad),
      excludeSemantics: true,
      child: Row(
        key: const ValueKey('indicador-pendientes'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconoApp(IconosApp.refresh, tamano: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              Textos.respuestasGuardadas(cantidad),
              textAlign: TextAlign.center,
              style: context.estilos.leyenda.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
