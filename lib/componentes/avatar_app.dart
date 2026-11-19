import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Avatar con iniciales: círculo de 44 en fondo/destacado con las iniciales
/// en Fredoka SemiBold 17/22 (estilo H3) y color accion/secundaria.
///
/// Es decorativo: el saludo de al lado ya dice el nombre.
class AvatarApp extends StatelessWidget {
  const AvatarApp({required this.iniciales, this.tamano = 44, super.key});

  final String iniciales;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey('circulo-avatar'),
        width: tamano,
        height: tamano,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: tokens.fondoDestacado, shape: BoxShape.circle),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            iniciales,
            style: context.estilos.h3.copyWith(color: tokens.accionSecundaria),
          ),
        ),
      ),
    );
  }
}
