import 'dart:io';

import 'package:abogator/datos/local/base_local.dart';
import 'package:abogator/datos/local/cola_respuestas_sqlite.dart';
import 'package:abogator/datos/local/onboarding_sqlite.dart';
import 'package:abogator/datos/mocks/cola_respuestas_en_memoria.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/respuesta_pendiente.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/cola_respuestas.dart';
import 'package:abogator/datos/repositorios/repositorio_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

RespuestaPendiente respuesta(String id, {String tarjeta = 't1'}) => RespuestaPendiente(
  id: id,
  sprintId: 'spr-1-3',
  tarjetaId: tarjeta,
  veredicto: Veredicto.ilegal,
  justificacion: 2,
  evidenciaCorrecta: true,
  respondidaEn: DateTime.utc(2026, 11, 20, 10, 30),
);

/// Las mismas pruebas para la cola en SQLite y en memoria.
void pruebasDeCola(String nombre, Future<ColaRespuestas> Function() crear) {
  group('cola $nombre', () {
    test('agregar, contar y conservar el orden y los campos', () async {
      final cola = await crear();
      expect(await cola.cantidadPendientes(), 0);
      await cola.agregar(respuesta('a'));
      await cola.agregar(respuesta('b', tarjeta: 't2'));
      await cola.agregar(
        RespuestaPendiente(
          id: 'c',
          sprintId: 'spr-1-3',
          tarjetaId: 't3',
          veredicto: Veredicto.escalar,
          respondidaEn: DateTime.utc(2026),
        ),
      );
      expect(await cola.cantidadPendientes(), 3);
      final p = await cola.pendientes();
      expect(p.map((r) => r.id), ['a', 'b', 'c']);
      expect(p.first, respuesta('a'));
      expect((p.last.justificacion, p.last.evidenciaCorrecta, p.last.intentos), (null, null, 0));
    });

    test('el mismo id no se duplica', () async {
      final cola = await crear();
      await cola.agregar(respuesta('a'));
      await cola.agregar(respuesta('a', tarjeta: 'otra'));
      expect(await cola.cantidadPendientes(), 1);
      expect((await cola.pendientes()).single.tarjetaId, 't1');
    });

    test('marcarEnviadas las borra y registrarIntentoFallido suma intentos', () async {
      final cola = await crear();
      for (final id in ['a', 'b', 'c']) {
        await cola.agregar(respuesta(id));
      }
      await cola.registrarIntentoFallido(['a', 'c']);
      await cola.registrarIntentoFallido(['a']);
      final intentos = {for (final r in await cola.pendientes()) r.id: r.intentos};
      expect(intentos, {'a': 2, 'b': 0, 'c': 1});
      await cola.marcarEnviadas(['a', 'b']);
      expect((await cola.pendientes()).map((r) => r.id), ['c']);
      await cola.marcarEnviadas([]);
      expect(await cola.cantidadPendientes(), 1);
    });
  });
}

void pruebasDeOnboarding(String nombre, Future<RepositorioOnboarding> Function() crear) {
  test('onboarding $nombre: empieza sin ver y se marca visto', () async {
    final repo = await crear();
    expect(await repo.fueVisto(), isFalse);
    await repo.marcarVisto();
    await repo.marcarVisto();
    expect(await repo.fueVisto(), isTrue);
  });
}

void main() {
  sqfliteFfiInit();
  final fabrica = databaseFactoryFfi;

  BaseLocal enMemoria() => BaseLocal(fabrica: fabrica, ruta: inMemoryDatabasePath);

  final bases = <BaseLocal>[];
  tearDown(() async {
    for (final b in bases) {
      await b.cerrar();
    }
    bases.clear();
  });
  BaseLocal nueva() {
    final base = enMemoria();
    bases.add(base);
    return base;
  }

  pruebasDeCola('SQLite', () async => ColaRespuestasSqlite(nueva()));
  pruebasDeCola('en memoria', () async => ColaRespuestasEnMemoria());
  pruebasDeOnboarding('SQLite', () async => OnboardingSqlite(nueva()));
  pruebasDeOnboarding('en memoria', () async => OnboardingEnMemoria());

  test('la base se abre en la primera operación, con las dos tablas', () async {
    final base = nueva();
    final db = await base.base;
    final tablas = await db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
    expect(
      tablas.map((t) => t['name']),
      containsAll([BaseLocal.tablaRespuestas, BaseLocal.tablaAjustes]),
    );
    expect(await db.getVersion(), BaseLocal.version);
  });

  test('la cola y el onboarding persisten al cerrar y volver a abrir la base', () async {
    final carpeta = await Directory.systemTemp.createTemp('abogator_db_');
    addTearDown(() => carpeta.delete(recursive: true));
    final ruta = '${carpeta.path}${Platform.pathSeparator}${BaseLocal.nombre}';

    final primera = BaseLocal(fabrica: fabrica, ruta: ruta);
    await ColaRespuestasSqlite(primera).agregar(respuesta('a'));
    await OnboardingSqlite(primera).marcarVisto();
    await primera.cerrar();

    final segunda = BaseLocal(fabrica: fabrica, ruta: ruta);
    addTearDown(segunda.cerrar);
    expect((await ColaRespuestasSqlite(segunda).pendientes()).single, respuesta('a'));
    expect(await OnboardingSqlite(segunda).fueVisto(), isTrue);
  });
}
