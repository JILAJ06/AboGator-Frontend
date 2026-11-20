import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/aviso_conexion.dart';
import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/indicador_pendientes.dart';
import 'package:abogator/componentes/interruptor_conexion_debug.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_respuestas.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/sincronizacion/estado_sincronizacion.dart';
import 'package:abogator/datos/sincronizacion/servicio_conexion.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_juego.dart';

final tarjetas = MockTarjetas.tarjetasPorSprint['spr-1-3']!;

Map<String, List<Tarjeta>> mazo(int n) => {sprintMock: tarjetas.take(n).toList()};

Future<void> elegir(WidgetTester tester, Veredicto v) async {
  final f = find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == v);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Responde la tarjeta actual con su veredicto correcto y cierra el panel.
Future<void> responderBien(WidgetTester tester) async {
  final e = estadoJuego(tester);
  final t = tarjetas[e.indice];
  await elegir(tester, t.respuestaCorrecta);
  // En los dilemas se elige la justificación y se confirma.
  if (find.text(Textos.confirmarJustificacion).evaluate().isNotEmpty) {
    await tester.tap(find.text(t.justificacion!.opciones.first));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Textos.confirmarJustificacion));
    await tester.tap(find.text(Textos.confirmarJustificacion));
    await tester.pumpAndSettle();
  }
  await cerrarPanel(tester);
}

int pendientes(WidgetTester tester) => contenedorDe(tester).read(respuestasPendientesProvider);

