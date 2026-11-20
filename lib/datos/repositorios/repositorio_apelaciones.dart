import '../modelos/apelacion.dart';
import '../modelos/buzon_apelaciones.dart';

/// Buzón de Apelaciones (pantallas 21, 21b, 22 y 22b).
abstract interface class RepositorioApelaciones {
  /// El Buzón con la hora del servidor.
  Future<BuzonApelaciones> obtenerBuzon();

  /// Manda al Buzón las tarjetas falladas en un sprint: una apelación de día 3
  /// (disponible a los 3 días, hora del servidor) por cada tarjeta que no esté
  /// ya en el Buzón.
  Future<void> registrarFallos(List<NuevaApelacion> fallos);
}
