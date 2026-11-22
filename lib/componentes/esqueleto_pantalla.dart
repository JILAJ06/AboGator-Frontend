import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';

/// Bloque gris de un esqueleto de carga (T-15c): [alto] × [ancho] (todo el
/// ancho si es nulo), radio [radio] y color [color] (por defecto
/// fondo/superficie-alt).
class BloqueEsqueleto extends StatelessWidget {
  const BloqueEsqueleto(this.alto, {this.ancho, this.radio = 16, this.color, super.key});

  final double alto;
  final double? ancho;
  final double radio;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: ancho,
    height: alto,
    decoration: BoxDecoration(
      color: color ?? context.tokens.fondoSuperficieAlt,
      borderRadius: BorderRadius.circular(radio),
    ),
  );
}

/// Armazón de los esqueletos de carga (T-15c): una sola región en vivo con
/// [etiqueta] (los bloques no se leen) y una columna de [hijos] que no se
/// desplaza, con la clave [clave] (`esqueleto-…`) y el [relleno] de la pantalla.
///
/// [areaSegura] la envuelve en `SafeArea` (con [areaSeguraAbajo] para el
/// borde inferior).
class EsqueletoPantalla extends StatelessWidget {
  const EsqueletoPantalla({
    required this.etiqueta,
    required this.clave,
    required this.hijos,
    this.relleno = EdgeInsets.zero,
    this.alineacion = CrossAxisAlignment.start,
    this.areaSegura = false,
    this.areaSeguraAbajo = true,
    super.key,
  });

  final String etiqueta;
  final Key clave;
  final List<Widget> hijos;
  final EdgeInsetsGeometry relleno;
  final CrossAxisAlignment alineacion;
  final bool areaSegura;
  final bool areaSeguraAbajo;

  @override
  Widget build(BuildContext context) {
    final Widget desplazable = SingleChildScrollView(
      key: clave,
      physics: const NeverScrollableScrollPhysics(),
      padding: relleno,
      child: Column(crossAxisAlignment: alineacion, children: hijos),
    );
    return Semantics(
      label: etiqueta,
      liveRegion: true,
      excludeSemantics: true,
      child: areaSegura ? SafeArea(bottom: areaSeguraAbajo, child: desplazable) : desplazable,
    );
  }
}
