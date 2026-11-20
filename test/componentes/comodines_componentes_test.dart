import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/etiqueta_lupa.dart';
import 'package:abogator/componentes/panel_abogado.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

final gpl = MockTarjetas.tarjetasPorSprint['spr-1-3']![4];

BoxDecoration decoDe(WidgetTester tester, Finder finder) =>
    tester.widget<Container>(finder).decoration! as BoxDecoration;

Finder pildoraDe(String nombre) => find.byKey(ValueKey('pildora-$nombre'));

void main() {
  group('BarraComodines', () {
    enAmbosModos('disponible, activa y deshabilitada con sus colores', (tester, brillo) async {
      await montar(
        tester,
        const SizedBox(
          width: 390,
          child: BarraComodines(
            lupa: 2,
            abogado: 0,
            amparo: 1,
            estadoAbogado: EstadoComodin.deshabilitado,
            estadoAmparo: EstadoComodin.activo,
          ),
        ),
        brillo: brillo,
      );
      final t = tokensDe(brillo);
      final lupa = decoDe(tester, pildoraDe(Textos.comodinLupa));
      expect((lupa.color, (lupa.border! as Border).top.color), (t.fondoSuperficie, t.accionAcento));
      expect((lupa.border! as Border).top.width, 1.5);
      final amparo = decoDe(tester, pildoraDe(Textos.comodinAmparo));
      expect(amparo.color, t.accionAcento);
      final abogado = decoDe(tester, pildoraDe(Textos.comodinAbogado));
      expect(
        (abogado.color, (abogado.border! as Border).top.color),
        (t.fondoSuperficieAlt, t.bordeDefault),
      );
      // La cantidad se sigue mostrando aunque sea 0.
      expect(find.text('Abogado ×0'), findsOneWidget);
      expect(tester.getSize(pildoraDe(Textos.comodinLupa)).height, greaterThanOrEqualTo(48));
      esperarSoloColoresDelTema(tester, brillo);
    });

    test('contraste AA del texto en cada estado (claro y oscuro)', () {
      for (final t in [TokensColor.claro, TokensColor.oscuro]) {
        expect(Contraste.razon(t.textoPrimario, t.fondoSuperficie), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoEnPrimario, t.accionAcento), greaterThanOrEqualTo(4.5));
        expect(Contraste.razon(t.textoSecundario, t.fondoSuperficieAlt), greaterThanOrEqualTo(4.5));
      }
    });

    testWidgets('semántica: botón con cantidad y estado', (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        SizedBox(
          width: 390,
          child: BarraComodines(
            lupa: 2,
            abogado: 0,
            amparo: 1,
            estadoAbogado: EstadoComodin.deshabilitado,
            estadoAmparo: EstadoComodin.activo,
            alUsarLupa: () {},
            alUsarAmparo: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Lupa, 2 disponibles'), findsOneWidget);
      expect(find.bySemanticsLabel('Abogado, 0 disponibles; no disponible'), findsOneWidget);
      expect(find.bySemanticsLabel('Amparo, 1 disponible; ${Textos.amparoArmado}'), findsOneWidget);
      final lupa = tester.getSemantics(pildoraDe(Textos.comodinLupa));
      expect(lupa.flagsCollection.isButton, isTrue);
      semantica.dispose();
    });

    testWidgets('teclado: Enter y Espacio usan el comodín', (tester) async {
      var usos = 0;
      await montar(
        tester,
        SizedBox(
          width: 390,
          child: BarraComodines(lupa: 2, abogado: 1, amparo: 1, alUsarLupa: () => usos++),
        ),
      );
      Focus.of(tester.element(pildoraDe(Textos.comodinLupa))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(usos, 2);
    });

    testWidgets('habilitados: false apaga toda la barra (Examen final)', (tester) async {
      var usos = 0;
      await montar(
        tester,
        SizedBox(
          width: 390,
          child: BarraComodines(
            lupa: 2,
            abogado: 1,
            amparo: 1,
            alUsarLupa: () => usos++,
            alUsarAbogado: () => usos++,
            alUsarAmparo: () => usos++,
            habilitados: false,
          ),
        ),
      );
      for (final p in tester.widgetList<PildoraComodin>(find.byType(PildoraComodin))) {
        expect((p.estado, p.alPresionar), (EstadoComodin.deshabilitado, null));
      }
      await tester.tap(pildoraDe(Textos.comodinLupa));
      expect(usos, 0);
    });

    testWidgets('al 200 % baja de línea sin desbordes', (tester) async {
      await montar(
        tester,
        const SizedBox(width: 320, child: BarraComodines(lupa: 2, abogado: 1, amparo: 1)),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Lupa (10b)', () {
    Widget globo(Brightness brillo) => SizedBox(
      width: 342,
      height: 440,
      child: TarjetaCaso(
        etiquetaCaso: gpl.etiquetaCaso,
        colorModulo: const Color(0xFFB86B23),
        iniciales: 'DJ',
        personaje: gpl.personaje,
        rol: gpl.rol,
        texto: gpl.texto,
        palabrasTrampa: gpl.palabrasTrampa,
      ),
    );

    enAmbosModos('el globo pinta el subrayado de las trampas', (tester, brillo) async {
      await montar(tester, globo(brillo), brillo: brillo);
      final pintura = tester.widget<CustomPaint>(find.byKey(const ValueKey('trampas-globo')));
      final pintor = pintura.painter! as PintorTrampas;
      expect(pintor.rangos, hasLength(3));
      expect(pintor.color, EfectosApp.trampa(brillo));
      esperarSoloColoresDelTema(tester, brillo);
    });

    test('el texto sobre el subrayado sigue en AA en claro y oscuro', () {
      for (final (t, brillo) in [
        (TokensColor.claro, Brightness.light),
        (TokensColor.oscuro, Brightness.dark),
      ]) {
        final fondo = Color.alphaBlend(EfectosApp.trampa(brillo), t.fondoSuperficieAlt);
        expect(
          Contraste.razon(t.textoPrimario, fondo),
          greaterThanOrEqualTo(4.5),
          reason: '$brillo',
        );
      }
    });

    testWidgets('sin trampas no hay subrayado', (tester) async {
      await montar(
        tester,
        SizedBox(
          width: 342,
          child: TextoConTrampas(texto: gpl.texto, estilo: const TextStyle(fontSize: 17)),
        ),
      );
      expect(find.byKey(const ValueKey('trampas-globo')), findsNothing);
    });

    enAmbosModos('etiqueta: píldora accion/acento que se anuncia y no recibe foco', (
      tester,
      brillo,
    ) async {
      final semantica = tester.ensureSemantics();
      await montar(tester, const EtiquetaLupa(), brillo: brillo);
      expect(
        decoDe(tester, find.byKey(const ValueKey('etiqueta-lupa'))).color,
        tokensDe(brillo).accionAcento,
      );
      final nodo = tester.getSemantics(find.byType(EtiquetaLupa));
      expect(nodo.label, Textos.lupaActiva);
      expect(nodo.flagsCollection.isLiveRegion, isTrue);
      // No recibe foco: no tiene ningún Focus dentro.
      expect(
        find.descendant(of: find.byType(EtiquetaLupa), matching: find.byType(Focus)),
        findsNothing,
      );
      esperarSoloColoresDelTema(tester, brillo);
      semantica.dispose();
    });
  });

  group('PanelAbogado (10c)', () {
    Widget panel({List<String>? normas}) => PanelAbogado(
      traduccion: gpl.traduccionLegal!,
      normas: normas ?? gpl.normas,
      alVolver: () {},
    );

    enAmbosModos('título, traducción, normas y "Volver a la tarjeta"', (tester, brillo) async {
      await montar(tester, panel(), brillo: brillo);
      final t = tokensDe(brillo);
      final icono = decoDe(tester, find.byKey(const ValueKey('icono-abogado')));
      expect((icono.color, icono.borderRadius), (t.accionSecundaria, BorderRadius.circular(12)));
      expect(tester.getSize(find.byKey(const ValueKey('icono-abogado'))), const Size(40, 40));
      final caja = decoDe(tester, find.byKey(const ValueKey('caja-traduccion')));
      expect((caja.color, caja.borderRadius), (t.fondoSuperficieAlt, BorderRadius.circular(16)));
      expect(find.text(Textos.normaAplicable), findsOneWidget);
      expect(find.text('Licencia GPL-3.0, sección 5: obras derivadas'), findsOneWidget);
      final b = tester.widget<BotonApp>(find.byType(BotonApp));
      expect((b.texto, b.tipo), (Textos.volverALaTarjeta, TipoBoton.primario));
      esperarSoloColoresDelTema(tester, brillo);
    });

    for (final escala in [1.0, 2.0]) {
      testWidgets('normas largas sin desbordes al ${(escala * 100).toInt()} %', (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await montar(
          tester,
          panel(
            normas: [
              ...gpl.normas,
              'Ley de datos personales en posesión de particulares: consentimiento expreso y '
                  'por escrito para datos sensibles',
            ],
          ),
          escalaTexto: escala,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
