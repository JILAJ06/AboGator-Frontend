import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'desplazable_alto_minimo.dart';

/// Composición de tablet con un panel de ilustración (Figma T34 `150:5709`,
/// T-13b; para la T-15).
///
/// - Horizontal (≥ 960): a la izquierda un panel fondo/destacado de hasta 597
///   (la mitad de la ventana) a toda la altura con la [ilustracion] centrada (se
///   reduce, sin crecer, si no cabe) y el [boton] arriba a la izquierda con margen
///   de 32; a la derecha el [contenido] en una columna de 470 centrada que se
///   desplaza.
/// - Vertical y de 600 a 959: el panel pasa a una franja de [altoFranja] arriba
///   con la misma ilustración reducida y el botón, y la columna de 470 debajo.
class DisposicionIlustracionTablet extends StatelessWidget {
  const DisposicionIlustracionTablet({
    required this.ilustracion,
    required this.contenido,
    this.boton,
    super.key,
  });

  /// Ancho máximo del panel (la mitad del lienzo de Figma de 1194).
  static const double anchoPanel = 597;
  static const double altoFranja = 260;

  final Widget ilustracion;
  final Widget contenido;
  final Widget? boton;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoDestacado;
    final boton = this.boton;

    Widget panel({required double relleno}) => ColoredBox(
      key: const ValueKey('panel-ilustracion-tablet'),
      color: color,
      child: SafeArea(
        right: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(relleno),
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: ilustracion),
                ),
              ),
            ),
            if (boton != null)
              Positioned(
                left: MedidasAdaptativas.margen,
                top: MedidasAdaptativas.margen,
                child: boton,
              ),
          ],
        ),
      ),
    );

    Widget columna({required bool centrarAlto}) => DesplazableAltoMinimo(
      claveDesplazable: const ValueKey('columna-ilustracion-tablet'),
      relleno: const EdgeInsets.symmetric(horizontal: MedidasAdaptativas.margen, vertical: 24),
      conAltoMinimo: centrarAlto,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: MedidasAdaptativas.columnaFormulario),
          child: contenido,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (ClasePantalla.deAncho(restricciones.maxWidth).esAncho) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: math.min(anchoPanel, restricciones.maxWidth / 2),
                child: panel(relleno: 24),
              ),
              Expanded(child: SafeArea(left: false, child: columna(centrarAlto: true))),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: altoFranja, child: panel(relleno: 16)),
            Expanded(child: SafeArea(top: false, child: columna(centrarAlto: false))),
          ],
        );
      },
    );
  }
}
