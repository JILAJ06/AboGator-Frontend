import 'dart:async';

/// Estado de la conexión con el servidor.
enum EstadoConexion { enLinea, sinConexion }

/// Conexión con el servidor. Hoy es simulada; en T-14 se cambiará por la
/// detección real sin tocar a quien la usa.
abstract interface class ServicioConexion {
  EstadoConexion get estado;

  /// Avisa cada cambio de estado.
  Stream<EstadoConexion> get cambios;
}

/// Conexión simulada: arranca en línea y cambia con [establecer] (el
/// interruptor de depuración y las pruebas).
class ConexionSimulada implements ServicioConexion {
  ConexionSimulada({EstadoConexion inicial = EstadoConexion.enLinea}) : _estado = inicial;

  EstadoConexion _estado;
  final _cambios = StreamController<EstadoConexion>.broadcast(sync: true);

  @override
  EstadoConexion get estado => _estado;

  @override
  Stream<EstadoConexion> get cambios => _cambios.stream;

  void establecer(EstadoConexion estado) {
    if (estado == _estado) return;
    _estado = estado;
    _cambios.add(estado);
  }

  Future<void> cerrar() => _cambios.close();
}
