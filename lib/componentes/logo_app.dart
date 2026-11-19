import 'package:material_ui/material_ui.dart';

import '../core/recursos/imagenes_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Logotipo de AboGator con los PNG exportados de Figma.
///
/// El alto sale de [ancho] y de la proporción del archivo. Sin [tono] se elige
/// solo: color en modo claro y negativo en modo oscuro.
class LogoApp extends StatelessWidget {
  const LogoApp({
    this.forma = FormaLogo.vertical,
    this.tono,
    this.ancho = 200,
    this.decorativo = false,
    super.key,
  });

  final FormaLogo forma;

  /// `null`: automático según el modo (color / negativo).
  final TonoLogo? tono;
  final double ancho;

  /// `true` lo excluye del lector de pantalla (cuando el texto ya dice "AboGator").
  final bool decorativo;

  double get alto => ancho / forma.proporcion;

  /// Tono que se usa en un contexto dado.
  TonoLogo tonoEn(BuildContext context) =>
      tono ?? (context.esModoOscuro ? TonoLogo.negativo : TonoLogo.color);

  @override
  Widget build(BuildContext context) {
    final imagen = Image.asset(
      ImagenesApp.logo(forma, tonoEn(context)),
      width: ancho,
      height: alto,
      fit: BoxFit.contain,
    );
    if (decorativo) {
      return ExcludeSemantics(child: imagen);
    }
    return Semantics(image: true, label: Textos.logo, excludeSemantics: true, child: imagen);
  }
}
