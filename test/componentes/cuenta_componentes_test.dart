import 'package:abogator/componentes/fila_acordeon.dart';
import 'package:abogator/componentes/ilustracion_insignia.dart';
import 'package:abogator/componentes/notificacion_apelacion.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

void main() {
  group('InsigniaCircular e IlustracionInsignia', () {
    testWidgets('la insignia mide 64, se lee con su etiqueta y sin ella es decorativa', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        const Column(
          children: [
            InsigniaCircular(icono: IconosApp.check, color: Color(0xFF1F4E35), etiqueta: 'Listo'),
            InsigniaCircular(icono: IconosApp.mail, color: Color(0xFF1F4E35)),
          ],
        ),
      );
      expect(tester.getSize(find.byType(InsigniaCircular).first), const Size(64, 64));
      expect(find.bySemanticsLabel('Listo'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('la ilustración mide 260 y su Sarko es decorativo', (tester) async {
      await montar(
        tester,
        const IlustracionInsignia(
          pose: PoseSarko.triste,
          insignia: InsigniaCircular(icono: IconosApp.alert, color: Color(0xFF9A5A1C)),
        ),
      );
      expect(tester.getSize(find.byType(IlustracionInsignia)), const Size(260, 260));
      expect(tester.widget<SarkoImagen>(find.byType(SarkoImagen)).decorativa, isTrue);
      esperarSoloColoresDelTema(tester, Brightness.light);
    });
  });

  group('FilaAcordeon', () {
    testWidgets('cerrada ≥ 50 sin cuerpo; abierta con cuerpo; Enter alterna', (tester) async {
      var veces = 0;
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: FilaAcordeon(
            titulo: 'Título',
            cuerpo: 'Cuerpo',
            abierta: false,
            alAlternar: () => veces++,
          ),
        ),
      );
      expect(tester.getSize(find.byType(FilaAcordeon)).height, greaterThanOrEqualTo(50));
      expect(find.text('Cuerpo'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(veces, 1);
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: FilaAcordeon(titulo: 'Título', cuerpo: 'Cuerpo', abierta: true, alAlternar: () {}),
        ),
      );
      expect(find.text('Cuerpo'), findsOneWidget);
    });

    for (final brillo in Brightness.values) {
      testWidgets('solo colores del tema (${brillo.name})', (tester) async {
        await montar(
          tester,
          SizedBox(
            width: 342,
            child: FilaAcordeon(titulo: 'T', cuerpo: 'C', abierta: true, alAlternar: () {}),
          ),
          brillo: brillo,
        );
        esperarSoloColoresDelTema(tester, brillo);
        final caja =
            tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first).decoration!
                as BoxDecoration;
        expect((caja.border! as Border).top.color, tokensDe(brillo).accionAcento);
      });
    }
  });

  group('InterruptorTocable', () {
    testWidgets('48 de alto, se lee como interruptor y cambia al tocar', (tester) async {
      final semantica = tester.ensureSemantics();
      bool? valor;
      await montar(
        tester,
        InterruptorTocable(valor: false, etiqueta: 'Recordatorio', alCambiar: (v) => valor = v),
      );
      expect(tester.getSize(find.byType(InterruptorTocable)).height, 48);
      final datos = tester.getSemantics(find.bySemanticsLabel('Recordatorio')).getSemanticsData();
      expect('${datos.flagsCollection.isToggled}', endsWith('isFalse'));
      await tester.tap(find.byType(InterruptorTocable));
      expect(valor, isTrue);
      expect(tester.getSize(find.byKey(const ValueKey('interruptor'))), const Size(52, 32));
      semantica.dispose();
    });
  });

  group('NotificacionSistema', () {
    testWidgets('se lee como un bloque con la app, la hora, el título y el cuerpo', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        NotificacionSistema(
          titulo: Textos.notificacionRachaRiesgoTitulo(7),
          cuerpo: Textos.notificacionRachaRiesgoCuerpo,
        ),
      );
      expect(
        find.bySemanticsLabel(
          '${Textos.notificacionApp}, ${Textos.notificacionAhora}. '
          '${Textos.notificacionRachaRiesgoTitulo(7)}. ${Textos.notificacionRachaRiesgoCuerpo}',
        ),
        findsOneWidget,
      );
      expect(tester.getSize(find.byType(NotificacionSistema)).width, NotificacionSistema.ancho);
      semantica.dispose();
    });
  });

  test('el borde de la fila abierta (accion/acento) contrasta ≥ 3:1 en ambos modos', () {
    for (final t in [TokensColor.claro, TokensColor.oscuro]) {
      expect(
        Contraste.razon(t.accionAcento, t.fondoSuperficie),
        greaterThanOrEqualTo(Contraste.minimoNoTexto),
      );
    }
  });
}
