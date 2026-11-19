import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Casilla con texto: cuadro de 22 (radio 6) y texto Leyenda a 10.
///
/// Marcada: relleno accion/primaria con check de 14 en texto/en-primario.
/// Sin marcar: relleno fondo/superficie y borde 1.5 borde/control.
/// Toda la fila es táctil (≥ 48 de alto). El error opcional se anuncia.
class CasillaApp extends StatelessWidget {
  const CasillaApp({
    required this.texto,
    required this.marcada,
    required this.alCambiar,
    this.error,
    this.nodoFoco,
    super.key,
  });

  static const double lado = 22;
  static const double radio = 6;
  static const double anchoTexto = 300;

  final String texto;
  final bool marcada;
  final ValueChanged<bool>? alCambiar;
  final String? error;
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final alPresionar = alCambiar == null ? null : () => alCambiar!(!marcada);

    final cuadro = Container(
      key: const ValueKey('cuadro-casilla'),
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        color: marcada ? tokens.accionPrimaria : tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        border: marcada ? null : Border.all(color: tokens.bordeControl, width: 1.5),
      ),
      child: marcada
          ? Center(child: IconoApp(IconosApp.check, tamano: 14, color: tokens.textoEnPrimario))
          : null,
    );

    final fila = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          cuadro,
          const SizedBox(width: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: anchoTexto),
              child: Text(texto, style: estilos.leyenda.copyWith(color: tokens.textoPrimario)),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AccionEnfocable(
          alPresionar: alPresionar,
          radio: radio,
          nodoFoco: nodoFoco,
          semantica: (hijo) => Semantics(
            checked: marcada,
            enabled: alCambiar != null,
            label: texto,
            onTap: alPresionar,
            excludeSemantics: true,
            child: hijo,
          ),
          child: fila,
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: lado + 10),
            child: Semantics(
              liveRegion: true,
              child: Text(error!, style: estilos.leyenda.copyWith(color: tokens.estadoIlegal)),
            ),
          ),
      ],
    );
  }
}
