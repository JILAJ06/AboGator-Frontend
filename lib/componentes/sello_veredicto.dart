import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'boton_veredicto.dart';

/// Sello de veredicto (Figma 10:81, 10:83, 32:408 y 32:410): recuadro
/// fondo/superficie con borde de 4 en el color del veredicto, radio 12,
/// relleno 18×6 y texto Fredoka Bold con espaciado 3: LEGAL e ILEGAL en 34,
/// CON CONDICIONES y A JURÍDICO en 26. Legal va inclinado +14° e Ilegal −14°.
///
/// Decorativo (los botones y el anuncio del veredicto ya lo dicen).
class SelloVeredicto extends StatelessWidget {
  const SelloVeredicto({required this.veredicto, this.opacidad = 1, super.key});

  final Veredicto veredicto;

  /// 0 en reposo y 1 al llegar al umbral.
  final double opacidad;

  static String texto(Veredicto v) => switch (v) {
    Veredicto.legal => Textos.selloLegal,
    Veredicto.ilegal => Textos.selloIlegal,
    Veredicto.condicional => Textos.selloCondicional,
    Veredicto.escalar => Textos.selloEscalar,
  };

  static double tamanoTexto(Veredicto v) => v == Veredicto.legal || v == Veredicto.ilegal ? 34 : 26;

  /// Inclinación en grados.
  static double angulo(Veredicto v) => switch (v) {
    Veredicto.legal => EfectosApp.anguloSello,
    Veredicto.ilegal => -EfectosApp.anguloSello,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = BotonVeredicto.color(veredicto, tokens);
    final sello = Container(
      key: ValueKey('sello-${veredicto.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 4),
      ),
      child: Text(
        texto(veredicto),
        maxLines: 1,
        softWrap: false,
        style: context.estilos.h1.copyWith(
          color: color,
          fontSize: tamanoTexto(veredicto),
          height: 1.2,
          letterSpacing: EfectosApp.espaciadoSello,
        ),
      ),
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacidad.clamp(0.0, 1.0),
          child: Transform.rotate(angle: angulo(veredicto) * 3.141592653589793 / 180, child: sello),
        ),
      ),
    );
  }
}
