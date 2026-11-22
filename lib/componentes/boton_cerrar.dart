import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import 'boton_icono_caja.dart';

/// Botón cuadrado con la x: 48×48, fondo/superficie, borde 1 borde/default,
/// radio 12 e ícono x de 20 en texto/primario. Se anuncia con [etiqueta]
/// ("Cerrar" en la intro del sprint, "Salir" en la barra de juego).
class BotonCerrar extends StatelessWidget {
  const BotonCerrar({required this.alPresionar, this.etiqueta = Textos.cerrar, super.key});

  static const double lado = BotonIconoCaja.lado;
  static const double radio = BotonIconoCaja.radio;

  final VoidCallback? alPresionar;
  final String etiqueta;

  @override
  Widget build(BuildContext context) => BotonIconoCaja(
    claveCaja: const ValueKey('caja-cerrar'),
    icono: IconosApp.x,
    etiqueta: etiqueta,
    alPresionar: alPresionar,
  );
}
