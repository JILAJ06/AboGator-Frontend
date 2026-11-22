import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/aviso_informativo.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/etiqueta_quiebra.dart';
import '../../componentes/ilustracion_sarko.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/estado_startup.dart';
import 'estado_juego.dart';
import 'logica_fin_sprint.dart';
import 'logica_veredicto.dart';
import 'piezas_fin_sprint.dart';

/// Pantalla 19b · Startup en quiebra: indicadores del momento de la quiebra,
/// causa, descripción y aviso de reinicio.
///
/// "Reiniciar sprint" descarta el avance y vuelve a la tarjeta 1 con los
/// indicadores del inicio; las vidas perdidas ya se guardaron y no vuelven.
/// Sin una quiebra registrada muestra un mensaje con regreso al mapa.
class PantallaStartupQuiebra extends ConsumerStatefulWidget {
  const PantallaStartupQuiebra({required this.sprintId, super.key});

  final String sprintId;

  @override
  ConsumerState<PantallaStartupQuiebra> createState() => _PantallaStartupQuiebraState();
}

class _PantallaStartupQuiebraState extends ConsumerState<PantallaStartupQuiebra> {
  /// Último resultado mostrado: si el sprint se reinicia mientras la
  /// pantalla sale, sigue mostrándolo en vez del mensaje "sin resultado".
  EstadoJuego? _juego;
  DatosJuego? _datos;

  @override
  Widget build(BuildContext context) {
    final sprintId = widget.sprintId;
    final actual = ref.watch(juegoProvider(sprintId));
    if (actual.fin == DestinoVeredicto.quiebra) _juego = actual;
    _datos = ref.watch(datosJuegoProvider(sprintId)).value ?? _datos;
    final juego = _juego;
    final moduloId = _datos?.modulo?.id;

    if (juego == null) {
      return Scaffold(
        body: MensajePantalla(
          texto: Textos.sinResultado,
          textoBoton: Textos.volverAlMapa,
          alPresionar: () =>
              context.go(moduloId == null ? Rutas.inicio : Rutas.mapaSprintsDe(moduloId)),
        ),
      );
    }

    final tokens = context.tokens;
    final causa = LogicaFinSprint.causaQuiebra(juego.estadoStartup) ?? CausaQuiebra.riesgoLegal;
    final indicadores = ElementoOrdenado(
      orden: 4,
      child: BloqueLectura(
        key: const ValueKey('indicadores-quiebra'),
        etiqueta: Textos.indicadoresSemantica,
        child: IndicadoresStartup(
          estado: juego.estadoStartup,
          cambios: LogicaFinSprint.cambios(juego.estadoInicial, juego.estadoStartup),
        ),
      ),
    );
    final descripcion = ElementoOrdenado(
      orden: 3,
      child: Text(
        LogicaFinSprint.descripcionQuiebra(_datos?.sprint, causa),
        key: const ValueKey('descripcion-quiebra'),
        style: context.estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
        textAlign: TextAlign.center,
      ),
    );
    final sarko = IlustracionSarko(
      pose: PoseSarko.triste,
      diametro: 220,
      anchoSarko: 176,
      colorFondo: tokens.fondoSuperficieAlt,
    );
    final etiquetaCausa = ElementoOrdenado(orden: 2, child: EtiquetaQuiebra(causa: causa));
    const titulo = ElementoOrdenado(orden: 1, child: TituloFinSprint(Textos.quiebraTitulo));
    final avisoReinicio = ElementoOrdenado(
      orden: 5,
      child: AvisoInformativo(
        key: const ValueKey('aviso-reinicio'),
        icono: IconosApp.info,
        colorIcono: tokens.textoAcento,
        rellenoVertical: 12,
        texto: Textos.avisoReinicio,
      ),
    );
    return ColumnaFinSprint(
      // T19b (Figma 98:2433): Sarko triste y la etiqueta de la causa × 1.7 en
      // el panel izquierdo; indicadores, título, descripción y aviso a la
      // derecha, con separación 16.
      ilustracionTablet: IlustracionAmpliada(
        anchoBase: 230,
        escala: 1.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [sarko, const SizedBox(height: 16), etiquetaCausa],
        ),
      ),
      contenidoTablet: [
        indicadores,
        const SizedBox(height: 16),
        titulo,
        const SizedBox(height: 16),
        descripcion,
        const SizedBox(height: 16),
        avisoReinicio,
      ],
      // Orden de lectura y foco: título → causa → descripción → indicadores →
      // aviso → botones.
      contenido: [
        const SizedBox(height: 16),
        indicadores,
        const SizedBox(height: 10),
        sarko,
        const SizedBox(height: 12),
        etiquetaCausa,
        const SizedBox(height: 8),
        titulo,
        const SizedBox(height: 8),
        descripcion,
        const SizedBox(height: 30),
        avisoReinicio,
      ],
      botones: [
        ElementoOrdenado(
          orden: 6,
          child: BotonApp(
            texto: Textos.reiniciarSprint,
            alPresionar: () {
              reiniciarJuego(ref, sprintId);
              context.go(Rutas.juegoDe(sprintId));
            },
          ),
        ),
        const SizedBox(height: 8),
        ElementoOrdenado(
          orden: 7,
          child: BotonApp(
            texto: Textos.irAlBuzon,
            tipo: TipoBoton.fantasma,
            altoMinimo: 48,
            alPresionar: () => context.go(Rutas.buzon),
          ),
        ),
      ],
    );
  }
}
