import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Botón de regreso: cuadro de 48 con radio 12, fondo fondo/superficie,
/// borde 1 borde/default e ícono back de 20. Se anuncia como "Atrás".
class BotonAtras extends StatelessWidget {
  const BotonAtras({required this.alPresionar, super.key});

  static const double lado = 48;
  static const double radio = 12;

  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        label: Textos.atras,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        key: const ValueKey('caja-atras'),
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Center(child: IconoApp(IconosApp.back, tamano: 20, color: tokens.textoPrimario)),
      ),
    );
  }
}
