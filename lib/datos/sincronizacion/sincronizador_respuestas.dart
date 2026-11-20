import '../repositorios/cola_respuestas.dart';
import '../repositorios/repositorio_respuestas.dart';

/// Envía al servidor las respuestas de la cola local y borra solo las que
/// acepta. Si el envío falla, suma un intento a cada una y no pierde nada.
///
/// No corre dos veces a la vez: una llamada mientras está corriendo no se
/// ejecuta en paralelo, pero deja pedida **una** pasada más al terminar (así
/// una respuesta guardada durante el envío no se queda esperando al
/// siguiente disparo).
class SincronizadorRespuestas {
  SincronizadorRespuestas({required this.cola, required this.servidor});

  final ColaRespuestas cola;
  final RepositorioRespuestas servidor;

  bool _enCurso = false;
  bool _otraPasada = false;

  /// Si hay un envío en curso.
  bool get enCurso => _enCurso;

  /// Sincroniza y devuelve cuántas respuestas aceptó el servidor (0 si ya
  /// estaba corriendo, no había nada o falló).
  Future<int> sincronizar() async {
    if (_enCurso) {
      _otraPasada = true;
      return 0;
    }
    _enCurso = true;
    var aceptadas = 0;
    try {
      do {
        _otraPasada = false;
        aceptadas += await _pasada();
      } while (_otraPasada);
    } finally {
      _enCurso = false;
    }
    return aceptadas;
  }

  Future<int> _pasada() async {
    final pendientes = await cola.pendientes();
    if (pendientes.isEmpty) return 0;
    final ids = [for (final r in pendientes) r.id];
    try {
      final aceptados = await servidor.enviarRespuestas(pendientes);
      await cola.marcarEnviadas(aceptados);
      // Las que el servidor no aceptó se reintentan después.
      final rechazados = ids.where((id) => !aceptados.contains(id)).toList();
      if (rechazados.isNotEmpty) await cola.registrarIntentoFallido(rechazados);
      return aceptados.length;
    } on Object {
      await cola.registrarIntentoFallido(ids);
      _otraPasada = false;
      return 0;
    }
  }
}
