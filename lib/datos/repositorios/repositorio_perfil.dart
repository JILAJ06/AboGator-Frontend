import '../modelos/resumen_perfil.dart';

/// Perfil y progreso (pantalla 25).
abstract interface class RepositorioPerfil {
  /// Datos, estadísticas e insignias de la persona con sesión.
  Future<ResumenPerfil> obtenerPerfil();
}
