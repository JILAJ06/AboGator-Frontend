import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// "Consejo de Sarko" del Inicio en tablet (Figma 96:578): fondo/superficie,
/// borde 1 borde/default, radio 20, relleno 16 y separación 4. Etiqueta
/// "CONSEJO DE SARKO" (Leyenda en texto/acento) y el [consejo] (Cuerpo/Base en
/// texto/primario). Se lee como un solo bloque.
class TarjetaConsejoSarko extends StatelessWidget {
  const TarjetaConsejoSarko({required this.consejo, super.key});

  static const double radio = 20;

  final String consejo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return MergeSemantics(
      child: Container(
        key: const ValueKey('tarjeta-consejo'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Textos.consejoEtiqueta,
              style: estilos.leyenda.copyWith(color: tokens.textoAcento),
            ),
            const SizedBox(height: 4),
            Text(consejo, style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario)),
          ],
        ),
      ),
    );
  }
}
