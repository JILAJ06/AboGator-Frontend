import 'package:material_ui/material_ui.dart';

import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';
import 'icono_app.dart';

/// Aviso con ícono sobre `fondo/destacado` (aviso del buzón en 19 y de
/// reinicio en 19b): radio 16, relleno 14 × [rellenoVertical], separación 10,
/// ícono de 20 y texto Leyenda `texto/primario`.
class AvisoInformativo extends StatelessWidget {
  const AvisoInformativo({
    required this.icono,
    required this.texto,
    this.colorIcono,
    this.rellenoVertical = 10,
    super.key,
  });

  static const double radio = 16;
  static const double tamanoIcono = 20;

  final IconData icono;
  final String texto;

  /// Por defecto `accion/secundaria` (ícono inbox de 19).
  final Color? colorIcono;

  /// 10 en 19 y 12 en 19b.
  final double rellenoVertical;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BloqueLectura(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: rellenoVertical),
        decoration: BoxDecoration(
          color: tokens.fondoDestacado,
          borderRadius: BorderRadius.circular(radio),
        ),
        child: Row(
          children: [
            IconoApp(icono, tamano: tamanoIcono, color: colorIcono ?? tokens.accionSecundaria),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                texto,
                style: context.estilos.leyenda.copyWith(color: tokens.textoPrimario),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
