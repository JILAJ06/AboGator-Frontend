import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/utilidades/extensiones_contexto.dart';

/// Camino decorativo del mapa (Figma 14:1131): une en línea recta los centros
/// de los nodos con un trazo punteado de 8 en borde/default (guiones de 2 con
/// puntas redondas y huecos de 15). Ocupa todo el espacio que le den y no se
/// lee en el lector de pantalla.
class CaminoSprints extends StatelessWidget {
  const CaminoSprints({required this.puntos, super.key});

  /// Centros de los nodos, en el sistema de coordenadas de este widget.
  final List<Offset> puntos;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: PintorCamino(puntos: puntos, color: context.tokens.bordeDefault),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class PintorCamino extends CustomPainter {
  const PintorCamino({required this.puntos, required this.color});

  final List<Offset> puntos;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.length < 2) return;
    final linea = Path()..moveTo(puntos.first.dx, puntos.first.dy);
    for (final punto in puntos.skip(1)) {
      linea.lineTo(punto.dx, punto.dy);
    }
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = EfectosApp.anchoCamino
      ..strokeCap = StrokeCap.round;
    const periodo = EfectosApp.guionCamino + EfectosApp.huecoCamino;
    for (final PathMetric tramo in linea.computeMetrics()) {
      for (var d = 0.0; d < tramo.length; d += periodo) {
        canvas.drawPath(tramo.extractPath(d, d + EfectosApp.guionCamino), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(PintorCamino anterior) =>
      anterior.color != color || !listEquals(anterior.puntos, puntos);
}
