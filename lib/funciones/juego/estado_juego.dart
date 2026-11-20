import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../mapa/logica_mapa.dart';
import 'logica_comodines.dart';
import 'logica_fin_sprint.dart';
import 'logica_veredicto.dart';

/// Datos que necesita la pantalla de juego de un sprint.
class DatosJuego {
  const DatosJuego({
    required this.vidas,
    this.tarjetas = const [],
    this.estadoStartup,
    this.modulo,
    this.sprint,
    this.numeroSprint = 1,
    this.comodines = const {},
  });

  final Vidas vidas;

  /// Vacía si el sprint no existe o no tiene tarjetas.
  final List<Tarjeta> tarjetas;

  /// `null` solo cuando no se cargó el juego (sin vidas).
  final EstadoStartup? estadoStartup;

  /// Módulo al que pertenece el sprint (color del chip del caso y regreso al
  /// mapa); `null` si no se encontró.
  final Modulo? modulo;
  final Sprint? sprint;

  /// Número del sprint dentro de su módulo (sin contar el Examen final).
  final int numeroSprint;

  /// Comodines que tiene el usuario al empezar (de la tienda).
  final Map<Comodin, int> comodines;

  /// Con 0 vidas no se carga el juego (marcador de "Sin vidas", T-08).
  bool get sinVidas => vidas.cantidad <= 0;
}

/// Carga primero las vidas: con 0 no carga el juego. Si hay vidas, pide en
/// paralelo las tarjetas, el estado de la Startup, los módulos (para el
/// número del sprint y el color del módulo) y los comodines de la tienda. Un sprint inexistente da una
/// lista de tarjetas vacía.
final datosJuegoProvider = FutureProvider.autoDispose.family<DatosJuego, String>((
  ref,
  sprintId,
) async {
  final repoVidas = ref.watch(repositorioVidasProvider);
  final repoTarjetas = ref.watch(repositorioTarjetasProvider);
  final repoProgreso = ref.watch(repositorioProgresoProvider);
  final repoTienda = ref.watch(repositorioTiendaProvider);

  final vidas = await repoVidas.obtenerVidas();
  if (vidas.cantidad <= 0) return DatosJuego(vidas: vidas);

  Future<List<Tarjeta>> tarjetas() async {
    try {
      return await repoTarjetas.obtenerTarjetasDelSprint(sprintId);
    } on StateError {
      return const [];
    }
  }

  final (lista, estado, modulos, comodines) = await (
    tarjetas(),
    repoProgreso.obtenerEstadoStartup(),
    repoProgreso.obtenerModulos(),
    repoTienda.obtenerComodines(),
  ).wait;

  Modulo? modulo;
  Sprint? sprint;
  for (final m in modulos) {
    final s = LogicaMapa.sprintPorId(m, sprintId);
    if (s != null) {
      modulo = m;
      sprint = s;
      break;
    }
  }

  return DatosJuego(
    vidas: vidas,
    tarjetas: lista,
    estadoStartup: estado,
    modulo: modulo,
    sprint: sprint,
    numeroSprint: modulo == null || sprint == null ? 1 : LogicaMapa.numeroDe(modulo, sprint) ?? 1,
    comodines: comodines,
  );
});

/// Respuesta del jugador a una tarjeta (el veredicto que eligió).
class RespuestaJuego {
  const RespuestaJuego({required this.tarjetaId, required this.veredicto});

  final String tarjetaId;
  final Veredicto veredicto;

  @override
  bool operator ==(Object other) =>
      other is RespuestaJuego && other.tarjetaId == tarjetaId && other.veredicto == veredicto;

  @override
  int get hashCode => Object.hash(tarjetaId, veredicto);

  @override
  String toString() => 'RespuestaJuego($tarjetaId, ${veredicto.name})';
}

/// Fase del panel de veredicto abierto.
///
/// La justificación de los dilemas (18) no es una fase: se elige en su propio
/// panel **antes** de calificar, y este panel se abre ya con el resultado.
enum FasePanel {
  /// Acierto con micro-pregunta sin responder (12).
  microPregunta,

