import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/composicion_juego_tablet.dart';
import 'package:abogator/componentes/disposicion_resultado_tablet.dart';
import 'package:abogator/componentes/fila_apelacion.dart';
import 'package:abogator/componentes/panel_lateral_juego.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/funciones/apelaciones/pantalla_juicio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';
import '../../ayudantes/tamano_pantalla.dart';
import '../juego/ayudante_juego.dart';
import 'buzon_test.dart' show abrirBuzon;
import 'juicio_test.dart' show servidor;

Finder get detalle => find.byKey(const ValueKey('panel-detalle-juicio'));

FilaApelacion fila(WidgetTester tester, String id) =>
    tester.widget<FilaApelacion>(find.byKey(ValueKey('fila-$id')));

void main() {
  group('T21 Buzón en lista-detalle (1194×834)', () {
    testWidgets('riel con insignia, lista de 500 y detalle de 526', (tester) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(find.byKey(const ValueKey('insignia-riel')), findsOneWidget);
      final lista = tester.getRect(find.byKey(const ValueKey('lista-apelaciones')));
      final panel = tester.getRect(detalle);
      expect(lista.left, closeTo(136, 0.5));
      expect(lista.width, closeTo(500, 1));
      expect(panel.left - lista.right, closeTo(32, 1));
      expect(panel.width, closeTo(526, 1));
      expect(panel.right, 1194);
      // La tarjeta del caso con el tamaño del móvil y el botón del juicio.
      final tarjeta = tester.getRect(find.byKey(const ValueKey('tarjeta-detalle-juicio')));
      expect(tarjeta.width, 342);
      expect(tarjeta.center.dx, closeTo(panel.center.dx, 1));
      expect(tester.getSize(find.byKey(const ValueKey('boton-iniciar-juicio'))).width, 342);
      expect(find.byKey(const ValueKey('sarko-detalle-juicio')), findsOneWidget);
    });

    testWidgets('la primera fila está seleccionada y tocar otra actualiza el detalle', (
      tester,
    ) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      expect(fila(tester, 'ape-001').seleccionada, isTrue);
      expect(fila(tester, 'ape-002').seleccionada, isFalse);
      final titulo2 = fila(tester, 'ape-002').titulo;
      await tocar(tester, find.byKey(const ValueKey('fila-ape-002')));
      // No navega: sigue en el Buzón.
      expect(rutaActual(tester), Rutas.buzon);
      expect(fila(tester, 'ape-002').seleccionada, isTrue);
      expect(find.descendant(of: detalle, matching: find.text(titulo2)), findsOneWidget);
    });

    testWidgets('flechas arriba y abajo recorren la selección', (tester) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('fila-ape-001')));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(fila(tester, 'ape-002').seleccionada, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(fila(tester, 'ape-001').seleccionada, isTrue);
    });

    testWidgets('"Iniciar juicio" abre el juicio de la apelación seleccionada', (tester) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('fila-ape-002')));
      await tocar(tester, find.byKey(const ValueKey('boton-iniciar-juicio')));
      expect(rutaActual(tester), Rutas.juicioApelacionDe('ape-002'));
      expect(find.byType(PantallaJuicio), findsOneWidget);
    });

    testWidgets('una apelación futura avisa cuándo se abre', (tester) async {
      await abrirBuzon(tester, tamano: Tamano.tabletHorizontal.medida);
      await tocar(tester, find.byKey(const ValueKey('fila-ape-003')));
      await tocar(tester, find.byKey(const ValueKey('boton-iniciar-juicio')));
      expect(rutaActual(tester), Rutas.buzon);
      expect(find.byKey(const ValueKey('aviso-apelacion-futura')), findsOneWidget);
    });

    testWidgets('vacío: riel y el estado vacío centrado', (tester) async {
      await abrirBuzon(
        tester,
        apelaciones: servidor(conSemilla: false),
        tamano: Tamano.tabletHorizontal.medida,
      );
      expect(find.byType(RielNavegacion), findsOneWidget);
      expect(find.byKey(const ValueKey('buzon-vacio')), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('buzon-vacio'))).width,
        lessThanOrEqualTo(640),
      );
      expect(detalle, findsNothing);
    });

    for (final tamano in [Tamano.tabletVertical, Tamano.tabletMinima]) {
      testWidgets('${tamano.name}: la lista del móvil centrada (máx. 640)', (tester) async {
        await abrirBuzon(tester, tamano: tamano.medida);
        expect(detalle, findsNothing);
        expect(
          tester.getSize(find.byKey(const ValueKey('lista-apelaciones'))).width,
          lessThanOrEqualTo(640),
        );
        await tocar(tester, find.byKey(const ValueKey('fila-ape-001')));
        expect(find.byType(PantallaJuicio), findsOneWidget);
      });
    }
  });

  group('T22 y T22b', () {
    testWidgets('el juicio usa la zona de juego con contexto y atajos; ganar muestra 22b', (
      tester,
    ) async {
      await abrirJuego(
        tester,
        ruta: Rutas.juicioApelacionDe('ape-001'),
        apelaciones: servidor(),
        vidas: 3,
        tamano: Tamano.tabletHorizontal.medida,
      );
      expect(find.byType(ComposicionJuegoTablet), findsOneWidget);
      expect(find.text(Textos.contextoApelacion(3)), findsOneWidget);
      expect(find.byType(TarjetaAtajos), findsOneWidget);
      expect(find.byKey(const ValueKey('nota-juicio')), findsOneWidget);
      final zona = tester.getRect(find.byKey(const ValueKey('zona-tarjeta-tablet')));
      expect(zona.width, 380);
      // La apelación ape-001 es la tarjeta de la GPL (Ilegal).
      final gpl = MockTarjetas.tarjetasPorSprint.values
          .expand((l) => l)
          .firstWhere((t) => t.id == 'tar-gpl-01');
      await tocar(
        tester,
        find.byWidgetPredicate((w) => w is BotonVeredicto && w.veredicto == gpl.respuestaCorrecta),
      );
      expect(find.byType(DisposicionResultadoTablet), findsOneWidget);
      expect(find.text(Textos.apelacionGanadaTitulo), findsOneWidget);
      expect(find.byKey(const ValueKey('vidas-resultado')), findsOneWidget);
    });
  });

  probarSinDesbordesTablet((tester, tamano) async {
    await abrirBuzon(tester, tamano: tamano.medida);
    expect(tester.takeException(), isNull);
  }, prefijo: 'Buzón y juicio en ');

  enAmbosModos('contrastes de los chips de plazo y de la recompensa', (tester, brillo) async {
    final t = tokensDe(brillo);
    expect(Contraste.razon(t.textoSecundario, t.fondoDestacado), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoEnPrimario, t.estadoIlegal), greaterThanOrEqualTo(4.5));
    expect(Contraste.razon(t.textoAcento, t.fondoDestacado), greaterThanOrEqualTo(4.5));
  });
}
