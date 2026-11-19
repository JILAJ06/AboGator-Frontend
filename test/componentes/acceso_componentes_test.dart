import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_atras.dart';
import 'package:abogator/componentes/casilla_app.dart';
import 'package:abogator/componentes/chip_seleccion.dart';
import 'package:abogator/componentes/enlace_texto.dart';
import 'package:abogator/core/tema/tema_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

BoxDecoration deco(WidgetTester tester, Key clave) =>
    tester.widget<Container>(find.byKey(clave)).decoration! as BoxDecoration;

const anillo = ValueKey('anillo-foco');

void main() {
  group('CasillaApp', () {
    enAmbosModos('sin marcar: fondo superficie y borde 1.5 borde/control', (tester, brillo) async {
      await montar(
        tester,
        CasillaApp(texto: 'Acepto', marcada: false, alCambiar: (_) {}),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final d = deco(tester, const ValueKey('cuadro-casilla'));
      expect(d.color, t.fondoSuperficie);
      expect((d.border! as Border).top.color, t.bordeControl);
      expect((d.border! as Border).top.width, 1.5);
      expect(find.byType(Icon), findsNothing);
      expect(tester.getSize(find.byKey(const ValueKey('cuadro-casilla'))), const Size.square(22));
      esperarSoloColoresDelTema(tester, brillo);
    });

    enAmbosModos('marcada: relleno accion/primaria con check', (tester, brillo) async {
      await montar(
        tester,
        CasillaApp(texto: 'Acepto', marcada: true, alCambiar: (_) {}),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      expect(deco(tester, const ValueKey('cuadro-casilla')).color, t.accionPrimaria);
      expect(tester.widget<Icon>(find.byType(Icon)).color, t.textoEnPrimario);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('toda la fila es táctil (≥ 48) y alterna el valor', (tester) async {
      bool? valor;
      await montar(
        tester,
        CasillaApp(texto: 'Acepto', marcada: false, alCambiar: (v) => valor = v),
      );
      expect(tester.getSize(find.byType(CasillaApp)).height, greaterThanOrEqualTo(48));
      await tester.tap(find.text('Acepto'));
      expect(valor, isTrue);
    });

    testWidgets('semántica de casilla y error anunciado', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        CasillaApp(texto: 'Acepto', marcada: false, error: 'Debes aceptar', alCambiar: (_) {}),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Acepto')),
        isSemantics(hasCheckedState: true, isChecked: false, hasTapAction: true),
      );
      expect(
        tester.getSemantics(find.text('Debes aceptar')),
        isSemantics(label: 'Debes aceptar', isLiveRegion: true),
      );
      semantica.dispose();
    });

    testWidgets('con teclado muestra el anillo y Espacio la marca', (tester) async {
      bool? valor;
      await montar(
        tester,
        CasillaApp(texto: 'Acepto', marcada: false, alCambiar: (v) => valor = v),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(valor, isTrue);
    });
  });

  group('ChipSeleccion', () {
    enAmbosModos('seleccionado y no seleccionado usan sus tokens', (tester, brillo) async {
      await montar(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChipSeleccion(
              key: const ValueKey('si'),
              texto: 'Sí',
              etiquetaSemantica: 'Sí',
              seleccionado: true,
              alPresionar: () {},
            ),
            ChipSeleccion(
              key: const ValueKey('no'),
              texto: 'No',
              etiquetaSemantica: 'No',
              seleccionado: false,
              alPresionar: () {},
            ),
          ],
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      BoxDecoration pildora(String clave) =>
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byKey(ValueKey(clave)),
                      matching: find.byKey(const ValueKey('pildora-chip')),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(pildora('si').color, t.accionPrimaria);
      expect((pildora('si').border! as Border).top.color, t.accionPrimaria);
      expect(tester.widget<Text>(find.text('Sí')).style!.color, t.textoEnPrimario);
      expect(pildora('no').color, t.fondoSuperficie);
      expect((pildora('no').border! as Border).top.color, t.bordeDefault);
      expect((pildora('no').border! as Border).top.width, 1.5);
      expect(tester.widget<Text>(find.text('No')).style!.color, t.textoPrimario);
      esperarSoloColoresDelTema(tester, brillo);
    });

    testWidgets('zona táctil ≥ 48 sin agrandar la píldora y semántica de opción', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        ChipSeleccion(
          texto: '💻 Desarrollador',
          etiquetaSemantica: 'Perfil Desarrollador, 2 de 3',
          seleccionado: true,
          alPresionar: () => toques++,
        ),
      );
      expect(tester.getSize(find.byType(ChipSeleccion)).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(find.byKey(const ValueKey('pildora-chip'))).height, lessThan(48));
      expect(
        tester.getSemantics(find.bySemanticsLabel('Perfil Desarrollador, 2 de 3')),
        isSemantics(isButton: true, isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      expect(find.bySemanticsLabel(RegExp('💻')), findsNothing);
      await tester.tap(find.byType(ChipSeleccion));
      expect(toques, 1);
      semantica.dispose();
    });
  });

  group('EnlaceTexto', () {
    enAmbosModos('Cuerpo/Énfasis en texto/acento con zona ≥ 48', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(
        tester,
        EnlaceTexto(texto: '¿Olvidaste tu contraseña?', alPresionar: () => toques++),
        brillo: brillo,
      );
      final texto = tester.widget<Text>(find.text('¿Olvidaste tu contraseña?'));
      expect(texto.style!.color, tokensDe(brillo).textoAcento);
      expect(texto.style!.fontWeight, FontWeight.w600);
      expect(tester.getSize(find.byType(EnlaceTexto)).height, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(find.bySemanticsLabel('¿Olvidaste tu contraseña?')),
        isSemantics(isLink: true, hasTapAction: true),
      );
      await tester.tap(find.byType(EnlaceTexto));
      expect(toques, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('BotonAtras', () {
    enAmbosModos('cuadro de 48, radio 12, borde 1 y etiqueta "Atrás"', (tester, brillo) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await montar(tester, BotonAtras(alPresionar: () => toques++), brillo: brillo);
      final t = tokensDe(brillo);
      final d = deco(tester, const ValueKey('caja-atras'));
      expect(tester.getSize(find.byKey(const ValueKey('caja-atras'))), const Size.square(48));
      expect(d.color, t.fondoSuperficie);
      expect(d.borderRadius, BorderRadius.circular(12));
      expect((d.border! as Border).top.color, t.bordeDefault);
      expect((d.border! as Border).top.width, 1);
      expect(tester.widget<Icon>(find.byType(Icon)).size, 20);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Atrás')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(anillo), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(toques, 1);
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('BotonApp cargando', () {
    testWidgets('no responde, muestra progreso y se anuncia', (tester) async {
      final semantica = tester.ensureSemantics();
      var toques = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: crearTemaClaro(),
          home: Scaffold(
            body: BotonApp(
              texto: 'Iniciar sesión',
              alPresionar: () => toques++,
              cargando: true,
              textoCargando: 'Iniciando sesión',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('progreso-boton')), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsNothing);
      expect(
        tester.getSemantics(find.byType(BotonApp)),
        isSemantics(label: 'Iniciando sesión', isEnabled: false, isLiveRegion: true),
      );
      await tester.tap(find.byType(BotonApp));
      expect(toques, 0);
      semantica.dispose();
    });
  });
}
