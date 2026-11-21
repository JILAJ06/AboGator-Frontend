import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';
import 'barra_comodines.dart';
import 'barra_juego.dart';

/// Composición del juego en tablet horizontal (T10, Figma `97:772`), sin riel:
/// barra de 64 arriba (x 24, y 8); a la izquierda (de 24 a ventana − 424) la
/// tarjeta de 380 × 470 centrada con su pila, los botones de veredicto y los
/// comodines; a la derecha el panel lateral de 376 (margen 24) con "Tu
/// Startup", el contexto del sprint y los atajos. Con texto grande el panel
/// pasa debajo y todo se desplaza en una columna. La usan el juego (T10) y el
/// Juicio de apelación (T22: [comodines] es la nota del juicio).
class ComposicionJuegoTablet extends StatelessWidget {
  const ComposicionJuegoTablet({
    required this.barra,
    required this.zonaTarjeta,
    required this.altoMinimoZona,
    required this.acciones,
    required this.comodines,
    required this.panel,
    this.interruptorDebug,
    super.key,
  });

  static const double anchoTarjeta = 380;

  /// Tarjeta de 470 más los 20 de la pila.
  /// Los 20 de la pila debajo de la tarjeta (`MazoSwipe.altoPila`).
  static const double altoPila = 20;

  static const double altoZona = 470 + altoPila;

  static const double margen = 24;
  static const double arribaBarra = 8;

  /// De la barra a la tarjeta (Figma: 108 − 72).
  static const double bajoBarra = 36;
  static const double bajoAcciones = 16;
  static const double separacionPanel = 16;
  static const double abajo = 24;

  final Widget barra;
  final Widget zonaTarjeta;
  final double altoMinimoZona;
  final Widget acciones;
  final Widget comodines;
  final List<Widget> panel;
  final Widget? interruptorDebug;

  @override
  Widget build(BuildContext context) {
    final textoGrande = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final columnaPanel = Column(
      key: const ValueKey('panel-lateral-juego'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, p) in panel.indexed) ...[
          if (i > 0) const SizedBox(height: separacionPanel),
          p,
        ],
      ],
    );
    final debug = interruptorDebug;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, restricciones) {
          Widget zona(double alto) => Center(
            child: SizedBox(
              key: const ValueKey('zona-tarjeta-tablet'),
              width: anchoTarjeta,
              height: alto,
              child: zonaTarjeta,
            ),
          );
          final cabeza = Padding(
            padding: const EdgeInsets.fromLTRB(margen, arribaBarra, margen, 0),
            child: barra,
          );
          final bajo = <Widget>[
            Center(child: acciones),
            const SizedBox(height: bajoAcciones),
            Center(child: comodines),
            if (debug != null) ...[const SizedBox(height: 8), Center(child: debug)],
          ];

          if (textoGrande) {
            // Una columna que se desplaza: la zona de juego y, debajo, el panel.
            return SingleChildScrollView(
              key: const ValueKey('juego-desplazable'),
              padding: const EdgeInsets.only(bottom: abajo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cabeza,
                  const SizedBox(height: bajoBarra),
                  zona(altoZona > altoMinimoZona ? altoZona : altoMinimoZona),
                  ...bajo,
                  const SizedBox(height: abajo),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: MedidasAdaptativas.contenidoUnaColumna,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: margen),
                        child: columnaPanel,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Alto de la zona: el de Figma si cabe; si no, se encoge hasta el
          // mínimo del móvil y la pantalla se desplaza si aun así no cabe.
          const fijo =
              arribaBarra +
              BarraJuegoTablet.alto +
              bajoBarra +
              90 +
              bajoAcciones +
              BarraComodines.alto +
              abajo;
          final disponible = restricciones.maxHeight - fijo;
          final altoTarjeta = disponible.clamp(altoMinimoZona, altoZona);
          final altoTotal = fijo + altoTarjeta > restricciones.maxHeight
              ? fijo + altoTarjeta
              : restricciones.maxHeight;

          return SingleChildScrollView(
            key: const ValueKey('juego-desplazable'),
            child: SizedBox(
              height: altoTotal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cabeza,
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: margen),
                        Expanded(
                          child: Column(
                            key: const ValueKey('zona-juego-tablet'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: bajoBarra),
                              zona(altoTarjeta),
                              ...bajo,
                            ],
                          ),
                        ),
                        const SizedBox(width: margen),
                        SizedBox(
                          width: MedidasAdaptativas.hojaLateral,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: margen, bottom: abajo),
                            child: columnaPanel,
                          ),
                        ),
                        const SizedBox(width: margen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
