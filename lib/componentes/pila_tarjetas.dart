import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'tarjeta_caso.dart';

/// Pila detrás de la tarjeta: Pila 1 (12 más adentro por lado y 10 más abajo,
/// al 80 %) y Pila 2 (24 por lado y 20 más abajo, al 50 %), con el mismo estilo
/// de tarjeta sin contenido. Se dibuja solo la que tenga tarjetas detrás.
///
/// Ocupa todo el alto de la zona: la tarjeta mide el alto de la zona − 20.
class PilaTarjetas extends StatelessWidget {
  const PilaTarjetas({required this.restantes, super.key});

  /// Tarjetas que quedan detrás de la actual.
  final int restantes;

  static const double desplazamiento = 10;
  static const double margen = 12;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget capa(int nivel, double opacidad) => Positioned(
      key: ValueKey('pila-$nivel'),
      left: margen * nivel,
      right: margen * nivel,
      top: desplazamiento * nivel,
      bottom: desplazamiento * (2 - nivel),
      child: Opacity(
        opacity: opacidad,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.fondoSuperficie,
            borderRadius: BorderRadius.circular(TarjetaCaso.radio),
            border: Border.all(color: tokens.bordeDefault),
          ),
        ),
      ),
    );
    return ExcludeSemantics(
      child: Stack(
        children: [
          if (restantes >= 2) capa(2, EfectosApp.opacidadPila2),
          if (restantes >= 1) capa(1, EfectosApp.opacidadPila1),
        ],
      ),
    );
  }
}
