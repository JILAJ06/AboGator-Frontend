import '../../core/textos/textos.dart';
import '../../datos/modelos/usuario.dart';

/// Validaciones de los formularios de acceso. Funciones puras: devuelven el
/// mensaje de error o `null` si el valor es válido.
///
/// Nunca incluyen la contraseña en el mensaje.
abstract final class Validadores {
  static const int minNombre = 2;
  static const int maxNombre = 60;
  static const int maxCorreo = 254;
  static const int minContrasena = 8;

  /// `algo@dominio.tld`, sin espacios.
  static final RegExp _formatoCorreo = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _digito = RegExp(r'\d');

  static String? nombre(String valor) {
    final limpio = valor.trim();
    if (limpio.length < minNombre || limpio.length > maxNombre) {
      return Textos.errorNombre;
    }
    return null;
  }

  static String? correo(String valor) {
    final limpio = valor.trim();
    if (limpio.isEmpty || limpio.length > maxCorreo || !_formatoCorreo.hasMatch(limpio)) {
      return Textos.errorCorreo;
    }
    return null;
  }

  /// Inicio de sesión: solo se exige que no esté vacía.
  static String? contrasenaInicio(String valor) =>
      valor.isEmpty ? Textos.errorContrasenaVacia : null;

  /// Registro: mínimo 8 caracteres y al menos un número.
  static String? contrasenaRegistro(String valor) {
    if (valor.length < minContrasena || !_digito.hasMatch(valor)) {
      return Textos.errorContrasenaRegistro;
    }
    return null;
  }

  static String? perfil(PerfilUsuario? valor) => valor == null ? Textos.errorPerfil : null;

  static String? avisoPrivacidad(bool aceptado) => aceptado ? null : Textos.errorAvisoPrivacidad;

  static String? terminos(bool aceptado) => aceptado ? null : Textos.errorTerminos;
}
