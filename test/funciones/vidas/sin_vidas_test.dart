import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_cerrar.dart';
import 'package:abogator/componentes/corazon_vida.dart';
import 'package:abogator/componentes/cuenta_regresiva_vida.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/falsos.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/sin_desbordes.dart';
import '../juego/ayudante_juego.dart';

FilaVidas filaVidas(WidgetTester tester) =>
    tester.widget<FilaVidas>(find.byKey(const ValueKey('vidas-sin-vidas')));

void main() {
  test('formato HH:MM:SS con ceros', () {
    expect(
      CuentaRegresivaVida.formato(const Duration(hours: 1, minutes: 47, seconds: 32)),
      '01:47:32',
    );
    expect(CuentaRegresivaVida.formato(const Duration(seconds: 5)), '00:00:05');
    expect(CuentaRegresivaVida.formato(Duration.zero), '00:00:00');
    expect(CuentaRegresivaVida.formato(const Duration(seconds: -3)), '00:00:00');
  });

  test('semántica por minuto', () {
    expect(
      Textos.proximaVidaSemantica(const Duration(hours: 1, minutes: 47, seconds: 32)),
      'Próxima vida en 1 hora y 47 minutos',
    );
    expect(Textos.proximaVidaSemantica(const Duration(hours: 2)), 'Próxima vida en 2 horas');
    expect(Textos.proximaVidaSemantica(const Duration(minutes: 1)), 'Próxima vida en 1 minuto');
    expect(
      Textos.proximaVidaSemantica(const Duration(seconds: 40)),
      'Próxima vida en menos de un minuto',
    );
  });

  test('estado/ilegal sobre fondo/app ≥ 3:1 (texto grande) en claro y oscuro', () {
    for (final t in [TokensColor.claro, TokensColor.oscuro]) {
      expect(Contraste.razon(t.estadoIlegal, t.fondoApp), greaterThanOrEqualTo(3));
    }
  });

  group('cuenta regresiva', () {
    testWidgets('descuenta con el reloj monótono y avisa una vez al llegar a 0', (tester) async {
      final reloj = CronometroFalso();
      var avisos = 0;
      await montar(
        tester,
        CuentaRegresivaVida(
          falta: const Duration(minutes: 1, seconds: 2),
          crearCronometro: () => reloj,
          alTerminar: () => avisos++,
        ),
      );
      expect(find.text('00:01:02'), findsOneWidget);
      reloj.transcurrido = const Duration(seconds: 3);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:00:59'), findsOneWidget);
      reloj.transcurrido = const Duration(minutes: 5);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:00:00'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(avisos, 1);
    });

    testWidgets('el lector lee la frase por minuto, no el tiempo, y sin región en vivo', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const CuentaRegresivaVida(
          falta: Duration(hours: 1, minutes: 47, seconds: 32),
          crearCronometro: CronometroFalso.new,
        ),
      );
      final nodo = tester.getSemantics(find.byKey(const ValueKey('cuenta-regresiva')));
      expect(nodo.label, 'Próxima vida en 1 hora y 47 minutos');
      expect(nodo.flagsCollection.isLiveRegion, isFalse);
      expect(find.bySemanticsLabel('01:47:32'), findsNothing);
      semantica.dispose();
    });
  });

  group('pantalla 20', () {
    testWidgets('llegar a 0: pide vidas, se llenan los corazones y se anuncia', (tester) async {
      var ahora = DateTime.utc(2026, 11, 20, 10);
      final vidas = MockVidas(espera: Duration.zero, cantidad: 0, ahoraServidor: () => ahora);
      final reloj = CronometroFalso();
      final anuncios = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (mensaje) async {
          final datos = (mensaje as Map)['data'] as Map;
          anuncios.add(datos['message'] as String);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await montar(
        tester,
        ProviderScope(
          overrides: [
            repositorioVidasProvider.overrideWithValue(vidas),
            repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas(2)),
          ],
          child: PantallaSinVidas(moduloId: 'mod-1', crearCronometro: () => reloj),
        ),
      );
      expect(filaVidas(tester).cantidad, 0);
      expect(find.text('02:00:00'), findsOneWidget);
      expect(find.text(Textos.proximaVidaEn), findsOneWidget);
      // Pasan las 2 horas (en el servidor y en el reloj monótono).
      ahora = ahora.add(const Duration(hours: 2));
      reloj.transcurrido = const Duration(hours: 2);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(filaVidas(tester).cantidad, 1);
      expect(find.text(Textos.vidaRecuperada), findsOneWidget);
      // Faltan más: se ve la cuenta de la siguiente.
      expect(find.text('02:00:00'), findsOneWidget);
      expect(anuncios, contains(Textos.vidaRecuperada));
    });

    for (final (n, texto) in [
      (2, '2 apelaciones pendientes: cada una que ganes te devuelve 1 vida.'),
      (1, '1 apelación pendiente: si la ganas te devuelve 1 vida.'),
    ]) {
      testWidgets('sugerencia del Buzón con $n', (tester) async {
        await montar(
          tester,
          ProviderScope(
            overrides: [
              repositorioVidasProvider.overrideWithValue(
                MockVidas(espera: Duration.zero, cantidad: 0),
              ),
              repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas(n)),
            ],
            child: const PantallaSinVidas(crearCronometro: CronometroFalso.new),
          ),
        );
        expect(find.byType(SugerenciaBuzon), findsOneWidget);
        expect(find.text(texto), findsOneWidget);
      });
    }

    testWidgets('sin apelaciones no se muestra la sugerencia', (tester) async {
      await montar(
        tester,
        ProviderScope(
          overrides: [
            repositorioVidasProvider.overrideWithValue(
              MockVidas(espera: Duration.zero, cantidad: 0),
            ),
            repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas(0)),
          ],
          child: const PantallaSinVidas(crearCronometro: CronometroFalso.new),
        ),
      );
      expect(find.byType(SugerenciaBuzon), findsNothing);
    });

    testWidgets('con los datos reales: las 2 de hoy del mock, foco al título', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      expect(find.text(Textos.sinVidasTitulo), findsOneWidget);
      expect(
        find.text('2 apelaciones pendientes: cada una que ganes te devuelve 1 vida.'),
        findsOneWidget,
      );
      expect(find.text(Textos.notaVidasServidor), findsOneWidget);
      final enFoco = FocusManager.instance.primaryFocus!.context!;
      expect(
        (enFoco.findAncestorWidgetOfExactType<Text>() ??
                enFoco.findAncestorWidgetOfExactType<PantallaSinVidas>()) !=
            null,
        isTrue,
      );
      expect(find.bySemanticsLabel(Textos.sinVidasTitulo), findsWidgets);
    });

    testWidgets('"Volver al mapa" y Cerrar van al mapa del módulo', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      await tocar(tester, find.widgetWithText(BotonApp, Textos.volverAlMapa));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      await tocar(tester, find.byType(BotonCerrar));
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });

    testWidgets('sin módulo, "Volver al mapa" va al Inicio', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidas, vidas: 0);
      await tocar(tester, find.widgetWithText(BotonApp, Textos.volverAlMapa));
      expect(rutaActual(tester), Rutas.inicio);
    });

    testWidgets('"Ir al Buzón de Apelaciones" navega al Buzón', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      await tocar(tester, find.widgetWithText(BotonApp, Textos.irAlBuzon));
      expect(rutaActual(tester), Rutas.buzon);
    });

    testWidgets('teclado: se llega a los botones con Tab', (tester) async {
      await abrirJuego(tester, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      final visitados = <String>{};
      for (var i = 0; i < 8; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final boton = FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<BotonApp>();
        if (boton != null) visitados.add(boton.texto);
        if (FocusManager.instance.primaryFocus?.context
                ?.findAncestorWidgetOfExactType<BotonCerrar>() !=
            null) {
          visitados.add('cerrar');
        }
      }
      expect(visitados, containsAll([Textos.irAlBuzon, Textos.volverAlMapa, 'cerrar']));
    });

    probarSinDesbordes((tester, tamano, _) async {
      await abrirJuego(tester, tamano: tamano, ruta: Rutas.sinVidasDe('mod-1'), vidas: 0);
      expect(tester.takeException(), isNull);
      // El tiempo nunca pasa de su caja de 64.
      expect(
        // Medido ya dibujado (después de que FittedBox lo encoja).
        tester.getRect(find.byKey(const ValueKey('tiempo-vida'))).height,
        lessThanOrEqualTo(CuentaRegresivaVida.alto),
      );
      await tester.ensureVisible(find.widgetWithText(BotonApp, Textos.volverAlMapa));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }, ambosBrillos: true);
  });
}
