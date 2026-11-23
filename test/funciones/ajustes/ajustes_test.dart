import 'dart:io';

import 'package:abogator/app/app.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/panel_evidencia.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/piezas_tienda.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/servicios/servicio_haptico.dart';
import 'package:abogator/core/tema/modo_tema.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/local/ajustes_sqlite.dart';
import 'package:abogator/datos/local/base_local.dart';
import 'package:abogator/datos/mocks/ajustes_en_memoria.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:abogator/datos/modelos/ajustes_notificaciones.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_ajustes.dart';
import 'package:abogator/funciones/ajustes/estado_ajustes.dart';
import 'package:abogator/funciones/ajustes/logica_ajustes.dart';
import 'package:abogator/funciones/ajustes/pantalla_ajustes.dart';
import 'package:abogator/funciones/perfil/estado_perfil.dart';
import 'package:abogator/funciones/perfil/pantalla_perfil.dart';
import 'package:abogator/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../ayudantes/falsos.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/sin_desbordes.dart';
import '../juego/ayudante_juego.dart';

/// Repositorio que no puede guardar.
class AjustesQueFallan extends AjustesEnMemoria {
  @override
  Future<void> guardar(Ajustes ajustes) async => throw Exception('disco lleno');
}

Future<AjustesEnMemoria> abrirAjustes(
  WidgetTester tester, {
  Ajustes ajustes = const Ajustes(),
  AjustesEnMemoria? repo,
  HapticaFalsa? haptica,
  Size tamano = const Size(390, 844),
}) async {
  final r = repo ?? AjustesEnMemoria();
  await abrirJuego(
    tester,
    ruta: Rutas.ajustes,
    ajustes: ajustes,
    repoAjustes: r,
    haptica: haptica,
    tamano: tamano,
  );
  return r;
}

Ajustes ajustesDe(WidgetTester tester) => contenedorDe(tester).read(ajustesProvider);

InterruptorApp interruptor(WidgetTester tester, String clave) => tester.widget<InterruptorApp>(
  find.descendant(of: find.byKey(ValueKey(clave)), matching: find.byType(InterruptorApp)),
);

