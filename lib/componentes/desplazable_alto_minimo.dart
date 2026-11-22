import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Desplazable cuyo contenido mide al menos el alto disponible (T-15e): así
/// un pie queda abajo o el contenido se centra sin medidas intrínsecas, y si
/// no cabe, todo se desplaza.
///
/// El alto mínimo es el alto disponible menos el [relleno] vertical (0 si el
/// alto no está acotado o si [conAltoMinimo] es falso). Conserva
/// [claveDesplazable], [controlador] y [fisica] de cada pantalla. Sin entrada
/// en la galería: no tiene vista propia.
class DesplazableAltoMinimo extends StatelessWidget {
  const DesplazableAltoMinimo({
    required this.child,
    this.relleno = EdgeInsets.zero,
    this.claveDesplazable,
    this.controlador,
    this.fisica,
    this.conAltoMinimo = true,
    super.key,
  });

  final Widget child;
  final EdgeInsets relleno;
  final Key? claveDesplazable;
  final ScrollController? controlador;
  final ScrollPhysics? fisica;
  final bool conAltoMinimo;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, restricciones) => SingleChildScrollView(
      key: claveDesplazable,
      controller: controlador,
      physics: fisica,
      padding: relleno == EdgeInsets.zero ? null : relleno,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: conAltoMinimo && restricciones.hasBoundedHeight
              ? math.max(0, restricciones.maxHeight - relleno.vertical)
              : 0,
        ),
        child: child,
      ),
    ),
  );
}
