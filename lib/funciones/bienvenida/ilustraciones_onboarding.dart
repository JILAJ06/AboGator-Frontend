import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../componentes/boton_veredicto.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/corazon_vida.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/pildora.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/tema/efectos.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/tarjeta.dart';

/// Lienzo de ilustración del onboarding: 390×400 en coordenadas del marco de
/// Figma, que corresponde a y = 90…490 del marco de 390×844. Se escala hacia
/// abajo en pantallas bajas. Es decorativo: se excluye de la semántica y no
/// escala con el texto del sistema (es una ilustración de tamaño fijo).
class LienzoOnboarding extends StatelessWidget {
  const LienzoOnboarding({required this.pagina, super.key});

  static const double ancho = 390;
  static const double alto = 400;

  /// Desplazamiento vertical del lienzo dentro del marco de 844.
  static const double origenY = 90;

  final int pagina;

  @override
  Widget build(BuildContext context) {
    final contenido = switch (pagina) {
      0 => const _PaginaSarko(),
      1 => const _PaginaGestos(),
      2 => const _PaginaStartup(),
      _ => const _PaginaVidas(),
    };
    return ExcludeSemantics(
      child: MediaQuery.withNoTextScaling(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: ancho,
            height: alto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _en(45, 130, _Circulo(color: context.tokens.fondoDestacado)),
                ...contenido.hijos,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Coloca [hijo] en (x, y) del marco de 844.
Widget _en(double x, double y, Widget hijo) =>
    Positioned(left: x, top: y - LienzoOnboarding.origenY, child: hijo);

class _Circulo extends StatelessWidget {
  const _Circulo({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('circulo-onboarding'),
      width: 300,
      height: 300,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

abstract class _ContenidoPagina {
  const _ContenidoPagina();
  List<Widget> get hijos;
}

/// Pantalla 02: Sarko alegre de 264×330 en (63, 140).
class _PaginaSarko extends _ContenidoPagina {
  const _PaginaSarko();

  @override
  List<Widget> get hijos => [
    _en(63, 140, const SarkoImagen(pose: PoseSarko.alegre, ancho: 264, decorativa: true)),
  ];
}

/// Pantalla 03: miniatura de tarjeta rotada 8° y los cuatro botones de veredicto.
class _PaginaGestos extends _ContenidoPagina {
  const _PaginaGestos();

  @override
  List<Widget> get hijos => [
    _en(51.8, 150, const _MiniTarjetaCaso()),
    _en(22, 300, const BotonVeredicto(veredicto: Veredicto.ilegal)),
    _en(300, 300, const BotonVeredicto(veredicto: Veredicto.legal)),
    _en(151.5, 92, const BotonVeredicto(veredicto: Veredicto.condicional)),
    _en(161, 394, const BotonVeredicto(veredicto: Veredicto.escalar)),
  ];
}

/// Pantalla 03b: indicadores (70, 60, 50, 25) y Sarko de 160×200.
class _PaginaStartup extends _ContenidoPagina {
  const _PaginaStartup();

  @override
  List<Widget> get hijos => [
    _en(
      24,
      150,
      const SizedBox(
        width: 342,
        child: IndicadoresStartup(
          estado: EstadoStartup(presupuesto: 70, reputacion: 60, velocidad: 50, riesgoLegal: 25),
        ),
      ),
    ),
    _en(115, 230, const SarkoImagen(pose: PoseSarko.alegre, decorativa: true)),
  ];
}

/// Pantalla 04: 4 de 5 vidas, Sarko de 208×260 y dos chips.
class _PaginaVidas extends _ContenidoPagina {
  const _PaginaVidas();

  @override
  List<Widget> get hijos => [
    _en(112.6, 140, const FilaVidas(cantidad: 4, tamano: 33.6, hueco: 11.2)),
    _en(91, 180, const SarkoImagen(pose: PoseSarko.alegre, ancho: 208, decorativa: true)),
    _en(
      40,
      330,
      const ChipHud(
        tipo: TipoChipHud.monedas,
        valor: Textos.onboarding4Monedas,
        etiquetaSemantica: Textos.onboarding4Monedas,
      ),
    ),
    _en(
      262,
      300,
      const ChipHud(
        tipo: TipoChipHud.racha,
        valor: Textos.onboarding4Racha,
        etiquetaSemantica: Textos.onboarding4Racha,
      ),
    ),
  ];
}

/// Miniatura decorativa de una tarjeta de caso (212×310, radio 17.4) rotada 8°
/// dentro de una caja de 253×336.
class _MiniTarjetaCaso extends StatelessWidget {
  const _MiniTarjetaCaso();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = context.estilos;
    TextStyle mini(TextStyle base, double tamano, Color color, {double? alto}) =>
        base.copyWith(fontSize: tamano, height: alto == null ? null : alto / tamano, color: color);

    final tarjeta = Container(
      key: const ValueKey('mini-tarjeta-caso'),
      width: 212,
      height: 310,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.fondoSuperficie,
        borderRadius: BorderRadius.circular(17.4),
        border: Border.all(color: t.bordeDefault, width: 0.6),
        boxShadow: EfectosApp.sombraTarjeta,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pildora(
            fondo: t.textoAcento.withValues(alpha: EfectosApp.opacidadEtiquetaCaso),
            relleno: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Text(Textos.casoEtiqueta, style: mini(e.etiqueta, 6.8, t.textoAcento)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: t.fondoDestacado, shape: BoxShape.circle),
                child: Text(Textos.casoIniciales, style: mini(e.boton, 10.5, t.accionSecundaria)),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Textos.casoPersona, style: mini(e.cuerpoEnfasis, 7.4, t.textoPrimario)),
                  Text(Textos.casoEquipo, style: mini(e.cuerpoBase, 6.8, t.textoSecundario)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: t.fondoSuperficieAlt,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3.7),
                topRight: Radius.circular(12.4),
                bottomLeft: Radius.circular(12.4),
                bottomRight: Radius.circular(12.4),
              ),
            ),
            child: Text(
              Textos.casoPregunta,
              style: mini(e.boton, 10.5, t.textoPrimario, alto: 15.5).copyWith(letterSpacing: 0),
            ),
          ),
          const Spacer(),
          // Pistas en tres columnas que se encogen si no caben (la tarjeta es fija).
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(Textos.casoPistaIlegal, style: mini(e.etiqueta, 6.8, t.estadoIlegal)),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    children: [
                      Text(
                        Textos.casoPistaCondicional,
                        style: mini(e.etiqueta, 6.8, t.estadoCondicional),
                      ),
                      Text(Textos.casoPistaEscalar, style: mini(e.etiqueta, 6.8, t.estadoEscalar)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(Textos.casoPistaLegal, style: mini(e.etiqueta, 6.8, t.estadoLegal)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return SizedBox(
      width: 253,
      height: 336,
      child: Center(
        child: Transform.rotate(angle: 8 * math.pi / 180, child: tarjeta),
      ),
    );
  }
}
