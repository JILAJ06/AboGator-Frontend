import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Describe el control con el foco: la clave (`ValueKey`) o la etiqueta
/// semántica del ancestro más cercano que la tenga.
String describirFoco(FocusNode? nodo) {
  final contexto = nodo?.context;
  if (contexto == null) return 'sin foco';
  String? descripcion;
  (contexto as Element).visitAncestorElements((e) {
    final w = e.widget;
    if (w.key is ValueKey) {
      descripcion = '${(w.key! as ValueKey).value}';
      return false;
    }
    if (w is Semantics && w.properties.label != null) {
      descripcion = 'sem:${w.properties.label}';
      return false;
    }
    return true;
  });
  return descripcion ?? contexto.widget.runtimeType.toString();
}

/// Pulsa Tab [veces] y devuelve qué recibió el foco en cada paso.
Future<List<String>> recorrerConTab(WidgetTester tester, int veces, {bool atras = false}) async {
  final orden = <String>[];
  for (var i = 0; i < veces; i++) {
    if (atras) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    } else {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    await tester.pump();
    orden.add(describirFoco(FocusManager.instance.primaryFocus));
  }
  return orden;
}

/// Si el foco está en [f] o dentro de él.
bool enfocadoDentroDe(Finder f) {
  final contexto = FocusManager.instance.primaryFocus?.context;
  if (contexto == null) return false;
  final objetivo = f.evaluate().toSet();
  if (objetivo.contains(contexto)) return true;
  var dentro = false;
  (contexto as Element).visitAncestorElements((e) {
    if (objetivo.contains(e)) {
      dentro = true;
      return false;
    }
    return true;
  });
  return dentro;
}

/// Guarda los anuncios del lector de pantalla (`SemanticsService.sendAnnouncement`).
List<String> capturarAnuncios(WidgetTester tester) {
  final anuncios = <String>[];
  tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
    SystemChannels.accessibility,
    (mensaje) async {
      final datos = (mensaje as Map)['data'] as Map;
      final texto = datos['message'];
      if (texto is String) anuncios.add(texto);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      null,
    ),
  );
  return anuncios;
}
