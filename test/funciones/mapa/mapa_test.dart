import 'dart:async';

import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/pantalla_pendiente.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_buzon.dart';
import 'package:abogator/componentes/camino_sprints.dart';
import 'package:abogator/componentes/encabezado_modulo.dart';
import 'package:abogator/componentes/globo_sprint_actual.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/nodo_sprint.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/apelacion.dart';
import 'package:abogator/datos/modelos/estado_startup.dart';
import 'package:abogator/datos/modelos/modulo.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_apelaciones.dart';
import 'package:abogator/datos/repositorios/repositorio_progreso.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/inicio/pantalla_inicio.dart';
import 'package:abogator/funciones/mapa/pantalla_intro_sprint.dart';
import 'package:abogator/funciones/mapa/pantalla_mapa_sprints.dart';
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
}

class ApelacionesFalsas implements RepositorioApelaciones {
  @override
  Future<List<Apelacion>> obtenerApelacionesPendientes() async => [
    for (var i = 0; i < 6; i++)
      Apelacion(
        id: 'a$i',
        tarjetaId: 't',
        resumen: 'r',
        diaRepaso: 3,
        disponibleEl: DateTime.utc(2026),
      ),
  ];
}

/// Módulo con los 5 sprints completados (el Examen final se puede abrir).
final moduloCompleto = moduloDePrueba(
  1,
  List.filled(5, EstadoSprint.completado),
  id: 'mod-1',
  conFinal: true,
);

/// Monta la app con sesión de Ana y abre [ruta] (por defecto, el mapa del
/// módulo 1 del mock real). Con [desdeInicio] primero abre el Inicio y toca
/// la tarjeta del módulo.
Future<ProgresoFalso> abrir(
  WidgetTester tester, {
  String? ruta,
  Size tamano = const Size(390, 844),
  List<Modulo>? modulos,
  bool conSesion = true,
  bool esperar = true,
  void Function(ProgresoFalso)? antes,
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final progreso = ProgresoFalso(modulos ?? MockProgreso.modulos);
  antes?.call(progreso);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioProgresoProvider.overrideWithValue(progreso),
        repositorioTiendaProvider.overrideWithValue(MockTienda(espera: Duration.zero)),
        repositorioVidasProvider.overrideWithValue(MockVidas(espera: Duration.zero)),
        repositorioApelacionesProvider.overrideWithValue(ApelacionesFalsas()),
        repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria(vistoAlInicio: true)),
      ],
      child: const AppAbogator(),
    ),
  );
  final contenedor = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));
  if (conSesion) contenedor.read(sesionProvider.notifier).iniciar(ana);
  contenedor.read(enrutadorProvider).go(ruta ?? Rutas.mapaSprintsDe('mod-1'));
  if (esperar) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
  return progreso;
}

