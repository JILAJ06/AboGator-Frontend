import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'pildora.dart';

/// Solo en depuración: píldora pequeña con un `Switch` para simular que no
/// hay conexión (la única forma de ver el estado 23 sin backend). En release
/// no existe (devuelve una caja vacía).
class InterruptorConexionDebug extends StatelessWidget {
  const InterruptorConexionDebug({
    required this.sinConexion,
    required this.alCambiar,
    this.visible = kDebugMode,
    super.key,
  });

  final bool sinConexion;
  final ValueChanged<bool> alCambiar;

  /// Por defecto, solo en modo depuración.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final tokens = context.tokens;
    return Center(
      child: Pildora(
        clave: const ValueKey('interruptor-conexion'),
        altoMinimo: 48,
        fondo: tokens.fondoSuperficieAlt,
        relleno: const EdgeInsets.only(left: 14, right: 4),
        borde: Border.all(color: tokens.bordeDefault),
        child: MergeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  Textos.simularSinConexion,
                  style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
                ),
              ),
              Switch(value: sinConexion, onChanged: alCambiar),
            ],
          ),
        ),
      ),
    );
  }
}
