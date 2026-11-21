import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/marco_principal.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/dialogo_confirmacion.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/piezas_perfil.dart';
import 'package:abogator/componentes/piezas_tienda.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/componentes/tarjeta_consejo_sarko.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/ajustes/estado_ajustes.dart';
import 'package:abogator/funciones/ajustes/pantalla_ajustes.dart';
import 'package:abogator/funciones/apelaciones/sesion_apelaciones.dart';
import 'package:abogator/funciones/perfil/logica_perfil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../../ayudantes/tamano_pantalla.dart';
import '../ajustes/ajustes_test.dart' show abrirAjustes;
import '../apelaciones/buzon_test.dart' show abrirBuzon;
import '../apelaciones/juicio_test.dart' show ahora, servidor;
import '../juego/ayudante_juego.dart' show contenedorDe;
import '../tienda/tienda_test.dart' show abrirTienda;
import 'perfil_test.dart' show abrirPerfil;

Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Caja visible del diálogo de confirmación (su contenido desplazable).
Rect cajaDialogo(WidgetTester tester) => tester.getRect(
  find
      .descendant(
        of: find.byKey(const ValueKey('dialogo-confirmacion')),
        matching: find.byType(SingleChildScrollView),
      )
      .first,
);

const tamanosTablet = [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima];

