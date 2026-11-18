import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_autenticacion.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/modelos/vidas.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_autenticacion.dart';
import 'package:abogator/datos/repositorios/repositorio_progreso.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockAutenticacion', () {
    test('inicia sesión con el usuario de ejemplo', () async {
      final repo = MockAutenticacion(espera: Duration.zero);
      final usuario = await repo.iniciarSesion(correo: 'a@b.mx', contrasena: 'x');
      expect(usuario.nombre, isNotEmpty);
      expect(await repo.usuarioActual(), isNotNull);
      await repo.cerrarSesion();
      expect(await repo.usuarioActual(), isNull);
    });

    test('rechaza el registro si falta alguno de los dos consentimientos', () async {
      final repo = MockAutenticacion(espera: Duration.zero);
      for (final (privacidad, terminos) in [(false, true), (true, false), (false, false)]) {
        await expectLater(
          repo.registrar(
            nombre: 'Ana',
            correo: 'ana@ejemplo.mx',
            contrasena: 'secreta',
            perfil: PerfilUsuario.estudiante,
            aceptaAvisoPrivacidad: privacidad,
            aceptaTerminos: terminos,
          ),
          throwsA(isA<ExcepcionAutenticacion>()),
        );
      }
    });

    test('registra cuando acepta ambos consentimientos', () async {
      final repo = MockAutenticacion(espera: Duration.zero);
      final usuario = await repo.registrar(
        nombre: 'Ana',
        correo: 'ana@ejemplo.mx',
        contrasena: 'secreta',
        perfil: PerfilUsuario.legal,
        aceptaAvisoPrivacidad: true,
        aceptaTerminos: true,
      );
      expect(usuario.perfil, PerfilUsuario.legal);
      expect(usuario.nivel, 1);
    });
  });

  test('MockProgreso devuelve los 5 módulos en orden', () async {
    final modulos = await MockProgreso(espera: Duration.zero).obtenerModulos();
    expect(modulos.map((m) => m.numero), [1, 2, 3, 4, 5]);
  });

  test('MockTarjetas incluye la tarjeta "Librería GPL en app cerrada"', () async {
    final tarjetas = await MockTarjetas(espera: Duration.zero).obtenerTarjetasDelSprint('spr-2-1');
    final gpl = tarjetas.firstWhere((t) => t.id == 'tar-gpl-01');
    expect(gpl.tipo, TipoTarjeta.evidencia);
    expect(gpl.respuestaCorrecta, Veredicto.ilegal);
    expect(gpl.evidencia, isNotNull);
  });

  test('MockTarjetas falla con un sprint inexistente', () async {
    await expectLater(
      MockTarjetas(espera: Duration.zero).obtenerTarjetasDelSprint('no-existe'),
      throwsStateError,
    );
  });

  test('MockVidas toma la hora del servidor, no del dispositivo', () async {
    final servidor = DateTime.utc(2026, 1, 1, 12);
    final vidas = await MockVidas(
      espera: Duration.zero,
      ahoraServidor: () => servidor,
    ).obtenerVidas();
    expect(vidas.cantidad, lessThanOrEqualTo(Vidas.maximo));
    expect(vidas.proximaEn!.isAfter(servidor), isTrue);
  });

  test('MockApelaciones y MockTienda devuelven datos de ejemplo', () async {
    expect(await MockApelaciones(espera: Duration.zero).obtenerApelacionesPendientes(), isNotEmpty);
    expect(await MockTienda(espera: Duration.zero).obtenerArticulos(), hasLength(3));
  });

  test('los proveedores exponen la interfaz y se pueden sustituir', () {
    final contenedor = ProviderContainer(
      overrides: [
        repositorioProgresoProvider.overrideWithValue(MockProgreso(espera: Duration.zero)),
      ],
    );
    addTearDown(contenedor.dispose);
    expect(contenedor.read(repositorioProgresoProvider), isA<RepositorioProgreso>());
    expect(contenedor.read(repositorioAutenticacionProvider), isA<RepositorioAutenticacion>());
  });
}
