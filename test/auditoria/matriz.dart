import 'package:abogator/datos/modelos/ajustes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'ayudante_auditoria.dart';
import 'catalogo.dart';

/// Tamaños de la auditoría: dos teléfonos y la tablet en vertical y en
/// horizontal.
const tamanosAuditoria = <String, Size>{
  '360×640': Size(360, 640),
  '390×844': Size(390, 844),
  '834×1194': Size(834, 1194),
  '1194×834': Size(1194, 834),
};

/// Escalas de texto: 100 %, la mayor de Ajustes antes del tope (160 %) y el
/// tope (200 %).
const escalasAuditoria = [100, 160, 200];

/// Recorre [escenas] en todos los tamaños, temas y escalas y verifica en cada
/// combinación:
/// - sin desbordes ni excepciones de dibujo (cualquier error de Flutter hace
///   fallar la prueba);
/// - objetivos táctiles de Android (≥ 48) e iOS (≥ 44) con [ZonaTactilMinima];
/// - nombre accesible en todo lo que se toca;
/// - contraste de texto (con la guía de Flutter) en claro y oscuro.
void auditar(List<Escena> escenas) {
  for (final escena in escenas) {
    group(escena.nombre, () {
      for (final MapEntry(key: nombreTamano, value: tamano) in tamanosAuditoria.entries) {
        for (final oscuro in [false, true]) {
          for (final escala in escalasAuditoria) {
            final tema = oscuro ? 'oscuro' : 'claro';
            testWidgets('$nombreTamano · $tema · $escala %', (tester) async {
              final semantica = tester.ensureSemantics();
              final ajustes = Ajustes(
                modoTema: oscuro ? ThemeMode.dark : ThemeMode.light,
                escalaTexto: escala,
              );
              await escena.llegar(tester, ajustes, tamano);
              await expectLater(tester, meetsGuideline(ZonaTactilMinima.android));
              await expectLater(tester, meetsGuideline(ZonaTactilMinima.ios));
              await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
              await expectLater(tester, meetsGuideline(textContrastGuideline));
              await escena.alFinal?.call(tester);
              semantica.dispose();
              // Desmonta la app y deja correr lo pendiente (la doble vibración
              // del error, avisos con tiempo) para que no queden relojes.
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 5));
            });
          }
        }
      }
    });
  }
}
