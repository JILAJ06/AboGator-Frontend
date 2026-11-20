/// Por qué el servidor rechazó una compra.
enum MotivoExcepcionTienda { monedasInsuficientes, maximoAlcanzado, articuloInexistente }

/// Compra rechazada por el servidor; no cambió nada.
class ExcepcionTienda implements Exception {
  const ExcepcionTienda(this.motivo);

  final MotivoExcepcionTienda motivo;

  @override
  String toString() => 'ExcepcionTienda: ${motivo.name}';
}
