import 'package:material_ui/material_ui.dart';

import '../core/recursos/imagenes_app.dart';
import '../core/textos/textos.dart';

/// Variantes del logotipo. Vertical y horizontal se arman con los dos
/// archivos entregados (isotipo y marca nominativa).
enum VarianteLogo { vertical, horizontal, isotipo }

/// Logotipo de AboGator.
///
/// [alto] es la altura del isotipo; la marca nominativa se ajusta a él.
class LogoApp extends StatelessWidget {
  const LogoApp({this.variante = VarianteLogo.vertical, this.alto = 96, super.key});

  /// Relación ancho/alto de los archivos originales.
  static const double proporcionIsotipo = 1068 / 973;
  static const double proporcionMarca = 1312 / 266;

  /// Logo vertical de Figma (323.7×187.9): isotipo de 109, hueco ≈ 13 y la
  /// marca nominativa a todo el ancho (323.7, ≈ 65.6 de alto).
  static const double huecoVertical = 13 / 109;
  static const double marcaVertical = (323.7 / proporcionMarca) / 109;

  final VarianteLogo variante;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final isotipo = Image.asset(
      ImagenesApp.logoIsotipo,
      height: alto,
      width: alto * proporcionIsotipo,
      fit: BoxFit.contain,
    );
    final contenido = switch (variante) {
      VarianteLogo.isotipo => isotipo,
      VarianteLogo.vertical => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isotipo,
          SizedBox(height: alto * huecoVertical),
          _marca(alto * marcaVertical),
        ],
      ),
      VarianteLogo.horizontal => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isotipo,
          SizedBox(width: alto * 0.2),
          _marca(alto * 0.5),
        ],
      ),
    };
    return Semantics(image: true, label: Textos.logo, excludeSemantics: true, child: contenido);
  }

  Widget _marca(double altoMarca) => Image.asset(
    ImagenesApp.logoMarcaNominativa,
    height: altoMarca,
    width: altoMarca * proporcionMarca,
    fit: BoxFit.contain,
  );
}
