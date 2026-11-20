import '../modelos/respuesta_pendiente.dart';

/// Lado del servidor de las respuestas del juego (en T-14, la API).
abstract interface class RepositorioRespuestas {
  /// Envía [respuestas] y devuelve los ids aceptados. El servidor no cuenta
  /// dos veces el mismo id. Si falla, lanza y no se acepta ninguna.
  Future<List<String>> enviarRespuestas(List<RespuestaPendiente> respuestas);
}
