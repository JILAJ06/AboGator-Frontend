import '../modelos/vidas.dart';
import '../repositorios/repositorio_vidas.dart';
import 'espera_simulada.dart';

/// Vidas simuladas que imitan al servidor (5 de 5 por defecto, como en Figma).
///
/// Con un reloj inyectable ([ahoraServidor]) guarda el momento de la próxima
/// regeneración:
/// - al bajar de 5 sin regeneración programada, la programa a ahora + 2 h;
/// - al pedir las vidas aplica las vencidas (+1 por cada 2 h cumplidas, sin
///   pasar de 5); si aún faltan, programa la siguiente 2 h después de la
///   anterior;
/// - con 5 no hay regeneración.
///
/// `faltaParaProxima` = próxima − ahora. Cada instancia empieza con
/// [cantidad] (las pruebas crean una nueva para reiniciar).
class MockVidas implements RepositorioVidas {
  MockVidas({
    this.espera = esperaSimuladaPorDefecto,
    int cantidad = Vidas.maximo,
    DateTime Function()? ahoraServidor,
  }) : _cantidad = cantidad.clamp(0, Vidas.maximo),
       _ahoraServidor = ahoraServidor ?? DateTime.now {
    _programarSiFalta();
  }

  final Duration espera;
  int _cantidad;
  final DateTime Function() _ahoraServidor;

  /// Momento (del servidor) de la próxima regeneración; `null` con 5 vidas.
  DateTime? _proxima;

  /// Vidas guardadas ahora mismo (sin aplicar regeneraciones pendientes).
  int get cantidad => _cantidad;

  /// Próxima regeneración programada (para las pruebas).
  DateTime? get proximaRegeneracion => _proxima;

  void _programarSiFalta() {
    if (_cantidad >= Vidas.maximo) {
      _proxima = null;
    } else {
      _proxima ??= _ahoraServidor().add(Vidas.intervaloRegeneracion);
    }
  }

  /// Aplica las regeneraciones vencidas.
  void _regenerar() {
    final ahora = _ahoraServidor();
    while (_proxima != null && !ahora.isBefore(_proxima!)) {
      _cantidad++;
      _proxima = _cantidad >= Vidas.maximo ? null : _proxima!.add(Vidas.intervaloRegeneracion);
    }
  }

  Vidas get _vidas =>
      Vidas(cantidad: _cantidad, faltaParaProxima: _proxima?.difference(_ahoraServidor()));

  @override
  Future<Vidas> obtenerVidas() async {
    await esperar(espera);
    _regenerar();
    return _vidas;
  }

  /// +1 sin pasar de 5. Si llega a 5 se quita la regeneración programada; si
  /// no, la programada se conserva.
  @override
  Future<Vidas> recuperarVida() async {
    await esperar(espera);
    _regenerar();
    _cantidad = (_cantidad + 1).clamp(0, Vidas.maximo);
    _programarSiFalta();
    return _vidas;
  }

  @override
  Future<Vidas> guardarVidas(int cantidad) async {
    await esperar(espera);
    _regenerar();
    _cantidad = cantidad.clamp(0, Vidas.maximo);
    _programarSiFalta();
    return _vidas;
  }
}
