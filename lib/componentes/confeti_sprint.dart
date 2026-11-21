import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';

/// Pieza de confeti: posición (sobre el marco de 390 de ancho, contada desde
/// el borde superior del contenido), color e inclinación en grados.
class PiezaConfeti {
  const PiezaConfeti(this.x, this.y, this.color, this.grados);

  final double x;
  final double y;
  final Color color;
  final double grados;
}

/// Confeti decorativo de "Sprint completado" (19): 7 piezas de 12×6 (radio 2)
/// que caen una vez al abrir la pantalla (1.2 s). Con "reducir animaciones"
/// aparecen quietas en su lugar. No se lee.
///
/// Mide [ancho]×[alto] y se centra en el ancho disponible (en pantallas
/// angostas las piezas de los bordes quedan fuera, sin desbordes).
class ConfetiSprint extends StatefulWidget {
  const ConfetiSprint({
    this.piezas = piezasSprint,
    this.anchoLienzo = ancho,
    this.altoLienzo = alto,
    super.key,
  });

  static const double ancho = 390;
  static const double alto = 260;
  static const double anchoPieza = 12;
  static const double altoPieza = 6;
  static const double radioPieza = 2;

  /// Posiciones de Figma 19 (38:5569 a 38:5575) menos la barra de estado (48).
  static const List<PiezaConfeti> piezasSprint = [
    PiezaConfeti(60, 72, EfectosApp.confetiAmbar, 0),
    PiezaConfeti(320, 96, EfectosApp.confetiVerde, -30),
    PiezaConfeti(90, 192, EfectosApp.confetiAzul, -60),
    PiezaConfeti(300, 39, EfectosApp.confetiRojo, -15),
    PiezaConfeti(200, 14, EfectosApp.confetiAmbarClaro, -45),
    PiezaConfeti(40, 248, EfectosApp.confetiVerde, -20),
    PiezaConfeti(340, 221, EfectosApp.confetiAmbar, -70),
  ];

  /// Posiciones de Figma 29 (18:2928 a 18:2935) menos la barra de estado (48).
  static const List<PiezaConfeti> piezasAuditoria = [
    PiezaConfeti(50, 60, EfectosApp.confetiAmbar, -10),
    PiezaConfeti(330, 74, EfectosApp.confetiVerde, -40),
    PiezaConfeti(80, 242, EfectosApp.confetiAzul, -60),
    PiezaConfeti(310, 29, EfectosApp.confetiRojo, -15),
    PiezaConfeti(190, 14, EfectosApp.confetiAmbarClaro, -45),
    PiezaConfeti(30, 188, EfectosApp.confetiVerde, -20),
    PiezaConfeti(350, 221, EfectosApp.confetiAmbar, -70),
    PiezaConfeti(260, 276, EfectosApp.confetiAzul, -30),
  ];

  /// Piezas a dibujar (por defecto, las de 19).
  final List<PiezaConfeti> piezas;

  /// Lienzo sobre el que se miden las piezas (390 × 260 en móvil; el panel de
  /// 597 en tablet).
  final double anchoLienzo;
  final double altoLienzo;

  /// Figma T19 (98:5164 a 98:5170) sobre el panel de 597, sin la barra de 32.
  static const List<PiezaConfeti> piezasSprintTablet = [
    PiezaConfeti(90, 76, EfectosApp.confetiAmbar, 0),
    PiezaConfeti(480, 103, EfectosApp.confetiVerde, -30),
    PiezaConfeti(135, 193, EfectosApp.confetiAzul, -60),
    PiezaConfeti(450, 49, EfectosApp.confetiRojo, -15),
    PiezaConfeti(300, 31, EfectosApp.confetiAmbarClaro, -45),
    PiezaConfeti(60, 238, EfectosApp.confetiVerde, -20),
    PiezaConfeti(510, 220, EfectosApp.confetiAmbar, -70),
  ];

  /// Figma T29 (101:5657 a 101:5664) sobre el panel de 597, sin la barra de 32.
  static const List<PiezaConfeti> piezasAuditoriaTablet = [
    PiezaConfeti(75, 67, EfectosApp.confetiAmbar, -10),
    PiezaConfeti(495, 85, EfectosApp.confetiVerde, -40),
    PiezaConfeti(120, 238, EfectosApp.confetiAzul, -60),
    PiezaConfeti(465, 40, EfectosApp.confetiRojo, -15),
    PiezaConfeti(285, 31, EfectosApp.confetiAmbarClaro, -45),
    PiezaConfeti(45, 184, EfectosApp.confetiVerde, -20),
    PiezaConfeti(525, 220, EfectosApp.confetiAmbar, -70),
    PiezaConfeti(390, 265, EfectosApp.confetiAzul, -30),
  ];

  @override
  State<ConfetiSprint> createState() => _ConfetiSprintState();
}

class _ConfetiSprintState extends State<ConfetiSprint> with SingleTickerProviderStateMixin {
  late final AnimationController _caida = AnimationController(
    vsync: this,
    duration: EfectosApp.duracionConfeti,
  );
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _caida.value = 1;
    } else {
      _caida.forward();
    }
  }

  @override
  void dispose() {
    _caida.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final piezas = widget.piezas;
    final paso = piezas.length <= 1 ? 0.0 : math.min(0.05, 0.3 / (piezas.length - 1));
    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox(
          height: widget.altoLienzo,
          child: OverflowBox(
            minWidth: widget.anchoLienzo,
            maxWidth: widget.anchoLienzo,
            child: AnimatedBuilder(
              animation: _caida,
              builder: (context, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, pieza) in piezas.indexed)
                    _Pieza(
                      key: ValueKey('confeti-$i'),
                      pieza: pieza,
                      // Cada pieza empieza un poco después que la anterior
                      // (0.05 con 7 piezas; menos si hay más, para acabar en 1).
                      avance: Curves.easeOut.transform(
                        Interval(i * paso, 0.7 + i * paso).transform(_caida.value),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pieza extends StatelessWidget {
  const _Pieza({required this.pieza, required this.avance, super.key});

  final PiezaConfeti pieza;

  /// 0 = arriba, fuera de la caja; 1 = en su lugar.
  final double avance;

  @override
  Widget build(BuildContext context) {
    final caida = (1 - avance) * (pieza.y + ConfetiSprint.anchoPieza * 3);
    return Positioned(
      left: pieza.x,
      top: pieza.y - caida,
      child: Opacity(
        opacity: avance.clamp(0, 1),
        child: Transform.rotate(
          // Gira media vuelta mientras cae.
          angle: (pieza.grados + (1 - avance) * 180) * 3.141592653589793 / 180,
          child: Container(
            width: ConfetiSprint.anchoPieza,
            height: ConfetiSprint.altoPieza,
            decoration: BoxDecoration(
              color: pieza.color,
              borderRadius: BorderRadius.circular(ConfetiSprint.radioPieza),
            ),
          ),
        ),
      ),
    );
  }
}
