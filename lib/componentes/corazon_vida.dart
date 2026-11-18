import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/vidas.dart';

/// Corazón de vida (24×24 por defecto).
///
/// Lleno: corazón relleno en estado/ilegal. Vacío: contorno en borde/control.
/// Lucide solo tiene la versión de contorno, así que se dibuja con la misma
/// silueta (trazo 2, esquinas redondeadas) para poder rellenarlo.
class CorazonVida extends StatelessWidget {
  const CorazonVida({required this.lleno, this.tamano = 24, super.key});

  final bool lleno;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(tamano),
        painter: PintorCorazon(
          color: lleno ? tokens.estadoIlegal : tokens.bordeControl,
          relleno: lleno,
        ),
      ),
    );
  }
}

/// Fila de corazones (5 por defecto, hueco ≈ 10). El tamaño es parámetro
/// (en el onboarding y en "Sin vidas" se usan 33.6 con hueco 11.2).
class FilaVidas extends StatelessWidget {
  const FilaVidas({
    required this.cantidad,
    this.maximo = Vidas.maximo,
    this.tamano = 24,
    this.hueco = 10,
    super.key,
  });

  final int cantidad;
  final int maximo;
  final double tamano;
  final double hueco;

  @override
  Widget build(BuildContext context) {
    final llenos = cantidad.clamp(0, maximo);
    return Semantics(
      label: Textos.filaVidas(llenos, maximo),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < maximo; i++) ...[
            if (i > 0) SizedBox(width: hueco),
            CorazonVida(lleno: i < llenos, tamano: tamano),
          ],
        ],
      ),
    );
  }
}

/// Silueta del ícono `heart` de Lucide (caja de 24).
class PintorCorazon extends CustomPainter {
  const PintorCorazon({required this.color, required this.relleno});

  final Color color;
  final bool relleno;

  static Path silueta() {
    return Path()
      ..moveTo(19, 14)
      ..cubicTo(20.49, 12.54, 22, 10.79, 22, 8.5)
      ..arcToPoint(const Offset(16.5, 3), radius: const Radius.circular(5.5), clockwise: false)
      ..cubicTo(14.74, 3, 13.5, 3.5, 12, 5)
      ..cubicTo(10.5, 3.5, 9.26, 3, 7.5, 3)
      ..arcToPoint(const Offset(2, 8.5), radius: const Radius.circular(5.5), clockwise: false)
      ..cubicTo(2, 10.8, 3.5, 12.55, 5, 14)
      ..lineTo(12, 21)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.shortestSide / 24;
    canvas.scale(escala);
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final path = silueta();
    if (relleno) {
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.drawPath(path, trazo);
  }

  @override
  bool shouldRepaint(PintorCorazon anterior) =>
      anterior.color != color || anterior.relleno != relleno;
}
