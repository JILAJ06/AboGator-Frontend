import 'package:abogator/componentes/campo_texto_app.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

Border bordeCaja(WidgetTester tester) {
  final caja = tester
      .widgetList<DecoratedBox>(
        find.descendant(of: find.byType(CampoTextoApp), matching: find.byType(DecoratedBox)),
      )
      .map((d) => d.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((d) => d.border != null);
  return caja.border! as Border;
}

void main() {
  enAmbosModos('reposo: borde 1.5 borde/control y etiqueta visible', (tester, brillo) async {
    await montar(
      tester,
      const CampoTextoApp(
        etiqueta: 'Correo electrónico',
        textoAyuda: 'tu@correo.com',
        iconoInicio: IconosApp.mail,
      ),
      brillo: brillo,
    );
    final borde = bordeCaja(tester).top;
    expect(borde.color, tokensDe(brillo).bordeControl);
    expect(borde.width, 1.5);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('tu@correo.com'), findsOneWidget);
    esperarSoloColoresDelTema(tester, brillo);
  });

  enAmbosModos('foco: borde 2 accion/primaria', (tester, brillo) async {
    await montar(tester, const CampoTextoApp(etiqueta: 'Nombre'), brillo: brillo);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final borde = bordeCaja(tester).top;
    expect(borde.color, tokensDe(brillo).accionPrimaria);
    expect(borde.width, 2);
  });

  enAmbosModos('error: borde 2 estado/ilegal y mensaje en Leyenda', (tester, brillo) async {
    await montar(
      tester,
      const CampoTextoApp(etiqueta: 'Correo', error: 'Ingresa un correo válido'),
      brillo: brillo,
    );
    final t = tokensDe(brillo);
    expect(bordeCaja(tester).top.color, t.estadoIlegal);
    expect(bordeCaja(tester).top.width, 2);
    final mensaje = tester.widget<Text>(find.text('Ingresa un correo válido'));
    expect(mensaje.style!.color, t.estadoIlegal);
    expect(mensaje.style!.fontSize, 11);
    esperarSoloColoresDelTema(tester, brillo);
  });

  testWidgets('la caja mide 52 de alto en reposo, foco y error', (tester) async {
    final caja = find.byKey(const ValueKey('caja-campo'));
    await montar(tester, const CampoTextoApp(etiqueta: 'Nombre'));
    expect(tester.getSize(caja).height, CampoTextoApp.altoCaja);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.getSize(caja).height, CampoTextoApp.altoCaja);
    await montar(tester, const CampoTextoApp(etiqueta: 'Nombre', error: 'Error'));
    expect(tester.getSize(caja).height, CampoTextoApp.altoCaja);
  });

  testWidgets('contraseña: se oculta y el botón la muestra', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(tester, const CampoTextoApp(etiqueta: 'Contraseña', tipo: TipoCampo.contrasena));
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    final boton = find.bySemanticsLabel(Textos.mostrarContrasena);
    expect(boton, findsOneWidget);
    expect(tester.getSize(boton).height, greaterThanOrEqualTo(48));
    await tester.tap(boton);
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    expect(find.bySemanticsLabel(Textos.ocultarContrasena), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('el tipo define el teclado', (tester) async {
    await montar(tester, const CampoTextoApp(etiqueta: 'Correo', tipo: TipoCampo.correo));
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.keyboardType, TextInputType.emailAddress);
    expect(campo.autofillHints, [AutofillHints.email]);
  });

  testWidgets('semántica: la etiqueta se asocia al campo y el error se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    await montar(
      tester,
      const CampoTextoApp(etiqueta: 'Correo electrónico', error: 'Ingresa un correo válido'),
    );
    expect(
      tester.getSemantics(find.byType(TextField)),
      isSemantics(label: 'Correo electrónico', isTextField: true),
    );
    expect(
      tester.getSemantics(find.text('Ingresa un correo válido')),
      isSemantics(label: 'Ingresa un correo válido', isLiveRegion: true),
    );
    semantica.dispose();
  });
}
