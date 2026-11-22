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

  /// 31 · Pide el enlace para crear una contraseña nueva. Responde igual
  /// aunque el correo no esté registrado (no revela qué cuentas existen).
  Future<void> solicitarRecuperacion(String correo);

  /// 31c · Guarda la contraseña nueva con el [token] del enlace. Lanza
  /// [ExcepcionEnlaceCaducado] si el enlace caducó o ya se usó.
  Future<void> restablecer({required String token, required String nueva});
}

/// El enlace de recuperación caducó o ya se usó (pantalla 31e).
class ExcepcionEnlaceCaducado implements Exception {
  const ExcepcionEnlaceCaducado();

  @override
  String toString() => 'ExcepcionEnlaceCaducado';
}

/// Error controlado de autenticación, con un mensaje para mostrar.
class ExcepcionAutenticacion implements Exception {
  const ExcepcionAutenticacion(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ExcepcionAutenticacion: $mensaje';
}
