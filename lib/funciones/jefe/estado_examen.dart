import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utilidades/cronometro.dart';
import '../../datos/modelos/examen.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/repositorios/repositorio_examen.dart';
import '../ajustes/estado_ajustes.dart';
import '../inicio/estado_inicio.dart';
import '../mapa/estado_mapa.dart';
import '../vidas/pantalla_sin_vidas.dart';

/// En qué parte del examen está la pantalla.
enum FaseJefe { intro, decision, replica, feedback, pausa, terminado }

/// Qué se muestra en el chip tras una respuesta.
enum TipoFeedback { golpe, falloVeredicto, falloTiempo, falloFundamento }

/// Estado del Examen Final en la app (27 a 28c). El servidor manda; aquí se
/// guarda lo que la pantalla y la T-11b necesitan.
class EstadoExamenJefe {
  const EstadoExamenJefe({
    required this.moduloId,
    this.fase = FaseJefe.intro,
    this.intento,
    this.decision,
    this.total = 10,
    this.vidas = Vidas.maximo,
    this.hp = 100,
    this.replica,
    this.limiteReplica,
    this.feedback,
    this.danio = 0,
    this.siguiente,
    this.resultado = EstadoExamen.enCurso,
    this.enviando = false,
    this.faseAntesDePausa,
    this.resumen = const ResumenExamen(),
    this.falladas = const [],
    this.veredictoElegido,
    this.ronda = 0,
  });

  final String moduloId;
  final FaseJefe fase;
  final IntentoExamen? intento;

  /// La decisión en pantalla.
  final DecisionCrisis? decision;
  final int total;
  final int vidas;
  final int hp;
  final Replica? replica;
  final Duration? limiteReplica;
  final TipoFeedback? feedback;
  final int danio;

  /// La que sigue tras el chip (`null` si el examen terminó).
  final DecisionCrisis? siguiente;
  final EstadoExamen resultado;

  /// Hay una respuesta en camino (no se acepta otra).
  final bool enviando;
  final FaseJefe? faseAntesDePausa;
  final ResumenExamen resumen;
  final List<DecisionFallada> falladas;

  /// El veredicto de la decisión actual (para la pose de la tarjeta en 28b).
  final Veredicto? veredictoElegido;

  /// Cambia con cada decisión y cada réplica (reinicia los relojes).
  final int ronda;

  bool get terminado => resultado != EstadoExamen.enCurso;

  EstadoExamenJefe copyWith({
    FaseJefe? fase,
    IntentoExamen? intento,
    DecisionCrisis? decision,
    int? total,
    int? vidas,
    int? hp,
    Replica? replica,
    Duration? limiteReplica,
    TipoFeedback? feedback,
    int? danio,
    DecisionCrisis? siguiente,
    EstadoExamen? resultado,
    bool? enviando,
    FaseJefe? faseAntesDePausa,
    ResumenExamen? resumen,
    List<DecisionFallada>? falladas,
    Veredicto? veredictoElegido,
    int? ronda,
    bool limpiarReplica = false,
    bool limpiarFeedback = false,
    bool limpiarSiguiente = false,
    bool limpiarVeredicto = false,
  }) => EstadoExamenJefe(
    moduloId: moduloId,
    fase: fase ?? this.fase,
    intento: intento ?? this.intento,
    decision: decision ?? this.decision,
    total: total ?? this.total,
    vidas: vidas ?? this.vidas,
    hp: hp ?? this.hp,
    replica: limpiarReplica ? null : replica ?? this.replica,
    limiteReplica: limpiarReplica ? null : limiteReplica ?? this.limiteReplica,
    feedback: limpiarFeedback ? null : feedback ?? this.feedback,
    danio: danio ?? this.danio,
    siguiente: limpiarSiguiente ? null : siguiente ?? this.siguiente,
    resultado: resultado ?? this.resultado,
    enviando: enviando ?? this.enviando,
    faseAntesDePausa: faseAntesDePausa ?? this.faseAntesDePausa,
    resumen: resumen ?? this.resumen,
    falladas: falladas ?? this.falladas,
    veredictoElegido: limpiarVeredicto ? null : veredictoElegido ?? this.veredictoElegido,
    ronda: ronda ?? this.ronda,
  );
}

/// Examen Final en curso. Se mantiene vivo entre pantallas hasta que la
/// T-11b guarde el resultado o se salga; `null` sin examen.
class ExamenNotifier extends Notifier<EstadoExamenJefe?> {
  @override
  EstadoExamenJefe? build() => null;

