import 'package:material_ui/material_ui.dart';

import 'sarko_imagen.dart';

/// Sarko sobre su fondo circular (19, 19b y 20): el círculo de [diametro] arriba
/// y Sarko de [anchoSarko] (caja 4:5) 4 dp más abajo, centrados. Es
/// decorativa, como en el panel de veredicto: el título dice lo que pasó.
class IlustracionSarko extends StatelessWidget {
  const IlustracionSarko({
    required this.pose,
    required this.diametro,
    required this.anchoSarko,
    required this.colorFondo,
    super.key,
  });

  /// Sarko empieza 4 dp debajo del borde superior del círculo.
  static const double desfaseSarko = 4;

  final PoseSarko pose;
  final double diametro;
  final double anchoSarko;
  final Color colorFondo;

  @override
  Widget build(BuildContext context) {
    final sarko = SarkoImagen(pose: pose, ancho: anchoSarko, decorativa: true);
    return SizedBox(
      width: diametro,
      height: desfaseSarko + sarko.alto,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            key: const ValueKey('fondo-sarko'),
            width: diametro,
            height: diametro,
            decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
          ),
          Positioned(top: desfaseSarko, child: sarko),
        ],
      ),
    );
  }
}
