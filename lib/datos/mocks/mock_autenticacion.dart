import '../../core/textos/textos.dart';
import '../modelos/usuario.dart';
import '../repositorios/repositorio_autenticacion.dart';
import 'espera_simulada.dart';

/// Autenticación simulada. No guarda ni registra contraseñas.
class MockAutenticacion implements RepositorioAutenticacion {
  MockAutenticacion({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;
  Usuario? _actual;

  static const Usuario usuarioDemo = Usuario(
    id: 'usr-001',
    nombre: 'Valeria Ríos',
    correo: 'valeria@ejemplo.mx',
    perfil: PerfilUsuario.desarrollador,
    nivel: 3,
    xp: 1250,
    racha: 4,
  );

  @override
  Future<Usuario> iniciarSesion({required String correo, required String contrasena}) async {
    await esperar(espera);
    if (correo.trim().isEmpty || contrasena.isEmpty) {
      throw const ExcepcionAutenticacion(Textos.errorCredenciales);
    }
    return _actual = usuarioDemo;
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required PerfilUsuario perfil,
    required bool aceptaAvisoPrivacidad,
    required bool aceptaTerminos,
  }) async {
    await esperar(espera);
    if (!aceptaAvisoPrivacidad || !aceptaTerminos) {
      throw const ExcepcionAutenticacion(Textos.errorConsentimientos);
    }
    return _actual = Usuario(
      id: 'usr-nuevo',
      nombre: nombre,
      correo: correo,
      perfil: perfil,
      nivel: 1,
      xp: 0,
      racha: 0,
    );
  }

  @override
  Future<Usuario?> usuarioActual() async {
    await esperar(espera);
    return _actual;
  }

  @override
  Future<void> cerrarSesion() async {
    await esperar(espera);
    _actual = null;
  }
}
