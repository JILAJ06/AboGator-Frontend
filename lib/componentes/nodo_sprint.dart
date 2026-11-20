import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Los 4 estados del nodo de nivel de Figma (10:119, 10:135, 10:143, 10:150).
enum TipoNodoSprint {
  /// Cara 72 accion/primaria con check de 30 y estrellas debajo (caja 96×106).
  completado(96, 106, 72, 30),

  /// Cara 80 accion/acento con gavel de 34 y aro de pulso de 100 (caja 104×114).
  actual(104, 114, 80, 34),

  /// Cara 72 fondo/superficie-alt con lock de 30 (caja 96×106).
  bloqueado(96, 106, 72, 30),

  /// Examen final: cara 92 accion/secundaria con trophy de 39 (caja 116×126).
  jefe(116, 126, 92, 39);

  const TipoNodoSprint(this.ancho, this.alto, this.cara, this.icono);

  final double ancho;
  final double alto;

  /// Diámetro de la cara.
  final double cara;
  final double icono;

  /// Centro de la cara dentro de la caja: la cara está en (12, 10).
  Offset get centroCara => Offset(12 + cara / 2, 10 + cara / 2);
}

/// Nodo de un sprint en el mapa: cara circular sobre una base (sombra sólida
/// inferior, 8 más abajo), con el ícono de su estado.
///
/// Sin [alPresionar] no responde ni recibe foco, pero se sigue anunciando con
/// [etiquetaSemantica] (como deshabilitado). Las estrellas y el pulso son
/// decorativos: el número de estrellas va en la etiqueta.
class NodoSprint extends StatelessWidget {
  const NodoSprint({
    required this.tipo,
    required this.etiquetaSemantica,
    required this.alPresionar,
    this.estrellas = 0,
    this.nodoFoco,
    super.key,
  });

  /// Estrellas posibles (se pintan solo en el estado completado).
  static const int maximoEstrellas = 3;
  static const double tamanoEstrella = 16;

  final TipoNodoSprint tipo;
  final String etiquetaSemantica;
  final VoidCallback? alPresionar;
  final int estrellas;
  final FocusNode? nodoFoco;

  /// Color de la cara según el estado.
  static Color colorCara(TipoNodoSprint tipo, TokensColor t) => switch (tipo) {
    TipoNodoSprint.completado => t.accionPrimaria,
    TipoNodoSprint.actual => t.accionAcento,
    TipoNodoSprint.bloqueado => t.fondoSuperficieAlt,
    TipoNodoSprint.jefe => t.accionSecundaria,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final cara = colorCara(tipo, tokens);
    final (icono, colorIcono) = switch (tipo) {
      TipoNodoSprint.completado => (IconosApp.check, tokens.textoEnPrimario),
      TipoNodoSprint.actual => (IconosApp.gavel, tokens.textoEnPrimario),
      TipoNodoSprint.bloqueado => (IconosApp.lock, tokens.textoSecundario),
      TipoNodoSprint.jefe => (IconosApp.trophy, tokens.textoEnPrimario),
    };

    final dibujo = SizedBox(
      key: ValueKey('nodo-${tipo.name}'),
      width: tipo.ancho,
      height: tipo.alto,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (tipo == TipoNodoSprint.actual)
            Positioned(
              left: 2,
              top: 0,
              child: Container(
                key: const ValueKey('pulso-nodo'),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tokens.accionAcento.withValues(alpha: EfectosApp.opacidadPulso),
                    width: 3,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            top: 18,
            child: Container(
              key: const ValueKey('base-nodo'),
              width: tipo.cara,
              height: tipo.cara,
              decoration: BoxDecoration(color: EfectosApp.baseNodo(cara), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 12,
            top: 10,
            child: Container(
              key: const ValueKey('cara-nodo'),
              width: tipo.cara,
              height: tipo.cara,
              decoration: BoxDecoration(color: cara, shape: BoxShape.circle),
              child: Center(
                child: IconoApp(icono, tamano: tipo.icono, color: colorIcono),
              ),
            ),
          ),
          if (tipo == TipoNodoSprint.completado)
            Positioned(
              left: 0,
              right: 0,
              top: 86,
              child: Center(child: EstrellasSprint(estrellas: estrellas)),
            ),
        ],
      ),
    );

    final radio = tipo.cara / 2;
    return Semantics(
      button: true,
      enabled: alPresionar != null,
      label: etiquetaSemantica,
      onTap: alPresionar,
      excludeSemantics: true,
      child: AccionEnfocable(
        alPresionar: alPresionar,
        radio: radio,
        nodoFoco: nodoFoco,
        child: dibujo,
      ),
    );
  }
}

/// Fila de 3 estrellas de 16 con separación 2: ganadas en accion/acento y las
/// demás en borde/default. Decorativa.
class EstrellasSprint extends StatelessWidget {
  const EstrellasSprint({required this.estrellas, super.key});

  final int estrellas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < NodoSprint.maximoEstrellas; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            CustomPaint(
              key: ValueKey('estrella-$i'),
              size: const Size.square(NodoSprint.tamanoEstrella),
              painter: PintorEstrella(
                color: i < estrellas ? tokens.accionAcento : tokens.bordeDefault,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estrella rellena con la silueta de Lucide (Figma la usa rellena; el ícono
/// de Lucide solo tiene contorno).
class PintorEstrella extends CustomPainter {
  const PintorEstrella({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final e = size.width / 16;
    final camino = Path()
      ..moveTo(8 * e, 1.333 * e)
      ..lineTo(10.067 * e, 5.533 * e)
      ..lineTo(14.667 * e, 6.2 * e)
      ..lineTo(11.333 * e, 9.467 * e)
      ..lineTo(12.133 * e, 14 * e)
      ..lineTo(8 * e, 11.867 * e)
      ..lineTo(3.867 * e, 14 * e)
      ..lineTo(4.667 * e, 9.467 * e)
      ..lineTo(1.333 * e, 6.2 * e)
      ..lineTo(5.933 * e, 5.533 * e)
      ..close();
    canvas.drawPath(camino, Paint()..color = color);
  }

  @override
  bool shouldRepaint(PintorEstrella anterior) => anterior.color != color;
}
