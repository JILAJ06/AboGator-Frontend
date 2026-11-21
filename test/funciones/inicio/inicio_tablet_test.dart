import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/componentes/tarjeta_buzon_inicio.dart';
import 'package:abogator/componentes/tarjeta_heroe_startup.dart';
import 'package:abogator/componentes/tarjeta_semana.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_perfil.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/resumen_perfil.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_perfil.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/apelaciones/pantalla_buzon.dart';
import 'package:abogator/funciones/inicio/logica_inicio.dart';
import 'package:abogator/funciones/inicio/pantalla_inicio.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:abogator/funciones/perfil/pantalla_perfil.dart';
import 'package:abogator/funciones/tienda/pantalla_tienda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';
import 'inicio_test.dart'
    show ApelacionesFalsas, ProgresoFalso, ana, b, c, h, moduloDe, modulosDePrueba;

class _PerfilQueFalla implements RepositorioPerfil {
  @override
  Future<ResumenPerfil> obtenerPerfil() async => throw Exception('sin red');
}

/// Abre el Inicio con la sesión de Ana en el [tamano] dado.
Future<ProgresoFalso> abrirInicioTablet(
  WidgetTester tester, {
  Tamano tamano = Tamano.tabletHorizontal,
  Size? medida,
  List<Modulo>? modulos,
  int apelaciones = 6,
  bool perfilFalla = false,
  double escalaTexto = 1,
  ThemeMode modo = ThemeMode.light,
}) async {
  await tamanoPantallaDe(tester, medida ?? tamano.medida);
  final progreso = ProgresoFalso(modulos ?? modulosDePrueba);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioProgresoProvider.overrideWithValue(progreso),
        repositorioPerfilProvider.overrideWithValue(
          perfilFalla ? _PerfilQueFalla() : MockPerfil(espera: Duration.zero),
        ),
        repositorioTiendaProvider.overrideWithValue(MockTienda(espera: Duration.zero)),
        repositorioVidasProvider.overrideWithValue(MockVidas(espera: Duration.zero)),
        repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas(apelaciones)),
        repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria(vistoAlInicio: true)),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: medida ?? tamano.medida,
          textScaler: TextScaler.linear(escalaTexto),
          platformBrightness: modo == ThemeMode.dark ? Brightness.dark : Brightness.light,
        ),
        child: const AppAbogator(),
      ),
    ),
  );
  final contenedor = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));
  contenedor.read(sesionProvider.notifier).iniciar(ana);
  contenedor.read(enrutadorProvider).go(Rutas.inicio);
  await tester.pumpAndSettle();
  return progreso;
}

Future<void> ir(WidgetTester tester, String ruta) async {
  final contenedor = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));
  contenedor.read(enrutadorProvider).go(ruta);
  await tester.pumpAndSettle();
}

Rect rect(WidgetTester tester, Finder f) => tester.getRect(f);

