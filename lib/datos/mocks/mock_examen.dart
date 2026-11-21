import '../modelos/examen.dart';
import '../modelos/modulo.dart';
import '../modelos/resultado_examen.dart';
import '../modelos/tarjeta.dart';
import '../repositorios/repositorio_autenticacion.dart';
import '../repositorios/repositorio_examen.dart';
import '../repositorios/repositorio_progreso.dart';
import '../repositorios/repositorio_vidas.dart';
import 'escenario_ransomware.dart';
import 'espera_simulada.dart';
import 'mock_autenticacion.dart';

/// Fase del intento en el servidor simulado.
enum _Turno { decision, replica, cerrado }

class _Intento {
  _Intento({
    required this.id,
    required this.moduloId,
    required this.vidas,
    required this.extendido,
    required this.vence,
  });

  final String id;
  final String moduloId;
  final bool extendido;
  int vidas;
  int hp = MockExamen.hpInicial;
  int indice = 0;
  _Turno turno = _Turno.decision;

  /// Cuándo vence la respuesta actual (hora del servidor).
  DateTime vence;
  DateTime? pausadoDesde;

  /// Veredictos acertados (para el certificado).
  int aciertos = 0;

  /// Cómo terminó (`null` mientras sigue).
  EstadoExamen? resultado;

  /// El registro ya hecho (idempotente).
  ResultadoRegistrado? registro;
}

/// Examen Final simulado que hace de servidor (§6.3, RF-34 a RF-38): un solo
/// escenario (módulo 1), reloj inyectable ([ahora]) y las vidas en
/// [vidas]. Rechaza como tiempo agotado toda respuesta que llegue más de
/// [tolerancia] después del límite.
class MockExamen implements RepositorioExamen {
  MockExamen({
    required this.vidas,
    this.progreso,
    this.autenticacion,
    this.espera = esperaSimuladaPorDefecto,
    DateTime Function()? ahora,
    bool Function()? enLinea,
  }) : _ahora = ahora ?? DateTime.now,
       _enLinea = enLinea ?? (() => true);

  final RepositorioVidas vidas;

  /// Para completar el Examen final y desbloquear el módulo siguiente.
  final RepositorioProgreso? progreso;

  /// Para el nombre del certificado (Ana si no hay).
  final RepositorioAutenticacion? autenticacion;

  /// Certificados emitidos, uno por módulo.
  final Map<String, Certificado> _certificados = {};
  int _siguienteFolio = 1;
  final Duration espera;
  final DateTime Function() _ahora;
  final bool Function() _enLinea;
  final Map<String, _Intento> _intentos = {};
  int _siguiente = 1;

  static const int hpInicial = 100;
  static const int danio = 20;
  static const Duration limiteDecision = Duration(seconds: 15);
  static const Duration limiteDecisionExtendido = Duration(seconds: 22);
  static const Duration limiteReplica = Duration(seconds: 8);
  static const Duration limiteReplicaExtendido = Duration(seconds: 12);
  static const Duration tolerancia = Duration(seconds: 2);

  static List<DecisionEscenario> get _escenario => EscenarioRansomware.decisiones;

  static Duration _limiteDecision(bool extendido) =>
      extendido ? limiteDecisionExtendido : limiteDecision;

  static Duration _limiteReplica(bool extendido) =>
      extendido ? limiteReplicaExtendido : limiteReplica;

  DecisionCrisis _decision(int indice, bool extendido) {
    final d = _escenario[indice];
    return DecisionCrisis(
      id: 'ran-${(indice + 1).toString().padLeft(2, '0')}',
      indice: indice + 1,
      hora: d.hora,
      limite: _limiteDecision(extendido),
      etiquetaCaso: EscenarioRansomware.etiqueta,
      personaje: d.personaje,
      rol: d.rol,
      texto: d.texto,
      iniciales: d.iniciales,
    );
  }