  /// Muestra la explicación ("¿Por qué?"): 12 sin micro-pregunta o con ella
  /// saltada o fallada, 12c, 14 y 14b.
  explicacion,

  /// Bonus ganado (12b): micro-pregunta bien respondida, evidencia bien
  /// marcada o justificación correcta.
  bonus,
}

/// Panel de veredicto pendiente de cerrar.
class PanelPendiente {
  const PanelPendiente({required this.tarjeta, required this.resultado, required this.fase});

  final Tarjeta tarjeta;
  final ResultadoVeredicto resultado;
  final FasePanel fase;
}

/// Resultado registrado de una tarjeta.
class ResultadoTarjeta {
  const ResultadoTarjeta({required this.tarjetaId, required this.tipo, this.bonus = false});

  final String tarjetaId;
  final TipoVeredicto tipo;
  final bool bonus;

  @override
  bool operator ==(Object other) =>
      other is ResultadoTarjeta &&
      other.tarjetaId == tarjetaId &&
      other.tipo == tipo &&
      other.bonus == bonus;

  @override
  int get hashCode => Object.hash(tarjetaId, tipo, bonus);

  @override
  String toString() => 'ResultadoTarjeta($tarjetaId, ${tipo.name}, bonus: $bonus)';
}

/// Avance del sprint en curso.
///
/// Vive mientras se juega y se muestra el final (19 o 19b). Al terminar, el
/// resultado se guarda en los repositorios con [JuegoNotifier.guardarResultado].
class EstadoJuego {
  const EstadoJuego({
    this.indice = 0,
    this.totalTarjetas = 0,
    this.estadoInicial = const EstadoStartup(
      presupuesto: 0,
      reputacion: 0,
      velocidad: 0,
      riesgoLegal: 0,
    ),
    this.respuestas = const [],
    this.estadoStartup = const EstadoStartup(
      presupuesto: 0,
      reputacion: 0,
      velocidad: 0,
      riesgoLegal: 0,
    ),
    this.vidas = 0,
    this.xp = 0,
    this.monedas = 0,
    this.resultados = const [],
    this.falladas = const [],
    this.panel,
    this.amparoActivo = false,
    this.fin,
    this.guardado = false,
    this.evidenciaMarcada = const {},
    this.lineasMarcadas = const {},
    this.comodines = const {},
    this.lupaUsada = const {},
    this.abogadoUsado = const {},
  });

  /// Tarjeta actual. Avanza al **cerrar** el panel, no al lanzar la tarjeta.
  final int indice;
  final int totalTarjetas;

  /// Estado de la Startup al empezar el sprint (para los cambios de 19 y 19b).
  final EstadoStartup estadoInicial;
  final List<RespuestaJuego> respuestas;
  final EstadoStartup estadoStartup;
  final int vidas;
  final int xp;
  final int monedas;
  final List<ResultadoTarjeta> resultados;

  /// Ids de las tarjetas falladas (irán al Buzón de Apelaciones en T-09).
  final List<String> falladas;

  /// Panel de veredicto abierto; `null` si no hay.
  final PanelPendiente? panel;

  /// Amparo armado: absorbe el siguiente error (T-07b).
  final bool amparoActivo;

  /// Cómo terminó el sprint; `null` mientras se juega.
  final DestinoVeredicto? fin;

  /// Si el resultado ya se guardó en los repositorios.
  final bool guardado;

  /// Evidencias marcadas: id de la tarjeta → si incluyó una línea clave. Se
  /// marca una sola vez por tarjeta.
  final Map<String, bool> evidenciaMarcada;

  /// Líneas que marcó el jugador en cada evidencia (para volver a mostrarlas).
  final Map<String, List<int>> lineasMarcadas;

  /// Comodines que quedan (se descuentan al usarlos).
  final Map<Comodin, int> comodines;

  /// Tarjetas en las que ya se usó la Lupa o se consultó al Abogado.
  final Set<String> lupaUsada;
  final Set<String> abogadoUsado;

  /// Cuántos quedan de [comodin].
  int cantidad(Comodin comodin) => comodines[comodin] ?? 0;

  /// Tarjetas correctas (con o sin bonus).
  int get aciertos => LogicaFinSprint.aciertos(resultados);

