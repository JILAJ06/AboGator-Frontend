import '../modelos/examen.dart';
import '../modelos/tarjeta.dart';

/// Examen Final de un módulo (pantallas 27 a 28c). El servidor manda: el
/// tiempo, las vidas, el HP del Jefe y el resultado.
abstract interface class RepositorioExamen {
  /// Lo que muestra 27. Lanza `ExcepcionExamen(examenNoDisponible)` si el
  /// módulo aún no tiene escenario.
  Future<InfoExamen> consultar(String moduloId);

  /// Empieza un intento (HP 100, 10 decisiones). Con [tiempoExtendido],
  /// 22 s por decisión y 12 s por réplica. Lanza `sinConexion`, `sinVidas` o
  /// `examenNoDisponible`.
  Future<IntentoExamen> iniciar(String moduloId, {bool tiempoExtendido = false});

  /// Responde la decisión actual; [veredicto] `null` = tiempo agotado.
  Future<ResultadoDecision> responderDecision(String intentoId, {Veredicto? veredicto});

  /// Responde el contraargumento; [fundamento] (0 o 1) `null` = tiempo
  /// agotado.
  Future<ResultadoContraargumento> responderContraargumento(String intentoId, {int? fundamento});

  /// Pausa (solo con tiempo extendido): el tiempo deja de correr.
  Future<void> pausar(String intentoId);

  Future<void> reanudar(String intentoId);

  /// Cierra el intento sin premio ni pérdida de vidas.
  Future<void> abandonar(String intentoId);
}

/// Por qué el servidor rechazó una operación del examen.
enum MotivoExcepcionExamen { sinConexion, sinVidas, intentoCerrado, examenNoDisponible }

class ExcepcionExamen implements Exception {
  const ExcepcionExamen(this.motivo);

  final MotivoExcepcionExamen motivo;

  @override
  String toString() => 'ExcepcionExamen: ${motivo.name}';
}
