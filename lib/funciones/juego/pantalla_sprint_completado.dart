import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/aviso_informativo.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/confeti_sprint.dart';
import '../../componentes/estadisticas_sprint.dart';
import '../../componentes/estrellas_sprint.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import 'estado_juego.dart';
import 'logica_fin_sprint.dart';
import 'logica_veredicto.dart';
import 'piezas_fin_sprint.dart';

/// Pantalla 19 · Sprint completado: estrellas, estadísticas, estado final de
/// la Startup y aviso del buzón.
///
/// Lee el sprint terminado de `juegoProvider` (el resultado ya se guardó al
/// salir del juego). Si no hay un sprint terminado (recarga o enlace directo)
/// muestra un mensaje con regreso al mapa.
class PantallaSprintCompletado extends ConsumerStatefulWidget {
  const PantallaSprintCompletado({required this.sprintId, super.key});

  final String sprintId;

  @override
  ConsumerState<PantallaSprintCompletado> createState() => _PantallaSprintCompletadoState();
}

class _PantallaSprintCompletadoState extends ConsumerState<PantallaSprintCompletado> {
  /// Último resultado mostrado: si el sprint se reinicia mientras la
  /// pantalla sale, sigue mostrándolo en vez del mensaje "sin resultado".
  EstadoJuego? _juego;
  DatosJuego? _datos;

  @override
  Widget build(BuildContext context) {
    final sprintId = widget.sprintId;
    final actual = ref.watch(juegoProvider(sprintId));
    if (actual.fin == DestinoVeredicto.sprintCompletado) _juego = actual;
    _datos = ref.watch(datosJuegoProvider(sprintId)).value ?? _datos;
    final juego = _juego;
    final moduloId = _datos?.modulo?.id;
    void alMapa() => context.go(moduloId == null ? Rutas.inicio : Rutas.mapaSprintsDe(moduloId));

    if (juego == null) {
      return Scaffold(
        body: MensajePantalla(
          texto: Textos.sinResultado,
          textoBoton: Textos.volverAlMapa,
          alPresionar: alMapa,
        ),
      );
    }

    final tokens = context.tokens;
    final estilos = context.estilos;
    final aviso = LogicaFinSprint.avisoBuzon(LogicaFinSprint.falladas(juego.resultados));
    return ColumnaFinSprint(
      fondo: const ConfetiSprint(),
      // Orden de lectura y foco: título → estrellas → estadísticas → estado
      // final → aviso → botones.
      contenido: [
        const SizedBox(height: 22),
        IlustracionFinSprint(
          pose: PoseSarko.alegre,
          diametro: 200,
          anchoSarko: 160,
          colorFondo: tokens.fondoDestacado,
        ),
        const SizedBox(height: 10),
        ElementoOrdenado(orden: 2, child: EstrellasSprint(ganadas: juego.estrellas)),
        const SizedBox(height: 8),
        ElementoOrdenado(
          orden: 1,
          child: Column(
            children: [
              const TituloFinSprint(Textos.sprintCompletadoTitulo),
              const SizedBox(height: 4),
              Text(
                _datos?.sprint?.mensajeCompletado ?? Textos.sprintCompletadoGenerico,
                key: const ValueKey('subtitulo-fin-sprint'),
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElementoOrdenado(
          orden: 3,
          child: EstadisticasSprint(
            aciertos: juego.aciertos,
            total: juego.totalTarjetas,
            xp: juego.xp,
            monedas: juego.monedas,
          ),
        ),
        const SizedBox(height: 18),
        ElementoOrdenado(
          orden: 4,
          // Se lee junto: "Estado final de tu Startup" y los 4 indicadores.
          child: BloqueLectura(
            key: const ValueKey('estado-final'),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    Textos.estadoFinalStartup,
                    style: estilos.etiqueta.copyWith(color: tokens.textoSecundario),
                  ),
                ),
                const SizedBox(height: 4),
                IndicadoresStartup(
                  estado: juego.estadoStartup,
                  cambios: LogicaFinSprint.cambios(juego.estadoInicial, juego.estadoStartup),
                ),
              ],
            ),
          ),
        ),
        if (aviso != null) ...[
          const SizedBox(height: 14),
          ElementoOrdenado(
            orden: 5,
            child: AvisoInformativo(
              key: const ValueKey('aviso-buzon'),
              icono: IconosApp.inbox,
              texto: aviso,
            ),
          ),
        ],
      ],
      botones: [
        ElementoOrdenado(
          orden: 6,
          child: BotonApp(texto: Textos.continuarAlMapa, alPresionar: alMapa),
        ),
        if (aviso != null) ...[
          const SizedBox(height: 8),
          ElementoOrdenado(
            orden: 7,
            child: BotonApp(
              texto: Textos.repasarFallos,
              tipo: TipoBoton.fantasma,
              altoMinimo: 48,
              alPresionar: () => context.go(Rutas.buzon),
            ),
          ),
        ],
      ],
    );
  }
}