  /// Estrellas que da el sprint si se completó.
  int get estrellas => LogicaFinSprint.estrellas(aciertos: aciertos, total: totalTarjetas);

  EstadoJuego copiar({
    int? indice,
    List<RespuestaJuego>? respuestas,
    EstadoStartup? estadoStartup,
    int? vidas,
    int? xp,
    int? monedas,
    List<ResultadoTarjeta>? resultados,
    List<String>? falladas,
    PanelPendiente? Function()? panel,
    bool? amparoActivo,
    DestinoVeredicto? Function()? fin,
    bool? guardado,
    Map<String, bool>? evidenciaMarcada,
    Map<String, List<int>>? lineasMarcadas,
    Map<Comodin, int>? comodines,
    Set<String>? lupaUsada,
    Set<String>? abogadoUsado,
  }) => EstadoJuego(
    indice: indice ?? this.indice,
    totalTarjetas: totalTarjetas,
    estadoInicial: estadoInicial,
    respuestas: respuestas ?? this.respuestas,
    estadoStartup: estadoStartup ?? this.estadoStartup,
    vidas: vidas ?? this.vidas,
    xp: xp ?? this.xp,
    monedas: monedas ?? this.monedas,
    resultados: resultados ?? this.resultados,
    falladas: falladas ?? this.falladas,
    panel: panel != null ? panel() : this.panel,
    amparoActivo: amparoActivo ?? this.amparoActivo,
    fin: fin != null ? fin() : this.fin,
    guardado: guardado ?? this.guardado,
    evidenciaMarcada: evidenciaMarcada ?? this.evidenciaMarcada,
    lineasMarcadas: lineasMarcadas ?? this.lineasMarcadas,
    comodines: comodines ?? this.comodines,
    lupaUsada: lupaUsada ?? this.lupaUsada,
    abogadoUsado: abogadoUsado ?? this.abogadoUsado,
  );
}

/// Lleva el avance del juego de un sprint: califica, actualiza indicadores,
/// vidas, XP y monedas, decide qué sigue al cerrar el panel y guarda el
/// resultado al terminar.
///
/// Se mantiene vivo (`keepAlive`) aunque la pantalla de juego se cierre, para
/// que 19 y 19b lean el resultado. Se reinicia solo con [reiniciarJuego].
class JuegoNotifier extends Notifier<EstadoJuego> {
  JuegoNotifier(this.sprintId);

  final String sprintId;

  @override
  EstadoJuego build() {
    ref.keepAlive();
    final datos = ref.watch(datosJuegoProvider(sprintId)).value;
    final inicial = datos?.estadoStartup ?? const EstadoJuego().estadoStartup;
    return EstadoJuego(
      totalTarjetas: datos?.tarjetas.length ?? 0,
      estadoInicial: inicial,
      estadoStartup: inicial,
      vidas: datos?.vidas.cantidad ?? 0,
      comodines: datos?.comodines ?? const {},
    );
  }

  /// Arma o desarma el Amparo. Armarlo no gasta (se gasta al absorber un
  /// error) y no se puede armar sin Amparos.
  void establecerAmparo({required bool activo}) {
    if (activo && state.cantidad(Comodin.amparo) <= 0) return;
    state = state.copiar(amparoActivo: activo);
  }

  /// Tocar el Amparo: lo arma o lo desarma. Devuelve si quedó armado.
  bool alternarAmparo() {
    establecerAmparo(activo: !state.amparoActivo);
    return state.amparoActivo;
  }

  /// Resta 1 a [comodin] en la sesión y lo guarda en la tienda en el momento.
  void _gastar(Comodin comodin) {
    state = state.copiar(
      comodines: {...state.comodines, comodin: LogicaComodines.restar(state.cantidad(comodin))},
    );
    unawaited(ref.read(repositorioTiendaProvider).consumirComodin(comodin));
  }

  /// Usa la Lupa en [tarjeta]: gasta 1 y marca la tarjeta. No hace nada (y
  /// devuelve `false`) si no se puede usar; ver [LogicaComodines.puedeUsarLupa].
  bool usarLupa(Tarjeta tarjeta) {
    if (!LogicaComodines.puedeUsarLupa(state, tarjeta)) return false;
    _gastar(Comodin.lupaAuditor);
    state = state.copiar(lupaUsada: {...state.lupaUsada, tarjeta.id});
    return true;
  }

