import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'caja_superficie.dart';

/// Barra de progreso: alto 12, radio 6, relleno accion/primaria con brillo
/// (franja de 3 de alto, blanco al 35 %, a 6 del borde izquierdo y 2.5 de
/// arriba, ancho = relleno − 12). El cambio se anima salvo con
/// "reducir animaciones". [colorRelleno] cambia el relleno (el Examen usa
/// accion/secundaria, T-13).
class BarraProgreso extends StatelessWidget {
  const BarraProgreso({
    required this.valor,
    required this.etiquetaSemantica,
    this.colorRelleno,
    super.key,
  });

  static const double alto = 12;

  /// Progreso de 0 a 1.
  final double valor;

  /// Por ejemplo "Tarjeta 5 de 10".
  final String etiquetaSemantica;

  /// Sin valor, accion/primaria.
  final Color? colorRelleno;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final acotado = valor.clamp(0.0, 1.0);
    final duracion = EfectosApp.duracion(context, milisegundos: 250);
    return Semantics(
      label: etiquetaSemantica,
      value: '${(acotado * 100).round()} %',
      excludeSemantics: true,
      // Alto fijo por fuera del LayoutBuilder: así la barra puede ir dentro de
      // un IntrinsicHeight (pantalla de juego).
      child: SizedBox(
        height: alto,
        child: LayoutBuilder(
          builder: (context, restricciones) {
            final total = restricciones.maxWidth;
            final relleno = total * acotado;
            return CajaSuperficie(
              ancho: total,
              alto: alto,
              fondo: FondoCaja.superficieAlt,
              radio: 6,
              child: Stack(
                children: [
                  AnimatedContainer(
                    key: const ValueKey('relleno-progreso'),
                    duration: duracion,
                    curve: Curves.easeOut,
                    width: relleno,
                    height: alto,
                    decoration: BoxDecoration(
                      color: colorRelleno ?? tokens.accionPrimaria,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (relleno > 12)
                    AnimatedPositioned(
                      duration: duracion,
                      curve: Curves.easeOut,
                      left: 6,
                      top: 2.5,
                      width: relleno - 12,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: EfectosApp.brilloBarra,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
