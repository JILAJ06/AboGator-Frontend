import 'package:material_ui/material_ui.dart';

/// Colores primitivos de la marca AboGator.
///
/// Son solo para usos decorativos (ilustraciones, acentos de marca).
/// Las pantallas deben usar los tokens de [TokensColor], que ya tienen
/// contraste AA en modo claro y oscuro.
abstract final class ColoresMarca {
  static const Color verdeBosqueGator = Color(0xFF1F4E35);
  static const Color azulMarinoLex = Color(0xFF0F294A);
  static const Color ambarMazo = Color(0xFFB86B23);
  static const Color verdeCircuitoTi = Color(0xFF68B678);
  static const Color verdeEscamaSarko = Color(0xFF506F52);
  static const Color cremaVentral = Color(0xFFE8D8A8);
  static const Color rojoVeredicto = Color(0xFFB52426);
  static const Color azulSastreOscuro = Color(0xFF222A35);
  static const Color blancoPuro = Color(0xFFFFFFFF);
  static const Color legalAcierto = Color(0xFF1E7B4A);
  static const Color ambarTexto = Color(0xFF8A4F17);
  static const Color neutro50 = Color(0xFFF8FAFC);
  static const Color neutro500 = Color(0xFF64748B);
  static const Color fondoOscuro = Color(0xFF0B1220);
  static const Color superficieOscura = Color(0xFF162030);
}

/// Color propio de cada uno de los 5 módulos.
abstract final class ColoresModulo {
  static const Color proteccionDeDatos = Color(0xFF2B5FA8);
  static const Color licenciasYPropiedadIntelectual = Color(0xFFB86B23);
  static const Color delitosInformaticos = Color(0xFF6B4BA1);
  static const Color contratosDigitales = Color(0xFF1F4E35);
  static const Color auditoriaYCumplimiento = Color(0xFF1B7F86);

  /// Colores en el orden de los módulos (1 a 5).
  static const List<Color> enOrden = [
    proteccionDeDatos,
    licenciasYPropiedadIntelectual,
    delitosInformaticos,
    contratosDigitales,
    auditoriaYCumplimiento,
  ];
}
