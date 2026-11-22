import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';

/// Enlace de texto: Cuerpo/Énfasis en texto/acento, zona táctil ≥ 48 de alto,
/// anillo de foco y semántica de enlace.
class EnlaceTexto extends StatelessWidget {
  const EnlaceTexto({required this.texto, required this.alPresionar, super.key});

  final String texto;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    return AccionEnfocable.boton(
      alPresionar: alPresionar,
      radio: 8,
      etiqueta: texto,
      enlace: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            texto,
            style: context.estilos.cuerpoEnfasis.copyWith(color: context.tokens.textoAcento),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
