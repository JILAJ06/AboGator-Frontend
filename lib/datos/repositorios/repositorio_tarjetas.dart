import '../modelos/tarjeta.dart';

/// Tarjetas de un sprint (pantallas 10 a 19b).
abstract interface class RepositorioTarjetas {
  Future<List<Tarjeta>> obtenerTarjetasDelSprint(String sprintId);
}
