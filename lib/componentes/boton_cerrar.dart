import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Botón cuadrado con la x: 48×48, fondo/superficie, borde 1 borde/default,
/// radio 12 e ícono x de 20 en texto/primario. Se anuncia con [etiqueta]
/// ("Cerrar" en la intro del sprint, "Salir" en la barra de juego).
class BotonCerrar extends StatelessWidget {
  const BotonCerrar({required this.alPresionar, this.etiqueta = Textos.cerrar, super.key});

  static const double lado = 48;
  static const double radio = 12;

  final VoidCallback? alPresionar;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        key: const ValueKey('caja-cerrar'),
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Center(child: IconoApp(IconosApp.x, tamano: 20, color: tokens.textoPrimario)),
      ),
    );
  }
}