void main() {
  group('repositorio', () {
    test('valores por defecto', () async {
      final a = await AjustesEnMemoria().cargar();
      expect(a, const Ajustes());
      expect(a.modoTema, ThemeMode.system);
      expect(a.escalaTexto, 100);
      expect(a.soloBotones, isFalse);
      expect(a.haptica, isTrue);
      expect(a.tiempoExtendido, isFalse);
      expect(a.reducirAnimaciones, isFalse);
    });

    const todos = Ajustes(
      modoTema: ThemeMode.dark,
      escalaTexto: 140,
      soloBotones: true,
      haptica: false,
      tiempoExtendido: true,
      reducirAnimaciones: true,
    );

    test('memoria: guarda y carga cada ajuste', () async {
      final r = AjustesEnMemoria();
      await r.guardar(todos);
      expect(await r.cargar(), todos);
    });

    test('un valor inválido o ausente toma el por defecto', () async {
      final r = AjustesEnMemoria({
        CodecAjustes.modoTema: 'morado',
        CodecAjustes.escalaTexto: '130',
        CodecAjustes.soloBotones: 'si',
        CodecAjustes.reducirAnimaciones: '1',
      });
      expect(await r.cargar(), const Ajustes(reducirAnimaciones: true));
    });

    group('SQLite', () {
      sqfliteFfiInit();
      final fabrica = databaseFactoryFfi;

      test('guarda, carga y sobrevive a reabrir la base', () async {
        final carpeta = await Directory.systemTemp.createTemp('abogator_ajustes_');
        addTearDown(() => carpeta.delete(recursive: true));
        final ruta = '${carpeta.path}${Platform.pathSeparator}${BaseLocal.nombre}';
        final primera = BaseLocal(fabrica: fabrica, ruta: ruta);
        expect(await AjustesSqlite(primera).cargar(), const Ajustes());
        await AjustesSqlite(primera).guardar(todos);
        await primera.cerrar();
        final segunda = BaseLocal(fabrica: fabrica, ruta: ruta);
        addTearDown(segunda.cerrar);
        expect(await AjustesSqlite(segunda).cargar(), todos);
        for (final m in ThemeMode.values) {
          await AjustesSqlite(segunda).guardar(todos.copyWith(modoTema: m));
          expect((await AjustesSqlite(segunda).cargar()).modoTema, m);
        }
      });

      test('valor inválido en la tabla = por defecto', () async {
        final base = BaseLocal(fabrica: fabrica, ruta: inMemoryDatabasePath);
        addTearDown(base.cerrar);
        final db = await base.base;
        await db.insert(BaseLocal.tablaAjustes, {'clave': 'escala_texto', 'valor': 'mucho'});
        await db.insert(BaseLocal.tablaAjustes, {'clave': 'haptica', 'valor': '0'});
        expect(await AjustesSqlite(base).cargar(), const Ajustes(haptica: false));
      });
    });
  });

  group('lógica', () {
    test('escala efectiva con tope de 200 %', () {
      expect(LogicaAjustes.escalaEfectiva(1, 100), 1);
      expect(LogicaAjustes.escalaEfectiva(1, 120), 1.2);
      expect(LogicaAjustes.escalaEfectiva(1, 160), 1.6);
      expect(LogicaAjustes.escalaEfectiva(1.5, 160), 2);
      expect(LogicaAjustes.escalaEfectiva(1.5, 120), closeTo(1.8, 1e-9));
      expect(LogicaAjustes.escalaEfectiva(2.5, 100), 2.5);
      expect(LogicaAjustes.escalaEfectiva(2.5, 120), 2.5);
    });

    test('modo oscuro efectivo', () {
      expect(LogicaAjustes.oscuroEfectivo(ThemeMode.system, Brightness.dark), isTrue);
      expect(LogicaAjustes.oscuroEfectivo(ThemeMode.system, Brightness.light), isFalse);
      expect(LogicaAjustes.oscuroEfectivo(ThemeMode.dark, Brightness.light), isTrue);
      expect(LogicaAjustes.oscuroEfectivo(ThemeMode.light, Brightness.dark), isFalse);
    });

    test('reducir animaciones: sistema o ajuste', () {
      const base = MediaQueryData();
      expect(LogicaAjustes.aplicar(base, const Ajustes()).disableAnimations, isFalse);
      expect(
        LogicaAjustes.aplicar(base, const Ajustes(reducirAnimaciones: true)).disableAnimations,
        isTrue,
      );
      expect(
        LogicaAjustes.aplicar(
          base.copyWith(disableAnimations: true),
          const Ajustes(),
        ).disableAnimations,
        isTrue,
      );
    });
  });

  group('servicio háptico', () {
    List<PulsoHaptico> pulsos = [];
    ServicioHapticoSistema servicio({bool activo = true, bool web = false}) {
      pulsos = [];
      return ServicioHapticoSistema(
        activo: () => activo,
        web: web,
        pulsar: (p) async => pulsos.add(p),
        esperar: (_) async {},
      );
    }

    test('patrones: error = dos pulsos', () async {
      final s = servicio();
      await s.acierto();
      await s.parcial();
      await s.error();
      await s.suave();
      expect(pulsos, [
        PulsoHaptico.ligero,
        PulsoHaptico.seleccion,
        PulsoHaptico.medio,
        PulsoHaptico.medio,
        PulsoHaptico.ligero,
      ]);
    });

    test('apagado o en web no vibra', () async {
      for (final s in [servicio(activo: false), servicio(web: true)]) {
        await s.acierto();
        await s.error();
        await s.suave();
        expect(pulsos, isEmpty);
      }
    });
  });

  group('estado', () {
    test('cambia al instante y guarda; si falla, revierte', () async {
      final repo = AjustesEnMemoria();
      final c = ProviderContainer(overrides: [repositorioAjustesProvider.overrideWithValue(repo)]);
      addTearDown(c.dispose);
      final futuro = c.read(ajustesProvider.notifier).cambiar(const Ajustes(escalaTexto: 140));
      expect(c.read(ajustesProvider).escalaTexto, 140);
      expect(await futuro, isTrue);
      expect((await repo.cargar()).escalaTexto, 140);

      final mal = ProviderContainer(
        overrides: [repositorioAjustesProvider.overrideWithValue(AjustesQueFallan())],
      );
      addTearDown(mal.dispose);
      expect(
        await mal.read(ajustesProvider.notifier).cambiar(const Ajustes(haptica: false)),
        isFalse,
      );
      expect(mal.read(ajustesProvider), const Ajustes());
    });

    test('modoTemaProvider sale de los ajustes y guarda', () async {
      final repo = AjustesEnMemoria();
      final c = ProviderContainer(overrides: [repositorioAjustesProvider.overrideWithValue(repo)]);
      addTearDown(c.dispose);
      expect(c.read(modoTemaProvider), ThemeMode.system);
      await c.read(modoTemaProvider.notifier).establecer(ThemeMode.dark);
      expect(c.read(modoTemaProvider), ThemeMode.dark);
      expect((await repo.cargar()).modoTema, ThemeMode.dark);
    });

    test('crearContenedor arranca con lo guardado (o los por defecto si falla)', () async {
      final repo = AjustesEnMemoria();
      await repo.guardar(const Ajustes(modoTema: ThemeMode.dark, escalaTexto: 120));
      final c = await crearContenedor(
        overrides: [repositorioAjustesProvider.overrideWithValue(repo)],
      );
      addTearDown(c.dispose);
      expect(c.read(ajustesProvider), const Ajustes(modoTema: ThemeMode.dark, escalaTexto: 120));

      final roto = await crearContenedor(
        overrides: [repositorioAjustesProvider.overrideWithValue(RepositorioQueNoCarga())],
      );
      addTearDown(roto.dispose);
      expect(roto.read(ajustesProvider), const Ajustes());
    });
  });

  group('efectos en la app', () {
    testWidgets('arranque con ajustes guardados: tema y tamaño desde el primer cuadro', (
      tester,
    ) async {
      final repo = AjustesEnMemoria();
      await repo.guardar(const Ajustes(modoTema: ThemeMode.dark, escalaTexto: 140));
      final c = await crearContenedor(
        overrides: [
          repositorioAjustesProvider.overrideWithValue(repo),
          repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria()),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const AppAbogator()));
      // Primer cuadro, sin esperar nada.
      final contexto = tester.element(find.byType(Scaffold).first);
      expect(Theme.of(contexto).brightness, Brightness.dark);
      expect(MediaQuery.textScalerOf(contexto).scale(10), closeTo(14, 1e-9));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('modo oscuro cambia el tema al instante y se guarda', (tester) async {
      final repo = await abrirAjustes(tester);
      BuildContext ctx() => tester.element(find.byType(PantallaAjustes));
      expect(Theme.of(ctx()).brightness, Brightness.light);
      expect(interruptor(tester, 'ajuste-modo-oscuro').valor, isFalse);
      expect(find.byKey(const ValueKey('usar-modo-sistema')), findsNothing);
      await tocar(tester, find.byKey(const ValueKey('ajuste-modo-oscuro')));
      expect(Theme.of(ctx()).brightness, Brightness.dark);
      expect(interruptor(tester, 'ajuste-modo-oscuro').valor, isTrue);
      expect((await repo.cargar()).modoTema, ThemeMode.dark);
      await tocar(tester, find.byKey(const ValueKey('ajuste-modo-oscuro')));
      expect(Theme.of(ctx()).brightness, Brightness.light);
      expect((await repo.cargar()).modoTema, ThemeMode.light);
      // Con modo explícito aparece "Usar el modo del sistema".
      await tocar(tester, find.byKey(const ValueKey('usar-modo-sistema')));
      expect(ajustesDe(tester).modoTema, ThemeMode.system);
      expect(find.byKey(const ValueKey('usar-modo-sistema')), findsNothing);
    });

    testWidgets('con el sistema en oscuro el interruptor sale encendido', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrirAjustes(tester);
      expect(interruptor(tester, 'ajuste-modo-oscuro').valor, isTrue);
      await tocar(tester, find.byKey(const ValueKey('ajuste-modo-oscuro')));
      expect(ajustesDe(tester).modoTema, ThemeMode.light);
    });

    testWidgets('selector de tamaño: abre, elige, cierra y aplica', (tester) async {
      final repo = await abrirAjustes(tester);
      expect(find.text('Aa 100 %'), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      expect(find.byKey(const ValueKey('selector-tamano')), findsOneWidget);
      expect(find.byType(OpcionTamano), findsNWidgets(4));
      for (final p in [100, 120, 140, 160]) {
        expect(find.text('$p %'), findsOneWidget);
      }
      // El foco empieza en la opción actual.
      expect(Focus.of(tester.element(find.text('100 %'))).hasFocus, isTrue);
      await tocar(tester, find.byKey(const ValueKey('tamano-160')));
      expect(find.byKey(const ValueKey('selector-tamano')), findsNothing);
      expect(find.text('Aa 160 %'), findsOneWidget);
      expect((await repo.cargar()).escalaTexto, 160);
      final ctx = tester.element(find.byType(PantallaAjustes));
      expect(MediaQuery.textScalerOf(ctx).scale(10), closeTo(16, 1e-9));
    });

    testWidgets('en oscuro el selector usa el fondo del tema oscuro', (tester) async {
      await abrirAjustes(tester, ajustes: const Ajustes(modoTema: ThemeMode.dark));
      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      final fondo = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('fondo-selector-tamano')),
      );
      expect((fondo.decoration as BoxDecoration).color, TokensColor.oscuro.fondoSuperficie);
      esperarSoloColoresDelTema(tester, Brightness.dark);
    });

    for (final p in [120, 140, 160]) {
      testWidgets('tamaño $p % cambia el texto', (tester) async {
        await abrirAjustes(tester, ajustes: Ajustes(escalaTexto: p));
        final ctx = tester.element(find.byType(PantallaAjustes));
        expect(MediaQuery.textScalerOf(ctx).scale(100), closeTo(p.toDouble(), 1e-9));
      });
    }

    testWidgets('con el sistema en 150 % el tope de 200 % se respeta', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await abrirAjustes(tester, ajustes: const Ajustes(escalaTexto: 160));
      final ctx = tester.element(find.byType(PantallaAjustes));
      expect(MediaQuery.textScalerOf(ctx).scale(1), 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reducir animaciones llega a la app (y con el sistema se mantiene)', (
      tester,
    ) async {
      await abrirAjustes(tester);
      bool desactivadas() =>
          MediaQuery.disableAnimationsOf(tester.element(find.byType(PantallaAjustes)));
      expect(desactivadas(), isFalse);
      await tocar(tester, find.byKey(const ValueKey('ajuste-animaciones')));
      expect(desactivadas(), isTrue);
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await tocar(tester, find.byKey(const ValueKey('ajuste-animaciones')));
      expect(ajustesDe(tester).reducirAnimaciones, isFalse);
      expect(desactivadas(), isTrue);
    });

    testWidgets('reducir animaciones: el juego no anima la entrada', (tester) async {
      await abrirJuego(tester, ajustes: const Ajustes(reducirAnimaciones: true));
      final ctx = tester.element(find.byType(TarjetaCaso));
      expect(MediaQuery.disableAnimationsOf(ctx), isTrue);
    });

    testWidgets('el Splash también recibe reducir animaciones', (tester) async {
      final c = await crearContenedor(
        overrides: [
          repositorioAjustesProvider.overrideWithValue(
            AjustesEnMemoria({CodecAjustes.reducirAnimaciones: '1'}),
          ),
          repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria()),
        ],
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const AppAbogator()));
      expect(MediaQuery.disableAnimationsOf(tester.element(find.byType(Scaffold).first)), isTrue);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('vibración: al encender da una muestra suave', (tester) async {
      final haptica = HapticaFalsa();
      await abrirAjustes(tester, ajustes: const Ajustes(haptica: false), haptica: haptica);
      expect(interruptor(tester, 'ajuste-haptica').valor, isFalse);
      await tocar(tester, find.byKey(const ValueKey('ajuste-haptica')));
      expect(ajustesDe(tester).haptica, isTrue);
      expect(haptica.llamadas, ['suave']);
      await tocar(tester, find.byKey(const ValueKey('ajuste-haptica')));
      expect(haptica.llamadas, ['suave']);
    });

    testWidgets('vibración apagada: el juego no vibra', (tester) async {
      final vibraciones = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (
        llamada,
      ) async {
        if (llamada.method == 'HapticFeedback.vibrate') vibraciones.add(llamada.arguments);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await abrirJuego(
        tester,
        ajustes: const Ajustes(haptica: false),
        tarjetas: {
          sprintMock: [MockTarjetas.tarjetasPorSprint['spr-1-3']![1]],
        },
      );
      await tocar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.legal),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(vibraciones, isEmpty);
    });

    testWidgets('la compra y el juicio usan el servicio háptico', (tester) async {
      final haptica = HapticaFalsa();
      await abrirJuego(tester, ruta: Rutas.tienda, haptica: haptica);
      await tocar(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('articulo-lupa')),
          matching: find.byType(BotonPrecio),
        ),
      );
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(haptica.llamadas, ['suave']);

      final juicio = HapticaFalsa();
      await abrirJuego(
        tester,
        ruta: Rutas.juicioApelacionDe('ape-001'),
        apelaciones: MockApelaciones(espera: Duration.zero),
        haptica: juicio,
      );
      await tocar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.ilegal),
      );
      expect(juicio.llamadas, ['suave']);
    });
  });

  group('solo botones', () {
    final normal = MockTarjetas.tarjetasPorSprint['spr-1-3']![1];
    final conEvidencia = MockTarjetas.tarjetasPorSprint['spr-1-3']![5];
    Finder gesto() => find.byKey(const ValueKey('gesto-tarjeta'));

    testWidgets('arrastrar no mueve la tarjeta; la pista cambia', (tester) async {
      await abrirJuego(
        tester,
        ajustes: const Ajustes(soloBotones: true),
        tarjetas: {
          sprintMock: [normal, normal],
        },
      );
      expect(find.text(Textos.casoPistaBotones), findsOneWidget);
      expect(find.text(Textos.casoPistaLegal), findsNothing);
      final antes = tester.getRect(gesto());
      await tester.drag(gesto(), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(gesto()), antes);
      expect(estadoJuego(tester).indice, 0);
      // Los botones sí califican.
      await tocar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == Veredicto.legal),
      );
      expect(estadoJuego(tester).panel, isNotNull);
    });

    testWidgets('el teclado sigue calificando', (tester) async {
      await abrirJuego(
        tester,
        ajustes: const Ajustes(soloBotones: true),
        tarjetas: {
          sprintMock: [normal, normal],
        },
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(estadoJuego(tester).panel, isNotNull);
    });

    testWidgets('un toque en la tarjeta con evidencia abre el visor', (tester) async {
      await abrirJuego(
        tester,
        ajustes: const Ajustes(soloBotones: true),
        tarjetas: {
          sprintMock: [conEvidencia, normal],
        },
      );
      await tester.tapAt(tester.getTopLeft(gesto()) + const Offset(60, 120));
      await tester.pumpAndSettle();
      expect(find.byType(PanelEvidencia), findsOneWidget);
    });

    testWidgets('también en el juicio de apelación', (tester) async {
      await abrirJuego(
        tester,
        ruta: Rutas.juicioApelacionDe('ape-001'),
        apelaciones: MockApelaciones(espera: Duration.zero),
        ajustes: const Ajustes(soloBotones: true),
      );
      expect(find.text(Textos.casoPistaBotones), findsOneWidget);
      final antes = tester.getRect(gesto());
      await tester.drag(gesto(), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(tester.getRect(gesto()), antes);
      expect(find.text(Textos.apelacionGanadaTitulo), findsNothing);
    });
  });

  group('26 · pantalla', () {
    for (final brillo in Brightness.values) {
      testWidgets('estructura de Figma con los valores por defecto (${brillo.name})', (
        tester,
      ) async {
        tester.platformDispatcher.platformBrightnessTestValue = brillo;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await abrirAjustes(tester);
        expect(find.byType(NavegacionInferiorApp), findsNothing);
        expect(find.text(Textos.ajustesTitulo), findsOneWidget);
        expect(find.text(Textos.ajustesSubtitulo), findsOneWidget);
        for (final t in [Textos.seccionVisual, Textos.seccionMotora, Textos.seccionCognitiva]) {
          expect(find.text(t), findsOneWidget);
        }
        // 7 de accesibilidad + Notificaciones + Aviso y Términos (T-13b).
        expect(find.byType(FilaAjuste), findsNWidgets(10));
        for (final f in tester.widgetList<FilaAjuste>(find.byType(FilaAjuste))) {
          expect(tester.getSize(find.byWidget(f)).height, greaterThanOrEqualTo(56));
        }
        expect(
          tester.getSize(find.byKey(const ValueKey('boton-atras-ajustes'))),
          const Size(48, 48),
        );
        expect(tester.getTopLeft(find.byKey(const ValueKey('boton-atras-ajustes'))).dx, 20);
        // Valores por defecto reales (no los de Figma).
        expect(interruptor(tester, 'ajuste-modo-oscuro').valor, brillo == Brightness.dark);
        expect(interruptor(tester, 'ajuste-solo-botones').valor, isFalse);
        expect(interruptor(tester, 'ajuste-haptica').valor, isTrue);
        expect(interruptor(tester, 'ajuste-tiempo').valor, isFalse);
        expect(interruptor(tester, 'ajuste-animaciones').valor, isFalse);
        expect(find.text('Aa 100 %'), findsOneWidget);
        expect(find.text(Textos.lectorDisponible), findsOneWidget);
        final pista = tester.getSize(find.byType(InterruptorApp).first);
        expect(pista, const Size(48, 28));
        esperarSoloColoresDelTema(tester, brillo);
      });
    }

    testWidgets('con lector activo el chip dice "Activo"', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        accessibleNavigation: true,
      );
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await abrirAjustes(tester);
      expect(find.text(Textos.lectorActivo), findsOneWidget);
      expect(find.bySemanticsLabel('Etiquetas para lector: activo'), findsOneWidget);
    });

    testWidgets('interruptores: solo botones, tiempo extendido', (tester) async {
      final repo = await abrirAjustes(tester);
      await tocar(tester, find.byKey(const ValueKey('ajuste-solo-botones')));
      await tocar(tester, find.byKey(const ValueKey('ajuste-tiempo')));
      final guardados = await repo.cargar();
      expect(guardados.soloBotones, isTrue);
      expect(guardados.tiempoExtendido, isTrue);
      expect(interruptor(tester, 'ajuste-solo-botones').valor, isTrue);
    });

    testWidgets('si no se puede guardar, revierte y avisa', (tester) async {
      await abrirAjustes(tester, repo: AjustesQueFallan());
      await tocar(tester, find.byKey(const ValueKey('ajuste-solo-botones')));
      expect(find.text(Textos.errorGuardarAjuste), findsOneWidget);
      expect(ajustesDe(tester).soloBotones, isFalse);
      expect(interruptor(tester, 'ajuste-solo-botones').valor, isFalse);
    });

    testWidgets('semántica: una etiqueta, toggled y sin doble lectura', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirAjustes(tester);
      final nodo = tester.getSemantics(find.byKey(const ValueKey('ajuste-modo-oscuro')));
      expect(nodo.label, 'Modo oscuro, contraste alto en fondos oscuros');
      expect(nodo.flagsCollection.isToggled, isNotNull);
      expect(find.bySemanticsLabel(Textos.modoOscuro), findsNothing);
      final tamano = tester.getSemantics(find.byKey(const ValueKey('ajuste-tamano')));
      expect(tamano.value, '100 por ciento');
      expect(tamano.flagsCollection.isButton, isTrue);
      expect(Focus.of(tester.element(find.text(Textos.ajustesTitulo))).hasFocus, isTrue);
      semantica.dispose();
    });

    testWidgets('atrás vuelve al Perfil (botón y sistema)', (tester) async {
      await abrirJuego(tester, ruta: Rutas.perfil, repoAjustes: AjustesEnMemoria());
      await tocar(tester, find.byKey(const ValueKey('boton-ajustes')));
      expect(find.byType(PantallaAjustes), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-atras-ajustes')));
      expect(find.byType(PantallaPerfil), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('menu-accesibilidad')));
      expect(find.byType(PantallaAjustes), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(rutaActual(tester), Rutas.perfil);
    });

    testWidgets('los ajustes sobreviven a cerrar sesión', (tester) async {
      final repo = AjustesEnMemoria();
      await abrirJuego(
        tester,
        ruta: Rutas.perfil,
        repoAjustes: repo,
        ajustes: const Ajustes(soloBotones: true, escalaTexto: 120),
      );
      final c = contenedorDe(tester);
      await c.read(ajustesProvider.notifier).cambiar(const Ajustes(soloBotones: true));
      for (final p in proveedoresDeLaPersona) {
        c.invalidate(p);
      }
      await tester.pumpAndSettle();
      expect(c.read(ajustesProvider).soloBotones, isTrue);
      expect((await repo.cargar()).soloBotones, isTrue);
    });

    test('contrastes AA de interruptores y chips', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.accionPrimaria, t.fondoSuperficie), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.bordeControl, t.fondoSuperficie), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.fondoSuperficie, t.accionPrimaria), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.fondoSuperficie, t.bordeControl), greaterThanOrEqualTo(3));
        expect(Contraste.razon(t.textoPrimario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoApp), greaterThanOrEqualTo(4.5));
      }
    });

    probarSinDesbordes((tester, tamano, _) async {
      await abrirAjustes(
        tester,
        tamano: tamano,
        ajustes: const Ajustes(modoTema: ThemeMode.dark),
      );
      expect(tester.takeException(), isNull);
      await tester.drag(find.byKey(const ValueKey('ajustes-desplazable')), const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tocar(tester, find.byKey(const ValueKey('ajuste-animaciones')));
      expect(tester.takeException(), isNull);
    });
  });
}

/// Repositorio que no puede leer.
class RepositorioQueNoCarga implements RepositorioAjustes {
  @override
  Future<Ajustes> cargar() async => throw Exception('base dañada');

  @override
  Future<void> guardar(Ajustes ajustes) async {}

  @override
  Future<AjustesNotificaciones> cargarNotificaciones() async => const AjustesNotificaciones();

  @override
  Future<void> guardarNotificaciones(AjustesNotificaciones notificaciones) async {}
}