String rutaActual(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
        .read(enrutadorProvider)
        .state
        .uri
        .path;

List<NodoSprint> nodos(WidgetTester tester) =>
    tester.widgetList<NodoSprint>(find.byType(NodoSprint, skipOffstage: false)).toList();

Finder nodo(int indice) => find.byType(NodoSprint, skipOffstage: false).at(indice);

Future<void> tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('Mapa de sprints (08)', () {
    testWidgets('encabezado del módulo 1 con 4… vidas y avance 2/5', (tester) async {
      await abrir(tester);
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(find.byType(EncabezadoModulo), findsOneWidget);
      expect(find.text('MÓDULO 1 · PROTECCIÓN DE DATOS'), findsOneWidget);
      expect(find.text('Del Garage al MVP'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // vidas del mock
      final pestanas = tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp));
      expect(pestanas.actual, PestanaApp.mapa);
      expect(find.byType(BotonBuzon), findsOneWidget);
    });

    testWidgets('6 nodos con su estado, etiquetas, globo y Sarko', (tester) async {
      await abrir(tester, tamano: const Size(390, 1400));
      expect(nodos(tester).map((n) => n.tipo), [
        TipoNodoSprint.completado,
        TipoNodoSprint.completado,
        TipoNodoSprint.actual,
        TipoNodoSprint.bloqueado,
        TipoNodoSprint.bloqueado,
        TipoNodoSprint.jefe,
      ]);
      expect(nodos(tester).take(2).map((n) => n.estrellas), [3, 3]);
      for (final texto in [
        'Datos personales',
        'Consentimiento',
        'Derechos ARCO',
        'Brechas de seguridad',
        'Auditoría de inversores',
        Textos.examenFinal,
      ]) {
        expect(find.text(texto, skipOffstage: false), findsOneWidget, reason: texto);
      }
      // El sprint actual no lleva etiqueta: su título va en el globo.
      expect(find.text('Sprint 3 · Aviso de privacidad'), findsOneWidget);
      expect(find.text('10 tarjetas · ≈ 4 min'), findsOneWidget);
      expect(find.byKey(const ValueKey('sarko-mapa')), findsOneWidget);
    });

    testWidgets('posiciones del zigzag y la etiqueta del sprint 4 a la izquierda', (tester) async {
      await abrir(tester, tamano: const Size(390, 1400));
      final centros = [
        for (var i = 0; i < 6; i++) tester.getTopLeft(nodo(i)) + nodos(tester)[i].tipo.centroCara,
      ];
      expect(centros.map((c) => c.dx.roundToDouble()), [195, 109, 195, 281, 195, 195]);
      // Separaciones verticales de Figma: 120, 120, 260 (globo), 130 y 130
      // entre los bordes superiores de los nodos.
      final arriba = [for (var i = 0; i < 6; i++) tester.getTopLeft(nodo(i)).dy];
      expect(arriba[1] - arriba[0], 120);
      expect(arriba[2] - arriba[1], 120);
      expect(arriba[3] - arriba[2], greaterThanOrEqualTo(250));
      expect(arriba[4] - arriba[3], 130);
      expect(arriba[5] - arriba[4], 130);
      // Etiqueta del sprint 4 (derecha del mapa): termina antes del nodo.
      final etiqueta4 = tester.getRect(find.byKey(const ValueKey('etiqueta-spr-1-4')));
      expect(etiqueta4.right, lessThanOrEqualTo(tester.getTopLeft(nodo(3)).dx));
      final etiqueta1 = tester.getRect(find.byKey(const ValueKey('etiqueta-spr-1-1')));
      expect(etiqueta1.left, greaterThan(tester.getTopRight(nodo(0)).dx));
      // El globo queda centrado bajo el nodo actual.
      expect(tester.getCenter(find.byType(GloboSprintActual)).dx, closeTo(centros[2].dx, 0.5));
    });

    testWidgets('el camino pasa por los centros de las 6 caras', (tester) async {
      await abrir(tester, tamano: const Size(390, 1400));
      final camino = tester.widget<CaminoSprints>(find.byType(CaminoSprints));
      expect(camino.puntos, hasLength(6));
      final origen = tester.getTopLeft(find.byType(CaminoSprints));
      for (var i = 0; i < 6; i++) {
        final centro = tester.getTopLeft(nodo(i)) + nodos(tester)[i].tipo.centroCara;
        expect(camino.puntos[i] + origen, centro);
      }
    });

    testWidgets('al abrir, el mapa se desplaza hasta el sprint actual', (tester) async {
      await abrir(tester, tamano: const Size(360, 640));
      final desplazamiento = tester
          .state<ScrollableState>(
            find.descendant(
              of: find.byKey(const ValueKey('mapa-sprints')),
              matching: find.byType(Scrollable),
            ),
          )
          .position
          .pixels;
      expect(desplazamiento, greaterThan(0));
      final actual = tester.getRect(nodo(2));
      final visible = tester.getRect(find.byKey(const ValueKey('mapa-sprints')));
      expect(visible.top, lessThanOrEqualTo(actual.top));
      expect(actual.bottom, lessThanOrEqualTo(visible.bottom));
    });

    testWidgets('el nodo actual y los completados abren la intro', (tester) async {
      await abrir(tester);
      await tocar(tester, nodo(2));
      expect(find.byType(PantallaIntroSprint), findsOneWidget);
      expect(rutaActual(tester), Rutas.introSprintDe('mod-1', 'spr-1-3'));

      await abrir(tester);
      await tocar(tester, nodo(0));
      expect(rutaActual(tester), Rutas.introSprintDe('mod-1', 'spr-1-1'));
    });

    testWidgets('los bloqueados y el Examen final bloqueado no responden', (tester) async {
      await abrir(tester);
      for (final i in [3, 4, 5]) {
        await tocar(tester, nodo(i));
        expect(find.byType(PantallaMapaSprints), findsOneWidget);
        expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
      }
    });

    testWidgets('con los 5 sprints completados el Examen final abre su ruta', (tester) async {
      await abrir(tester, modulos: [moduloCompleto]);
      expect(find.byType(GloboSprintActual), findsNothing);
      await tocar(tester, nodo(5));
      expect(find.text(Textos.pendienteJefe), findsOneWidget);
      expect(rutaActual(tester), Rutas.crisisJefeDe('mod-1'));
    });

    testWidgets('"Comenzar" del globo abre la intro del sprint actual', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text(Textos.comenzar));
      expect(rutaActual(tester), Rutas.introSprintDe('mod-1', 'spr-1-3'));
    });

    testWidgets('desde el Inicio: tocar el módulo abre el mapa y "atrás" regresa', (tester) async {
      await abrir(tester, ruta: Rutas.inicio);
      await tocar(tester, find.byKey(const ValueKey('modulo-mod-1')));
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(Textos.atras));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
      expect(rutaActual(tester), Rutas.inicio);
    });

    testWidgets('"atrás" sin pila también va al Inicio', (tester) async {
      await abrir(tester);
      await tester.tap(find.byKey(const ValueKey('atras-encabezado')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('las pestañas: Mapa vuelve al Inicio y Buzón a su marcador', (tester) async {
      await abrir(tester);
      await tester.tap(
        find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text('Mapa')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);

      await abrir(tester);
      await tester.tap(find.byType(BotonBuzon));
      await tester.pumpAndSettle();
      expect(find.text(Textos.pendienteBuzon), findsOneWidget);
    });

    testWidgets('mientras carga muestra el esqueleto y luego el mapa', (tester) async {
      final progreso = await abrir(tester, esperar: false, antes: (p) => p.bloqueo = Completer());
      expect(find.byKey(const ValueKey('esqueleto-mapa')), findsOneWidget);
      expect(find.byType(NodoSprint), findsNothing);
      progreso.bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('esqueleto-mapa')), findsNothing);
      expect(find.byType(NodoSprint), findsWidgets);
    });

    testWidgets('si falla la carga, "Reintentar" vuelve a pedir', (tester) async {
      final progreso = await abrir(tester, antes: (p) => p.fallar = true);
      expect(find.text(Textos.mapaErrorCarga), findsOneWidget);
      final llamadas = progreso.llamadas;
      progreso.fallar = false;
      await tester.tap(find.text(Textos.reintentar));
      await tester.pumpAndSettle();
      expect(progreso.llamadas, greaterThan(llamadas));
      expect(find.byType(EncabezadoModulo), findsOneWidget);
    });

    testWidgets('módulo inexistente: mensaje y "Volver al inicio"', (tester) async {
      await abrir(tester, ruta: Rutas.mapaSprintsDe('no-existe'));
      expect(find.text(Textos.moduloNoEncontrado), findsOneWidget);
      await tester.tap(find.text(Textos.volverAlInicio));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaInicio), findsOneWidget);
    });

    testWidgets('sin sesión redirige al inicio de sesión', (tester) async {
      await abrir(tester, conSesion: false);
      expect(find.byType(PantallaMapaSprints), findsNothing);
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('semántica de los nodos: nombre, título, estado y estrellas', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, tamano: const Size(390, 1400));
      expect(
        tester.getSemantics(
          find.bySemanticsLabel('Sprint 1, Datos personales, completado, 3 de 3 estrellas'),
        ),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Sprint 4, Derechos ARCO, bloqueado')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      expect(
        find.bySemanticsLabel('Examen final, Auditoría de inversores, bloqueado'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Sprint 3, Aviso de privacidad, en curso'), findsOneWidget);
      // Las etiquetas visibles no se leen dos veces.
      expect(find.bySemanticsLabel('Datos personales'), findsNothing);
      semantica.dispose();
    });

    testWidgets('orden de foco: atrás → nodos abiertos → Comenzar → Buzón → pestañas', (
      tester,
    ) async {
      await abrir(tester, tamano: const Size(390, 1400));
      final orden = <String>[];
      for (var i = 0; i < 7; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final contexto = FocusManager.instance.primaryFocus?.context;
        String? dentro<T extends Widget>(String nombre) =>
            contexto?.findAncestorWidgetOfExactType<T>() != null ? nombre : null;
        final nodoEnFoco = contexto?.findAncestorWidgetOfExactType<NodoSprint>();
        orden.add(
          (nodoEnFoco == null ? null : 'nodo${nodos(tester).indexOf(nodoEnFoco) + 1}') ??
              dentro<EncabezadoModulo>('atras') ??
              dentro<GloboSprintActual>('comenzar') ??
              dentro<BotonBuzon>('buzon') ??
              dentro<NavegacionInferiorApp>('pestana') ??
              'otro',
        );
      }
      // Los nodos 4, 5 y el Examen final están bloqueados y no reciben foco.
      expect(orden, ['atras', 'nodo1', 'nodo2', 'nodo3', 'comenzar', 'buzon', 'pestana']);
    });
  });

  group('Intro del sprint (09)', () {
    testWidgets('muestra sprint, título, objetivo y los 3 detalles de Figma', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, ruta: Rutas.introSprintDe('mod-1', 'spr-1-3'));
      expect(find.text('SPRINT 3 · MÓDULO 1'), findsOneWidget);
      // Título largo de la intro (D1 de T-04b).
      expect(find.text('Aviso de privacidad en el MVP'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Aviso de privacidad en el MVP')),
        isSemantics(isHeader: true),
      );
      expect(find.textContaining('Objetivo: el MVP sale a producción el viernes.'), findsOneWidget);
      expect(find.text('10 tarjetas'), findsOneWidget);
      expect(find.text('6 normales · 3 con evidencia · 1 dilema'), findsOneWidget);
      expect(find.text('Hasta 60 monedas'), findsOneWidget);
      expect(find.text(Textos.monedasDilema), findsOneWidget);
      expect(find.text(Textos.indicadoresTitulo), findsOneWidget);
      expect(find.text(Textos.indicadoresLista), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // vidas
      expect(find.byType(NavegacionInferiorApp), findsNothing);
      expect(
        tester.getSemantics(find.bySemanticsLabel(Textos.cerrar)),
        isSemantics(isButton: true, hasTapAction: true),
      );
      // La elipse y Sarko no se leen.
      expect(find.bySemanticsLabel(Textos.sarkoAlegre), findsNothing);
      semantica.dispose();
    });

    testWidgets('"Comenzar sprint" está fijo abajo y abre el juego', (tester) async {
      await abrir(tester, ruta: Rutas.introSprintDe('mod-1', 'spr-1-3'));
      final boton = tester.getRect(find.widgetWithText(BotonApp, Textos.comenzarSprint));
      expect(boton.height, 52);
      expect(boton.width, 342);
      expect(844 - boton.bottom, 16);
      await tester.tap(find.text(Textos.comenzarSprint));
      await tester.pumpAndSettle();
      expect(find.text(Textos.pendienteJuego), findsOneWidget);
      expect(rutaActual(tester), Rutas.juegoDe('spr-1-3'));
    });

    testWidgets('Cerrar regresa al mapa del módulo', (tester) async {
      await abrir(tester);
      await tocar(tester, find.text(Textos.comenzar));
      await tester.tap(find.bySemanticsLabel(Textos.cerrar));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
      expect(rutaActual(tester), Rutas.mapaSprintsDe('mod-1'));
    });

    testWidgets('Cerrar sin pila también va al mapa', (tester) async {
      await abrir(tester, ruta: Rutas.introSprintDe('mod-1', 'spr-1-1'));
      await tester.tap(find.byKey(const ValueKey('cerrar-intro')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });

    testWidgets('"Continuar sprint" del Inicio abre la intro y Cerrar lleva al mapa', (
      tester,
    ) async {
      await abrir(tester, ruta: Rutas.inicio);
      await tocar(tester, find.text(Textos.continuarSprint));
      expect(find.byType(PantallaIntroSprint), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('cerrar-intro')));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });

    testWidgets('sprint bloqueado por ruta directa: aviso y botón deshabilitado', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, ruta: Rutas.introSprintDe('mod-1', 'spr-1-4'));
      expect(find.byKey(const ValueKey('aviso-bloqueado')), findsOneWidget);
      final boton = tester.widget<BotonApp>(find.widgetWithText(BotonApp, Textos.comenzarSprint));
      expect(boton.alPresionar, isNull);
      expect(
        tester.getSemantics(find.bySemanticsLabel(Textos.comenzarSprint)),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
      await tester.tap(find.text(Textos.comenzarSprint));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaIntroSprint), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('sprint inexistente: mensaje y "Volver al mapa"', (tester) async {
      await abrir(tester, ruta: Rutas.introSprintDe('mod-1', 'no-existe'));
      expect(find.text(Textos.errorSprintNoEncontrado), findsOneWidget);
      await tester.tap(find.text(Textos.volverAlMapa));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaMapaSprints), findsOneWidget);
    });

    testWidgets('módulo inexistente: mensaje y "Volver al inicio"', (tester) async {
      await abrir(tester, ruta: Rutas.introSprintDe('no-existe', 'spr-1-1'));
      expect(find.text(Textos.errorSprintNoEncontrado), findsOneWidget);
      expect(find.text(Textos.volverAlInicio), findsOneWidget);
    });

    testWidgets('mientras carga muestra el esqueleto; si falla, reintenta', (tester) async {
      final progreso = await abrir(
        tester,
        ruta: Rutas.introSprintDe('mod-1', 'spr-1-3'),
        esperar: false,
        antes: (p) => p.bloqueo = Completer(),
      );
      expect(find.byKey(const ValueKey('esqueleto-intro')), findsOneWidget);
      progreso
        ..fallar = true
        ..bloqueo!.complete();
      await tester.pumpAndSettle();
      expect(find.text(Textos.introErrorCarga), findsOneWidget);
      progreso.fallar = false;
      await tester.tap(find.text(Textos.reintentar));
      await tester.pumpAndSettle();
      expect(find.text('SPRINT 3 · MÓDULO 1'), findsOneWidget);
    });
  });

  group('sin desbordes', () {
    for (final (tamano, escala) in [
      (const Size(390, 844), 1.0),
      (const Size(390, 844), 2.0),
      (const Size(360, 640), 2.0),
      (const Size(320, 640), 1.0),
      (const Size(320, 640), 2.0),
    ]) {
      for (final brillo in Brightness.values) {
        final nombre = '${tamano.width.toInt()}×${tamano.height.toInt()} texto ${escala}x';
        testWidgets('mapa $nombre ${brillo.name}', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          await abrir(tester, tamano: tamano);
          expect(tester.takeException(), isNull);
          final mapa = find.byKey(const ValueKey('mapa-sprints'));
          await tester.drag(mapa, const Offset(0, 2000));
          await tester.pumpAndSettle();
          for (var i = 0; i < 8; i++) {
            await tester.drag(mapa, const Offset(0, -300));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          // El último nodo queda por encima del Buzón al final del desplazamiento.
          final ultimo = tester.getRect(nodo(5));
          expect(ultimo.bottom, lessThanOrEqualTo(tester.getRect(find.byType(BotonBuzon)).top));
        });

        testWidgets('intro $nombre ${brillo.name}', (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = escala;
          tester.platformDispatcher.platformBrightnessTestValue = brillo;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
          await abrir(tester, tamano: tamano, ruta: Rutas.introSprintDe('mod-1', 'spr-1-3'));
          expect(tester.takeException(), isNull);
          final intro = find.byKey(const ValueKey('intro-sprint'));
          for (var i = 0; i < 6; i++) {
            await tester.drag(intro, const Offset(0, -300));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          // El botón sigue a la vista.
          expect(find.text(Textos.comenzarSprint).hitTestable(), findsOneWidget);
        });
      }
    }
  });

  testWidgets('el marcador del juego es una pantalla pendiente', (tester) async {
    await abrir(tester, ruta: Rutas.juegoDe('spr-1-3'));
    expect(find.byType(PantallaPendiente), findsOneWidget);
  });
}
