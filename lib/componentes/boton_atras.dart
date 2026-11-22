import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import 'boton_icono_caja.dart';

/// Botón de regreso: cuadro de 48 con radio 12, fondo fondo/superficie,
/// borde 1 borde/default e ícono back de 20. Se anuncia como "Atrás".
class BotonAtras extends StatelessWidget {
  const BotonAtras({required this.alPresionar, super.key});

  static const double lado = BotonIconoCaja.lado;
  static const double radio = BotonIconoCaja.radio;

  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) => BotonIconoCaja(
    claveCaja: const ValueKey('caja-atras'),
    icono: IconosApp.back,
    etiqueta: Textos.atras,
    alPresionar: alPresionar,
  );
}
