import '../modelos/respuesta_pendiente.dart';

/// Cola local de respuestas por enviar al servidor (offline-first). Cada
/// respuesta se guarda aquí primero y se borra cuando el servidor la acepta.
abstract interface class ColaRespuestas {
  /// Guarda [respuesta]. Si ya existe una con el mismo id, no la duplica.
  Future<void> agregar(RespuestaPendiente respuesta);

  /// Respuestas pendientes, de la más antigua a la más reciente.
  Future<List<RespuestaPendiente>> pendientes();

  Future<int> cantidadPendientes();

  /// Borra las respuestas que el servidor ya aceptó.
  Future<void> marcarEnviadas(List<String> ids);

  /// Suma un intento fallido a cada una (no las borra).
  Future<void> registrarIntentoFallido(List<String> ids);
}