  @override
  Future<InfoExamen> consultar(String moduloId) async {
    await esperar(espera);
    if (moduloId != EscenarioRansomware.moduloId) {
      throw const ExcepcionExamen(MotivoExcepcionExamen.examenNoDisponible);
    }
    return InfoExamen(
      moduloId: moduloId,
      titulo: EscenarioRansomware.titulo,
      descripcion: EscenarioRansomware.descripcion,
      totalDecisiones: _escenario.length,
    );
  }

  @override
  Future<IntentoExamen> iniciar(String moduloId, {bool tiempoExtendido = false}) async {
    await esperar(espera);
    if (!_enLinea()) throw const ExcepcionExamen(MotivoExcepcionExamen.sinConexion);
    if (moduloId != EscenarioRansomware.moduloId) {
      throw const ExcepcionExamen(MotivoExcepcionExamen.examenNoDisponible);
    }
    final actuales = (await vidas.obtenerVidas()).cantidad;
    if (actuales <= 0) throw const ExcepcionExamen(MotivoExcepcionExamen.sinVidas);
    final id = 'exa-${(_siguiente++).toString().padLeft(3, '0')}';
    final intento = _Intento(
      id: id,
      moduloId: moduloId,
      vidas: actuales,
      extendido: tiempoExtendido,
      vence: _ahora().add(_limiteDecision(tiempoExtendido)),
    );
    _intentos[id] = intento;
    return IntentoExamen(
      id: id,
      moduloId: moduloId,
      hpJefe: intento.hp,
      vidas: intento.vidas,
      totalDecisiones: _escenario.length,
      decision: _decision(0, tiempoExtendido),
    );
  }

  _Intento _abierto(String intentoId, _Turno turno) {
    final i = _intentos[intentoId];
    if (i == null || i.turno != turno || i.pausadoDesde != null) {
      throw const ExcepcionExamen(MotivoExcepcionExamen.intentoCerrado);
    }
    return i;
  }

  /// Llegó tarde: más de [tolerancia] después del límite.
  bool _tarde(_Intento i) => _ahora().isAfter(i.vence.add(tolerancia));

  Future<void> _perderVida(_Intento i) async {
    i.vidas = i.vidas > 0 ? i.vidas - 1 : 0;
    await vidas.guardarVidas(i.vidas);
  }

  /// Estado tras una respuesta; si sigue, prepara la siguiente decisión.
  EstadoExamen _estado(_Intento i) {
    if (i.hp <= 0) return EstadoExamen.aprobado;
    if (i.vidas <= 0) return EstadoExamen.reprobado;
    if (i.indice + 1 >= _escenario.length) return EstadoExamen.reprobado;
    return EstadoExamen.enCurso;
  }

  DecisionCrisis? _avanzar(_Intento i, EstadoExamen estado) {
    if (estado != EstadoExamen.enCurso) {
      i
        ..turno = _Turno.cerrado
        ..resultado = estado;
      return null;
    }
    i
      ..indice += 1
      ..turno = _Turno.decision
      ..vence = _ahora().add(_limiteDecision(i.extendido));
    return _decision(i.indice, i.extendido);
  }

  @override
  Future<ResultadoDecision> responderDecision(String intentoId, {Veredicto? veredicto}) async {
    await esperar(espera);
    final i = _abierto(intentoId, _Turno.decision);
    final d = _escenario[i.indice];
    final agotado = veredicto == null || _tarde(i);
    final correcta = !agotado && veredicto == d.respuestaCorrecta;
    if (correcta) {
      i
        ..aciertos += 1
        ..turno = _Turno.replica
        ..vence = _ahora().add(_limiteReplica(i.extendido));
      return ResultadoDecision(
        correcta: true,
        tiempoAgotado: false,
        vidas: i.vidas,
        hpJefe: i.hp,
        estado: EstadoExamen.enCurso,
        replica: Replica(texto: d.replica, fundamentos: d.fundamentos),
        limiteReplica: _limiteReplica(i.extendido),
      );
    }
    await _perderVida(i);
    final estado = _estado(i);
    return ResultadoDecision(
      correcta: false,
      tiempoAgotado: agotado,
      vidas: i.vidas,
      hpJefe: i.hp,
      estado: estado,
      siguiente: _avanzar(i, estado),
      respuestaCorrecta: d.respuestaCorrecta,
    );
  }

