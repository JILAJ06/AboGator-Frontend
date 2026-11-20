import 'dart:async';

import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/tarjeta_heroe_startup.dart';
import 'package:abogator/componentes/tarjeta_modulo.dart';
import 'package:abogator/core/tema/colores_marca.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_perfil.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/apelacion.dart';
import 'package:abogator/datos/modelos/buzon_apelaciones.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/resultado_apelacion.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_apelaciones.dart';
import 'package:abogator/datos/repositorios/repositorio_progreso.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/inicio/pantalla_inicio.dart';
import 'package:abogator/funciones/mapa/pantalla_intro_sprint.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/datos.dart';

const ana = Usuario(
  id: 'u-ana',
  nombre: 'Ana López',
  correo: 'ana@startup.mx',
  perfil: PerfilUsuario.desarrollador,
  nivel: 4,
  xp: 0,
  racha: 7,
);

Modulo moduloDe(int n, List<EstadoSprint> estados) => Modulo(
  id: 'mod-$n',
  numero: n,
  nombre: 'Módulo $n',
  color: ColoresModulo.enOrden[n - 1],
  sprints: [for (final (i, e) in estados.indexed) sprintDePrueba('spr-$n-${i + 1}', e)],
);

const h = EstadoSprint.completado;
const c = EstadoSprint.enCurso;
const d = EstadoSprint.disponible;
const b = EstadoSprint.bloqueado;

/// Un módulo por estado: en curso, disponible, completado, bloqueado y bloqueado.
final modulosDePrueba = [
  moduloDe(1, [h, h, c, b, b]),
  moduloDe(2, [d, b, b, b, b]),
  moduloDe(3, [h, h, h, h, h]),
  moduloDe(4, [b, b, b, b, b]),
  moduloDe(5, [b, b, b, b, b]),
];

class ProgresoFalso implements RepositorioProgreso {
  ProgresoFalso(this.modulos);

  List<Modulo> modulos;
  bool fallar = false;
  Completer<void>? bloqueo;
  int llamadas = 0;

  @override
  Future<List<Modulo>> obtenerModulos() async {
    llamadas++;
    await bloqueo?.future;
    if (fallar) throw Exception('sin red');
    return modulos;
  }

  @override
  Future<EstadoStartup> obtenerEstadoStartup() async =>
      const EstadoStartup(presupuesto: 0, reputacion: 0, velocidad: 0, riesgoLegal: 0);

  @override
  Future<void> registrarSprintCompletado({
    required String sprintId,
    required int estrellas,
    required EstadoStartup estadoFinal,
  }) async {}
}

class ApelacionesFalsas implements RepositorioApelaciones {
  ApelacionesFalsas(this.cantidad);

  final int cantidad;

  @override
  Future<BuzonApelaciones> obtenerBuzon() async => BuzonApelaciones(
    ahoraServidor: DateTime.utc(2026),
    apelaciones: [
      for (var i = 0; i < cantidad; i++)
        Apelacion(
          id: 'a$i',
          tarjetaId: 't$i',
          moduloId: 'mod-1',
          titulo: 'Caso $i',
          tema: 'Tema',
          diaRepaso: 3,
          disponibleEl: DateTime.utc(2026),
        ),
    ],
  );

  @override
  Future<void> registrarFallos(List<NuevaApelacion> fallos) async {}

  @override
  Future<ResultadoApelacion> resolverApelacion(String apelacionId, {required bool ganada}) =>
      throw UnimplementedError();
}

/// Monta la app con sesión de Ana y abre el Inicio.
Future<ProgresoFalso> abrirInicio(
  WidgetTester tester, {
  Size tamano = const Size(390, 844),
  List<Modulo>? modulos,
  int apelaciones = 6,
  bool conSesion = true,
  bool esperar = true,
  void Function(ProgresoFalso)? antes,
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final progreso = ProgresoFalso(modulos ?? modulosDePrueba);
  antes?.call(progreso);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioProgresoProvider.overrideWithValue(progreso),
        repositorioPerfilProvider.overrideWithValue(MockPerfil(espera: Duration.zero)),
        repositorioTiendaProvider.overrideWithValue(MockTienda(espera: Duration.zero)),
        repositorioVidasProvider.overrideWithValue(MockVidas(espera: Duration.zero)),
        repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas(apelaciones)),
        repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria(vistoAlInicio: true)),
      ],
      child: const AppAbogator(),
    ),
  );
  final contenedor = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));
  if (conSesion) contenedor.read(sesionProvider.notifier).iniciar(ana);
  contenedor.read(enrutadorProvider).go(Rutas.inicio);
  if (esperar) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
  return progreso;
}

