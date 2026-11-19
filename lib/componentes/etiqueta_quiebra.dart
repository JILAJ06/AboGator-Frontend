import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/estado_startup.dart';
import 'icono_app.dart';

/// Píldora de "Startup en quiebra" (19b): `estado/ilegal`, relleno 12×6,
/// separación 6, ícono trending-down de 16 y "RIESGO LEGAL 100%" (o
/// "PRESUPUESTO 0%") en Etiqueta `texto/en-primario`.
class EtiquetaQuiebra extends StatelessWidget {
  const EtiquetaQuiebra({required this.causa, super.key});

  static const double tamanoIcono = 16;

  final CausaQuiebra causa;

  String get texto => switch (causa) {
    CausaQuiebra.riesgoLegal => Textos.etiquetaQuiebraRiesgo,
    CausaQuiebra.presupuesto => Textos.etiquetaQuiebraPresupuesto,
  };

  String get etiquetaSemantica => switch (causa) {
    CausaQuiebra.riesgoLegal => Textos.etiquetaQuiebraRiesgoSemantica,
    CausaQuiebra.presupuesto => Textos.etiquetaQuiebraPresupuestoSemantica,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      container: true,
      label: etiquetaSemantica,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: tokens.estadoIlegal,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(IconosApp.trendingDown, tamano: tamanoIcono, color: tokens.textoEnPrimario),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texto,
                style: context.estilos.etiqueta.copyWith(color: tokens.textoEnPrimario),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
