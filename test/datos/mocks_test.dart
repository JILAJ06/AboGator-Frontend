import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_autenticacion.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/modulo.dart';
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

    test('rechaza la contraseña "incorrecta" y acepta otra', () async {
      final repo = MockAutenticacion(espera: Duration.zero);
      await expectLater(
        repo.iniciarSesion(correo: 'ana@startup.mx', contrasena: 'incorrecta'),
        throwsA(
          isA<ExcepcionAutenticacion>().having(
            (e) => e.mensaje,
            'mensaje',
            Textos.errorCredenciales,
          ),
        ),
      );
      expect(await repo.usuarioActual(), isNull);
      final usuario = await repo.iniciarSesion(correo: 'ana@startup.mx', contrasena: 'correcta1');
      expect(usuario, MockAutenticacion.usuarioDemo);
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
    // 5 sprints más el Examen final, que va al último.
    for (final m in modulos) {
      expect(m.sprints, hasLength(6));
      expect(m.sprints.last.esExamenFinal, isTrue);
      expect(m.sprints.where((s) => s.esExamenFinal), hasLength(1));
    }
    final primero = modulos.first.sprints;
    expect(primero.map((s) => s.titulo), [
      'Datos personales',
      'Consentimiento',
      'Aviso de privacidad',
      'Derechos ARCO',
      'Brechas de seguridad',
      'Auditoría de inversores',
    ]);
    expect(primero.map((s) => s.estado).where((e) => e == EstadoSprint.completado), hasLength(2));
    expect(primero.take(2).map((s) => s.estrellas), [3, 3]);
    expect(primero[2].estado, EstadoSprint.enCurso);
  });

  test('el sprint 3 del módulo 1 tiene los datos de Figma', () {
    final sprint = MockProgreso.modulos.first.sprints[2];
    expect(sprint.numeroTarjetas, 10);
    expect((sprint.tarjetasNormales, sprint.tarjetasConEvidencia, sprint.dilemas), (6, 3, 1));
    expect(sprint.monedasMaximas, 60);
    expect(sprint.minutosEstimados, 4);
    expect(sprint.objetivo, startsWith('el MVP sale a producción el viernes.'));
  });

  test('el usuario demo es Ana López, Dev, nivel 4 y racha 7', () {
    const ana = MockAutenticacion.usuarioDemo;
    expect(ana.nombre, 'Ana López');
    expect(ana.perfil, PerfilUsuario.desarrollador);
    expect((ana.nivel, ana.racha), (4, 7));
  });

  test('la tarjeta "Librería GPL en app cerrada" es la 5 de spr-1-3', () async {
    final tarjetas = await MockTarjetas(espera: Duration.zero).obtenerTarjetasDelSprint('spr-1-3');
    final gpl = tarjetas[4];
    expect(gpl.id, 'tar-gpl-01');
    expect(gpl.etiquetaCaso, 'CASO 5 · LICENCIAS OSS');
    expect(MockTarjetas.tarjetasPorSprint['spr-2-1']!.where((t) => t.id == 'tar-gpl-01'), isEmpty);
    expect(gpl.tipo, TipoTarjeta.evidencia);
    expect(gpl.respuestaCorrecta, Veredicto.ilegal);
    expect(gpl.evidencia, isNotNull);
  });

  test('el sprint en curso tiene 10 tarjetas: 6 normales, 3 con evidencia y 1 dilema', () async {
    final tarjetas = await MockTarjetas(espera: Duration.zero).obtenerTarjetasDelSprint('spr-1-3');
    expect(tarjetas, hasLength(10));
    expect(tarjetas.where((t) => t.tipo == TipoTarjeta.normal), hasLength(6));
    expect(tarjetas.where((t) => t.tipo == TipoTarjeta.evidencia), hasLength(3));
    expect(tarjetas.where((t) => t.tipo == TipoTarjeta.justificacion), hasLength(1));
    expect(
      tarjetas.where((t) => t.tipo == TipoTarjeta.evidencia).every((t) => t.evidencia != null),
      isTrue,
    );
    for (final t in MockTarjetas.tarjetasPorSprint.values.expand((l) => l)) {
      expect(t.personaje, isNotEmpty);
      expect(t.rol, isNotEmpty);
      expect(t.etiquetaCaso, startsWith('CASO '));
    }
    // Coincide con lo que anuncia la intro del sprint.
    final sprint = MockProgreso.modulos.first.sprints[2];
    expect(sprint.numeroTarjetas, tarjetas.length);
  });

  test('el estado de la Startup del mock es el de Figma (70, 60, 50, 25)', () async {
    final e = await MockProgreso(espera: Duration.zero).obtenerEstadoStartup();
    expect((e.presupuesto, e.reputacion, e.velocidad, e.riesgoLegal), (70, 60, 50, 25));
  });

  test('MockTarjetas falla con un sprint inexistente', () async {
    await expectLater(
      MockTarjetas(espera: Duration.zero).obtenerTarjetasDelSprint('no-existe'),
      throwsStateError,
    );
  });

  test('MockVidas da 5 vidas y 240 monedas en la tienda', () async {
    final vidas = await MockVidas(espera: Duration.zero).obtenerVidas();
    expect(vidas.cantidad, Vidas.maximo);
    expect(vidas.faltaParaProxima, isNull);
    expect(await MockTienda(espera: Duration.zero).obtenerMonedas(), 240);
  });

  test('MockVidas toma la hora del servidor, no del dispositivo', () async {
    final servidor = DateTime.utc(2026, 1, 1, 12);
    final vidas = await MockVidas(
      espera: Duration.zero,
      cantidad: 3,
      ahoraServidor: () => servidor,
    ).obtenerVidas();
    expect(vidas.cantidad, 3);
    expect(vidas.faltaParaProxima, Vidas.intervaloRegeneracion);
  });

  test('MockApelaciones y MockTienda devuelven datos de ejemplo', () async {
    expect(
      await MockApelaciones(espera: Duration.zero).obtenerApelacionesPendientes(),
      hasLength(6),
    );
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