void main() {
  testWidgets('en línea: cada respuesta se guarda con UUID y se envía sin duplicar', (
    tester,
  ) async {
    final servidor = MockRespuestas(espera: Duration.zero);
    await abrirJuego(tester, tarjetas: mazo(3), servidorRespuestas: servidor);
    expect(find.byType(AvisoConexion), findsNothing);
    expect(find.byType(BarraComodines), findsOneWidget);
    await responderBien(tester);
    await responderBien(tester);
    expect(servidor.recibidas, hasLength(2));
    expect(servidor.recibidas.map((r) => r.tarjetaId), [tarjetas[0].id, tarjetas[1].id]);
    expect(servidor.recibidas.map((r) => r.id).toSet(), hasLength(2));
    expect(servidor.recibidas.first.sprintId, sprintMock);
    expect(pendientes(tester), 0);
    expect(find.byType(IndicadorPendientes), findsNothing);
  });

  testWidgets('sin conexión: aviso, contador y sin comodines; al volver se sincroniza', (
    tester,
  ) async {
    final conexion = ConexionSimulada();
    final servidor = MockRespuestas(espera: Duration.zero);
    await abrirJuego(tester, tarjetas: mazo(5), conexion: conexion, servidorRespuestas: servidor);
    conexion.establecer(EstadoConexion.sinConexion);
    await tester.pumpAndSettle();
    expect(find.text(Textos.conexionInestable), findsOneWidget);
    expect(find.byType(BarraComodines), findsNothing);
    expect(find.text('0 respuestas guardadas en el dispositivo (SQLite)'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await responderBien(tester);
    }
    expect(find.text('3 respuestas guardadas en el dispositivo (SQLite)'), findsOneWidget);
    expect(servidor.recibidas, isEmpty);
    // La calificación y el avance no esperan a la red.
    expect(estadoJuego(tester).indice, 3);
    expect(estadoJuego(tester).aciertos, 3);
    // Vuelve la conexión: se sincroniza y el aviso dice que se restableció.
    conexion.establecer(EstadoConexion.enLinea);
    await tester.pump();
    await tester.pump();
    expect(servidor.recibidas, hasLength(3));
    expect(pendientes(tester), 0);
    expect(find.text(Textos.conexionRestablecida), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(AvisoConexion), findsNothing);
    expect(find.byType(BarraComodines), findsOneWidget);
    expect(find.byType(IndicadorPendientes), findsNothing);
  });

  testWidgets('el aviso no bloquea el arrastre de la tarjeta', (tester) async {
    final conexion = ConexionSimulada(inicial: EstadoConexion.sinConexion);
    await abrirJuego(tester, tarjetas: mazo(2), conexion: conexion);
    expect(find.byType(AvisoConexion), findsOneWidget);
    // Se arrastra desde el punto donde está el aviso.
    await tester.dragFrom(tester.getCenter(find.byType(AvisoConexion)), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.byType(PanelVeredicto), findsOneWidget);
    expect(estadoJuego(tester).respuestas, hasLength(1));
  });

  testWidgets('el sprint se completa sin conexión y las respuestas quedan en cola', (tester) async {
    final conexion = ConexionSimulada(inicial: EstadoConexion.sinConexion);
    final servidor = MockRespuestas(espera: Duration.zero);
    await abrirJuego(tester, tarjetas: mazo(3), conexion: conexion, servidorRespuestas: servidor);
    for (var i = 0; i < 3; i++) {
      await responderBien(tester);
    }
    expect(rutaActual(tester), Rutas.sprintCompletadoDe(sprintMock));
    expect(pendientes(tester), 3);
    expect(servidor.recibidas, isEmpty);
    // Al volver la conexión (en cualquier pantalla) se envían.
    conexion.establecer(EstadoConexion.enLinea);
    await tester.pump();
    await tester.pump();
    expect(servidor.recibidas, hasLength(3));
    expect(pendientes(tester), 0);
  });

  testWidgets('si el servidor falla no se pierde nada', (tester) async {
    final servidor = MockRespuestas(espera: Duration.zero, fallar: true);
    await abrirJuego(tester, tarjetas: mazo(2), servidorRespuestas: servidor);
    await responderBien(tester);
    expect(pendientes(tester), 1);
    final cola = contenedorDe(tester).read(repositorioColaRespuestasProvider);
    expect((await cola.pendientes()).single.intentos, greaterThanOrEqualTo(1));
    servidor.fallar = false;
    await contenedorDe(tester).read(respuestasPendientesProvider.notifier).sincronizar();
    await tester.pump();
    expect(pendientes(tester), 0);
    expect(servidor.recibidas, hasLength(1));
  });

  testWidgets('el interruptor de depuración simula la falta de conexión', (tester) async {
    await abrirJuego(tester, tarjetas: mazo(2));
    final interruptor = find.descendant(
      of: find.byType(InterruptorConexionDebug),
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(interruptor);
    await tester.pumpAndSettle();
    await tester.tap(interruptor);
    await tester.pumpAndSettle();
    expect(find.text(Textos.conexionInestable), findsOneWidget);
    expect(find.byType(IndicadorPendientes), findsOneWidget);
  });

  testWidgets('con "reducir animaciones" el aviso aparece sin transición', (tester) async {
    final conexion = ConexionSimulada();
    await abrirJuego(tester, tarjetas: mazo(2), conexion: conexion);
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pump();
    conexion.establecer(EstadoConexion.sinConexion);
    await tester.pump();
    expect(find.text(Textos.conexionInestable), findsOneWidget);
  });

  group('sin vidas', () {
    testWidgets('perder la última vida guarda las 0 vidas y lleva a la 20', (tester) async {
      final vidas = MockVidas(espera: Duration.zero, cantidad: 1);
      await abrirJuego(tester, tarjetas: mazo(3), antes: (_) {}, vidasRepo: vidas);
      await elegir(tester, Veredicto.legal); // la correcta es Ilegal
      await cerrarPanel(tester);
      expect(rutaActual(tester), Rutas.sinVidas);
      expect(vidas.cantidad, 0);
      expect(find.byType(PantallaSinVidas), findsOneWidget);
      expect(find.text(Textos.sinVidasTitulo), findsOneWidget);
    });

    testWidgets('abrir un sprint con 0 vidas muestra la 20 y vuelve a su mapa', (tester) async {
      final repo = await abrirJuego(tester, vidas: 0);
      expect(find.byType(PantallaSinVidas), findsOneWidget);
      expect(repo.llamadas, 0);
      expect(tester.widget<PantallaSinVidas>(find.byType(PantallaSinVidas)).moduloId, 'mod-1');
      expect(
        contenedorDe(tester).read(datosJuegoProvider(sprintMock)).value?.sprint?.id,
        sprintMock,
      );
    });
  });
}
