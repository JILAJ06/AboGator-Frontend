import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_atras.dart';
import 'package:abogator/componentes/casilla_app.dart';
import 'package:abogator/componentes/chip_seleccion.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/core/recursos/imagenes_app.dart';
import 'package:abogator/core/tema/efectos.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/funciones/acceso/pantalla_registro.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/inicio/pantalla_inicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../ayudantes/tamano_pantalla.dart';
import 'ayudante_acceso.dart';

Finder get formulario => find.byKey(const ValueKey('formulario-tablet'));

Future<void> tocarVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('05 Inicio de sesión en tablet horizontal (T05)', () {
    testWidgets('panel de marca de 597 a la izquierda y columna de 470', (tester) async {
      await abrirEn(tester, Rutas.inicioSesion, tamano: Tamano.tabletHorizontal.medida);
      final panel = tester.getRect(find.byKey(const ValueKey('panel-marca')));
      expect(panel.left, 0);
      expect(panel.width, 597);
      expect(panel.height, 834);
      final columna = tester.getRect(formulario);
      expect(columna.width, 470);
      // Centrada en la mitad derecha (Figma x ≈ 661).
      expect(columna.left, closeTo(597 + (597 - 470) / 2, 0.5));
      // Todos los controles a todo el ancho de la columna.
      for (final texto in [Textos.botonIniciarSesion, Textos.botonCrearUnaCuenta]) {
        final boton = find.ancestor(of: find.text(texto), matching: find.byType(BotonApp));
        expect(tester.getSize(boton).width, closeTo(470, 0.5), reason: texto);
      }
    });

    testWidgets('el panel lleva el logo horizontal de 400, Sarko de 288, lema y círculo', (
      tester,
    ) async {
      await abrirEn(tester, Rutas.inicioSesion, tamano: Tamano.tabletHorizontal.medida);
      final logo = tester.widget<LogoApp>(find.byKey(const ValueKey('logo-panel-marca')));
      expect(logo.ancho, 400);
      expect(logo.tono, TonoLogo.sobreVerde);
      expect(tester.getSize(find.byKey(const ValueKey('sarko-panel-marca'))).width, 288);
      expect(find.text(Textos.lemaUnaLinea), findsOneWidget);
      final circulo = tester.getRect(find.byKey(const ValueKey('circulo-panel-marca')));
      expect(circulo.size, const Size(520, 520));
      expect(circulo.topLeft, const Offset(260, 388));
      // Sin la franja de tablet vertical ni el logo de móvil.
      expect(find.byKey(const ValueKey('franja-marca')), findsNothing);
      expect(find.byType(LogoApp), findsOneWidget);
    });

    testWidgets('el formulario funciona igual: errores, foco y envío con Enter', (tester) async {
      final repo = await abrirEn(
        tester,
        Rutas.inicioSesion,
        tamano: Tamano.tabletHorizontal.medida,
      );
      await tocarVisible(tester, find.text(Textos.botonIniciarSesion));
      expect(find.text(Textos.errorCorreo), findsOneWidget);
      expect(repo.llamadasInicio, isEmpty);

      await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana.dev@startup.mx');
      await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'Secreta123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(repo.llamadasInicio.single.correo, 'ana.dev@startup.mx');
      expect(contenedor(tester).read(sesionProvider), isNotNull);
      expect(find.byType(PantallaInicio), findsOneWidget);
      // Deja terminar las esperas de los mocks del Inicio.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('"Crear una cuenta" lleva al Registro', (tester) async {
      await abrirEn(tester, Rutas.inicioSesion, tamano: Tamano.tabletHorizontal.medida);
      await tocarVisible(tester, find.text(Textos.botonCrearUnaCuenta));
      expect(find.byType(PantallaRegistro), findsOneWidget);
    });
  });

  group('06 Registro en tablet horizontal (T06)', () {
    testWidgets('panel de registro, botón atrás y columna de 470', (tester) async {
      await abrirEn(tester, Rutas.registro, tamano: Tamano.tabletHorizontal.medida);
      expect(find.text(Textos.registroPanelFrase), findsOneWidget);
      expect(find.text(Textos.registroPanelTexto), findsOneWidget);
      final logo = tester.widget<LogoApp>(find.byKey(const ValueKey('logo-panel-marca')));
      expect(logo.ancho, 320);
      expect(tester.getSize(find.byKey(const ValueKey('sarko-panel-marca'))).width, 240);
      expect(
        tester.getRect(find.byKey(const ValueKey('circulo-panel-marca'))).topLeft,
        const Offset(-180, -152),
      );
      expect(tester.getSize(formulario).width, 470);
      // Botón atrás arriba, 4 antes de la columna (Figma x 657, y 48 − 32).
      final atras = tester.getRect(find.byType(BotonAtras));
      expect(atras.left, closeTo(tester.getRect(formulario).left - 4, 0.5));
      expect(atras.top, 16);
    });

    testWidgets('mantiene los dos consentimientos separados y sin marcar', (tester) async {
      final repo = await abrirEn(tester, Rutas.registro, tamano: Tamano.tabletHorizontal.medida);
      final casillas = tester.widgetList<CasillaApp>(find.byType(CasillaApp)).toList();
      expect(casillas.map((c) => c.texto), [Textos.aceptoAvisoPrivacidad, Textos.aceptoTerminos]);
      expect(casillas.any((c) => c.marcada), isFalse);

      await tester.tap(find.byType(ChipSeleccion).at(1));
      await tester.enterText(entradaDe(Textos.campoNombreRegistro), 'Ana López');
      await tester.enterText(entradaDe(Textos.campoCorreoInicio), 'ana.dev@startup.mx');
      await tester.enterText(entradaDe(Textos.campoContrasenaInicio), 'Secreta123');
      await tocarVisible(tester, find.text(Textos.aceptoAvisoPrivacidad));
      await tocarVisible(tester, find.text(Textos.botonCrearCuenta));
      // Falta Términos: no se envía.
      expect(repo.llamadasRegistro, isEmpty);
      expect(find.text(Textos.errorTerminos), findsOneWidget);
      await tocarVisible(tester, find.text(Textos.aceptoTerminos));
      await tocarVisible(tester, find.text(Textos.botonCrearCuenta));
      final envio = repo.llamadasRegistro.single;
      expect(envio.perfil, PerfilUsuario.desarrollador);
      expect(envio.aceptaAvisoPrivacidad, isTrue);
      expect(envio.aceptaTerminos, isTrue);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('el botón atrás vuelve al Inicio de sesión', (tester) async {
      await abrirEn(tester, Rutas.registro, tamano: Tamano.tabletHorizontal.medida);
      await tocarVisible(tester, find.byType(BotonAtras));
      expect(find.text(Textos.inicioSesionTitulo), findsOneWidget);
    });
  });

  group('tablet vertical', () {
    for (final ruta in [Rutas.inicioSesion, Rutas.registro]) {
      testWidgets('$ruta: franja de marca arriba y formulario de 470 debajo', (tester) async {
        await abrirEn(tester, ruta, tamano: Tamano.tabletVertical.medida);
        expect(find.byKey(const ValueKey('panel-marca')), findsNothing);
        final franja = tester.getRect(find.byKey(const ValueKey('franja-marca')));
        expect(franja.height, 240);
        expect(franja.width, 834);
        final columna = tester.getRect(formulario);
        expect(columna.width, 470);
        expect(columna.center.dx, closeTo(834 / 2, 0.5));
        expect(columna.top, greaterThanOrEqualTo(franja.bottom));
      });
    }
  });

  group('sin desbordes', () {
    for (final ruta in [Rutas.inicioSesion, Rutas.registro]) {
      probarSinDesbordesTablet(
        (tester, tamano) async {
          await abrirEn(tester, ruta, tamano: tamano.medida);
          expect(tester.takeException(), isNull);
          // El último control se alcanza desplazando la columna.
          final ultimo = ruta == Rutas.registro
              ? find.text(Textos.yaTienesCuenta)
              : find.text(Textos.notaSeguridad);
          await tester.ensureVisible(ultimo);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
        grupo: null,
        ambosBrillos: false,
        prefijo: '$ruta en ',
      );
    }
  });

  test('contraste del panel de marca (fijo en ambos modos)', () {
    final verde = TokensColor.claro.accionPrimaria;
    expect(
      Contraste.razon(TokensColor.claro.fondoDestacado, verde),
      greaterThanOrEqualTo(Contraste.minimoTexto),
    );
    expect(
      Contraste.razon(TokensColor.claro.textoEnPrimario, verde),
      greaterThanOrEqualTo(Contraste.minimoTexto),
    );
    // El círculo es decorativo y apenas aclara el verde: el lema sigue en AA encima.
    final circulo = Color.alphaBlend(EfectosApp.circuloPanelMarca, verde);
    expect(
      Contraste.razon(TokensColor.claro.fondoDestacado, circulo),
      greaterThanOrEqualTo(Contraste.minimoTexto),
    );
  });
}
