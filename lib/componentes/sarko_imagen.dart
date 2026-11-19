import 'package:material_ui/material_ui.dart';

import '../core/recursos/imagenes_app.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'icono_app.dart';

/// Poses de Sarko disponibles en `assets/imagenes/`.
enum PoseSarko {
  alegre(ImagenesApp.sarkoAlegre, Textos.sarkoAlegre),
  enojado(ImagenesApp.sarkoEnojado, Textos.sarkoEnojado),
  sorprendido(ImagenesApp.sarkoSorprendido, Textos.sarkoSorprendido),
  triste(ImagenesApp.sarkoTriste, Textos.sarkoTriste);

  const PoseSarko(this.ruta, this.textoAlternativo);

  final String ruta;
  final String textoAlternativo;
}

/// Imagen de Sarko en una caja de relación 4:5 (ancho:alto).
///
/// Las poses no son 4:5 (alegre es 1:1; las demás ≈ 0.76–0.86), así que se
/// ajustan con `BoxFit.contain` **abajo al centro**: los pies quedan sobre la
/// misma línea en todas las poses.
///
/// Tamaños del diseño: 264, 208, 184, 176, 160, 120, 104, 96 y 88 de ancho.
/// Si la imagen no carga se muestra un marcador. Con [decorativa] se excluye
/// del lector de pantalla.
class SarkoImagen extends StatelessWidget {
  const SarkoImagen({required this.pose, this.ancho = 160, this.decorativa = false, super.key});

  final PoseSarko pose;
  final double ancho;
  final bool decorativa;

  double get alto => ancho * 5 / 4;

  @override
  Widget build(BuildContext context) {
    final imagen = SizedBox(
      width: ancho,
      height: alto,
      child: Image.asset(
        pose.ruta,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, pila) => _Marcador(ancho: ancho),
      ),
    );
    if (decorativa) {
      return ExcludeSemantics(child: imagen);
    }
    return Semantics(
      image: true,
      label: pose.textoAlternativo,
      excludeSemantics: true,
      child: imagen,
    );
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({required this.ancho});

  final double ancho;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.fondoSuperficieAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Center(
        child: IconoApp(
          IconosApp.gavel,
          tamano: ancho / 3,
          color: tokens.textoSecundario,
          etiquetaSemantica: Textos.sarkoNoDisponible,
        ),
      ),
    );
  }
}
