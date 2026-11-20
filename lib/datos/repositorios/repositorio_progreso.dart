import '../modelos/estado_startup.dart';
import '../modelos/modulo.dart';

/// Módulos, sprints y estado de la Startup (pantallas 07, 08, 09 y 19).
abstract interface class RepositorioProgreso {
  Future<List<Modulo>> obtenerModulos();

  Future<EstadoStartup> obtenerEstadoStartup();

  /// Registra un sprint terminado (19): lo marca completado con sus
  /// [estrellas] (si ya lo estaba, conserva el máximo), pone en curso el
  /// siguiente sprint del módulo si estaba bloqueado y guarda [estadoFinal]
  /// como el estado actual de la Startup.
  ///
  /// En T-14 será una llamada al servidor, que validará el resultado.
  Future<void> registrarSprintCompletado({
    required String sprintId,
    required int estrellas,
    required EstadoStartup estadoFinal,
  });
}
