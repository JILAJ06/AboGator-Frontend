import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/piezas_perfil.dart';
import 'package:abogator/componentes/piezas_tienda.dart';
import 'package:abogator/core/tema/iconos_app.dart';
import 'package:abogator/core/tema/tema_app.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../ayudantes/montar.dart';

/// Los controles exponen la acción de tocar al lector de pantalla (corrección
/// de la T-15e): con acción, el nodo la tiene y al usarla llama a
/// `alPresionar`; deshabilitados, no la tienen.
void main() {
  Future<void> probar(
    WidgetTester tester,
    Widget Function(VoidCallback? alPresionar) control,
    Finder nodo, {
    bool conDeshabilitado = true,
  }) async {
    final semantica = tester.ensureSemantics();
    var veces = 0;
    await montar(tester, SizedBox(width: 342, child: control(() => veces++)));
    final nodoSemantico = tester.getSemantics(nodo);
    expect(nodoSemantico.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    // Lo que hace el lector de pantalla con el doble toque.
    nodoSemantico.owner!.performAction(nodoSemantico.id, SemanticsAction.tap);
    await tester.pump();
    expect(veces, 1);
    if (conDeshabilitado) {
      await montar(tester, SizedBox(width: 342, child: control(null)));
      expect(tester.getSemantics(nodo).getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    }
    semantica.dispose();
  }

  testWidgets('BotonIconoCuadrado', (tester) async {
    await probar(
      tester,
      (accion) => BotonIconoCuadrado(
        icono: IconosApp.settings,
        etiqueta: 'Ajustes',
        alPresionar: accion ?? () {},
      ),
      find.bySemanticsLabel('Ajustes'),
      conDeshabilitado: false,
    );
    // Mismo aspecto: 48 × 48.
    await montar(
      tester,
      BotonIconoCuadrado(icono: IconosApp.settings, etiqueta: 'Ajustes', alPresionar: () {}),
    );
    expect(tester.getSize(find.byType(BotonIconoCuadrado)), const Size(48, 48));
  });

  testWidgets('FilaMenu', (tester) async {
    await probar(
      tester,
      (accion) => FilaMenu(icono: IconosApp.mail, texto: 'Correo', alPresionar: accion ?? () {}),
      find.bySemanticsLabel('Correo'),
      conDeshabilitado: false,
    );
  });

  testWidgets('FilaAjuste (con y sin interruptor)', (tester) async {
    await probar(
      tester,
      (accion) => FilaAjuste(
        titulo: 'Tema',
        detalle: 'Claro',
        etiquetaSemantica: 'Tema, claro',
        control: const SizedBox(width: 24, height: 24),
        alPresionar: accion,
      ),
      find.bySemanticsLabel('Tema, claro'),
    );
    await probar(
      tester,
      (accion) => FilaAjuste(
        titulo: 'Vibración',
        detalle: 'Al responder',
        etiquetaSemantica: 'Vibración',
        interruptor: true,
        control: const InterruptorApp(valor: true),
        alPresionar: accion,
      ),
      find.bySemanticsLabel('Vibración'),
    );
  });

  testWidgets('OpcionTamano', (tester) async {
    await probar(
      tester,
      (accion) => OpcionTamano(porcentaje: 120, elegida: false, alElegir: accion ?? () {}),
      find.byType(OpcionTamano),
      conDeshabilitado: false,
    );
  });

  testWidgets('BotonPrecio (y sin acción mientras compra)', (tester) async {
    await probar(
      tester,
      (accion) => BotonPrecio(precio: 50, etiquetaSemantica: 'Comprar', alPresionar: accion),
      find.byType(BotonPrecio),
    );
    final semantica = tester.ensureSemantics();
    // Con el indicador girando no se puede esperar a que se asiente.
    await tester.pumpWidget(
      MaterialApp(
        theme: crearTemaClaro(),
        home: Scaffold(
          body: Center(
            child: BotonPrecio(
              precio: 50,
              etiquetaSemantica: 'Comprar',
              alPresionar: () {},
              cargando: true,
            ),
          ),
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.byType(BotonPrecio))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    semantica.dispose();
  });
}
