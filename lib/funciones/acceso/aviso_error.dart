import 'package:material_ui/material_ui.dart';

import '../../componentes/icono_app.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/utilidades/extensiones_contexto.dart';

/// Error general de un formulario (por ejemplo, del repositorio): ícono de
/// alerta y texto en estado/ilegal. Se anuncia al aparecer.
class AvisoError extends StatelessWidget {
  const AvisoError({required this.mensaje, super.key});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.estadoIlegal;
    return Semantics(
      liveRegion: true,
      container: true,
      label: mensaje,
      excludeSemantics: true,
      child: Row(
        key: const ValueKey('aviso-error'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: IconoApp(IconosApp.alert, tamano: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(mensaje, style: context.estilos.cuerpoEnfasis.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
