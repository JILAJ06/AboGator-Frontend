import '../modelos/respuesta_pendiente.dart';
import '../repositorios/repositorio_respuestas.dart';
import 'espera_simulada.dart';

/// Servidor simulado de respuestas. Guarda lo recibido sin duplicar por id
/// (enviar dos veces el mismo UUID cuenta una vez). Con [fallar] lanza y no
/// acepta nada.
class MockRespuestas implements RepositorioRespuestas {
  MockRespuestas({this.espera = esperaSimuladaPorDefecto, this.fallar = false});

  final Duration espera;

  /// Si es `true`, el siguiente envío falla (para las pruebas).
  bool fallar;

  final Map<String, RespuestaPendiente> _recibidas = {};

  /// Envíos recibidos (cuántas veces se llamó), para las pruebas.
  int envios = 0;

  /// Respuestas recibidas, una por id.
  List<RespuestaPendiente> get recibidas => List.unmodifiable(_recibidas.values);

  @override
  Future<List<String>> enviarRespuestas(List<RespuestaPendiente> respuestas) async {
    envios++;
    await esperar(espera);
    if (fallar) throw StateError('Sin conexión con el servidor');
    for (final r in respuestas) {
      _recibidas.putIfAbsent(r.id, () => r);
    }
    return [for (final r in respuestas) r.id];
  }
}
