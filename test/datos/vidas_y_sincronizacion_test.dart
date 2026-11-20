import 'dart:async';

import 'package:abogator/core/utilidades/uuid.dart';
import 'package:abogator/datos/mocks/cola_respuestas_en_memoria.dart';
import 'package:abogator/datos/mocks/mock_respuestas.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/respuesta_pendiente.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/modelos/vidas.dart';
import 'package:abogator/datos/repositorios/repositorio_respuestas.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/datos/sincronizacion/sincronizador_respuestas.dart';
import 'package:flutter_test/flutter_test.dart';

RespuestaPendiente respuesta(String id) => RespuestaPendiente(
  id: id,
  sprintId: 'spr-1-3',
  tarjetaId: 'tar-$id',
  veredicto: Veredicto.legal,
  respondidaEn: DateTime.utc(2026, 11, 20),
);

/// Servidor que no responde hasta que se complete [puerta].
class ServidorLento implements RepositorioRespuestas {
  final puerta = Completer<void>();
  int envios = 0;

  @override
  Future<List<String>> enviarRespuestas(List<RespuestaPendiente> respuestas) async {
    envios++;
    await puerta.future;
    return [for (final r in respuestas) r.id];
  }
}

void main() {
  group('UUID v4', () {
    final formato = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    test('formato 8-4-4-4-12, versión 4 y variante RFC 4122', () {
      for (var i = 0; i < 200; i++) {
        expect(generarUuidV4(), matches(formato));
      }
    });

    test('1000 llamadas, 1000 distintos', () {
      final todos = {for (var i = 0; i < 1000; i++) generarUuidV4()};
      expect(todos, hasLength(1000));
    });
  });

  group('MockVidas (servidor)', () {
    late DateTime ahora;
    MockVidas mock({int cantidad = Vidas.maximo}) =>
        MockVidas(espera: Duration.zero, cantidad: cantidad, ahoraServidor: () => ahora);

    setUp(() => ahora = DateTime.utc(2026, 11, 20, 10));

    test('con 5 no hay regeneración ni cuenta', () async {
      final v = await mock().obtenerVidas();
      expect((v.cantidad, v.faltaParaProxima), (5, null));
    });

    test('al bajar de 5 programa la regeneración a ahora + 2 h', () async {
      final m = mock();
      final v = await m.guardarVidas(4);
      expect(v.faltaParaProxima, const Duration(hours: 2));
      expect(m.proximaRegeneracion, ahora.add(const Duration(hours: 2)));
      // Bajar más no reprograma: la próxima sigue siendo la misma.
      ahora = ahora.add(const Duration(minutes: 30));
      final otra = await m.guardarVidas(2);
      expect(otra.faltaParaProxima, const Duration(hours: 1, minutes: 30));
    });

    test('faltaParaProxima descuenta con la hora del servidor', () async {
      final m = mock(cantidad: 0);
      ahora = ahora.add(const Duration(minutes: 12, seconds: 28));
      expect(
        (await m.obtenerVidas()).faltaParaProxima,
        const Duration(hours: 1, minutes: 47, seconds: 32),
      );
    });

    test('aplica 0, 1 y 2 regeneraciones vencidas', () async {
      final m = mock(cantidad: 1);
      ahora = ahora.add(const Duration(hours: 1, minutes: 59));
      expect((await m.obtenerVidas()).cantidad, 1);
      ahora = ahora.add(const Duration(minutes: 1));
      final una = await m.obtenerVidas();
      expect((una.cantidad, una.faltaParaProxima), (2, const Duration(hours: 2)));
      ahora = ahora.add(const Duration(hours: 4, minutes: 30));
      final dos = await m.obtenerVidas();
      // La siguiente se cuenta desde la anterior, no desde la consulta.
      expect((dos.cantidad, dos.faltaParaProxima), (4, const Duration(hours: 1, minutes: 30)));
    });

    test('nunca pasa de 5 y al llegar a 5 deja de contar', () async {
      final m = mock(cantidad: 3);
      ahora = ahora.add(const Duration(days: 2));
      final v = await m.obtenerVidas();
      expect((v.cantidad, v.faltaParaProxima), (5, null));
      expect(m.proximaRegeneracion, isNull);
    });
  });

  group('MockRespuestas (servidor)', () {
    test('cuenta una vez el mismo UUID aunque llegue dos veces', () async {
      final servidor = MockRespuestas(espera: Duration.zero);
      expect(await servidor.enviarRespuestas([respuesta('a'), respuesta('b')]), ['a', 'b']);
      expect(await servidor.enviarRespuestas([respuesta('a')]), ['a']);
      expect(servidor.recibidas.map((r) => r.id), ['a', 'b']);
    });

    test('con fallar no acepta nada', () async {
      final servidor = MockRespuestas(espera: Duration.zero, fallar: true);
      await expectLater(servidor.enviarRespuestas([respuesta('a')]), throwsStateError);
      expect(servidor.recibidas, isEmpty);
    });
  });

  group('SincronizadorRespuestas', () {
    late ColaRespuestasEnMemoria cola;
    late MockRespuestas servidor;
    late SincronizadorRespuestas sincronizador;

    setUp(() {
      cola = ColaRespuestasEnMemoria();
      servidor = MockRespuestas(espera: Duration.zero);
      sincronizador = SincronizadorRespuestas(cola: cola, servidor: servidor);
    });

    test('envía y vacía la cola', () async {
      await cola.agregar(respuesta('a'));
      await cola.agregar(respuesta('b'));
      expect(await sincronizador.sincronizar(), 2);
      expect(await cola.cantidadPendientes(), 0);
      expect(servidor.recibidas.map((r) => r.id), ['a', 'b']);
    });

    test('sin pendientes no llama al servidor', () async {
      expect(await sincronizador.sincronizar(), 0);
      expect(servidor.envios, 0);
    });

    test('si falla no pierde nada y suma intentos; luego reintenta', () async {
      await cola.agregar(respuesta('a'));
      servidor.fallar = true;
      expect(await sincronizador.sincronizar(), 0);
      expect(await sincronizador.sincronizar(), 0);
      final pendiente = (await cola.pendientes()).single;
      expect((pendiente.id, pendiente.intentos), ('a', 2));
      servidor.fallar = false;
      expect(await sincronizador.sincronizar(), 1);
      expect(await cola.cantidadPendientes(), 0);
    });

    test('reenviar el mismo UUID no lo cuenta dos veces en el servidor', () async {
      await cola.agregar(respuesta('a'));
      await sincronizador.sincronizar();
      // Se vuelve a guardar (por ejemplo, tras perder la confirmación).
      await cola.agregar(respuesta('a'));
      await sincronizador.sincronizar();
      expect(servidor.recibidas, hasLength(1));
    });

    test('no corre dos veces a la vez', () async {
      final lento = ServidorLento();
      final s = SincronizadorRespuestas(cola: cola, servidor: lento);
      await cola.agregar(respuesta('a'));
      final primera = s.sincronizar();
      expect(s.enCurso, isTrue);
      // Mientras corre, la segunda llamada no envía en paralelo.
      expect(await s.sincronizar(), 0);
      expect(lento.envios, 1);
      lento.puerta.complete();
      expect(await primera, 1);
      expect(s.enCurso, isFalse);
      expect(await cola.cantidadPendientes(), 0);
    });

    test('una respuesta guardada durante el envío sale en la pasada siguiente', () async {
      final lento = ServidorLento();
      final s = SincronizadorRespuestas(cola: cola, servidor: lento);
      await cola.agregar(respuesta('a'));
      final primera = s.sincronizar();
      await cola.agregar(respuesta('b'));
      await s.sincronizar();
      lento.puerta.complete();
      expect(await primera, 2);
      expect(lento.envios, 2);
      expect(await cola.cantidadPendientes(), 0);
    });
  });

  group('ConexionSimulada', () {
    test('arranca en línea y avisa cada cambio', () async {
      final c = ConexionSimulada();
      addTearDown(c.cerrar);
      final cambios = <EstadoConexion>[];
      c.cambios.listen(cambios.add);
      expect(c.estado, EstadoConexion.enLinea);
      c
        ..establecer(EstadoConexion.sinConexion)
        ..establecer(EstadoConexion.sinConexion)
        ..establecer(EstadoConexion.enLinea);
      expect(cambios, [EstadoConexion.sinConexion, EstadoConexion.enLinea]);
    });
  });
}
