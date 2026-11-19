import 'dart:async';

import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_autenticacion.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const usuarioPrueba = Usuario(
  id: 'u-1',
  nombre: 'Ana López',
  correo: 'ana.dev@startup.mx',
  perfil: PerfilUsuario.desarrollador,
  nivel: 1,
  xp: 0,
  racha: 0,
);

/// Repositorio falso: registra lo que recibe y permite controlar la respuesta.
class AutenticacionFalsa implements RepositorioAutenticacion {
  Completer<Usuario>? pendiente;
  String? errorARegresar;
  final llamadasInicio = <({String correo, String contrasena})>[];
  final llamadasRegistro =
      <
        ({
          String nombre,
          String correo,
          PerfilUsuario perfil,
          bool aceptaAvisoPrivacidad,
          bool aceptaTerminos,
        })
      >[];

  Future<Usuario> _responder() {
    if (errorARegresar != null) {
      return Future.error(ExcepcionAutenticacion(errorARegresar!));
    }
    return pendiente?.future ?? Future.value(usuarioPrueba);
  }

  @override
  Future<Usuario> iniciarSesion({required String correo, required String contrasena}) {
    llamadasInicio.add((correo: correo, contrasena: contrasena));
    return _responder();
  }

  @override
  Future<Usuario> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required PerfilUsuario perfil,
    required bool aceptaAvisoPrivacidad,
    required bool aceptaTerminos,
  }) {
    llamadasRegistro.add((
      nombre: nombre,
      correo: correo,
      perfil: perfil,
      aceptaAvisoPrivacidad: aceptaAvisoPrivacidad,
      aceptaTerminos: aceptaTerminos,
    ));
    return _responder();
  }

  @override
  Future<Usuario?> usuarioActual() async => null;

  @override
  Future<void> cerrarSesion() async {}
}

/// Monta la app y abre [ruta] directamente.
Future<AutenticacionFalsa> abrirEn(
  WidgetTester tester,
  String ruta, {
  Size tamano = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repo = AutenticacionFalsa();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioAutenticacionProvider.overrideWithValue(repo),
        repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria(vistoAlInicio: true)),
      ],
      child: const AppAbogator(),
    ),
  );
  irA(tester, ruta);
  await tester.pumpAndSettle();
  return repo;
}

void irA(WidgetTester tester, String ruta) {
  ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
      .read(enrutadorProvider)
      .go(ruta);
}

ProviderContainer contenedor(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));

/// Campo de texto por su etiqueta visible.
Finder campo(String etiqueta) => find.ancestor(
  of: find.text(etiqueta),
  matching: find.byWidgetPredicate((w) => w.runtimeType.toString() == 'CampoTextoApp'),
);

Finder entradaDe(String etiqueta) =>
    find.descendant(of: campo(etiqueta), matching: find.byType(EditableText));

/// Primer ancestro de tipo [T] del nodo con foco, o `null`.
T? enfocadoDentroDe<T extends Widget>() =>
    FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<T>();

/// Todos los textos que expone el árbol semántico (etiquetas, valores y pistas).
List<String> textosSemanticos(WidgetTester tester) {
  final textos = <String>[];
  void visitar(SemanticsNode nodo) {
    textos
      ..add(nodo.label)
      ..add(nodo.value)
      ..add(nodo.hint);
    nodo.visitChildren((hijo) {
      visitar(hijo);
      return true;
    });
  }

  visitar(tester.getSemantics(find.byType(Scaffold).first));
  return textos;
}

void conTextoGrandeYModo(WidgetTester tester, Brightness brillo) {
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}
