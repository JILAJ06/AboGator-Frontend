import '../modelos/respuesta_pendiente.dart';
import '../repositorios/cola_respuestas.dart';

/// Cola de respuestas en memoria: para web (sqflite no corre en el
/// navegador; se pierde al recargar) y para las pruebas.
class ColaRespuestasEnMemoria implements ColaRespuestas {
  /// En orden de llegada (un mapa de Dart conserva el orden de inserción).
  final Map<String, RespuestaPendiente> _respuestas = {};

  @override
  Future<void> agregar(RespuestaPendiente respuesta) async {
    _respuestas.putIfAbsent(respuesta.id, () => respuesta);
  }

  @override
  Future<List<RespuestaPendiente>> pendientes() async => _respuestas.values.toList();

  @override
  Future<int> cantidadPendientes() async => _respuestas.length;

  @override
  Future<void> marcarEnviadas(List<String> ids) async {
    ids.forEach(_respuestas.remove);
  }

  @override
  Future<void> registrarIntentoFallido(List<String> ids) async {
    for (final id in ids) {
      final r = _respuestas[id];
      if (r != null) _respuestas[id] = r.copiar(intentos: r.intentos + 1);
    }
  }
}
