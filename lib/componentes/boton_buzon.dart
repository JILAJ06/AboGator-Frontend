import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'icono_app.dart';

/// Botón Buzón con contador: 60×60 en accion/secundaria, radio 20, sombra
/// (0, 16, 40) e ícono inbox de 26. Contador de 24×22 en estado/ilegal con borde
/// 2 de fondo/app, en (46, −8). Sin pendientes no se dibuja el contador.
class BotonBuzon extends StatelessWidget {
  const BotonBuzon({required this.pendientes, required this.alPresionar, super.key});

  static const double lado = 60;
  static const double radio = 20;

  final int pendientes;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final boton = Container(
      key: const ValueKey('caja-buzon'),
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        color: tokens.accionSecundaria,
        borderRadius: BorderRadius.circular(radio),
        boxShadow: EfectosApp.sombraBuzon,
      ),
      child: Center(child: IconoApp(IconosApp.inbox, tamano: 26, color: tokens.textoEnPrimario)),
    );

    return AccionEnfocable.boton(
      alPresionar: alPresionar,
      radio: radio,
      etiqueta: Textos.buzonSemantica(pendientes),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          boton,
          if (pendientes > 0)
            Positioned(
              left: 46,
              top: -8,
              child: DecoratedBox(
                key: const ValueKey('contador-buzon'),
                decoration: BoxDecoration(
                  color: tokens.estadoIlegal,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: tokens.fondoApp, width: 2),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: MediaQuery.withNoTextScaling(
                        child: Text(
                          '$pendientes',
                          style: context.estilos.leyenda.copyWith(color: tokens.textoEnPrimario),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
