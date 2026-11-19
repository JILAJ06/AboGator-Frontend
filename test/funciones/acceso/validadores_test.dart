import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/funciones/acceso/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nombre', () {
    test('válidos', () {
      expect(Validadores.nombre('Ana'), isNull);
      expect(Validadores.nombre('  Al  '), isNull);
      expect(Validadores.nombre('A' * 60), isNull);
    });
    test('inválidos', () {
      for (final valor in ['', '   ', 'A', ' A ', 'A' * 61]) {
        expect(Validadores.nombre(valor), Textos.errorNombre, reason: '"$valor"');
      }
    });
  });

  group('correo', () {
    test('válidos', () {
      for (final valor in ['ana@startup.mx', ' ana.dev@startup.mx ', 'a.b+c@dominio.co.uk']) {
        expect(Validadores.correo(valor), isNull, reason: valor);
      }
    });
    test('inválidos', () {
      for (final valor in [
        '',
        'ana',
        'ana@',
        '@startup.mx',
        'ana@startup',
        'ana@startup.m',
        'ana @startup.mx',
        'ana@@startup.mx',
      ]) {
        expect(Validadores.correo(valor), Textos.errorCorreo, reason: valor);
      }
    });
    test('máximo de 254 caracteres', () {
      final local = 'a' * 64;
      final dominio = '${'b' * 63}.${'c' * 63}.${'d' * 58}.mx';
      final justo = '$local@$dominio';
      expect(justo.length, 254);
      expect(Validadores.correo(justo), isNull);
      expect(Validadores.correo('a$justo'), Textos.errorCorreo);
    });
  });

  group('contraseña', () {
    test('inicio de sesión: solo no vacía', () {
      expect(Validadores.contrasenaInicio(''), Textos.errorContrasenaVacia);
      expect(Validadores.contrasenaInicio('x'), isNull);
    });
    test('registro: mínimo 8 y al menos un número', () {
      expect(Validadores.contrasenaRegistro('abcdefg1'), isNull);
      expect(Validadores.contrasenaRegistro('12345678'), isNull);
      for (final valor in ['', 'abc1', 'abcdefg', 'abcdefgh', 'abcdef1']) {
        expect(
          Validadores.contrasenaRegistro(valor),
          'Mínimo 8 caracteres, incluye un número',
          reason: '${valor.length} caracteres',
        );
      }
    });
    test('el mensaje nunca contiene la contraseña', () {
      const secreta = 'MiClave';
      expect(Validadores.contrasenaRegistro(secreta), isNot(contains(secreta)));
    });
  });

  test('perfil y consentimientos son obligatorios', () {
    expect(Validadores.perfil(null), Textos.errorPerfil);
    expect(Validadores.perfil(PerfilUsuario.legal), isNull);
    expect(Validadores.avisoPrivacidad(false), Textos.errorAvisoPrivacidad);
    expect(Validadores.avisoPrivacidad(true), isNull);
    expect(Validadores.terminos(false), Textos.errorTerminos);
    expect(Validadores.terminos(true), isNull);
  });
}
