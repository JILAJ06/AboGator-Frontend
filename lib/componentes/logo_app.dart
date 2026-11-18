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
          SizedBox(height: alto * 0.16),
          _marca(alto * 0.36),
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
