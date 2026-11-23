import 'package:flutter_test/flutter_test.dart';

import 'sin_desbordes.dart';
import 'tamano_pantalla.dart';

/// Lo que ve cada prueba registrada: su nombre, la escala y el brillo.
String _visto(WidgetTester tester) {
  final p = tester.platformDispatcher;
  return '${tester.testDescription} · ${p.textScaleFactor} · ${p.platformBrightness.name}';
}

void main() {
  group('probarSinDesbordes', () {
    final vistos = <String>[];
    probarSinDesbordes(
      (tester, tamano, escala) async => vistos.add('${_visto(tester)} · $tamano · $escala'),
      grupo: null,
      ambosBrillos: true,
      prefijo: 'p ',
      texto: 'texto ',
    );

    testWidgets('registra los 6 casos por brillo con su escala, y la restaura', (tester) async {
      expect(vistos, hasLength(12));
      expect(vistos, contains('p 320×640 texto 2.0x dark · 2.0 · dark · Size(320.0, 640.0) · 2.0'));
      expect(
        vistos,
        contains('p 390×844 texto 1.0x light · 1.0 · light · Size(390.0, 844.0) · 1.0'),
      );
      expect(tester.platformDispatcher.textScaleFactor, 1);
    });
  });

  group('probarSinDesbordesTablet', () {
    final vistos = <String>[];
    probarSinDesbordesTablet(
      (tester, tamano) async => vistos.add('${_visto(tester)} · ${tamano.name}'),
      grupo: null,
      prefijo: 't ',
    );

    testWidgets('registra los 3 tamaños × 2 escalas × 2 brillos', (tester) async {
      expect(vistos, hasLength(12));
      expect(vistos, contains('t tabletMinima al 200 % (dark) · 2.0 · dark · tabletMinima'));
      expect(tester.platformDispatcher.textScaleFactor, 1);
    });
  });
}