void main() {
  group('24 Tienda en tablet (T24)', () {
    testWidgets('horizontal: riel, catálogo en 4 columnas y consejo con Sarko', (tester) async {
      await abrirTienda(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(RielNavegacion), findsOneWidget);
      final tarjetas = find.byType(TarjetaArticulo);
      expect(tarjetas, findsNWidgets(4));
      final a = tester.getRect(tarjetas.at(0));
      final b = tester.getRect(tarjetas.at(1));
      final d = tester.getRect(tarjetas.at(3));
      expect(a.top, b.top);
      expect(a.top, d.top);
      expect(b.left - a.right, closeTo(24, 0.5));
      expect(a.left, 136);
      expect(d.right, closeTo(1162, 0.5));
      expect(a.width, closeTo(238.5, 0.5));
      expect(find.byType(TarjetaConsejoSarko), findsOneWidget);
      expect(
        tester.widget<TarjetaConsejoSarko>(find.byType(TarjetaConsejoSarko)).destacada,
        isTrue,
      );
      expect(find.text(Textos.tiendaConsejo), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('sarko-tienda'))).width, 136);
      // El saldo arriba a la derecha.
      expect(tester.getRect(find.byType(PildoraSaldo)).right, closeTo(1162, 0.5));
    });

    testWidgets('vertical: 2 columnas en un ancho máximo de 640', (tester) async {
      await abrirTienda(tester, tamano: Tamano.tabletVertical.medida);
      final tarjetas = find.byType(TarjetaArticulo);
      final a = tester.getRect(tarjetas.at(0));
      final b = tester.getRect(tarjetas.at(1));
      final c = tester.getRect(tarjetas.at(2));
      expect(a.top, b.top);
      expect(c.top, greaterThan(a.bottom));
      expect(b.right - a.left, lessThanOrEqualTo(640));
    });

    testWidgets('compra de punta a punta con el diálogo de 440 centrado', (tester) async {
      final tienda = await abrirTienda(tester, tamano: Tamano.tabletHorizontal.medida);
      final antes = await tienda.obtenerMonedas();
      await tocar(
        tester,
        find.descendant(of: find.byType(TarjetaArticulo).first, matching: find.byType(BotonPrecio)),
      );
      final dialogo = cajaDialogo(tester);
      expect(dialogo.width, lessThanOrEqualTo(DialogoConfirmacion.anchoMaximoTablet));
      expect(dialogo.width, greaterThan(DialogoConfirmacion.anchoMaximo));
      expect(dialogo.center.dx, closeTo(1194 / 2, 1));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(await tienda.obtenerMonedas(), lessThan(antes));
      expect(find.byKey(const ValueKey('aviso-tienda')), findsOneWidget);
    });
  });

  group('25 Perfil en tablet (T25)', () {
    testWidgets('horizontal: dos columnas de 500 y 502 con el progreso por módulo', (tester) async {
      await abrirPerfil(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(RielNavegacion), findsOneWidget);
      final izquierda = tester.getRect(find.byKey(const ValueKey('perfil-columna-izquierda')));
      final derecha = tester.getRect(find.byKey(const ValueKey('perfil-columna-derecha')));
      expect(izquierda.left, 136);
      expect(izquierda.width, closeTo(500, 1));
      expect(derecha.left - izquierda.right, closeTo(24, 1));
      expect(derecha.right, closeTo(1162, 0.5));
      expect(find.text(Textos.cuentaYPreferencias), findsOneWidget);
      expect(find.byType(TarjetaProgresoModulos), findsOneWidget);
      // Un renglón por módulo, con su porcentaje.
      for (final m in MockProgreso.modulos) {
        expect(
          find.bySemanticsLabel(
            RegExp('^${m.numero} · .*, ${LogicaPerfil.porcentajeModulo(m)} %\$'),
          ),
          findsOneWidget,
        );
      }
      // Las medallas se reparten a todo el ancho de la columna izquierda.
      final medallas = find.byType(MedallaInsignia);
      expect(tester.getTopLeft(medallas.first).dx, closeTo(136, 0.5));
      expect(tester.getTopRight(medallas.last).dx, closeTo(izquierda.right, 0.5));
    });

    testWidgets('cerrar sesión con el diálogo centrado', (tester) async {
      await abrirPerfil(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('menu-cerrar-sesion')));
      final dialogo = cajaDialogo(tester);
      expect(dialogo.width, lessThanOrEqualTo(440));
      expect(dialogo.center.dx, closeTo(1194 / 2, 1));
      await tocar(tester, find.byKey(const ValueKey('boton-confirmar')));
      expect(find.byType(PantallaInicioSesion), findsOneWidget);
    });

    testWidgets('vertical: una columna de hasta 640', (tester) async {
      await abrirPerfil(tester, tamano: Tamano.tabletVertical.medida);
      expect(find.byKey(const ValueKey('perfil-columna-izquierda')), findsNothing);
      final tarjeta = tester.getRect(find.byType(TarjetaPerfil));
      final progreso = tester.getRect(find.byType(TarjetaProgresoModulos, skipOffstage: false));
      expect(tarjeta.width, lessThanOrEqualTo(640));
      expect(progreso.left, tarjeta.left);
      expect(progreso.top, greaterThan(tarjeta.bottom));
    });

    test('porcentaje del módulo sin el Examen final', () {
      final m = MockProgreso.modulos.first;
      expect(LogicaPerfil.porcentajeModulo(m), 40);
      expect(LogicaPerfil.porcentajeModulo(MockProgreso.modulos[1]), 0);
    });
  });

  group('26 Ajustes en tablet (T26)', () {
    testWidgets('horizontal: con riel (Perfil activo), dos columnas y vista previa', (
      tester,
    ) async {
      await abrirAjustes(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(tester.widget<RielNavegacion>(find.byType(RielNavegacion)).actual, PestanaApp.perfil);
      final izquierda = tester.getRect(find.byKey(const ValueKey('ajustes-columna-izquierda')));
      final derecha = tester.getRect(find.byKey(const ValueKey('ajustes-columna-derecha')));
      expect(izquierda.width, closeTo(500, 1));
      expect(derecha.left - izquierda.right, closeTo(24, 1));
      expect(find.byType(VistaPreviaTexto), findsOneWidget);
      expect(find.text(Textos.vistaPreviaEtiqueta(100)), findsOneWidget);
      // Visual y la vista previa a la izquierda; motor y cognitiva a la derecha.
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('ajuste-modo-oscuro'))).dx,
        lessThan(izquierda.right),
      );
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('ajuste-tiempo'))).dx,
        greaterThanOrEqualTo(derecha.left),
      );
    });

    testWidgets('los ajustes se aplican al instante y el tamaño se elige en un diálogo de 440', (
      tester,
    ) async {
      final repo = await abrirAjustes(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('ajuste-solo-botones')));
      expect(contenedorDe(tester).read(ajustesProvider).soloBotones, isTrue);
      expect((await repo.cargar()).soloBotones, isTrue);

      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      expect(find.byType(BottomSheet), findsNothing);
      final selector = tester.getRect(find.byKey(const ValueKey('fondo-selector-tamano')));
      expect(selector.width, lessThanOrEqualTo(SelectorTamano.anchoDialogo));
      expect(selector.center.dx, closeTo(1194 / 2, 1));
      await tocar(tester, find.byKey(const ValueKey('tamano-120')));
      expect(contenedorDe(tester).read(ajustesProvider).escalaTexto, 120);
      expect(find.text(Textos.vistaPreviaEtiqueta(120)), findsOneWidget);
    });

    testWidgets('atrás vuelve al Perfil', (tester) async {
      await abrirAjustes(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('boton-atras-ajustes')));
      expect(
        contenedorDe(tester).read(enrutadorProvider).routerDelegate.currentConfiguration.uri.path,
        Rutas.perfil,
      );
    });

    testWidgets('en móvil sigue sin navegación y con la hoja', (tester) async {
      await abrirAjustes(tester);
      expect(find.byType(RielNavegacion), findsNothing);
      expect(find.byType(NavegacionInferiorApp), findsNothing);
      expect(find.byType(VistaPreviaTexto), findsNothing);
      await tocar(tester, find.byKey(const ValueKey('ajuste-tamano')));
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });

  group('sin desbordes', () {
    final pantallas = <String, Future<void> Function(WidgetTester, Size)>{
      'Tienda': (t, m) => abrirTienda(t, tamano: m),
      'Perfil': (t, m) => abrirPerfil(t, tamano: m),
      'Ajustes': (t, m) => abrirAjustes(t, tamano: m),
    };
    for (final MapEntry(key: pantalla, value: abrir) in pantallas.entries) {
      for (final tamano in tamanosTablet) {
        for (final escala in [1.0, 2.0]) {
          for (final brillo in Brightness.values) {
            final nombre = '${tamano.name} al ${(escala * 100).round()} % (${brillo.name})';
            testWidgets('$pantalla: $nombre', (tester) async {
              tester.platformDispatcher.textScaleFactorTestValue = escala;
              tester.platformDispatcher.platformBrightnessTestValue = brillo;
              addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
              addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
              await abrir(tester, tamano.medida);
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }
  });

  testWidgets('la insignia del riel baja de N a N−1 al ganar un juicio', (tester) async {
    // El Buzón se arma hoy y luego el reloj avanza 10 días: todas quedan
    // disponibles.
    var momento = ahora;
    final repo = servidor(reloj: () => momento);
    await repo.obtenerBuzon();
    momento = ahora.add(const Duration(days: 10));
    await abrirBuzon(tester, apelaciones: repo, tamano: Tamano.tabletHorizontal.medida);
    final total = (await repo.obtenerBuzon()).total;
    Finder insignia(int n) =>
        find.descendant(of: find.byKey(const ValueKey('insignia-riel')), matching: find.text('$n'));
    expect(insignia(total), findsOneWidget);
    // Ganar la última vuelta (día 14) la saca del Buzón.
    final ultima = (await repo.obtenerBuzon()).apelaciones.firstWhere((a) => a.diaRepaso == 14);
    await repo.resolverApelacion(ultima.id, ganada: true);
    contenedorDe(tester).read(sesionApelacionesProvider.notifier).refrescar();
    await tester.pumpAndSettle();
    expect(insignia(total - 1), findsOneWidget);
    expect(contenedorDe(tester).read(totalBuzonRielProvider).value, total - 1);
  });

  enAmbosModos('contraste de la etiqueta del consejo destacado y la vista previa', (
    tester,
    brillo,
  ) async {
    final t = tokensDe(brillo);
    expect(Contraste.razon(t.textoAcento, t.fondoDestacado), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoPrimario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
  });
}
