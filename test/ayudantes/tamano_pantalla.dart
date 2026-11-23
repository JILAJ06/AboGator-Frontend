import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'sin_desbordes.dart';

/// Tamaños de pantalla de referencia para las pruebas de tablet (T-12 a T-12d).
enum Tamano {
  /// iPad 11" en horizontal, como el lienzo de Figma (sin barra de estado).
  tabletHorizontal(Size(1194, 834)),

  /// iPad 11" en vertical: riel y una sola columna.
  tabletVertical(Size(834, 1194)),

  /// El tablet más angosto (ventana de 600): riel y una columna.
  tabletMinima(Size(600, 960)),

  /// El teléfono del diseño móvil.
  movil(Size(390, 844));

  const Tamano(this.medida);

  final Size medida;
}

/// Fija el tamaño lógico de la pantalla de prueba y lo restaura al terminar.
Future<void> tamanoPantalla(WidgetTester tester, Tamano tamano) =>
    tamanoPantallaDe(tester, tamano.medida);

/// Igual que [tamanoPantalla] con un tamaño cualquiera.
Future<void> tamanoPantallaDe(WidgetTester tester, Size medida) async {
  await tester.binding.setSurfaceSize(medida);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Los tres tamaños de tablet (sin el móvil).
const tamanosTablet = [Tamano.tabletHorizontal, Tamano.tabletVertical, Tamano.tabletMinima];

/// Registra una prueba por tamaño de tablet, por escala del texto (1.0 y 2.0)
/// y, con [ambosBrillos], por brillo. Cada una fija la escala y el brillo y
/// luego corre [cuerpo]. Con [grupo] las agrupa; con `grupo: null` las deja en
/// el grupo actual.
///
/// Nombre: `'${prefijo}tabletHorizontal al 200 % (dark)'`; sin [ambosBrillos],
/// sin el paréntesis.
void probarSinDesbordesTablet(
  Future<void> Function(WidgetTester tester, Tamano tamano) cuerpo, {
  String? grupo = 'sin desbordes',
  bool ambosBrillos = true,
  String prefijo = '',
}) {
  void registrar() {
    for (final tamano in tamanosTablet) {
      for (final escala in [1.0, 2.0]) {
        for (final brillo in ambosBrillos ? Brightness.values : const [null]) {
          final sufijo = brillo == null ? '' : ' (${brillo.name})';
          testWidgets('$prefijo${tamano.name} al ${(escala * 100).round()} %$sufijo', (
            tester,
          ) async {
            fijarTextoYBrillo(tester, escala, brillo);
            await cuerpo(tester, tamano);
          });
        }
      }
    }
  }

  if (grupo == null) {
    registrar();
  } else {
    group(grupo, registrar);
  }
}
