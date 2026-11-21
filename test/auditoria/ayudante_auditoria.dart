import 'dart:async';
import 'dart:ui' show FlutterView, SemanticsAction;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/rendering.dart' show MatrixUtils, SemanticsNode;
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

/// Zona táctil mínima (como `androidTapTargetGuideline` e
/// `iOSTapTargetGuideline` de Flutter) que omite, igual que la original, los
/// controles cortados por el borde de su contenedor desplazable.
///
/// Diferencia con la de Flutter: compara el rectángulo del control con el del
/// desplazable **en el mismo sistema de coordenadas** (la original le aplica
/// antes la transformación del desplazable, así que no reconoce el recorte
/// cuando el desplazable no empieza en el origen de su padre, como el mapa
/// de sprints bajo su encabezado fijo). Todo lo que se ve completo se mide
/// igual.
class ZonaTactilMinima extends AccessibilityGuideline {
  const ZonaTactilMinima({required this.tamano, required this.enlace});

  /// Android: 48 × 48.
  static const android = ZonaTactilMinima(
    tamano: Size(48, 48),
    enlace: 'https://support.google.com/accessibility/android/answer/7101858',
  );

  /// iOS: 44 × 44.
  static const ios = ZonaTactilMinima(
    tamano: Size(44, 44),
    enlace: 'https://developer.apple.com/design/human-interface-guidelines/accessibility',
  );

  final Size tamano;
  final String enlace;

  static const double _holgura = 0.001;

  @override
  String get description => 'Los controles tocables miden al menos $tamano';

  @override
  FutureOr<Evaluation> evaluate(WidgetTester tester) {
    var resultado = const Evaluation.pass();
    for (final vista in tester.binding.renderViews) {
      resultado += _recorrer(vista.flutterView, vista.owner!.semanticsOwner!.rootSemanticsNode!);
    }
    return resultado;
  }

  Evaluation _recorrer(FlutterView vista, SemanticsNode nodo) {
    var resultado = const Evaluation.pass();
    nodo.visitChildren((hijo) {
      resultado += _recorrer(vista, hijo);
      return true;
    });
    if (nodo.isMergedIntoParent) return resultado;
    final datos = nodo.getSemanticsData();
    final tocable =
        datos.hasAction(SemanticsAction.tap) || datos.hasAction(SemanticsAction.longPress);
    if (!tocable || datos.flagsCollection.isHidden || datos.flagsCollection.isLink) {
      return resultado;
    }
    var limites = nodo.rect;
    SemanticsNode? actual = nodo;
    while (actual != null) {
      // Aquí `limites` está en el sistema de `actual` (como su `rect`).
      if (!identical(actual, nodo) &&
          actual.flagsCollection.hasImplicitScrolling &&
          _enElBorde(limites, actual.rect)) {
        return resultado;
      }
      final transformacion = actual.transform;
      if (transformacion != null) limites = MatrixUtils.transformRect(transformacion, limites);
      actual = actual.parent;
    }
    if (_enElBorde(limites, Offset.zero & vista.physicalSize)) return resultado;
    final medida = limites.size / vista.devicePixelRatio;
    if (medida.width < tamano.width - precisionErrorTolerance ||
        medida.height < tamano.height - precisionErrorTolerance) {
      resultado += Evaluation.fail(
        '$nodo: se esperaba al menos $tamano y mide $medida\nVer: $enlace',
      );
    }
    return resultado;
  }

  static bool _enElBorde(Rect hijo, Rect padre) =>
      hijo.left - padre.left <= _holgura ||
      padre.right - hijo.right <= _holgura ||
      hijo.top - padre.top <= _holgura ||
      padre.bottom - hijo.bottom <= _holgura;
}
