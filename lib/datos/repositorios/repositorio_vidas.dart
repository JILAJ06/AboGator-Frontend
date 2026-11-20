import '../modelos/vidas.dart';

/// Vidas del usuario (pantalla 20). El servidor decide la regeneración.
abstract interface class RepositorioVidas {
  Future<Vidas> obtenerVidas();

  /// Guarda las vidas que quedan al terminar o perder un sprint y devuelve
  /// las vidas resultantes (en T-14 el servidor recalcula la regeneración).
  Future<Vidas> guardarVidas(int cantidad);
}
