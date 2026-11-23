import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/juego/logica_swipe.dart';
import 'package:abogator/funciones/juego/mazo_swipe.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/montar.dart';

/// Doble del mazo: anota lo que le pide el teclado.
class _MazoDoble extends Fake implements MazoSwipeState {
  _MazoDoble({this.previa});

  @override
  Veredicto? previa;

  final llamadas = <String>[];

  @override
  void previsualizar(Veredicto veredicto) => llamadas.add('previsualizar ${veredicto.name}');

  @override
  void confirmar(Veredicto veredicto) => llamadas.add('confirmar ${veredicto.name}');

  @override
  void cancelarPrevia() => llamadas.add('cancelar');

  // `State` es diagnosticable: su `toString` lleva el nivel.
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) => 'MazoDoble';
}

KeyEvent _pulsar(LogicalKeyboardKey tecla) => KeyDownEvent(
  physicalKey: PhysicalKeyboardKey.keyA,
  logicalKey: tecla,
  timeStamp: Duration.zero,
);

KeyEvent _mantener(LogicalKeyboardKey tecla) => KeyRepeatEvent(
  physicalKey: PhysicalKeyboardKey.keyA,
  logicalKey: tecla,
  timeStamp: Duration.zero,
);

KeyEvent _soltar(LogicalKeyboardKey tecla) =>
    KeyUpEvent(physicalKey: PhysicalKeyboardKey.keyA, logicalKey: tecla, timeStamp: Duration.zero);

void main() {
  group('teclearMazo', () {
    final flechas = {
      LogicalKeyboardKey.arrowLeft: Veredicto.ilegal,
      LogicalKeyboardKey.arrowRight: Veredicto.legal,
      LogicalKeyboardKey.arrowUp: Veredicto.condicional,
      LogicalKeyboardKey.arrowDown: Veredicto.escalar,
    };

    for (final MapEntry(key: tecla, value: veredicto) in flechas.entries) {
      test('${tecla.keyLabel} previsualiza ${veredicto.name} (al pulsar y al mantener)', () {
        final mazo = _MazoDoble();
        expect(teclearMazo(mazo, _pulsar(tecla)), KeyEventResult.handled);
        expect(teclearMazo(mazo, _mantener(tecla)), KeyEventResult.handled);
        expect(mazo.llamadas, [
          'previsualizar ${veredicto.name}',
          'previsualizar ${veredicto.name}',
        ]);
      });
    }

    test('las flechas previsualizan aunque ya haya una previsualización', () {
      final mazo = _MazoDoble(previa: Veredicto.legal);
      expect(teclearMazo(mazo, _pulsar(LogicalKeyboardKey.arrowLeft)), KeyEventResult.handled);
      expect(mazo.llamadas, ['previsualizar ilegal']);
    });

    for (final tecla in [LogicalKeyboardKey.enter, LogicalKeyboardKey.numpadEnter]) {
      test('${tecla.keyLabel} confirma la previsualización', () {
        final mazo = _MazoDoble(previa: Veredicto.condicional);
        expect(teclearMazo(mazo, _pulsar(tecla)), KeyEventResult.handled);
        expect(mazo.llamadas, ['confirmar condicional']);
      });

      test('${tecla.keyLabel} sin previsualización sigue su camino', () {
        final mazo = _MazoDoble();
        expect(teclearMazo(mazo, _pulsar(tecla)), KeyEventResult.ignored);
        expect(mazo.llamadas, isEmpty);
      });
    }

    test('Esc cancela la previsualización', () {
      final mazo = _MazoDoble(previa: Veredicto.escalar);
      expect(teclearMazo(mazo, _pulsar(LogicalKeyboardKey.escape)), KeyEventResult.handled);
      expect(mazo.llamadas, ['cancelar']);
    });

    test('Esc sin previsualización sigue su camino', () {
      final mazo = _MazoDoble();
      expect(teclearMazo(mazo, _pulsar(LogicalKeyboardKey.escape)), KeyEventResult.ignored);
      expect(mazo.llamadas, isEmpty);
    });

    test('soltar una tecla no hace nada', () {
      final mazo = _MazoDoble(previa: Veredicto.legal);
      for (final tecla in [
        ...flechas.keys,
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.numpadEnter,
        LogicalKeyboardKey.escape,
      ]) {
        expect(teclearMazo(mazo, _soltar(tecla)), KeyEventResult.ignored);
      }
      expect(mazo.llamadas, isEmpty);
    });

    test('las teclas ajenas no hacen nada, con o sin previsualización', () {
      for (final previa in [null, Veredicto.legal]) {
        final mazo = _MazoDoble(previa: previa);
        for (final tecla in [
          LogicalKeyboardKey.keyP,
          LogicalKeyboardKey.space,
          LogicalKeyboardKey.tab,
        ]) {
          expect(teclearMazo(mazo, _pulsar(tecla)), KeyEventResult.ignored);
        }
        expect(mazo.llamadas, isEmpty);
      }
    });
  });

  group('TinteArrastre', () {
    Future<void> montarTinte(
      WidgetTester tester,
      ValueNotifier<ArrastreVisible> arrastre,
      Brightness brillo,
    ) => montar(
      tester,
      SizedBox(
        width: 200,
        height: 200,
        child: Stack(children: [TinteArrastre(arrastre: arrastre)]),
      ),
      brillo: brillo,
    );

    for (final brillo in Brightness.values) {
      testWidgets('color y opacidad del veredicto (${brillo.name})', (tester) async {
        final arrastre = ValueNotifier(const ArrastreVisible());
        addTearDown(arrastre.dispose);
        await montarTinte(tester, arrastre, brillo);
        // En reposo no hay tinte.
        expect(_tinte(), findsNothing);

        for (final veredicto in Veredicto.values) {
          arrastre.value = ArrastreVisible(veredicto: veredicto, progreso: 0.5);
          await tester.pump();
          final caja = tester.widget<ColoredBox>(find.byKey(ValueKey('tinte-${veredicto.name}')));
          final esperado = BotonVeredicto.color(
            veredicto,
            tokensDe(brillo),
          ).withValues(alpha: 0.5 * LogicaSwipe.opacidadTinte);
          expect(caja.color, esperado);
          // Ocupa toda la pantalla.
          expect(tester.getSize(_tinte()), const Size(200, 200));
        }

        // Al soltar vuelve a quedar sin tinte.
        arrastre.value = const ArrastreVisible();
        await tester.pump();
        expect(_tinte(), findsNothing);
      });
    }
  });
}

/// Cajas de color dentro del tinte (y no las del resto de la app).
Finder _tinte() =>
    find.descendant(of: find.byType(TinteArrastre), matching: find.byType(ColoredBox));
