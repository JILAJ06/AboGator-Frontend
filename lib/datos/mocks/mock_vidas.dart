import '../modelos/vidas.dart';
import '../repositorios/repositorio_vidas.dart';
import 'espera_simulada.dart';

/// Vidas simuladas (5 de 5, como en Figma). Si faltan vidas, la hora de la
/// próxima imita la que mandaría el servidor.
///
/// Guarda las vidas en memoria; cada instancia empieza con [cantidad] (las
/// pruebas crean una nueva para reiniciar).
class MockVidas implements RepositorioVidas {
  MockVidas({
    this.espera = esperaSimuladaPorDefecto,
    this._cantidad = Vidas.maximo,
    DateTime Function()? ahoraServidor,
  }) : _ahoraServidor = ahoraServidor ?? DateTime.now;

  final Duration espera;
  int _cantidad;
  final DateTime Function() _ahoraServidor;

  /// Vidas guardadas ahora mismo.
  int get cantidad => _cantidad;

  Vidas get _vidas => Vidas(
    cantidad: _cantidad,
    proximaEn: _cantidad >= Vidas.maximo
        ? null
        : _ahoraServidor().add(const Duration(hours: 1, minutes: 24)),
  );

  @override
  Future<Vidas> obtenerVidas() async {
    await esperar(espera);
    return _vidas;
  }

  @override
  Future<Vidas> guardarVidas(int cantidad) async {
    await esperar(espera);
    _cantidad = cantidad.clamp(0, Vidas.maximo);
    return _vidas;
  }
}