void main() {
  group('Inicio en tablet horizontal (T07, 1194×834)', () {
    testWidgets('riel en lugar de la barra inferior y sin botón flotante', (tester) async {
      await abrirInicioTablet(tester);
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(find.byType(NavegacionInferiorApp), findsNothing);
      expect(find.byType(BotonBuzon), findsNothing);
      expect(rect(tester, find.byType(RielNavegacion)).width, 104);
      // El riel muestra el total del Buzón.
      expect(find.byKey(const ValueKey('insignia-riel')), findsOneWidget);
      expect(find.text('6'), findsWidgets);
    });

    testWidgets('dos columnas con las posiciones de Figma', (tester) async {
      await abrirInicioTablet(tester);
      final heroe = rect(tester, find.byType(TarjetaHeroeStartup));
      expect(heroe.left, 136);
      expect(heroe.top, 120 - 32);
      expect(heroe.width, closeTo(620, 0.5));
      // Alto mínimo de Figma (crece con la fuente de pruebas).
      expect(heroe.height, greaterThanOrEqualTo(200));

      final reto = rect(tester, find.byKey(const ValueKey('tarjeta-reto')));
      expect(reto.left, closeTo(780, 0.5));
      expect(reto.top, 120 - 32);
      expect(reto.width, closeTo(382, 0.5));
      expect(reto.right, closeTo(1162, 0.5));

      final semana = rect(tester, find.byType(TarjetaSemana));
      // Figma: 200 − 32 con el reto de 60 de alto (20 de separación).
      expect(semana.top, closeTo(reto.bottom + 20, 0.5));
      final buzon = rect(tester, find.byType(TarjetaBuzonInicio));
      expect(buzon.top, closeTo(semana.bottom + 16, 0.5));

      // Módulos de 300 en dos columnas con separación 20.
      final m1 = rect(tester, find.byKey(const ValueKey('modulo-mod-1')));
      final m2 = rect(tester, find.byKey(const ValueKey('modulo-mod-2')));
      final m3 = rect(tester, find.byKey(const ValueKey('modulo-mod-3')));
      expect(m1.width, closeTo(300, 0.5));
      expect(m2.left - m1.right, closeTo(20, 0.5));
      expect(m1.top, m2.top);
      expect(m3.left, m1.left);
      // Figma: el título "Ruta de tu Startup" 26 bajo el héroe y los módulos 14 bajo él.
      final ruta = rect(tester, find.text(Textos.rutaStartup));
      expect(ruta.top, closeTo(heroe.bottom + 26, 0.5));
      expect(m1.top, closeTo(ruta.bottom + 14, 0.5));

      // El encabezado: avatar en x 136 y el HUD termina en el margen de 32.
      expect(find.text('Hola, Ana'), findsOneWidget);
      expect(tester.getTopLeft(find.byKey(const ValueKey('circulo-avatar')).first).dx, 136);
    });

    testWidgets('consejo y Sarko quedan al fondo de la columna derecha', (tester) async {
      await abrirInicioTablet(tester);
      final consejo = rect(tester, find.byKey(const ValueKey('tarjeta-consejo')));
      final sarko = rect(tester, find.byKey(const ValueKey('sarko-consejo')));
      expect(sarko.size, const Size(120, 150));
      // Al fondo (834 − 24) o más abajo si la columna no cabe y fluye.
      expect(sarko.bottom, greaterThanOrEqualTo(834 - 24 - 0.5));
      expect(consejo.top, greaterThan(rect(tester, find.byType(TarjetaBuzonInicio)).bottom));
      expect(consejo.left, closeTo(780, 0.5));
      expect(consejo.width, closeTo(252, 0.5));
      expect(find.text('Termina el Sprint 3 hoy y desbloquea la Ronda Semilla.'), findsOneWidget);
    });

    testWidgets('"Tu semana" con racha, precisión del Perfil y monedas', (tester) async {
      await abrirInicioTablet(tester);
      expect(find.text('7 días'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('240'), findsWidgets);
      expect(find.bySemanticsLabel('Precisión: 82%'), findsOneWidget);
    });

    testWidgets('si el Perfil falla, Precisión dice "—" y el Inicio se ve igual', (tester) async {
      await abrirInicioTablet(tester, perfilFalla: true);
      expect(find.text(Textos.semanaSinDato), findsOneWidget);
      expect(find.byType(TarjetaHeroeStartup), findsOneWidget);
      expect(find.bySemanticsLabel('Precisión: sin datos'), findsOneWidget);
    });

    testWidgets('el Buzón abre con su botón y con 0 dice que no hay pendientes', (tester) async {
      await abrirInicioTablet(tester);
      expect(find.text('Abrir Buzón (6)'), findsOneWidget);
      expect(
        find.text('6 tarjetas falladas esperan juicio. Gánalas para recuperar vidas.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('boton-abrir-buzon')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaBuzon), findsOneWidget);
    });

    testWidgets('sin apelaciones no hay botón ni insignia', (tester) async {
      await abrirInicioTablet(tester, apelaciones: 0);
      expect(find.text(Textos.buzonInicioVacio), findsOneWidget);
      expect(find.byKey(const ValueKey('boton-abrir-buzon')), findsNothing);
      expect(find.byKey(const ValueKey('insignia-riel')), findsNothing);
    });

    testWidgets('sin sprint en curso, el consejo general y sin tarjeta héroe', (tester) async {
      await abrirInicioTablet(
        tester,
        modulos: [
          moduloDe(1, [h, h, h, h, h]),
          moduloDe(2, [b, b, b, b, b]),
        ],
      );
      expect(find.byType(TarjetaHeroeStartup), findsNothing);
      expect(find.text(Textos.consejoGeneral), findsOneWidget);
    });

    testWidgets('el riel navega a Buzón, Tienda, Perfil, Ajustes y de vuelta a Mapa', (
      tester,
    ) async {
      await abrirInicioTablet(tester);
      for (final (clave, pantalla) in [
        ('riel-buzon', PantallaBuzon),
        ('riel-tienda', PantallaTienda),
        ('riel-perfil', PantallaPerfil),
      ]) {
        await tester.tap(find.byKey(ValueKey(clave)));
        await tester.pumpAndSettle();
        expect(find.byType(pantalla), findsOneWidget, reason: clave);
        expect(find.byType(RielNavegacion), findsOneWidget);
        expect(find.byType(NavegacionInferiorApp), findsNothing);
      }
      await tester.tap(find.byKey(const ValueKey('riel-ajustes')));
      await tester.pumpAndSettle();
      final enrutador = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
          .read(enrutadorProvider);
      expect(enrutador.routerDelegate.currentConfiguration.uri.path, Rutas.ajustes);
      await ir(tester, Rutas.tienda);
      await tester.tap(find.byKey(const ValueKey('riel-mapa')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('el Mapa de sprints hereda el riel', (tester) async {
      await abrirInicioTablet(tester);
      await tester.tap(find.byKey(const ValueKey('modulo-mod-1')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(find.byType(BotonBuzon), findsNothing);
    });

    testWidgets('tocar un módulo y "Continuar sprint" navegan como en móvil', (tester) async {
      await abrirInicioTablet(tester, modulos: MockProgreso.modulos);
      await tester.tap(find.text(Textos.continuarSprint));
      await tester.pumpAndSettle();
      final enrutador = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
          .read(enrutadorProvider);
      expect(enrutador.routerDelegate.currentConfiguration.uri.path, contains('/sprint/'));
    });
  });

  group('Inicio en tablet vertical', () {
    for (final tamano in [Tamano.tabletVertical, Tamano.tabletMinima]) {
      testWidgets('una columna en ${tamano.name}: la derecha debajo de la izquierda', (
        tester,
      ) async {
        await abrirInicioTablet(tester, tamano: tamano);
        expect(find.byType(RielNavegacion), findsOneWidget);
        final heroe = rect(tester, find.byType(TarjetaHeroeStartup));
        final reto = rect(tester, find.byKey(const ValueKey('tarjeta-reto'), skipOffstage: false));
        expect(reto.left, heroe.left);
        expect(reto.top, greaterThan(heroe.bottom));
        expect(heroe.width, lessThanOrEqualTo(640));
      });
    }
  });

  group('sin desbordes', () {
    for (final tamano in [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima]) {
      for (final escala in [1.0, 2.0]) {
        for (final modo in [ThemeMode.light, ThemeMode.dark]) {
          testWidgets('${tamano.name} al ${(escala * 100).round()} % (${modo.name})', (
            tester,
          ) async {
            await abrirInicioTablet(tester, tamano: tamano, escalaTexto: escala, modo: modo);
            expect(tester.takeException(), isNull);
            // Todo el contenido se puede alcanzar desplazando.
            await tester.scrollUntilVisible(
              find.byKey(const ValueKey('sarko-consejo')),
              200,
              scrollable: find.descendant(
                of: find.byKey(const ValueKey('inicio-tablet')),
                matching: find.byType(Scrollable),
              ),
            );
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });

  test('consejo: módulo siguiente, sprint siguiente en el último módulo o general', () {
    expect(
      LogicaInicio.consejo(modulosDePrueba),
      'Termina el Sprint 3 hoy y desbloquea la Ronda Semilla.',
    );
    expect(
      LogicaInicio.consejo([
        moduloDe(5, [h, c, b, b, b]),
      ]),
      'Termina el Sprint 2 hoy y desbloquea S.',
    );
    expect(
      LogicaInicio.consejo([
        moduloDe(1, [h, h, h, h, h]),
      ]),
      Textos.consejoGeneral,
    );
  });

  testWidgets('en móvil sigue la barra inferior y el botón Buzón', (tester) async {
    await abrirInicioTablet(tester, tamano: Tamano.movil);
    expect(find.byType(RielNavegacion), findsNothing);
    expect(find.byType(NavegacionInferiorApp), findsOneWidget);
    expect(find.byType(BotonBuzon), findsOneWidget);
    expect(find.byType(TarjetaSemana), findsNothing);
  });
}