  /// Consulta al Abogado en [tarjeta]: la primera vez gasta 1; reabrirlo en la
  /// misma tarjeta es gratis. Devuelve si se puede abrir el panel.
  bool consultarAbogado(Tarjeta tarjeta) {
    if (state.abogadoUsado.contains(tarjeta.id)) return state.panel == null;
    if (!LogicaComodines.puedeUsarAbogado(state, tarjeta)) return false;
    _gastar(Comodin.abogadoSenior);
    state = state.copiar(abogadoUsado: {...state.abogadoUsado, tarjeta.id});
    return true;
  }

  /// Marca las [lineas] de la evidencia de [tarjeta] y dice si incluyen una
  /// línea clave. Solo se marca una vez: si ya estaba marcada, devuelve el
  /// resultado anterior sin cambiarlo. `null` si la tarjeta no tiene evidencia
  /// o no se marcó nada.
  bool? marcarEvidencia(Tarjeta tarjeta, List<int> lineas) {
    final evidencia = tarjeta.evidencia;
    final previo = state.evidenciaMarcada[tarjeta.id];
    if (previo != null) return previo;
    if (evidencia == null || lineas.isEmpty) return null;
    final acierta = LogicaVeredicto.aciertaEvidencia(evidencia, lineas);
    state = state.copiar(
      evidenciaMarcada: {...state.evidenciaMarcada, tarjeta.id: acierta},
      lineasMarcadas: {...state.lineasMarcadas, tarjeta.id: List.unmodifiable(lineas)},
    );
    return acierta;
  }

  /// Califica la respuesta, aplica sus efectos y abre el panel. No avanza la
  /// tarjeta: eso pasa al cerrar el panel.
  ///
  /// [justificacion] es la opción elegida en el panel 18 (solo en dilemas).
  /// El bonus de evidencia o de justificación abre el panel en Bonus (12b).
  ResultadoVeredicto responder(Tarjeta tarjeta, Veredicto veredicto, {int? justificacion}) {
    final calificado = LogicaVeredicto.calificar(
      tarjeta,
      veredicto,
      amparoActivo: state.amparoActivo,
    );
    final bonusEvidencia = LogicaVeredicto.bonusEvidencia(
      tarjeta: tarjeta,
      evidenciaCorrecta: state.evidenciaMarcada[tarjeta.id],
      tipo: calificado.tipo,
    );
    final bonusJustificacion = LogicaVeredicto.bonusJustificacion(
      tarjeta: tarjeta,
      opcion: justificacion,
      tipo: calificado.tipo,
    );
    final bonus = bonusEvidencia || bonusJustificacion;
    final resultado = bonus ? calificado.conBonus(monedasDobles: bonusJustificacion) : calificado;
    final conPregunta =
        !bonus && resultado.tipo == TipoVeredicto.correcto && tarjeta.microPregunta != null;
    state = state.copiar(
      respuestas: [
        ...state.respuestas,
        RespuestaJuego(tarjetaId: tarjeta.id, veredicto: veredicto),
      ],
      estadoStartup: LogicaVeredicto.aplicar(state.estadoStartup, resultado.impacto),
      vidas: resultado.pierdeVida ? (state.vidas - 1).clamp(0, state.vidas) : state.vidas,
      xp: state.xp + resultado.xp,
      monedas: state.monedas + resultado.monedas,
      resultados: [
        ...state.resultados,
        ResultadoTarjeta(tarjetaId: tarjeta.id, tipo: resultado.tipo, bonus: bonus),
      ],
      falladas: resultado.esFallo ? [...state.falladas, tarjeta.id] : state.falladas,
      // El Amparo se desarma al absorber un error (el gasto va abajo).
      amparoActivo: resultado.tipo == TipoVeredicto.amparo ? false : state.amparoActivo,
      panel: () => PanelPendiente(
        tarjeta: tarjeta,
        resultado: resultado,
        fase: bonus
            ? FasePanel.bonus
            : conPregunta
            ? FasePanel.microPregunta
            : FasePanel.explicacion,
      ),
    );
    // El Amparo se gasta cuando absorbe el error, no al armarlo.
    if (resultado.tipo == TipoVeredicto.amparo) _gastar(Comodin.amparo);
    return resultado;
  }

