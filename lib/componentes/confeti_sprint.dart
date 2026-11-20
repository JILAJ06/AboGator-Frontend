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
  const ConfetiSprint({super.key});

  static const double ancho = 390;
  static const double alto = 260;
  static const double anchoPieza = 12;
  static const double altoPieza = 6;
  static const double radioPieza = 2;

  /// Posiciones de Figma 19 (38:5569 a 38:5575) menos la barra de estado (48).
  static const List<PiezaConfeti> piezas = [
    PiezaConfeti(60, 72, EfectosApp.confetiAmbar, 0),
    PiezaConfeti(320, 96, EfectosApp.confetiVerde, -30),
    PiezaConfeti(90, 192, EfectosApp.confetiAzul, -60),
    PiezaConfeti(300, 39, EfectosApp.confetiRojo, -15),
    PiezaConfeti(200, 14, EfectosApp.confetiAmbarClaro, -45),
    PiezaConfeti(40, 248, EfectosApp.confetiVerde, -20),
    PiezaConfeti(340, 221, EfectosApp.confetiAmbar, -70),
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
    const piezas = ConfetiSprint.piezas;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: SizedBox(
          height: ConfetiSprint.alto,
          child: OverflowBox(
            minWidth: ConfetiSprint.ancho,
            maxWidth: ConfetiSprint.ancho,
            child: AnimatedBuilder(
              animation: _caida,
              builder: (context, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final (i, pieza) in piezas.indexed)
                    _Pieza(
                      key: ValueKey('confeti-$i'),
                      pieza: pieza,
                      // Cada pieza empieza un poco después que la anterior.
                      avance: Curves.easeOut.transform(
                        Interval(i * 0.05, 0.7 + i * 0.05).transform(_caida.value),
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
