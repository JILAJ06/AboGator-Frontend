import 'dart:async';

import 'package:abogator/app/pantalla_pendiente.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/campo_texto_app.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/core/recursos/imagenes_app.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/funciones/acceso/aviso_error.dart';
import 'package:abogator/funciones/acceso/pantalla_registro.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_acceso.dart';

Future<void> tocarIniciar(WidgetTester tester) async {
  await tester.tap(find.text(Textos.botonIniciarSesion));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra logo horizontal, título, subtítulo, formulario y nota', (tester) async {
    await abrirEn(tester, Rutas.inicioSesion);
    final logo = tester.widget<LogoApp>(find.byType(LogoApp));
    expect(logo.forma, FormaLogo.horizontal);
    expect(tester.getSize(find.byType(LogoApp)).width, closeTo(306.9, 0.01));
    expect(tester.getSize(find.byType(LogoApp)).height, closeTo(74.4, 0.1));
    for (final texto in [
      Textos.inicioSesionTitulo,
      Textos.inicioSesionSubtitulo,
      Textos.campoCorreoInicio,
      Textos.campoContrasenaInicio,
      Textos.olvidasteContrasena,
      Textos.botonIniciarSesion,
      Textos.separadorO,
      Textos.botonCrearUnaCuenta,
      Textos.notaSeguridad,
    ]) {
      expect(find.text(texto), findsOneWidget, reason: texto);
    }
    final contrasena = tester.widget<TextField>(
      find.descendant(of: campo(Textos.campoContrasenaInicio), matching: find.byType(TextField)),
    );
    expect(contrasena.obscureText, isTrue);
    expect(contrasena.autofillHints, [AutofillHints.password]);
    final correo = tester.widget<TextField>(
      find.descendant(of: campo(Textos.campoCorreoInicio), matching: find.byType(TextField)),
    );
    expect(correo.keyboardType, TextInputType.emailAddress);
    expect(correo.autocorrect, isFalse);
  });

  testWidgets('al enviar vacío muestra los errores y enfoca el correo', (tester) async {
    final repo = await abrirEn(tester, Rutas.inicioSesion);
    await tocarIniciar(tester);
    expect(find.text(Textos.errorCorreo), findsOneWidget);
    expect(find.text(Textos.errorContrasenaVacia), findsOneWidget);
    expect(enfocadoDentroDe<CampoTextoApp>()?.etiqueta, Textos.campoCorreoInicio);
    expect(repo.llamadasInicio, isEmpty);
  });

  testWidgets('correo inválido muestra su error y editar lo limpia', (tester) async {
    await abrirEn(tester, Rutas.inicioSesion);
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana@');
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'x');
    await tocarIniciar(tester);
    expect(find.text(Textos.errorCorreo), findsOneWidget);
    expect(find.text(Textos.errorContrasenaVacia), findsNothing);
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana@startup.mx');
    await tester.pump();
    expect(find.text(Textos.errorCorreo), findsNothing);
  });

  testWidgets('mientras envía: progreso, deshabilitado y anuncio; luego va al Inicio', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    final repo = await abrirEn(tester, Rutas.inicioSesion);
    repo.pendiente = Completer();
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), '  ana.dev@startup.mx ');
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'Secreta123');
    await tester.tap(find.text(Textos.botonIniciarSesion));
    await tester.pump();

    expect(find.byKey(const ValueKey('progreso-boton')), findsOneWidget);
    expect(find.bySemanticsLabel(Textos.iniciandoSesion), findsOneWidget);
    expect(repo.llamadasInicio.single.correo, 'ana.dev@startup.mx');

    // Un segundo toque mientras carga no envía otra vez.
    await tester.tap(find.byKey(const ValueKey('progreso-boton')));
    await tester.pump();
    expect(repo.llamadasInicio, hasLength(1));

    repo.pendiente!.complete(usuarioPrueba);
    await tester.pumpAndSettle();
    expect(find.byType(PantallaPendiente), findsOneWidget);
    expect(find.text(Textos.pendienteInicio), findsOneWidget);
    expect(contenedor(tester).read(sesionProvider)?.nombre, usuarioPrueba.nombre);
    semantica.dispose();
  });

  testWidgets('el error del repositorio aparece arriba del botón y se anuncia', (tester) async {
    final semantica = tester.ensureSemantics();
    final repo = await abrirEn(tester, Rutas.inicioSesion);
    repo.errorARegresar = Textos.errorCredenciales;
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana@startup.mx');
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'mala');
    await tocarIniciar(tester);
    expect(find.byType(AvisoError), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(AvisoError)),
      isSemantics(label: Textos.errorCredenciales, isLiveRegion: true),
    );
    expect(
      tester.getTopLeft(find.byType(AvisoError)).dy,
      lessThan(tester.getTopLeft(find.text(Textos.botonIniciarSesion)).dy),
    );
    expect(contenedor(tester).read(sesionProvider), isNull);
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'otra');
    await tester.pump();
    expect(find.byType(AvisoError), findsNothing);
    semantica.dispose();
  });

  testWidgets('Enter en la contraseña envía el formulario', (tester) async {
    final repo = await abrirEn(tester, Rutas.inicioSesion);
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana@startup.mx');
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'Secreta123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repo.llamadasInicio, hasLength(1));
    expect(find.text(Textos.pendienteInicio), findsOneWidget);
  });

  testWidgets('"Crear una cuenta" lleva al registro', (tester) async {
    await abrirEn(tester, Rutas.inicioSesion);
    await tester.ensureVisible(find.text(Textos.botonCrearUnaCuenta));
    await tester.tap(find.text(Textos.botonCrearUnaCuenta));
    await tester.pumpAndSettle();
    expect(find.byType(PantallaRegistro), findsOneWidget);
  });

  testWidgets('"¿Olvidaste tu contraseña?" muestra un aviso breve', (tester) async {
    await abrirEn(tester, Rutas.inicioSesion);
    await tester.tap(find.text(Textos.olvidasteContrasena));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(Textos.recuperacionPronto), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('la contraseña no aparece en ningún texto semántico', (tester) async {
    final semantica = tester.ensureSemantics();
    final repo = await abrirEn(tester, Rutas.inicioSesion);
    repo.errorARegresar = Textos.errorCredenciales;
    await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana@startup.mx');
    await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'Secreta123');
    await tester.pump();
    expect(textosSemanticos(tester).where((t) => t.contains('Secreta123')), isEmpty);
    // También con la contraseña visible el texto queda dentro del campo, no en etiquetas.
    await tocarIniciar(tester);
    expect(
      textosSemanticos(tester).where((t) => t.contains('Secreta123') && t != 'Secreta123'),
      isEmpty,
    );
    semantica.dispose();
  });

  testWidgets('el orden de foco con teclado sigue el orden visual', (tester) async {
    await abrirEn(tester, Rutas.inicioSesion);
    final etiquetas = <String>[];
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final campoEnfocado = enfocadoDentroDe<CampoTextoApp>();
      etiquetas.add(campoEnfocado?.etiqueta ?? 'otro');
    }
    expect(etiquetas.take(2), [Textos.campoCorreoInicio, Textos.campoContrasenaInicio]);
  });

  group('sin desbordes con texto al 200 %', () {
    for (final tamano in [const Size(390, 844), const Size(360, 640)]) {
      for (final brillo in Brightness.values) {
        testWidgets('${tamano.width.toInt()}×${tamano.height.toInt()} ${brillo.name}', (
          tester,
        ) async {
          conTextoGrandeYModo(tester, brillo);
          final repo = await abrirEn(tester, Rutas.inicioSesion, tamano: tamano);
          expect(tester.takeException(), isNull);
          repo.errorARegresar = Textos.errorCredenciales;
          await tester.ensureVisible(find.text(Textos.botonIniciarSesion));
          await tocarIniciar(tester);
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.text(Textos.notaSeguridad));
          await tester.pumpAndSettle();
          expect(find.text(Textos.notaSeguridad), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  test('PerfilUsuario sigue igual para el registro', () {
    expect(PerfilUsuario.values, hasLength(3));
  });
}
