import 'package:abogator/componentes/aviso_conexion.dart';
import 'package:abogator/componentes/indicador_pendientes.dart';
import 'package:abogator/componentes/interruptor_conexion_debug.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration decoDe(WidgetTester tester, Finder f) =>
    tester.widget<Container>(f).decoration! as BoxDecoration;

void main() {
  group('AvisoConexion', () {
    enAmbosModos('superficie con borde accion/acento de 1.5 y 5 a la izquierda', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, const SizedBox(width: 342, child: AvisoConexion()), brillo: brillo);
      final t = tokensDe(brillo);
      final borde = tester.widget<Container>(find.byKey(const ValueKey('aviso-conexion')));
      expect((borde.decoration! as BoxDecoration).color, t.accionAcento);
      expect(borde.padding, const EdgeInsets.fromLTRB(5, 1.5, 1.5, 1.5));
      expect((borde.decoration! as BoxDecoration).borderRadius, BorderRadius.circular(14));
      expect(find.text(Textos.conexionInestable), findsOneWidget);
      final nodo = tester.getSemantics(find.byType(AvisoConexion));
      expect(nodo.label, Textos.conexionInestable);
      expect(nodo.flagsCollection.isLiveRegion, isTrue);
      // No recibe toques ni foco.
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('aviso-conexion')),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });

    testWidgets('variante restablecida', (tester) async {
      await montar(tester, const AvisoConexion(restablecida: true));
      expect(find.text(Textos.conexionRestablecida), findsOneWidget);
    });

    testWidgets('al 200 % el texto baja de línea sin desbordes', (tester) async {
      await montar(tester, const SizedBox(width: 272, child: AvisoConexion()), escalaTexto: 2);
      expect(tester.takeException(), isNull);
    });
  });

  group('IndicadorPendientes', () {
    enAmbosModos('refresh de 14 y texto en texto/acento, singular y plural', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, const IndicadorPendientes(cantidad: 3), brillo: brillo);
      expect(find.text('3 respuestas guardadas en el dispositivo (SQLite)'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          '3 respuestas guardadas en el dispositivo, pendientes de sincronizar',
        ),
        findsOneWidget,
      );
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
      await montar(tester, const IndicadorPendientes(cantidad: 1), brillo: brillo);
      expect(find.text('1 respuesta guardada en el dispositivo (SQLite)'), findsOneWidget);
    });

    test('texto/acento sobre fondo/app en AA', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoAcento, t.fondoApp), greaterThanOrEqualTo(4.5));
      }
    });
  });

  group('InterruptorConexionDebug', () {
    testWidgets('alto ≥ 48 y cambia el estado', (tester) async {
      bool? valor;
      await montar(
        tester,
        InterruptorConexionDebug(sinConexion: false, alCambiar: (v) => valor = v),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('interruptor-conexion'))).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byType(Switch));
      expect(valor, isTrue);
    });

    testWidgets('fuera de depuración no existe', (tester) async {
      await montar(
        tester,
        InterruptorConexionDebug(sinConexion: false, alCambiar: (_) {}, visible: false),
      );
      expect(find.byType(Switch), findsNothing);
    });
  });

  group('SugerenciaBuzon', () {
    enAmbosModos('fondo/destacado, radio 22 y cuadrado accion/secundaria', (tester, brillo) async {
      await montar(
        tester,
        SizedBox(width: 342, child: SugerenciaBuzon(pendientes: 2, alIr: () {})),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final caja = decoDe(tester, find.byKey(const ValueKey('sugerencia-buzon')));
      expect((caja.color, caja.borderRadius), (t.fondoDestacado, BorderRadius.circular(22)));
      final icono = decoDe(tester, find.byKey(const ValueKey('icono-buzon')));
      expect((icono.color, icono.borderRadius), (t.accionSecundaria, BorderRadius.circular(14)));
      expect(tester.getSize(find.byKey(const ValueKey('icono-buzon'))), const Size(44, 44));
      esperarSoloColoresDelTema(tester, brillo);
    });
  });
}
