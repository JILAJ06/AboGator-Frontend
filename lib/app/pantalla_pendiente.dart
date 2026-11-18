import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Marcador temporal para una pantalla que llega en otra tarea.
class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente({required this.texto, super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              texto,
              style: context.estilos.h2.copyWith(color: context.tokens.textoSecundario),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
