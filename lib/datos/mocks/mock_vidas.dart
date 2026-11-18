import '../modelos/vidas.dart';
import '../repositorios/repositorio_vidas.dart';
import 'espera_simulada.dart';

/// Vidas simuladas. La hora de la próxima vida imita la que mandaría el servidor.
class MockVidas implements RepositorioVidas {
  MockVidas({this.espera = esperaSimuladaPorDefecto, DateTime Function()? ahoraServidor})
    : _ahoraServidor = ahoraServidor ?? DateTime.now;

  final Duration espera;
  final DateTime Function() _ahoraServidor;

  @override
  Future<Vidas> obtenerVidas() async {
    await esperar(espera);
    return Vidas(
      cantidad: 3,
      proximaEn: _ahoraServidor().add(const Duration(hours: 1, minutes: 24)),
    );
  }
}
