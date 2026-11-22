import 'package:abogator/componentes/accion_enfocable.dart';
import 'package:abogator/componentes/desplazable_alto_minimo.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  group('AccionEnfocable.boton', () {
    for (final brillo in Brightness.values) {
      testWidgets('se anuncia como botón con su etiqueta y se activa con toque y Enter '
          '(${brillo.name})', (tester) async {
        final semantica = tester.ensureSemantics();
        var veces = 0;
        await montar(
          tester,
          AccionEnfocable.boton(
            etiqueta: 'Abrir',
            radio: 12,
            alPresionar: () => veces++,
            child: const SizedBox(key: ValueKey('caja'), width: 48, height: 48),
          ),
          brillo: brillo,
        );
        expect(
          tester.getSemantics(find.byType(AccionEnfocable)),
          isSemantics(label: 'Abrir', isButton: true, hasTapAction: true),
        );
        expect(tester.getSize(find.byKey(const ValueKey('caja'))), const Size(48, 48));
        await tester.tap(find.byType(AccionEnfocable));
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(veces, 2);
        semantica.dispose();
      });
    }

    testWidgets('pasa tal cual las banderas opcionales', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        Column(
          children: [
            AccionEnfocable.boton(
              key: const ValueKey('a'),
              etiqueta: 'Seleccionado',
              radio: 8,
              seleccionado: true,
              habilitado: true,
              alPresionar: () {},
              child: const SizedBox(width: 48, height: 48),
            ),
            AccionEnfocable.boton(
              key: const ValueKey('b'),
              etiqueta: 'Enlace',
              radio: 8,
              enlace: true,
              alPresionar: () {},
              child: const SizedBox(width: 48, height: 48),
            ),
            AccionEnfocable.boton(
              key: const ValueKey('c'),
              etiqueta: 'Sección',
              radio: 8,
              expandido: false,
              alPresionar: () {},
              child: const SizedBox(width: 48, height: 48),
            ),
            const AccionEnfocable.boton(
              key: ValueKey('d'),
              etiqueta: 'Apagado',
              radio: 8,
              habilitado: false,
              alPresionar: null,
              child: SizedBox(width: 48, height: 48),
            ),
          ],
        ),
      );
      final a = tester.getSemantics(find.byKey(const ValueKey('a'))).flagsCollection;
      expect(a.isSelected.toString(), contains('isTrue'));
      expect(a.isEnabled.toString(), contains('isTrue'));
      expect(tester.getSemantics(find.byKey(const ValueKey('b'))).flagsCollection.isLink, isTrue);
      expect(
        tester.getSemantics(find.byKey(const ValueKey('c'))).flagsCollection.isExpanded.toString(),
        contains('isFalse'),
      );
      final d = tester.getSemantics(find.byKey(const ValueKey('d')));
      expect(d.flagsCollection.isEnabled.toString(), contains('isFalse'));
      expect(d.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
      semantica.dispose();
    });
  });

  group('DesplazableAltoMinimo', () {
    Future<void> montarEn(WidgetTester tester, Widget hijo, {double alto = 400}) =>
        montar(tester, SizedBox(width: 300, height: alto, child: hijo));

    testWidgets('el contenido mide al menos el alto disponible menos el relleno', (tester) async {
      await montarEn(
        tester,
        const DesplazableAltoMinimo(
          claveDesplazable: ValueKey('desplazable'),
          relleno: EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            key: ValueKey('contenido'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('arriba'), Text('abajo')],
          ),
        ),
      );
      expect(find.byKey(const ValueKey('desplazable')), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('contenido'))).height, 400 - 36);
      // El pie queda abajo: 24 antes del borde inferior.
      final abajo = tester.getBottomLeft(find.text('abajo')).dy;
      final caja = tester.getBottomLeft(find.byType(DesplazableAltoMinimo)).dy;
      expect(caja - abajo, 24);
    });

    testWidgets('si no cabe, se desplaza; sin alto mínimo, mide lo que su hijo', (tester) async {
      await montarEn(
        tester,
        const DesplazableAltoMinimo(
          claveDesplazable: ValueKey('largo'),
          child: SizedBox(key: ValueKey('hijo'), height: 900),
        ),
      );
      await tester.drag(find.byKey(const ValueKey('largo')), const Offset(0, -300));
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(const ValueKey('hijo'))).dy, lessThan(0));

      await montarEn(
        tester,
        const DesplazableAltoMinimo(
          conAltoMinimo: false,
          child: SizedBox(key: ValueKey('corto'), height: 40),
        ),
      );
      expect(tester.getSize(find.byKey(const ValueKey('corto'))).height, 40);
    });

    testWidgets('con alto sin límite no pide alto mínimo', (tester) async {
      await montar(
        tester,
        const SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: DesplazableAltoMinimo(child: SizedBox(key: ValueKey('hijo'), height: 40)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(const ValueKey('hijo'))).height, 40);
    });

    testWidgets('conserva el controlador y la física', (tester) async {
      final controlador = ScrollController();
      addTearDown(controlador.dispose);
      await montarEn(
        tester,
        DesplazableAltoMinimo(
          controlador: controlador,
          fisica: const NeverScrollableScrollPhysics(),
          child: const SizedBox(height: 900),
        ),
      );
      final vista = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(vista.controller, same(controlador));
      expect(vista.physics, isA<NeverScrollableScrollPhysics>());
    });
  });
}
