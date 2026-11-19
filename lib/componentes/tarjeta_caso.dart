import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'avatar_app.dart';

/// Tarjeta de caso del juego (Figma 10:5): 342×440 (el alto lo da quien la
/// usa), fondo/superficie, borde 1 borde/default, radio 28 y sombra de la
/// tarjeta. Relleno 24/22/20/22 y separación 18 entre: etiqueta del caso (chip
/// con el color del módulo al 14 % y texto/acento), personaje (avatar 48 con
/// iniciales, nombre y rol), globo del caso (fondo/superficie-alt, esquinas
/// 6/20/20/20, Fredoka SemiBold 17/25), un espacio flexible y la pista de
/// gesto, que lleva texto además de color.
///
/// Si el texto del globo no cabe, se desplaza dentro de la tarjeta.
class TarjetaCaso extends StatelessWidget {
  const TarjetaCaso({
    required this.etiquetaCaso,
    required this.colorModulo,
    required this.iniciales,
    required this.personaje,
    required this.rol,
    required this.texto,
    super.key,
  });

  static const double ancho = 342;
  static const double alto = 440;
  static const double radio = 28;

  /// Alto mínimo (la zona de la tarjeta se encoge hasta aquí).
  static const double altoMinimo = 260;

  /// Alto mínimo con el texto dinámico: lo que ocupan el relleno, la
  /// etiqueta, el personaje, dos líneas del globo y la pista. Con texto
  /// grande la zona pide más alto y la pantalla se vuelve desplazable.
  static double altoMinimoPara(TextScaler escala) {
    double s(double tamano) => escala.scale(tamano);
    final contenido =
        24 +
        20 + // relleno
        s(14) +
        10 + // etiqueta
        18 +
        math.max(48, s(20) + 2 + s(14)) + // personaje
        18 +
        36 +
        s(25) * 2 + // globo con dos líneas
        18 +
        math.max(s(16), s(14) * 2 + 2); // pista
    return math.max(altoMinimo, contenido);
  }

  final String etiquetaCaso;
  final Color colorModulo;
  final String iniciales;
  final String personaje;
  final String rol;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;

    return Semantics(
      label: Textos.casoSemantica(personaje, rol, texto),
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('tarjeta-caso'),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault),
          boxShadow: EfectosApp.sombraTarjetaCaso,
        ),
        // Si todo cabe, el globo ocupa el espacio libre y la pista queda al
        // pie; si no (texto grande o tarjeta baja), el contenido se desplaza
        // dentro de la tarjeta.
        child: CustomScrollView(
          key: const ValueKey('contenido-caso'),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: const ValueKey('etiqueta-caso'),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorModulo.withValues(alpha: EfectosApp.opacidadEtiquetaCaso),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      etiquetaCaso,
                      style: estilos.leyenda.copyWith(color: tokens.textoAcento),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      AvatarApp(iniciales: iniciales, tamano: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personaje,
                              style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rol,
                              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        key: const ValueKey('globo-caso'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: tokens.fondoSuperficieAlt,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          texto,
                          style: estilos.h3.copyWith(color: tokens.textoPrimario, height: 25 / 17),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const PistaGesto(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pista de gesto al pie de la tarjeta: "← ILEGAL" (estado/ilegal), "↑
/// CONDICIONAL" sobre "↓ ESCALAR" (estado/condicional y estado/escalar) y
/// "LEGAL →" (estado/legal). Decorativa: los botones dicen lo mismo.
class PistaGesto extends StatelessWidget {
  const PistaGesto({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return ExcludeSemantics(
      child: Row(
        key: const ValueKey('pista-gesto'),
        children: [
          Expanded(
            child: Text(
              Textos.casoPistaIlegal,
              style: estilos.etiqueta.copyWith(color: tokens.estadoIlegal),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Textos.casoPistaCondicional,
                  textAlign: TextAlign.center,
                  style: estilos.leyenda.copyWith(color: tokens.estadoCondicional),
                ),
                const SizedBox(height: 2),
                Text(
                  Textos.casoPistaEscalar,
                  textAlign: TextAlign.center,
                  style: estilos.leyenda.copyWith(color: tokens.estadoEscalar),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              Textos.casoPistaLegal,
              textAlign: TextAlign.right,
              style: estilos.etiqueta.copyWith(color: tokens.estadoLegal),
            ),
          ),
        ],
      ),
    );
  }
}
