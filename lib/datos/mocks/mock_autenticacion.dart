import '../../core/textos/textos.dart';
import '../modelos/usuario.dart';
import '../repositorios/repositorio_autenticacion.dart';
import 'espera_simulada.dart';

/// Autenticación simulada. No guarda ni registra contraseñas.
class MockAutenticacion implements RepositorioAutenticacion {
  MockAutenticacion({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;
  Usuario? _actual;

  /// Contraseña que el mock rechaza, para probar el error sin servidor.
  static const String contrasenaRechazada = 'incorrecta';

  static const Usuario usuarioDemo = Usuario(
    id: 'usr-001',
    nombre: 'Ana López',
    correo: 'ana@ejemplo.mx',
    perfil: PerfilUsuario.desarrollador,
    nivel: 4,
    xp: 1250,
    racha: 7,
  );

  @override
  Future<Usuario> iniciarSesion({required String correo, required String contrasena}) async {
    await esperar(espera);
    // `incorrecta` simula credenciales rechazadas por el servidor.
    if (correo.trim().isEmpty || contrasena.isEmpty || contrasena == contrasenaRechazada) {
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

  /// Token que el mock trata como caducado (31e).
  static const String tokenCaducado = 'caducado';

  /// Token de demostración que abre "Abrir correo" en el mock.
  static const String tokenDemo = 'demo';

  /// Correos para los que se pidió un enlace (pruebas).
  final List<String> solicitudesRecuperacion = [];

  @override
  Future<void> solicitarRecuperacion(String correo) async {
    await esperar(espera);
    // Siempre responde igual, exista o no la cuenta.
    solicitudesRecuperacion.add(correo.trim());
  }

  @override
  Future<void> restablecer({required String token, required String nueva}) async {
    await esperar(espera);
    if (token == tokenCaducado) throw const ExcepcionEnlaceCaducado();
    // T-14: el servidor guarda la contraseña y cierra las otras sesiones.
  }
}
