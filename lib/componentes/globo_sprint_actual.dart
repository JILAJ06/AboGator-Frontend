import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'boton_app.dart';

/// Globo del sprint actual (Figma 13:685): fondo/superficie, radio 16,
/// relleno 14×12, sombra elevada (0, 16, 40, 22 %). Título en Cuerpo/Énfasis,
/// detalle en Leyenda texto/secundario y botón acento "Comenzar" de 170×48,
/// con 8 de separación.
class GloboSprintActual extends StatelessWidget {
  const GloboSprintActual({
    required this.titulo,
    required this.detalle,
    required this.alComenzar,
    super.key,
  });

  static const double radio = 16;
  static const double anchoBoton = 170;
  static const double altoBoton = 48;

  /// Ancho máximo (el del contenido de la pantalla).
  static const double anchoMaximo = 342;

  final String titulo;
  final String detalle;
  final VoidCallback? alComenzar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Container(
      key: const ValueKey('globo-sprint'),
      constraints: const BoxConstraints(maxWidth: anchoMaximo),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        boxShadow: EfectosApp.sombraGlobo,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario)),
                const SizedBox(height: 8),
                Text(detalle, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: anchoBoton),
            child: BotonApp(
              texto: Textos.comenzar,
              tipo: TipoBoton.acento,
              expandido: false,
              altoMinimo: altoBoton,
              alPresionar: alComenzar,
            ),
          ),
        ],
      ),
    );
  }
}
