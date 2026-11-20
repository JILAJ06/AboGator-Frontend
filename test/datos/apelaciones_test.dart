import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/modelos/apelacion.dart';
import 'package:abogator/datos/modelos/buzon_apelaciones.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:flutter_test/flutter_test.dart';

final modulo1 = [
  for (final s in MockProgreso.modulos.first.sprints.where((s) => !s.esExamenFinal))
    ...MockTarjetas.tarjetasPorSprint[s.id]!,
];

Apelacion apelacion(String id, DateTime el) => Apelacion(
  id: id,
  tarjetaId: 't-$id',
  moduloId: 'mod-1',
  titulo: 'Caso $id',
  tema: 'Tema',
  diaRepaso: 3,
  disponibleEl: el,
);

void main() {
  group('BuzonApelaciones', () {
    final ahora = DateTime.utc(2026, 11, 20, 23, 30);

    test('días calendario UTC con la hora del servidor', () {
      expect(BuzonApelaciones.diasEntre(ahora, DateTime.utc(2026, 11, 20, 1)), 0);
      expect(BuzonApelaciones.diasEntre(ahora, DateTime.utc(2026, 11, 21, 0, 10)), 1);
      expect(BuzonApelaciones.diasEntre(ahora, DateTime.utc(2026, 11, 22)), 2);
      expect(BuzonApelaciones.diasEntre(ahora, DateTime.utc(2026, 11, 18)), -2);
    });

    test('deHoy incluye las vencidas y las de hoy (hasta el fin del día); orden por fecha', () {
      final buzon = BuzonApelaciones(
        ahoraServidor: ahora,
        apelaciones: [
          apelacion('manana', DateTime.utc(2026, 11, 21, 9)),
          apelacion('vencida', DateTime.utc(2026, 11, 17)),
          apelacion('hoy-noche', DateTime.utc(2026, 11, 20, 23, 59)),
        ],
      );
      expect(buzon.apelaciones.map((a) => a.id), ['vencida', 'hoy-noche', 'manana']);
      expect(buzon.deHoy.map((a) => a.id), ['vencida', 'hoy-noche']);
      expect(buzon.total, 3);
    });
  });

  group('MockApelaciones (servidor)', () {
    late DateTime ahora;
    MockApelaciones mock() => MockApelaciones(espera: Duration.zero, ahoraServidor: () => ahora);

    setUp(() => ahora = DateTime.utc(2026, 11, 20, 10));

    test('semilla: 6, las dos de Figma hoy, luego mañana y en 2 días', () async {
      final buzon = await mock().obtenerBuzon();
      expect(buzon.total, 6);
      expect(buzon.ahoraServidor, ahora);
      expect(buzon.deHoy.map((a) => a.titulo), [
        'Librería GPL en app cerrada',
        'Casilla de consentimiento pre-marcada',
      ]);
      expect(buzon.apelaciones.first.tema, 'Licencias OSS');
      expect(buzon.apelaciones[1].tema, 'Protección de datos');
      expect([for (final a in buzon.apelaciones) a.diaRepaso], [3, 7, 3, 7, 14, 14]);
      expect([for (final a in buzon.apelaciones) buzon.diasHasta(a)], [0, 0, 1, 2, 5, 9]);
    });

    test('la semilla usa tarjetas y módulos que existen', () async {
      final buzon = await mock().obtenerBuzon();
      final ids = {
        for (final l in MockTarjetas.tarjetasPorSprint.values)
          for (final t in l) t.id,
      };
      final modulos = {for (final m in MockProgreso.modulos) m.id};
      for (final a in buzon.apelaciones) {
        expect(ids, contains(a.tarjetaId), reason: a.id);
        expect(modulos, contains(a.moduloId), reason: a.id);
      }
    });

    test('registrarFallos crea día 3 a +3 días y no duplica por tarjeta', () async {
      final m = mock();
      await m.registrarFallos(const [
        NuevaApelacion(tarjetaId: 'tar-aviso-01', moduloId: 'mod-1', titulo: 'A', tema: 'T'),
        NuevaApelacion(tarjetaId: 'tar-gpl-01', moduloId: 'mod-1', titulo: 'B', tema: 'T'),
        NuevaApelacion(tarjetaId: 'tar-aviso-01', moduloId: 'mod-1', titulo: 'A', tema: 'T'),
      ]);
      final buzon = await m.obtenerBuzon();
      expect(buzon.total, 7);
      final nueva = buzon.apelaciones.singleWhere((a) => a.tarjetaId == 'tar-aviso-01');
      expect(nueva.diaRepaso, 3);
      expect(nueva.disponibleEl, ahora.add(const Duration(days: 3)));
      expect(buzon.diasHasta(nueva), 3);
      // Al pasar los días (en el servidor), pasa a ser de hoy.
      ahora = ahora.add(const Duration(days: 3));
      expect((await m.obtenerBuzon()).deHoy.map((a) => a.tarjetaId), contains('tar-aviso-01'));
    });

    test('cada instancia empieza de nuevo y se puede crear vacía', () async {
      final a = mock();
      await a.registrarFallos(const [
        NuevaApelacion(tarjetaId: 'x', moduloId: 'mod-1', titulo: 'X', tema: 'T'),
      ]);
      expect((await mock().obtenerBuzon()).total, 6);
      expect(
        (await MockApelaciones(espera: Duration.zero, conSemilla: false).obtenerBuzon()).total,
        0,
      );
    });
  });

  group('tarjetas', () {
    test('las 42 del módulo 1 tienen título (≤ 45) y tema', () {
      expect(modulo1, hasLength(42));
      for (final t in modulo1) {
        expect(t.titulo, isNotNull, reason: t.id);
        expect(t.titulo!.length, lessThanOrEqualTo(Tarjeta.largoTitulo), reason: t.id);
        expect(t.tema, isNotNull, reason: t.id);
        expect(t.tema, isNotEmpty, reason: t.id);
        expect(t.titulo!.contains(RegExp(r'\d')), isFalse, reason: t.id);
      }
    });

    test('sin título, el respaldo es el texto cortado en 45 con "…"', () {
      const t = Tarjeta(
        id: 'x',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'C',
        personaje: 'P',
        rol: 'R',
        texto: 'Un texto bastante largo que no cabe en el título del Buzón de apelaciones',
        respuestaCorrecta: Veredicto.legal,
        explicacion: 'E',
      );
      expect(t.tituloCorto.length, 45);
      expect(t.tituloCorto, endsWith('…'));
    });

    test('obtenerTarjeta encuentra cualquier tarjeta y lanza si no existe', () async {
      final mock = MockTarjetas(espera: Duration.zero);
      expect((await mock.obtenerTarjeta('tar-gpl-01')).titulo, 'Librería GPL en app cerrada');
      expect((await mock.obtenerTarjeta('tar-mit-02')).id, 'tar-mit-02');
      await expectLater(mock.obtenerTarjeta('no-existe'), throwsStateError);
    });
  });
}