  RepositorioExamen get _repo => ref.read(repositorioExamenProvider);

  /// Al abrir 27: si no hay examen de [moduloId] en curso, deja la intro.
  void preparar(String moduloId) {
    final s = state;
    if (s == null || s.moduloId != moduloId || s.fase == FaseJefe.terminado) {
      state = EstadoExamenJefe(moduloId: moduloId);
    }
  }

  /// "Enfrentar la auditoría": pide el intento al servidor. Lanza
  /// `ExcepcionExamen` (sin vidas, sin conexión…) sin cambiar el estado.
  Future<void> iniciar() async {
    final s = state;
    if (s == null || s.fase != FaseJefe.intro || s.enviando) return;
    state = s.copyWith(enviando: true);
    try {
      final tiempoExtendido = ref.read(ajustesProvider).tiempoExtendido;
      final intento = await _repo.iniciar(s.moduloId, tiempoExtendido: tiempoExtendido);
      if (!ref.mounted) return;
      state = EstadoExamenJefe(
        moduloId: s.moduloId,
        fase: FaseJefe.decision,
        intento: intento,
        decision: intento.decision,
        total: intento.totalDecisiones,
        vidas: intento.vidas,
        hp: intento.hpJefe,
        ronda: 1,
        resumen: ResumenExamen(vidasRestantes: intento.vidas),
      );
    } finally {
      final actual = state;
      if (ref.mounted && actual != null && actual.fase == FaseJefe.intro) {
        state = actual.copyWith(enviando: false);
      }
    }
  }

  /// Responde la decisión (`null` = tiempo agotado). Solo una vez por
  /// decisión. Devuelve el resultado (o `null` si no se envió).
  Future<ResultadoDecision?> responderDecision(Veredicto? veredicto) async {
    final s = state;
    final intento = s?.intento;
    final decision = s?.decision;
    if (s == null || intento == null || decision == null) return null;
    if (s.fase != FaseJefe.decision || s.enviando) return null;
    state = s.copyWith(enviando: true, veredictoElegido: veredicto);
    try {
      final r = await _repo.responderDecision(intento.id, veredicto: veredicto);
      final actual = state;
      if (!ref.mounted || actual == null) return r;
      final resumen = actual.resumen.copyWith(
        decisionesJugadas: r.correcta ? null : actual.resumen.decisionesJugadas + 1,
        aciertos: r.correcta ? actual.resumen.aciertos + 1 : null,
        porTiempo: r.tiempoAgotado ? actual.resumen.porTiempo + 1 : null,
        vidasRestantes: r.vidas,
        aprobado: r.estado == EstadoExamen.aprobado,
      );
      if (r.correcta) {
        state = actual.copyWith(
          fase: FaseJefe.replica,
          enviando: false,
          replica: r.replica,
          limiteReplica: r.limiteReplica,
          vidas: r.vidas,
          hp: r.hpJefe,
          resumen: resumen,
          ronda: actual.ronda + 1,
        );
      } else {
        state = actual.copyWith(
          fase: FaseJefe.feedback,
          enviando: false,
          feedback: r.tiempoAgotado ? TipoFeedback.falloTiempo : TipoFeedback.falloVeredicto,
          danio: 0,
          vidas: r.vidas,
          hp: r.hpJefe,
          siguiente: r.siguiente,
          limpiarSiguiente: r.siguiente == null,
          resultado: r.estado,
          resumen: resumen,
          falladas: [
            ...actual.falladas,
            DecisionFallada(
              decision: decision,
              veredicto: veredicto,
              respuestaCorrecta: r.respuestaCorrecta,
            ),
          ],
        );
      }
      _refrescarVidas();
      return r;
    } on Object {
      final actual = state;
      if (ref.mounted && actual != null) state = actual.copyWith(enviando: false);
      rethrow;
    }
  }

