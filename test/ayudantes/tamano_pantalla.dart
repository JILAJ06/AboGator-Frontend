import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
