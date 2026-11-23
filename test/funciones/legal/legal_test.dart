import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/fila_acordeon.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/textos/textos_legales.dart';
import 'package:abogator/funciones/acceso/pantalla_registro.dart';
import 'package:abogator/funciones/ajustes/pantalla_ajustes.dart';
import 'package:abogator/funciones/legal/pantalla_legal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../auditoria/ayudante_auditoria.dart';
import '../../ayudantes/montar.dart';
import '../../ayudantes/tamano_pantalla.dart';
import '../juego/ayudante_juego.dart';

List<FilaAcordeon> filas(WidgetTester tester) =>
    tester.widgetList<FilaAcordeon>(find.byType(FilaAcordeon)).toList();

BoxDecoration decoracion(WidgetTester tester, String titulo) =>
    tester.widget<AnimatedContainer>(find.byKey(ValueKey('acordeon-$titulo'))).decoration!
        as BoxDecoration;

void main() {
  group('32 Aviso de Privacidad', () {
    testWidgets('título, versión, 7 secciones y "¿Qué datos recopilamos?" abierta', (tester) async {
      await abrirJuego(tester, ruta: Rutas.legalAviso, conSesion: false);
      expect(find.text(Textos.avisoPrivacidadTitulo), findsOneWidget);
      expect(find.text(Textos.versionLegal), findsOneWidget);
      // La lista se construye al desplazarse: el documento tiene 7 secciones.
      expect(TextosLegales.avisoPrivacidad.secciones, hasLength(7));
      expect(find.byType(FilaAcordeon), findsWidgets);
      final abiertas = filas(tester).where((f) => f.abierta).toList();
      expect(abiertas.single.titulo, '¿Qué datos recopilamos?');
      expect(find.textContaining('No recopilamos datos personales sensibles'), findsOneWidget);
    });

    testWidgets('fila abierta: fondo superficie y borde de 2 accion/acento', (tester) async {
      await abrirJuego(tester, ruta: Rutas.legalAviso, conSesion: false);
      final abierta = decoracion(tester, '¿Qué datos recopilamos?');
      expect(abierta.color, TokensColor.claro.fondoSuperficie);
      expect((abierta.border! as Border).top.width, 2);
      expect((abierta.border! as Border).top.color, TokensColor.claro.accionAcento);
      final cerrada = decoracion(tester, '¿Quién es responsable?');
      expect((cerrada.border! as Border).top.width, 1);
      expect((cerrada.border! as Border).top.color, TokensColor.claro.bordeDefault);
      expect(
        tester.getSize(find.byKey(const ValueKey('acordeon-¿Quién es responsable?'))).height,
        greaterThanOrEqualTo(FilaAcordeon.altoCerrada),
      );
    });

    testWidgets('solo una abierta: abrir otra cierra la anterior; tocarla la cierra', (
      tester,
    ) async {
      await abrirJuego(tester, ruta: Rutas.legalAviso, conSesion: false);
      await tocar(tester, find.text('Tus derechos ARCO'));
      expect(filas(tester).where((f) => f.abierta).single.titulo, 'Tus derechos ARCO');
      await tocar(tester, find.text('Tus derechos ARCO'));
      expect(filas(tester).where((f) => f.abierta), isEmpty);
    });

    testWidgets('semántica expandida y Enter con teclado', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrirJuego(tester, ruta: Rutas.legalAviso, conSesion: false);
      final datos = tester
          .getSemantics(
            find.bySemanticsLabel(Textos.seccionLegalSemantica('¿Qué datos recopilamos?', 2, 7)),
          )
          .getSemanticsData();
      expect('${datos.flagsCollection.isExpanded}', endsWith('isTrue'));
      // Tab: atrás → título → versión… hasta la primera sección.
      var llegue = false;
      for (var i = 0; i < 6 && !llegue; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        llegue = describirFoco(FocusManager.instance.primaryFocus).contains('Quién es');
      }
      expect(llegue, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(filas(tester).where((f) => f.abierta).single.titulo, '¿Quién es responsable?');
      semantica.dispose();
    });

    testWidgets('con "Reducir animaciones" el cambio no se anima', (tester) async {
      await montar(
        tester,
        FilaAcordeon(titulo: 'T', cuerpo: 'C', abierta: true, alAlternar: () {}),
        reducirAnimaciones: true,
      );
      expect(tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration, Duration.zero);
    });

    testWidgets('"Entendido" cierra y regresa', (tester) async {
      await abrirJuego(tester, ruta: Rutas.ajustes);
      await tocar(tester, find.byKey(const ValueKey('ajuste-aviso')));
      expect(find.byType(PantallaLegal), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-entendido-legal')));
      expect(find.byType(PantallaAjustes), findsOneWidget);
    });
  });

  group('33 Términos de uso', () {
    testWidgets('8 secciones con "Contenido educativo" abierta', (tester) async {
      await abrirJuego(tester, ruta: Rutas.legalTerminos, conSesion: false);
      expect(find.text(Textos.terminosTitulo), findsOneWidget);
      expect(TextosLegales.terminos.secciones, hasLength(8));
      await tester.scrollUntilVisible(find.text('Cambios a los términos'), 200);
      expect(find.text('Cambios a los términos'), findsOneWidget);
      expect(filas(tester).where((f) => f.abierta).single.titulo, 'Contenido educativo');
      expect(find.textContaining('no sustituyen la asesoría de un abogado'), findsOneWidget);
    });
  });

  group('accesos', () {
    testWidgets('desde el Registro se lee sin perder lo escrito', (tester) async {
      await abrirJuego(tester, ruta: Rutas.registro, conSesion: false);
      final nombre = find.descendant(
        of: find.byType(PantallaRegistro),
        matching: find.byType(EditableText),
      );
      await tester.enterText(nombre.first, 'Ana');
      await tocar(tester, find.text(Textos.leerTerminos));
      expect(find.byType(PantallaLegal), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('boton-entendido-legal')));
      expect(find.byType(PantallaRegistro), findsOneWidget);
      expect(tester.widget<EditableText>(nombre.first).controller.text, 'Ana');
    });

    testWidgets('desde Ajustes: Aviso y Términos en la sección Legal', (tester) async {
      await abrirJuego(tester, ruta: Rutas.ajustes);
      expect(find.text(Textos.seccionLegal), findsOneWidget);
      await tocar(tester, find.byKey(const ValueKey('ajuste-terminos')));
      expect(find.text(Textos.terminosTitulo), findsOneWidget);
    });
  });

  group('tablet', () {
    for (final t in [Tamano.tabletHorizontal, Tamano.tabletVertical]) {
      testWidgets('columna de lectura de 640 centrada (${t.name})', (tester) async {
        await abrirJuego(tester, ruta: Rutas.legalAviso, conSesion: false, tamano: t.medida);
        final columna = tester.getRect(
          find.byKey(const ValueKey('pantalla-legal-avisoPrivacidad')),
        );
        expect(columna.width, PantallaLegal.anchoTablet);
        expect(columna.center.dx, closeTo(t.medida.width / 2, 1));
      });
    }
  });
}
