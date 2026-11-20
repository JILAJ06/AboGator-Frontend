import '../modelos/apelacion.dart';
import '../modelos/buzon_apelaciones.dart';
import '../modelos/resultado_apelacion.dart';

/// Buzón de Apelaciones (pantallas 21, 21b, 22 y 22b).
abstract interface class RepositorioApelaciones {
  /// El Buzón con la hora del servidor.
  Future<BuzonApelaciones> obtenerBuzon();

  /// Manda al Buzón las tarjetas falladas en un sprint: una apelación de día 3
  /// (disponible a los 3 días, hora del servidor) por cada tarjeta que no esté
  /// ya en el Buzón.
  Future<void> registrarFallos(List<NuevaApelacion> fallos);

  /// Resuelve el juicio de [apelacionId] (pantallas 22 y 22b):
  /// - ganada: pasa al siguiente día de repaso (3 → 7 en 4 días, 7 → 14 en 7
  ///   días) o, si era de día 14, queda dominada y sale del Buzón;
  /// - perdida: se queda en su día y se vuelve a abrir mañana.
  ///
  /// Lanza `StateError` si no existe o no está disponible hoy.
  Future<ResultadoApelacion> resolverApelacion(String apelacionId, {required bool ganada});
}
