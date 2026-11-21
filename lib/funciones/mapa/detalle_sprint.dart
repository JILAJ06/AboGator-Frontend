import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/fila_detalle_sprint.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/modulo.dart';
import '../juego/estado_juego.dart';
import 'logica_mapa.dart';

/// Cómo se acomoda el detalle del sprint.
enum DisposicionDetalle {
  /// Intro del móvil (09, Figma 13:776): todo centrado, elipse de 230 y
  /// separaciones 20 · 6 · 8 · 14.
  intro(230, 184, CrossAxisAlignment.center, TextAlign.center),

  /// Panel "Detalle del sprint" de tablet (T08, Figma 96:844): alineado a la
  /// izquierda, elipse de 207 (la de la intro × 0.9) y separación 14.
  panel(207, 165.6, CrossAxisAlignment.start, TextAlign.left);

  const DisposicionDetalle(this.elipse, this.anchoSarko, this.alineacion, this.texto);

  final double elipse;
  final double anchoSarko;
  final CrossAxisAlignment alineacion;
  final TextAlign texto;
}

/// Detalle de un sprint: Sarko sobre la elipse, "SPRINT N · MÓDULO M", título,
/// objetivo, la tarjeta de detalles (tarjetas, monedas e indicadores) y, si
/// está bloqueado, el aviso. Lo comparten la intro del móvil (09) y el panel
/// derecho del mapa en tablet (T08); el botón "Comenzar sprint" lo pone cada
/// una (fijo abajo en la intro, al final de la columna en el panel).
class DetalleSprint extends StatelessWidget {
  const DetalleSprint({
    required this.modulo,
    required this.sprint,
    this.disposicion = DisposicionDetalle.intro,
    super.key,
  });

  final Modulo modulo;
  final Sprint sprint;
  final DisposicionDetalle disposicion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final abierto = LogicaMapa.puedeAbrir(modulo, sprint);
    final numero = LogicaMapa.numeroDe(modulo, sprint);
    final etiqueta = numero == null
        ? Textos.introEtiquetaExamen(modulo.numero)
        : Textos.introEtiqueta(numero, modulo.numero);
    final panel = disposicion == DisposicionDetalle.panel;
    final alineacion = disposicion.texto;

    final textos = <Widget>[
      Text(
        etiqueta,
        textAlign: alineacion,
        style: estilos.etiqueta.copyWith(color: tokens.textoAcento),
      ),
      SizedBox(height: panel ? 14 : 6),
      Semantics(
        header: true,
        child: Text(
          sprint.tituloIntro ?? sprint.titulo,
          textAlign: alineacion,
          style: estilos.h1.copyWith(color: tokens.textoPrimario),
        ),
      ),
      SizedBox(height: panel ? 14 : 8),
      Text(
        Textos.introObjetivo(sprint.objetivo),
        textAlign: alineacion,
        style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
      ),
      const SizedBox(height: 14),
      TarjetaDetallesSprint(
        filas: [
          FilaDetalleSprint(
            icono: IconosApp.doc,
            titulo: Textos.tarjetasCantidad(sprint.numeroTarjetas),
            texto: LogicaMapa.desglose(sprint),
          ),
          FilaDetalleSprint(
            icono: IconosApp.coin,
            titulo: Textos.monedasHasta(sprint.monedasMaximas),
            texto: Textos.monedasDilema,
          ),
          const FilaDetalleSprint(
            icono: IconosApp.zap,
            titulo: Textos.indicadoresTitulo,
            texto: Textos.indicadoresLista,
          ),
        ],
      ),
      if (!abierto) ...[
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            Textos.sprintBloqueado,
            key: const ValueKey('aviso-bloqueado'),
            textAlign: alineacion,
            style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
          ),
        ),
      ],
    ];

    final ilustracion = SarkoConElipse(
      elipse: disposicion.elipse,
      anchoSarko: disposicion.anchoSarko,
    );

    if (panel) {
      return Column(
        key: const ValueKey('detalle-sprint'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: ilustracion),
          const SizedBox(height: 14),
          ...textos,
        ],
      );
    }
    return Column(
      key: const ValueKey('detalle-sprint'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: ilustracion),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: textos),
        ),
      ],
    );
  }
}

/// Empieza [sprint] desde la tarjeta 1 (descarta un avance anterior); el Examen
/// final abre la crisis.
void comenzarSprint(BuildContext context, WidgetRef ref, Modulo modulo, Sprint sprint) {
  if (!sprint.esExamenFinal) reiniciarJuego(ref, sprint.id);
  context.push(sprint.esExamenFinal ? Rutas.crisisJefeDe(modulo.id) : Rutas.juegoDe(sprint.id));
}

/// Elipse en fondo/destacado con Sarko alegre encima (en la intro: elipse de
/// 230 en (80, 110) y Sarko de 184 en (103, 112)). Decorativo.
class SarkoConElipse extends StatelessWidget {
  const SarkoConElipse({this.elipse = 230, this.anchoSarko = 184, super.key});

  final double elipse;
  final double anchoSarko;

  @override
  Widget build(BuildContext context) {
    // La elipse de 230 deja 2 arriba de Sarko (en el panel, 1.8: Figma 96:853).
    final arriba = elipse / 115;
    return ExcludeSemantics(
      child: SizedBox(
        width: elipse,
        height: elipse + arriba,
        child: Stack(
          children: [
            Container(
              key: const ValueKey('elipse-intro'),
              width: elipse,
              height: elipse,
              decoration: BoxDecoration(
                color: context.tokens.fondoDestacado,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              left: (elipse - anchoSarko) / 2,
              top: arriba,
              child: SarkoImagen(pose: PoseSarko.alegre, ancho: anchoSarko, decorativa: true),
            ),
          ],
        ),
      ),
    );
  }
}
