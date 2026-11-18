import 'package:material_ui/material_ui.dart';

/// Ícono del diseño (usar los de `IconosApp`).
///
/// Sin [etiquetaSemantica] es decorativo y se excluye del lector de pantalla.
/// Sin [color] toma el del texto que lo rodea (`IconTheme`).
class IconoApp extends StatelessWidget {
  const IconoApp(this.icono, {this.tamano = 24, this.color, this.etiquetaSemantica, super.key});

  final IconData icono;
  final double tamano;
  final Color? color;
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(icono, size: tamano, color: color);
    final etiqueta = etiquetaSemantica;
    if (etiqueta == null) {
      return ExcludeSemantics(child: icon);
    }
    return Semantics(label: etiqueta, image: true, excludeSemantics: true, child: icon);
  }
}
