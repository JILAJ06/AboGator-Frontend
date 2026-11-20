import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';

/// Módulos, sprints y estado de la Startup (pantallas 07, 08 y 09).
abstract interface class RepositorioProgreso {
  Future<List<Modulo>> obtenerModulos();

  Future<EstadoStartup> obtenerEstadoStartup();
}
