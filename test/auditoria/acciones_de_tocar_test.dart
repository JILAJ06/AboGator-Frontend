import 'dart:ui' show CheckedState, Tristate;

import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'catalogo.dart';
import 'matriz.dart';

/// Todo control con semántica de botón, enlace, casilla (`checked`: casillas,
/// opciones de justificación, selector de tamaño) o interruptor (`toggled`),
/// habilitado, visible y con etiqueta, expone la acción de tocar al lector de
/// pantalla (corrección de la T-15e; casillas e interruptores desde la T-15d). Recorre las mismas escenas de la auditoría en sus cuatro
/// tamaños; la semántica no cambia con el tema ni con la escala del texto.
void main() {
  final todas = <String, List<Escena>>{
    'acceso': escenasAcceso,
    'navegación': escenasNavegacion,
    'juego': escenasJuego,
    'buzón': escenasBuzon,
    'examen': escenasExamen,
    'cuenta': escenasCuenta,
  };
  for (final MapEntry(key: grupo, value: escenas) in todas.entries) {
    group(grupo, () {
      for (final escena in escenas) {
        for (final MapEntry(key: nombreTamano, value: tamano) in tamanosAuditoria.entries) {
          testWidgets('${escena.nombre} · $nombreTamano', (tester) async {
            final semantica = tester.ensureSemantics();
            await escena.llegar(tester, const Ajustes(), tamano);
            expect(controlesSinAccion(tester), isEmpty);
            await escena.alFinal?.call(tester);
            semantica.dispose();
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump(const Duration(seconds: 5));
          });
        }
      }
    });
  }
}

/// Etiquetas de los botones, enlaces, casillas e interruptores habilitados que
/// no tienen la acción de tocar.
List<String> controlesSinAccion(WidgetTester tester) {
  final faltan = <String>[];
  void visitar(SemanticsNode nodo) {
    final datos = nodo.getSemanticsData();
    final flags = datos.flagsCollection;
    final control =
        flags.isButton ||
        flags.isLink ||
        flags.isChecked != CheckedState.none ||
        flags.isToggled != Tristate.none;
    final deshabilitado = flags.isEnabled == Tristate.isFalse;
    if (control && !deshabilitado && !nodo.isInvisible && datos.label.trim().isNotEmpty) {
      if (!datos.hasAction(SemanticsAction.tap)) faltan.add(datos.label);
    }
    nodo.visitChildren((hijo) {
      visitar(hijo);
      return true;
    });
  }

  for (final vista in tester.binding.renderViews) {
    final raiz = vista.owner?.semanticsOwner?.rootSemanticsNode;
    if (raiz != null) visitar(raiz);
  }
  return faltan;
}
