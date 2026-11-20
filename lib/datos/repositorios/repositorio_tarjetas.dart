import '../modelos/tarjeta.dart';

/// Tarjetas de un sprint (pantallas 10 a 19b).
abstract interface class RepositorioTarjetas {
  Future<List<Tarjeta>> obtenerTarjetasDelSprint(String sprintId);

  /// Una tarjeta por id (para abrir la de una apelación). Lanza
  /// `StateError` si no existe.
  Future<Tarjeta> obtenerTarjeta(String id);
}