  /// Responde la micro-pregunta: si acierta, +5 XP y pasa a Bonus; si no, a
  /// la explicación.
  void elegirOpcion(int opcion) {
    final panel = state.panel;
    final pregunta = panel?.tarjeta.microPregunta;
    if (panel == null || pregunta == null || panel.fase != FasePanel.microPregunta) return;
    if (!LogicaVeredicto.aciertaMicroPregunta(pregunta, opcion)) {
      saltarBonus();
      return;
    }
    state = state.copiar(
      xp: state.xp + LogicaVeredicto.xpBonus,
      resultados: [
        for (final r in state.resultados)
          r.tarjetaId == panel.tarjeta.id
              ? ResultadoTarjeta(tarjetaId: r.tarjetaId, tipo: r.tipo, bonus: true)
              : r,
      ],
      panel: () => PanelPendiente(
        tarjeta: panel.tarjeta,
        resultado: panel.resultado.conBonus(),
        fase: FasePanel.bonus,
      ),
    );
  }

  /// "Saltar bonus" (o micro-pregunta fallada): muestra la explicación sin
  /// sumar el bonus.
  void saltarBonus() {
    final panel = state.panel;
    if (panel == null || panel.fase != FasePanel.microPregunta) return;
    state = state.copiar(
      panel: () => PanelPendiente(
        tarjeta: panel.tarjeta,
        resultado: panel.resultado,
        fase: FasePanel.explicacion,
      ),
    );
  }

  /// Cierra el panel y dice qué sigue. Solo con [DestinoVeredicto.siguiente]
  /// avanza a la siguiente tarjeta.
  DestinoVeredicto cerrarPanel({required int totalTarjetas}) {
    final destino = LogicaVeredicto.destino(
      estado: state.estadoStartup,
      vidas: state.vidas,
      esUltima: state.indice + 1 >= totalTarjetas,
    );
    final sigue = destino == DestinoVeredicto.siguiente;
    state = state.copiar(
      panel: () => null,
      indice: sigue ? state.indice + 1 : state.indice,
      fin: () => sigue ? null : destino,
    );
    return destino;
  }

  /// Guarda el resultado del sprint terminado (una sola vez):
  /// - completado (19): progreso con estrellas y estado final, vidas y monedas;
  /// - quiebra (19b) o sin vidas: solo las vidas (el progreso no cambia).
  ///
  /// En T-14 lo recibirá el servidor.
  Future<void> guardarResultado() async {
    final fin = state.fin;
    if (fin == null || state.guardado) return;
    final terminado = state;
    state = state.copiar(guardado: true);
    final vidas = ref.read(repositorioVidasProvider);
    if (fin == DestinoVeredicto.sprintCompletado) {
      await (
        ref
            .read(repositorioProgresoProvider)
            .registrarSprintCompletado(
              sprintId: sprintId,
              estrellas: terminado.estrellas,
              estadoFinal: terminado.estadoStartup,
            ),
        vidas.guardarVidas(terminado.vidas),
        ref.read(repositorioTiendaProvider).sumarMonedas(terminado.monedas),
      ).wait;
    } else {
      await vidas.guardarVidas(terminado.vidas);
    }
  }
}

final juegoProvider = NotifierProvider.autoDispose.family<JuegoNotifier, EstadoJuego, String>(
  JuegoNotifier.new,
);

/// Descarta el avance de [sprintId] y vuelve a pedir sus datos (vidas y
/// estado de la Startup ya guardados): el siguiente juego empieza desde la
/// tarjeta 1. Se llama al entrar con "Comenzar sprint", al salir del juego y
/// con "Reiniciar sprint".
void reiniciarJuego(WidgetRef ref, String sprintId) {
  ref
    ..invalidate(juegoProvider(sprintId))
    ..invalidate(datosJuegoProvider(sprintId));
}
