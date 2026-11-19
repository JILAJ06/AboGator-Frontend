import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'boton_app.dart';

/// Mensaje centrado con un botón secundario (error de carga con
/// "Reintentar", o "no encontrado" con "Volver"). El mensaje se anuncia.
class MensajePantalla extends StatelessWidget {
  const MensajePantalla({
    required this.texto,
    required this.textoBoton,
    required this.alPresionar,
    super.key,
  });

  final String texto;
  final String textoBoton;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  texto,
                  style: context.estilos.cuerpoGrande.copyWith(color: context.tokens.textoPrimario),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              BotonApp(
                texto: textoBoton,
                tipo: TipoBoton.secundario,
                expandido: false,
                alPresionar: alPresionar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
