import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../componentes/boton_cerrar.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Marcador temporal para una pantalla que llega en otra tarea o aún no tiene
/// diseño. Con [conVolver], un botón "Atrás" arriba a la izquierda regresa a
/// la pantalla anterior.
class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente({required this.texto, this.conVolver = false, super.key});

  final String texto;
  final bool conVolver;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  texto,
                  style: context.estilos.h2.copyWith(color: context.tokens.textoSecundario),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (conVolver)
              Positioned(
                left: 20,
                top: 4,
                child: BotonCerrar(
                  etiqueta: Textos.atras,
                  alPresionar: () {
                    if (context.canPop()) context.pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
