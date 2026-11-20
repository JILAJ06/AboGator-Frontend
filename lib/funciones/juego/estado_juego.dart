import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../mapa/logica_mapa.dart';
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

  /// Con 0 vidas no se carga el juego (marcador de "Sin vidas", T-08).
  bool get sinVidas => vidas.cantidad <= 0;
}

/// Comodines que se muestran en la barra mientras el repositorio no da las
/// cantidades (se activan en T-07).
abstract final class ComodinesJuego {
  static const int lupa = 2;
  static const int abogado = 1;
  static const int amparo = 1;
}

/// Carga primero las vidas: con 0 no carga el juego. Si hay vidas, pide en
/// paralelo las tarjetas, el estado de la Startup y los módulos (para el
/// número del sprint y el color del módulo). Un sprint inexistente da una
/// lista de tarjetas vacía.
final datosJuegoProvider = FutureProvider.autoDispose.family<DatosJuego, String>((
  ref,
  sprintId,
) async {
  final repoVidas = ref.watch(repositorioVidasProvider);
  final repoTarjetas = ref.watch(repositorioTarjetasProvider);
  final repoProgreso = ref.watch(repositorioProgresoProvider);

  final vidas = await repoVidas.obtenerVidas();
  if (vidas.cantidad <= 0) return DatosJuego(vidas: vidas);

  Future<List<Tarjeta>> tarjetas() async {
    try {
      return await repoTarjetas.obtenerTarjetasDelSprint(sprintId);
    } on StateError {
      return const [];
    }
  }

  final (lista, estado, modulos) = await (
    tarjetas(),
    repoProgreso.obtenerEstadoStartup(),
    repoProgreso.obtenerModulos(),
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
enum FasePanel {
  /// Acierto con micro-pregunta sin responder (12).
  microPregunta,

  /// Muestra la explicación ("¿Por qué?"): 12 sin micro-pregunta o con ella
  /// saltada o fallada, 12c, 14 y 14b.
  explicacion,

  /// Micro-pregunta bien respondida (12b).
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
/// Es **local de la sesión del sprint**: los repositorios solo se leen al
/// entrar; vidas, XP y monedas no se guardan todavía (lo hará el servidor en
/// T-14).
class EstadoJuego {
  const EstadoJuego({
    this.indice = 0,
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
  });

  /// Tarjeta actual. Avanza al **cerrar** el panel, no al lanzar la tarjeta.
  final int indice;
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

  /// Amparo activo para el siguiente error (se activa en T-07).
  final bool amparoActivo;

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
  }) => EstadoJuego(
    indice: indice ?? this.indice,
    respuestas: respuestas ?? this.respuestas,
    estadoStartup: estadoStartup ?? this.estadoStartup,
    vidas: vidas ?? this.vidas,
    xp: xp ?? this.xp,
    monedas: monedas ?? this.monedas,
    resultados: resultados ?? this.resultados,
    falladas: falladas ?? this.falladas,
    panel: panel != null ? panel() : this.panel,
    amparoActivo: amparoActivo ?? this.amparoActivo,
  );
}

/// Lleva el avance del juego de un sprint: califica, actualiza indicadores,
/// vidas, XP y monedas, y decide qué sigue al cerrar el panel.
class JuegoNotifier extends Notifier<EstadoJuego> {
  JuegoNotifier(this.sprintId);

  final String sprintId;

  @override
  EstadoJuego build() {
    final datos = ref.watch(datosJuegoProvider(sprintId)).value;
    return EstadoJuego(
      estadoStartup: datos?.estadoStartup ?? const EstadoJuego().estadoStartup,
      vidas: datos?.vidas.cantidad ?? 0,
    );
  }

  /// Activa o desactiva el Amparo para el siguiente error (T-07 lo usará).
  void establecerAmparo({required bool activo}) => state = state.copiar(amparoActivo: activo);

  /// Califica la respuesta, aplica sus efectos y abre el panel. No avanza la
  /// tarjeta: eso pasa al cerrar el panel.
  ResultadoVeredicto responder(Tarjeta tarjeta, Veredicto veredicto) {
    final resultado = LogicaVeredicto.calificar(
      tarjeta,
      veredicto,
      amparoActivo: state.amparoActivo,
    );
    final conPregunta = resultado.tipo == TipoVeredicto.correcto && tarjeta.microPregunta != null;
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
        ResultadoTarjeta(tarjetaId: tarjeta.id, tipo: resultado.tipo),
      ],
      falladas: resultado.esFallo ? [...state.falladas, tarjeta.id] : state.falladas,
      // El Amparo se gasta al absorber un error.
      amparoActivo: resultado.tipo == TipoVeredicto.amparo ? false : state.amparoActivo,
      panel: () => PanelPendiente(
        tarjeta: tarjeta,
        resultado: resultado,
        fase: conPregunta ? FasePanel.microPregunta : FasePanel.explicacion,
      ),
    );
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
    state = state.copiar(
      panel: () => null,
      indice: destino == DestinoVeredicto.siguiente ? state.indice + 1 : state.indice,
    );
    return destino;
  }
}

final juegoProvider = NotifierProvider.autoDispose.family<JuegoNotifier, EstadoJuego, String>(
  JuegoNotifier.new,
);
