import '../modelos/usuario.dart';

/// Inicio de sesión y registro (pantallas 05 y 06).
abstract interface class RepositorioAutenticacion {
  Future<Usuario> iniciarSesion({required String correo, required String contrasena});

  /// Los dos consentimientos viajan por separado al backend.
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required PerfilUsuario perfil,
    required bool aceptaAvisoPrivacidad,
    required bool aceptaTerminos,
  });

  Future<Usuario?> usuarioActual();

  Future<void> cerrarSesion();
}

/// Error controlado de autenticación, con un mensaje para mostrar.
class ExcepcionAutenticacion implements Exception {
  const ExcepcionAutenticacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ExcepcionAutenticacion: $mensaje';
}
