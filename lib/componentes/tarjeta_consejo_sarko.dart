import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// "Consejo de Sarko": etiqueta "CONSEJO DE SARKO" (Leyenda en texto/acento) y
/// el [consejo] (Cuerpo/Base en texto/primario). Se lee como un solo bloque.
///
/// - Inicio de tablet (Figma 96:578): fondo/superficie, borde 1 borde/default,
///   radio 20, relleno 16 y separación 4.
/// - Tienda de tablet con [destacada] (Figma 101:4545): fondo/destacado sin
///   borde, radio 20, relleno 20 y separación 6.
class TarjetaConsejoSarko extends StatelessWidget {
  const TarjetaConsejoSarko({required this.consejo, this.destacada = false, super.key});

  static const double radio = 20;

  final String consejo;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return MergeSemantics(
      child: Container(
        key: const ValueKey('tarjeta-consejo'),
        padding: EdgeInsets.all(destacada ? 20 : 16),
        decoration: BoxDecoration(
          color: destacada ? tokens.fondoDestacado : tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: destacada ? null : Border.all(color: tokens.bordeDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Textos.consejoEtiqueta,
              style: estilos.leyenda.copyWith(color: tokens.textoAcento),
            ),
            SizedBox(height: destacada ? 6 : 4),
            Text(consejo, style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario)),
          ],
        ),
      ),
    );
  }
}