  @override
  Future<ResultadoContraargumento> responderContraargumento(
    String intentoId, {
    int? fundamento,
  }) async {
    await esperar(espera);
    final i = _abierto(intentoId, _Turno.replica);
    final d = _escenario[i.indice];
    final agotado = fundamento == null || _tarde(i);
    final correcto = !agotado && fundamento == d.fundamentoCorrecto;
    if (correcto) {
      i.hp = (i.hp - danio).clamp(0, hpInicial);
    } else {
      await _perderVida(i);
    }
    final estado = _estado(i);
    return ResultadoContraargumento(
      correcto: correcto,
      tiempoAgotado: agotado,
      vidas: i.vidas,
      hpJefe: i.hp,
      danio: correcto ? danio : 0,
      estado: estado,
      siguiente: _avanzar(i, estado),
    );
  }

  @override
  Future<void> pausar(String intentoId) async {
    await esperar(espera);
    final i = _intentos[intentoId];
    if (i == null || i.turno == _Turno.cerrado || !i.extendido) {
      throw const ExcepcionExamen(MotivoExcepcionExamen.intentoCerrado);
    }
    i.pausadoDesde ??= _ahora();
  }

  @override
  Future<void> reanudar(String intentoId) async {
    await esperar(espera);
    final i = _intentos[intentoId];
    final desde = i?.pausadoDesde;
    if (i == null || desde == null) return;
    // El tiempo en pausa no cuenta.
    i
      ..vence = i.vence.add(_ahora().difference(desde))
      ..pausadoDesde = null;
  }

  @override
  Future<ResultadoRegistrado> registrarResultado(String intentoId) async {
    await esperar(espera);
    if (!_enLinea()) throw const ExcepcionExamen(MotivoExcepcionExamen.sinConexion);
    final i = _intentos[intentoId];
    final resultado = i?.resultado;
    if (i == null || resultado == null) {
      throw const ExcepcionExamen(MotivoExcepcionExamen.intentoCerrado);
    }
    final previo = i.registro;
    if (previo != null) return previo;
    final actuales = await vidas.obtenerVidas();
    if (resultado != EstadoExamen.aprobado) {
      return i.registro = ResultadoRegistrado(
        aprobado: false,
        vidas: actuales.cantidad,
        faltaParaProximaVida: actuales.faltaParaProxima,
      );
    }
    final modulos = await progreso?.obtenerModulos() ?? const <Modulo>[];
    final indice = modulos.indexWhere((m) => m.id == i.moduloId);
    final modulo = indice < 0 ? null : modulos[indice];
    final siguiente = indice >= 0 && indice + 1 < modulos.length ? modulos[indice + 1] : null;
    final certificado = _certificados[i.moduloId] ??= Certificado(
      folio: 'AG-M${modulo?.numero ?? 1}-${(_siguienteFolio++).toString().padLeft(4, '0')}',
      moduloId: i.moduloId,
      nombreModulo: modulo?.nombre ?? i.moduloId,
      nombrePersona:
          (await autenticacion?.usuarioActual())?.nombre ?? MockAutenticacion.usuarioDemo.nombre,
      aciertos: i.aciertos,
      totalDecisiones: _escenario.length,
      fecha: _ahora().toUtc(),
    );
    await progreso?.registrarExamenAprobado(moduloId: i.moduloId);
    return i.registro = ResultadoRegistrado(
      aprobado: true,
      certificado: certificado,
      siguienteModulo: siguiente == null
          ? null
          : ModuloDesbloqueado(
              id: siguiente.id,
              numero: siguiente.numero,
              nombre: siguiente.nombre,
            ),
      vidas: actuales.cantidad,
      faltaParaProximaVida: actuales.faltaParaProxima,
    );
  }

  @override
  Future<List<Certificado>> obtenerCertificados() async {
    await esperar(espera);
    return List.unmodifiable(_certificados.values);
  }

  @override
  Future<void> abandonar(String intentoId) async {
    await esperar(espera);
    _intentos[intentoId]?.turno = _Turno.cerrado;
  }
}
