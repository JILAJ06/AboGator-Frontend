import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';

/// Estrellas ganadas en un sprint (19): tres estrellas de 36 · 46 · 36
/// alineadas abajo, separación 6. Las ganadas van rellenas en `accion/acento`;
/// las no ganadas, en contorno `borde/control`. Se leen como un texto:
/// "N de 3 estrellas".
class EstrellasSprint extends StatelessWidget {
  const EstrellasSprint({required this.ganadas, super.key});

  static const int total = 3;
  static const List<double> tamanos = [36, 46, 36];
  static const double separacion = 6;

  /// 0 a 3.
  final int ganadas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final n = ganadas.clamp(0, total);
    return BloqueLectura(
      etiqueta: Textos.estrellasSemantica(n, total),
      excluirHijos: true,
      radio: 8,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: separacion),
            CustomPaint(
              key: ValueKey('estrella-$i'),
              size: Size.square(tamanos[i]),
              painter: PintorEstrella(
                llena: i < n,
                color: i < n ? tokens.accionAcento : tokens.bordeControl,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estrella de cinco puntas con la silueta del ícono star (Lucide), rellena
/// o en contorno. Figma la usa rellena; el ícono de Lucide solo tiene
/// contorno. También la usan las estrellas de los nodos del mapa.
class PintorEstrella extends CustomPainter {
  const PintorEstrella({required this.color, this.llena = true});

  final bool llena;
  final Color color;

  /// Puntas del ícono star de Figma sobre una caja de 36.
  static const List<Offset> _puntos = [
    Offset(18, 3),
    Offset(22.65, 12.45),
    Offset(33, 13.95),
    Offset(25.5, 21.3),
    Offset(27.3, 31.5),
    Offset(18, 26.7),
    Offset(8.7, 31.5),
    Offset(10.5, 21.3),
    Offset(3, 13.95),
    Offset(13.35, 12.45),
  ];

  /// Grosor del contorno sobre la caja de 36.
  static const double grosor = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / 36;
    final camino = Path()..addPolygon([for (final p in _puntos) p * escala], true);
    canvas.drawPath(
      camino,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = llena ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = grosor * escala
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(PintorEstrella anterior) => anterior.llena != llena || anterior.color != color;
}
