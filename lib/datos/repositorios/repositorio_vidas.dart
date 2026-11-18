import '../modelos/vidas.dart';

/// Vidas del usuario (pantalla 20). El servidor decide la regeneración.
abstract interface class RepositorioVidas {
  Future<Vidas> obtenerVidas();
}
