import 'tarjeta.dart';

/// Respuesta del jugador guardada en el dispositivo hasta que el servidor la
/// recibe (offline-first). El [id] lo genera el cliente (UUID v4): el
/// servidor lo usa para no contarla dos veces.
class RespuestaPendiente {
  const RespuestaPendiente({
    required this.id,
    required this.sprintId,
    required this.tarjetaId,
    required this.veredicto,
    required this.respondidaEn,
    this.justificacion,
    this.evidenciaCorrecta,
    this.intentos = 0,
  });

  final String id;
  final String sprintId;
  final String tarjetaId;
  final Veredicto veredicto;

  /// Opción elegida en la justificación (dilemas).
  final int? justificacion;

  /// Si marcó bien la evidencia; `null` si no la marcó o no tiene.
  final bool? evidenciaCorrecta;

  /// Momento de la respuesta en UTC. Solo informativo: el servidor no se fía
  /// del reloj del dispositivo.
  final DateTime respondidaEn;

  /// Envíos fallidos.
  final int intentos;

  RespuestaPendiente copiar({int? intentos}) => RespuestaPendiente(
    id: id,
    sprintId: sprintId,
    tarjetaId: tarjetaId,
    veredicto: veredicto,
    justificacion: justificacion,
    evidenciaCorrecta: evidenciaCorrecta,
    respondidaEn: respondidaEn,
    intentos: intentos ?? this.intentos,
  );

  /// Fila de la tabla `respuestas_pendientes`.
  Map<String, Object?> aFila() => {
    'id': id,
    'sprint_id': sprintId,
    'tarjeta_id': tarjetaId,
    'veredicto': veredicto.name,
    'justificacion': justificacion,
    'evidencia_correcta': evidenciaCorrecta == null ? null : (evidenciaCorrecta! ? 1 : 0),
    'respondida_en': respondidaEn.toUtc().toIso8601String(),
    'intentos': intentos,
  };

  factory RespuestaPendiente.deFila(Map<String, Object?> fila) {
    final evidencia = fila['evidencia_correcta'] as int?;
    return RespuestaPendiente(
      id: fila['id']! as String,
      sprintId: fila['sprint_id']! as String,
      tarjetaId: fila['tarjeta_id']! as String,
      veredicto: Veredicto.values.byName(fila['veredicto']! as String),
      justificacion: fila['justificacion'] as int?,
      evidenciaCorrecta: evidencia == null ? null : evidencia == 1,
      respondidaEn: DateTime.parse(fila['respondida_en']! as String).toUtc(),
      intentos: fila['intentos']! as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RespuestaPendiente &&
      other.id == id &&
      other.sprintId == sprintId &&
      other.tarjetaId == tarjetaId &&
      other.veredicto == veredicto &&
      other.justificacion == justificacion &&
      other.evidenciaCorrecta == evidenciaCorrecta &&
      other.respondidaEn == respondidaEn &&
      other.intentos == intentos;

  @override
  int get hashCode => Object.hash(
    id,
    sprintId,
    tarjetaId,
    veredicto,
    justificacion,
    evidenciaCorrecta,
    respondidaEn,
    intentos,
  );

  @override
  String toString() => 'RespuestaPendiente($id, $tarjetaId, ${veredicto.name}, $intentos)';
}
