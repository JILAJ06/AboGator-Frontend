import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Agarre de las hojas inferiores: 40 × 5, radio 3, borde/default (T-15b).
/// Es decorativo: no se anuncia. Lleva la clave `agarre`.
class AgarreHoja extends StatelessWidget {
  const AgarreHoja({super.key});

  static const Size tamano = Size(40, 5);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      key: const ValueKey('agarre'),
      width: tamano.width,
      height: tamano.height,
      decoration: BoxDecoration(
        color: context.tokens.bordeDefault,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}