  /// Responde el contraargumento (`null` = tiempo agotado). Solo una vez.
  Future<ResultadoContraargumento?> responderContraargumento(int? fundamento) async {
    final s = state;
    final intento = s?.intento;
    final decision = s?.decision;
    if (s == null || intento == null || decision == null) return null;
    if (s.fase != FaseJefe.replica || s.enviando) return null;
    state = s.copyWith(enviando: true);
    try {
      final r = await _repo.responderContraargumento(intento.id, fundamento: fundamento);
      final actual = state;
      if (!ref.mounted || actual == null) return r;
      state = actual.copyWith(
        fase: FaseJefe.feedback,
        enviando: false,
        feedback: r.correcto
            ? TipoFeedback.golpe
            : r.tiempoAgotado
            ? TipoFeedback.falloTiempo
            : TipoFeedback.falloFundamento,
        danio: r.danio,
        vidas: r.vidas,
        hp: r.hpJefe,
        siguiente: r.siguiente,
        limpiarSiguiente: r.siguiente == null,
        resultado: r.estado,
        resumen: actual.resumen.copyWith(
          decisionesJugadas: actual.resumen.decisionesJugadas + 1,
          golpes: r.correcto ? actual.resumen.golpes + 1 : null,
          porTiempo: r.tiempoAgotado ? actual.resumen.porTiempo + 1 : null,
          vidasRestantes: r.vidas,
          aprobado: r.estado == EstadoExamen.aprobado,
        ),
        falladas: r.correcto
            ? null
            : [
                ...actual.falladas,
                DecisionFallada(
                  decision: decision,
                  veredicto: actual.veredictoElegido,
                  respuestaCorrecta: actual.veredictoElegido,
                  enContraargumento: true,
                ),
              ],
      );
      if (!r.correcto) _refrescarVidas();
      return r;
    } on Object {
      final actual = state;
      if (ref.mounted && actual != null) state = actual.copyWith(enviando: false);
      rethrow;
    }
  }

  /// Tras el chip: la siguiente decisión, o fin del examen.
  void continuar() {
    final s = state;
    if (s == null || s.fase != FaseJefe.feedback) return;
    final siguiente = s.siguiente;
    if (s.terminado || siguiente == null) {
      state = s.copyWith(fase: FaseJefe.terminado, limpiarFeedback: true);
      return;
    }
    state = s.copyWith(
      fase: FaseJefe.decision,
      decision: siguiente,
      limpiarSiguiente: true,
      limpiarFeedback: true,
      limpiarReplica: true,
      limpiarVeredicto: true,
      ronda: s.ronda + 1,
    );
  }

  /// Pausa (solo con tiempo extendido).
  Future<void> pausar() async {
    final s = state;
    final intento = s?.intento;
    if (s == null || intento == null) return;
    if (s.fase != FaseJefe.decision && s.fase != FaseJefe.replica) return;
    if (!ref.read(ajustesProvider).tiempoExtendido || s.enviando) return;
    state = s.copyWith(fase: FaseJefe.pausa, faseAntesDePausa: s.fase);
    await _repo.pausar(intento.id);
  }

  Future<void> reanudar() async {
    final s = state;
    final intento = s?.intento;
    if (s == null || intento == null || s.fase != FaseJefe.pausa) return;
    await _repo.reanudar(intento.id);
    final actual = state;
    if (!ref.mounted || actual == null) return;
    state = actual.copyWith(fase: actual.faseAntesDePausa ?? FaseJefe.decision);
  }

  /// Salir: cierra el intento sin premio ni pérdida de vidas.
  Future<void> abandonar() async {
    final intento = state?.intento;
    state = null;
    if (intento != null) {
      try {
        await _repo.abandonar(intento.id);
      } on Object {
        // Sin red: el servidor lo cerrará solo (T-14).
      }
    }
    _refrescarVidas();
  }

  void _refrescarVidas() {
    ref
      ..invalidate(vidasActualesProvider)
      ..invalidate(datosInicioProvider)
      ..invalidate(datosModuloProvider);
  }
}

final examenProvider = NotifierProvider<ExamenNotifier, EstadoExamenJefe?>(ExamenNotifier.new);

/// Lo que muestra 27: el examen del servidor y las vidas.
class DatosCrisis {
  const DatosCrisis({required this.info, required this.vidas});

  final InfoExamen info;
  final int vidas;
}

final datosCrisisProvider = FutureProvider.autoDispose.family<DatosCrisis, String>((
  ref,
  moduloId,
) async {
  // En orden: así "no disponible" llega como `ExcepcionExamen` y no envuelto.
  final info = await ref.watch(repositorioExamenProvider).consultar(moduloId);
  final vidas = await ref.watch(repositorioVidasProvider).obtenerVidas();
  return DatosCrisis(info: info, vidas: vidas.cantidad);
});

/// Cronómetros monótonos del examen (falsos en pruebas).
final crearCronometroJefeProvider = Provider<Cronometro Function()>((ref) => CronometroSistema.new);
