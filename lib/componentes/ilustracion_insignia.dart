import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';
import 'sarko_imagen.dart';

/// Insignia circular (Figma 31b, 31d y 31e): círculo de [diametro] con el
/// [icono] en texto/en-primario al centro. El color de fondo lo da [color]
/// (accion/primaria o accion/acento). Con [etiqueta] se lee; sin ella es
/// decorativa.
class InsigniaCircular extends StatelessWidget {
  const InsigniaCircular({
    required this.icono,
    required this.color,
    this.diametro = 64,
    this.tamanoIcono,
    this.etiqueta,
    super.key,
  });

  final IconData icono;
  final Color color;
  final double diametro;

  /// Por defecto, el 44 % del diámetro (28 en la de 64; la de 84 de 34 usa 40).
  final double? tamanoIcono;
  final String? etiqueta;

  @override
  Widget build(BuildContext context) {
    final circulo = Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.tokens.fondoApp, width: 4),
      ),
      alignment: Alignment.center,
      child: IconoApp(
        icono,
        tamano: tamanoIcono ?? diametro * 0.44,
        color: context.tokens.textoEnPrimario,
      ),
    );
    final texto = etiqueta;
    if (texto == null) return ExcludeSemantics(child: circulo);
    return Semantics(label: texto, image: true, excludeSemantics: true, child: circulo);
  }
}

/// Ilustración de 260 × 260 de la recuperación de contraseña (Figma 31b, 31d
/// y 31e): círculo fondo/destacado de 230 centrado, Sarko de 150 × 196 abajo
/// al centro y la [insignia] arriba a la derecha. Escala con [escala] (tablet)
/// y es decorativa salvo la insignia, que dice el estado.
class IlustracionInsignia extends StatelessWidget {
  const IlustracionInsignia({
    required this.pose,
    required this.insignia,
    this.escala = 1,
    super.key,
  });

  static const double lado = 260;

  final PoseSarko pose;
  final Widget insignia;
  final double escala;

  @override
  Widget build(BuildContext context) {
    final e = escala;
    return SizedBox(
      key: const ValueKey('ilustracion-insignia'),
      width: lado * e,
      height: lado * e,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 15 * e,
            top: 15 * e,
            child: Container(
              width: 230 * e,
              height: 230 * e,
              decoration: BoxDecoration(
                color: context.tokens.fondoDestacado,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: (lado - 150) / 2 * e,
            top: 40 * e,
            child: SarkoImagen(pose: pose, ancho: 150 * e, decorativa: true),
          ),
          Positioned(right: 14 * e, top: 14 * e, child: insignia),
        ],
      ),
    );
  }
}
