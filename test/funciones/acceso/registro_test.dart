import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/casilla_app.dart';
import 'package:abogator/componentes/chip_seleccion.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/funciones/acceso/pantalla_inicio_sesion.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_acceso.dart';

Future<void> tocarCrear(WidgetTester tester) async {
  await tester.ensureVisible(find.text(Textos.botonCrearCuenta));
  await tester.tap(find.text(Textos.botonCrearCuenta));
  await tester.pumpAndSettle();
}

Future<void> llenarCampos(
  WidgetTester tester, {
  String nombre = 'Ana López',
  String correo = 'ana.dev@startup.mx',
  String contrasena = 'Secreta123',
}) async {
  await tester.enterText(entradaDe(Textos.campoNombreRegistro), nombre);
  await tester.enterText(entradaDe(Textos.campoCorreoInicio), correo);
  await tester.enterText(entradaDe(Textos.campoContrasenaInicio), contrasena);
}

Future<void> tocarCasilla(WidgetTester tester, String texto) async {
  await tester.ensureVisible(find.text(texto));
  await tester.tap(find.text(texto));
  await tester.pump();
}

List<CasillaApp> casillas(WidgetTester tester) =>
    tester.widgetList<CasillaApp>(find.byType(CasillaApp)).toList();

void main() {
  testWidgets('al abrir: campos vacíos, sin perfil y casillas sin marcar', (tester) async {
    await abrirEn(tester, Rutas.registro);
    expect(find.text(Textos.registroTitulo), findsOneWidget);
    expect(find.text(Textos.registroSubtitulo), findsOneWidget);
    final chips = tester.widgetList<ChipSeleccion>(find.byType(ChipSeleccion)).toList();
    expect(chips.map((c) => c.texto), [
      Textos.perfilEstudianteVisible,
      Textos.perfilDesarrolladorVisible,
      Textos.perfilLegalVisible,
    ]);
    expect(chips.any((c) => c.seleccionado), isFalse);
    expect(casillas(tester).map((c) => c.texto), [
      Textos.aceptoAvisoPrivacidad,
      Textos.aceptoTerminos,
    ]);
    expect(casillas(tester).any((c) => c.marcada), isFalse);
    for (final editable in tester.widgetList<EditableText>(find.byType(EditableText))) {
      expect(editable.controller.text, isEmpty);
    }
  });

  testWidgets('los perfiles se anuncian sin emoji y la selección es única', (tester) async {
    final semantica = tester.ensureSemantics();
    await abrirEn(tester, Rutas.registro);
    expect(find.bySemanticsLabel('Perfil Estudiante, 1 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Perfil Desarrollador, 2 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Perfil Legal, 3 de 3'), findsOneWidget);
    await tester.tap(find.text(Textos.perfilDesarrolladorVisible));
    await tester.pump();
    await tester.tap(find.text(Textos.perfilLegalVisible));
    await tester.pump();
    final seleccionados = tester
        .widgetList<ChipSeleccion>(find.byType(ChipSeleccion))
        .where((c) => c.seleccionado);
    expect(seleccionados.single.texto, Textos.perfilLegalVisible);
    semantica.dispose();
  });

  testWidgets('al enviar vacío muestra todos los errores y enfoca el perfil', (tester) async {
    final repo = await abrirEn(tester, Rutas.registro);
    await tocarCrear(tester);
    for (final error in [
      Textos.errorPerfil,
      Textos.errorNombre,
      Textos.errorCorreo,
      Textos.errorContrasenaRegistro,
      Textos.errorAvisoPrivacidad,
      Textos.errorTerminos,
    ]) {
      expect(find.text(error), findsOneWidget, reason: error);
    }
    expect(enfocadoDentroDe<ChipSeleccion>()?.texto, Textos.perfilEstudianteVisible);
    expect(repo.llamadasRegistro, isEmpty);
  });

  testWidgets('las dos casillas son independientes y el foco va a la que falta', (tester) async {
    final repo = await abrirEn(tester, Rutas.registro);
    await tester.tap(find.text(Textos.perfilDesarrolladorVisible));
    await llenarCampos(tester);
    await tocarCasilla(tester, Textos.aceptoAvisoPrivacidad);
    expect(casillas(tester).map((c) => c.marcada), [true, false]);

    await tocarCrear(tester);
    expect(find.text(Textos.errorAvisoPrivacidad), findsNothing);
    expect(find.text(Textos.errorTerminos), findsOneWidget);
    expect(enfocadoDentroDe<CasillaApp>()?.texto, Textos.aceptoTerminos);
    expect(repo.llamadasRegistro, isEmpty);

    // Y al revés: solo términos.
    await tocarCasilla(tester, Textos.aceptoAvisoPrivacidad);
    await tocarCasilla(tester, Textos.aceptoTerminos);
    expect(casillas(tester).map((c) => c.marcada), [false, true]);
    await tocarCrear(tester);
    expect(find.text(Textos.errorAvisoPrivacidad), findsOneWidget);
    expect(find.text(Textos.errorTerminos), findsNothing);
    expect(enfocadoDentroDe<CasillaApp>()?.texto, Textos.aceptoAvisoPrivacidad);
  });

  testWidgets('contraseña sin número: mensaje exacto y foco en la contraseña', (tester) async {
    await abrirEn(tester, Rutas.registro);
    await tester.tap(find.text(Textos.perfilEstudianteVisible));
    await llenarCampos(tester, contrasena: 'abcdefgh');
    await tocarCasilla(tester, Textos.aceptoAvisoPrivacidad);
    await tocarCasilla(tester, Textos.aceptoTerminos);
    await tocarCrear(tester);
    expect(find.text('Mínimo 8 caracteres, incluye un número'), findsOneWidget);
    final enfocado = FocusManager.instance.primaryFocus!.context!;
    expect(
      find.descendant(
        of: campo(Textos.campoContrasenaInicio),
        matching: find.byElementPredicate((e) => e == enfocado),
      ),
      findsOneWidget,
    );
  });

  testWidgets('éxito: envía los datos recortados y los dos consentimientos por separado', (
    tester,
  ) async {
    final repo = await abrirEn(tester, Rutas.registro);
    await tester.tap(find.text(Textos.perfilLegalVisible));
    await llenarCampos(tester, nombre: '  Ana López ', correo: ' ana.dev@startup.mx ');
    await tocarCasilla(tester, Textos.aceptoAvisoPrivacidad);
    await tocarCasilla(tester, Textos.aceptoTerminos);
    await tocarCrear(tester);
    final llamada = repo.llamadasRegistro.single;
    expect(llamada.nombre, 'Ana López');
    expect(llamada.correo, 'ana.dev@startup.mx');
    expect(llamada.perfil, PerfilUsuario.legal);
    expect(llamada.aceptaAvisoPrivacidad, isTrue);
    expect(llamada.aceptaTerminos, isTrue);
    expect(find.text(Textos.pendienteInicio), findsOneWidget);
    expect(contenedor(tester).read(sesionProvider), isNotNull);
  });

  testWidgets('el botón atrás y el enlace regresan al inicio de sesión', (tester) async {
    await abrirEn(tester, Rutas.registro);
    await tester.tap(find.bySemanticsLabel(Textos.atras));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaInicioSesion), findsOneWidget);

    irA(tester, Rutas.registro);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Textos.yaTienesCuenta));
    await tester.tap(find.text(Textos.yaTienesCuenta));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaInicioSesion), findsOneWidget);
  });

  testWidgets('la contraseña no aparece en ningún texto semántico', (tester) async {
    final semantica = tester.ensureSemantics();
    await abrirEn(tester, Rutas.registro);
    await llenarCampos(tester);
    await tocarCrear(tester);
    expect(textosSemanticos(tester).where((t) => t.contains('Secreta123')), isEmpty);
    semantica.dispose();
  });

  group('sin desbordes con texto al 200 %', () {
    for (final tamano in [const Size(390, 844), const Size(360, 640)]) {
      for (final brillo in Brightness.values) {
        testWidgets('${tamano.width.toInt()}×${tamano.height.toInt()} ${brillo.name}', (
          tester,
        ) async {
          conTextoGrandeYModo(tester, brillo);
          await abrirEn(tester, Rutas.registro, tamano: tamano);
          expect(tester.takeException(), isNull);
          await tocarCrear(tester);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text(Textos.yaTienesCuenta));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
