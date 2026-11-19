import '../modelos/vidas.dart';
import '../repositorios/repositorio_vidas.dart';
import 'espera_simulada.dart';

/// Vidas simuladas (5 de 5, como en Figma). Si faltan vidas, la hora de la
/// próxima imita la que mandaría el servidor.
class MockVidas implements RepositorioVidas {
  MockVidas({
    this.espera = esperaSimuladaPorDefecto,
    this.cantidad = Vidas.maximo,
    DateTime Function()? ahoraServidor,
  }) : _ahoraServidor = ahoraServidor ?? DateTime.now;

  final Duration espera;
  final int cantidad;
  final DateTime Function() _ahoraServidor;

  @override
  Future<Vidas> obtenerVidas() async {
    await esperar(espera);
    return Vidas(
      cantidad: cantidad,
      proximaEn: cantidad >= Vidas.maximo
          ? null
          : _ahoraServidor().add(const Duration(hours: 1, minutes: 24)),
    );
  }
}
