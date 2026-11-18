import 'package:material_ui/material_ui.dart';

import '../tema/tipografia.dart';
import '../tema/tokens_color.dart';

/// Atajos para leer el tema desde un widget.
extension ExtensionesTema on BuildContext {
  /// Tokens de color del modo actual (claro u oscuro).
  TokensColor get tokens => Theme.of(this).extension<TokensColor>()!;

  /// Los 11 estilos de texto del diseño.
  EstilosTexto get estilos => Theme.of(this).extension<EstilosTexto>()!;

  /// `true` si el tema que se está mostrando es el oscuro.
  bool get esModoOscuro => Theme.of(this).brightness == Brightness.dark;
}