List<TarjetaModulo> tarjetas(WidgetTester tester) =>
    tester.widgetList<TarjetaModulo>(find.byType(TarjetaModulo, skipOffstage: false)).toList();

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra encabezado, héroe, reto, título y los 5 módulos con su estado', (
    tester,
  ) async {
    await abrirInicio(tester, tamano: const Size(390, 1600));
    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
    expect(find.text('Dev · Nivel 4'), findsOneWidget);
    expect(find.text('7'), findsOneWidget); // racha
    expect(find.text('240'), findsOneWidget); // monedas del mock de tienda
    expect(find.text('5'), findsOneWidget); // vidas del mock
    expect(find.text(Textos.heroeEtiqueta), findsOneWidget);
    expect(find.text('Del Garage al MVP'), findsNWidgets(2)); // héroe y tarjeta 1
    expect(find.text('Sprint 3 de 5 · Protección de datos'), findsOneWidget);
    expect(find.text(Textos.retoTitulo), findsOneWidget);
    expect(find.text('Mantén tu racha de 7 días · +15 monedas'), findsOneWidget);
    expect(find.text(Textos.rutaStartup), findsOneWidget);
    expect(tarjetas(tester).map((t) => t.estado), [
      EstadoModulo.enCurso,
      EstadoModulo.disponible,
      EstadoModulo.completado,
      EstadoModulo.bloqueado,
      EstadoModulo.bloqueado,
    ]);
    expect(tarjetas(tester).map((t) => t.completados), [2, 0, 5, 0, 0]);
    expect(find.text('MÓDULO 2 · LICENCIAS OPEN SOURCE'), findsOneWidget);
    expect(find.text('6'), findsOneWidget); // contador del Buzón
  });

  testWidgets('en 390 el saludo no se recorta: si no cabe, los chips bajan (D6)', (tester) async {
    await abrirInicio(tester);
    final saludo = tester.renderObject<RenderParagraph>(find.text('Hola, Ana'));
    expect(saludo.didExceedMaxLines, isFalse);
    final chips = tester.getRect(find.text('240'));
    final texto = tester.getRect(find.text('Hola, Ana'));
    // O caben en la misma fila (los chips a la derecha) o los chips van abajo.
    expect(chips.left >= texto.right || chips.top >= texto.bottom, isTrue);
  });

  testWidgets('el título "Ruta de tu Startup" y el saludo son encabezados', (tester) async {
    final semantica = tester.ensureSemantics();
    await abrirInicio(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel(Textos.rutaStartup)),
      isSemantics(isHeader: true),
    );
    final saludo = tester.getSemantics(find.bySemanticsLabel(RegExp('Hola, Ana')));
    expect(saludo.label, contains('Dev'));
    expect(saludo.label, contains('Nivel 4'));
    expect(saludo, isSemantics(isHeader: true));
    semantica.dispose();
  });

  testWidgets('"Continuar sprint" va a la intro del sprint actual', (tester) async {
    await abrirInicio(tester);
    await tocar(tester, find.text(Textos.continuarSprint));
    expect(find.byType(PantallaIntroSprint), findsOneWidget);
    final ruta = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
        .read(enrutadorProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .path;
    expect(ruta, Rutas.introSprintDe('mod-1', 'spr-1-3'));
  });

  testWidgets('las tarjetas abiertas van al mapa de su módulo; la bloqueada no responde', (
    tester,
  ) async {
    await abrirInicio(tester, tamano: const Size(390, 1600));
    await tocar(tester, find.byKey(const ValueKey('modulo-mod-4')));
    expect(find.byType(PantallaInicio), findsOneWidget);

    await tocar(tester, find.byKey(const ValueKey('modulo-mod-2')));
    expect(find.byType(PantallaMapaSprints), findsOneWidget);
  });

  testWidgets('el Buzón está fijo, lleva al buzón y se anuncia con sus pendientes', (tester) async {
    final semantica = tester.ensureSemantics();
    await abrirInicio(tester);
    final antes = tester.getTopLeft(find.byType(BotonBuzon));
    expect(
      tester.getBottomRight(find.byType(BotonBuzon)).dy,
      tester.getTopLeft(find.byType(NavegacionInferiorApp)).dy - PantallaInicio.separacionBuzon,
    );
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(BotonBuzon)), antes);
    expect(find.bySemanticsLabel('Buzón de apelaciones, 6 pendientes'), findsOneWidget);
    await tester.tap(find.byType(BotonBuzon));
    await tester.pumpAndSettle();
    expect(find.text(Textos.buzonTitulo), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('la última tarjeta no queda tapada por el Buzón', (tester) async {
    await abrirInicio(tester);
    final posicion = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    // La extensión es una estimación hasta que se construye toda la lista.
    for (var i = 0; i < 3; i++) {
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pumpAndSettle();
    }
    final ultima = tester.getRect(find.byKey(const ValueKey('modulo-mod-5')));
    final buzon = tester.getRect(find.byType(BotonBuzon));
    expect(ultima.bottom, lessThanOrEqualTo(buzon.top));
  });

  for (final (pestana, nombre, texto) in [
    (PestanaApp.buzon, 'Buzón', Textos.buzonTitulo),
    (PestanaApp.tienda, 'Tienda', Textos.tuInventario),
    (PestanaApp.perfil, 'Perfil', Textos.perfilTitulo),
  ]) {
    testWidgets('la pestaña ${pestana.name} lleva a su pantalla', (tester) async {
      await abrirInicio(tester);
      await tester.tap(
        find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text(nombre)),
      );
      await tester.pumpAndSettle();
      expect(find.text(texto), findsOneWidget);
    });
  }

  testWidgets('tocar Mapa estando en el Inicio no hace nada', (tester) async {
    await abrirInicio(tester);
    await tester.tap(
      find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text('Mapa')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PantallaInicio), findsOneWidget);
  });

  testWidgets('mientras carga muestra el esqueleto y luego el contenido', (tester) async {
    final progreso = await abrirInicio(
      tester,
      esperar: false,
      antes: (p) => p.bloqueo = Completer<void>(),
    );
    expect(find.byKey(const ValueKey('esqueleto-inicio')), findsOneWidget);
    expect(find.byType(TarjetaHeroeStartup), findsNothing);
    progreso.bloqueo!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('esqueleto-inicio')), findsNothing);
    expect(find.byType(TarjetaHeroeStartup), findsOneWidget);
  });

  testWidgets('si falla la carga muestra el error y "Reintentar" vuelve a pedir', (tester) async {
    final progreso = await abrirInicio(tester, antes: (p) => p.fallar = true);
    expect(find.text(Textos.inicioErrorCarga), findsOneWidget);
    final llamadas = progreso.llamadas;
    progreso.fallar = false;
    await tester.tap(find.text(Textos.reintentar));
    await tester.pumpAndSettle();
    expect(progreso.llamadas, greaterThan(llamadas));
    expect(find.byType(TarjetaHeroeStartup), findsOneWidget);
  });

  testWidgets('sin sesión redirige al inicio de sesión', (tester) async {
    await abrirInicio(tester, conSesion: false);
    expect(find.byType(PantallaInicio), findsNothing);
    expect(find.byType(PantallaInicioSesion), findsOneWidget);
  });

  testWidgets('con el mock real: 2/5 en el módulo 1 y los demás bloqueados', (tester) async {
    await abrirInicio(tester, modulos: MockProgreso.modulos, tamano: const Size(390, 1600));
    expect(tarjetas(tester).map((t) => (t.estado, t.completados)).toList(), [
      (EstadoModulo.enCurso, 2),
      (EstadoModulo.bloqueado, 0),
      (EstadoModulo.bloqueado, 0),
      (EstadoModulo.bloqueado, 0),
      (EstadoModulo.bloqueado, 0),
    ]);
    expect(find.text('Sprint 3 de 5 · Protección de datos'), findsOneWidget);
  });

  testWidgets('orden de foco: Continuar → módulos abiertos → Buzón → pestañas', (tester) async {
    await abrirInicio(tester, tamano: const Size(390, 1600));
    final orden = <String>[];
    for (var i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final contexto = FocusManager.instance.primaryFocus?.context;
      String? dentro<T extends Widget>(String nombre) =>
          contexto?.findAncestorWidgetOfExactType<T>() != null ? nombre : null;
      orden.add(
        dentro<TarjetaHeroeStartup>('heroe') ??
            (contexto?.findAncestorWidgetOfExactType<TarjetaModulo>()?.numero.toString()) ??
            dentro<BotonBuzon>('buzon') ??
            dentro<NavegacionInferiorApp>('pestana') ??
            'otro',
      );
    }
    // Los módulos 4 y 5 están bloqueados y no reciben foco.
    expect(orden, ['heroe', '1', '2', '3', 'buzon', 'pestana']);
  });

  group('sin desbordes', () {
    for (final (tamano, escala) in [
      (const Size(390, 844), 2.0),
      (const Size(360, 640), 2.0),
      (const Size(320, 640), 1.0),
      (const Size(320, 640), 2.0),
    ]) {
      for (final brillo in Brightness.values) {
        testWidgets(
          '${tamano.width.toInt()}×${tamano.height.toInt()} texto ${escala}x ${brillo.name}',
          (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = escala;
            tester.platformDispatcher.platformBrightnessTestValue = brillo;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
            addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
            await abrirInicio(tester, tamano: tamano);
            expect(tester.takeException(), isNull);
            for (var i = 0; i < 8; i++) {
              await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  });
}
