import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Pantallas de resultado en tablet horizontal (T19, T19b, T20, T29 y T30;
/// Figma `98:5016`…): sin riel; a la izquierda un panel fondo/superficie de la
/// mitad de la ventana (hasta 597) a toda la altura con la [ilustracion]
/// centrada y el [fondo] decorativo (el confeti) arriba; a la derecha el
/// [contenido] en una columna de 470 centrada (también en alto) que se
/// desplaza si no cabe. [encabezado] (el botón Cerrar de T20) va arriba a la
/// izquierda del panel, en (24, 12).
class DisposicionResultadoTablet extends StatelessWidget {
  const DisposicionResultadoTablet({
    required this.ilustracion,
    required this.contenido,
    this.fondo,
    this.encabezado,
    super.key,
  });

  /// Ancho máximo del panel de la ilustración (la mitad del lienzo de Figma).
  static const double anchoPanel = 597;

  static const double relleno = 24;

  final Widget ilustracion;
  final Widget contenido;
  final Widget? fondo;
  final Widget? encabezado;

  @override
  Widget build(BuildContext context) {
    final capaFondo = fondo;
    final cabeza = encabezado;
    return LayoutBuilder(
      builder: (context, restricciones) {
        final anchoIzquierda = math.min(anchoPanel, restricciones.maxWidth / 2);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: anchoIzquierda,
              child: ColoredBox(
                key: const ValueKey('panel-ilustracion-resultado'),
                color: context.tokens.fondoSuperficie,
                child: SafeArea(
                  right: false,
                  child: Stack(
                    children: [
                      if (capaFondo != null)
                        Positioned(top: 0, left: 0, right: 0, child: capaFondo),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(relleno),
                          child: Center(
                            child: FittedBox(fit: BoxFit.scaleDown, child: ilustracion),
                          ),
                        ),
                      ),
                      if (cabeza != null) Positioned(left: 24, top: 12, child: cabeza),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SafeArea(
                left: false,
                child: LayoutBuilder(
                  builder: (context, caja) => SingleChildScrollView(
                    key: const ValueKey('columna-resultado'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: MedidasAdaptativas.margen,
                      vertical: relleno,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, caja.maxHeight - 2 * relleno),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: MedidasAdaptativas.columnaFormulario,
                          ),
                          child: contenido,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// La ilustración del móvil ampliada (T19 a T30 usan la del móvil × 1.7, T29
/// × 1.6): se dibuja a [anchoBase] y se escala a `anchoBase × escala`.
class IlustracionAmpliada extends StatelessWidget {
  const IlustracionAmpliada({
    required this.anchoBase,
    required this.escala,
    required this.child,
    super.key,
  });

  final double anchoBase;
  final double escala;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // El texto de la ilustración (la etiqueta de quiebra) no se escala con el
    // sistema: ya se amplía con la ilustración.
    return SizedBox(
      key: const ValueKey('ilustracion-ampliada'),
      width: anchoBase * escala,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: anchoBase,
          child: MediaQuery.withNoTextScaling(child: child),
        ),
      ),
    );
  }
}
