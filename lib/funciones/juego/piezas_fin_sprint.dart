import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/bloque_lectura.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/utilidades/extensiones_contexto.dart';

/// Sarko sobre su fondo circular (19 y 19b): el círculo de [diametro] arriba
/// y Sarko de [anchoSarko] (caja 4:5) 4 dp más abajo, centrados. Es
/// decorativa, como en el panel de veredicto: el título dice lo que pasó.
class IlustracionFinSprint extends StatelessWidget {
  const IlustracionFinSprint({
    required this.pose,
    required this.diametro,
    required this.anchoSarko,
    required this.colorFondo,
    super.key,
  });

  /// Sarko empieza 4 dp debajo del borde superior del círculo.
  static const double desfaseSarko = 4;

  final PoseSarko pose;
  final double diametro;
  final double anchoSarko;
  final Color colorFondo;

  @override
  Widget build(BuildContext context) {
    final sarko = SarkoImagen(pose: pose, ancho: anchoSarko, decorativa: true);
    return SizedBox(
      width: diametro,
      height: desfaseSarko + sarko.alto,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            key: const ValueKey('fondo-sarko'),
            width: diametro,
            height: diametro,
            decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
          ),
          Positioned(top: desfaseSarko, child: sarko),
        ],
      ),
    );
  }
}

/// Título de 19 y 19b: Título/H1 `texto/primario` centrado. Se anuncia al
/// abrir la pantalla y recibe el foco (sin anillo, como el panel de T-06).
class TituloFinSprint extends StatelessWidget {
  const TituloFinSprint(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return BloqueLectura(
      key: const ValueKey('titulo-fin-sprint'),
      encabezado: true,
      enVivo: true,
      autofocus: true,
      radio: 8,
      child: Text(
        texto,
        style: context.estilos.h1.copyWith(color: context.tokens.textoPrimario),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Elemento con lugar fijo en el orden de lectura y de foco de 19 y 19b (el
/// título va primero aunque las estrellas o la etiqueta estén arriba de él).
class ElementoOrdenado extends StatelessWidget {
  const ElementoOrdenado({required this.orden, required this.child, super.key});

  final double orden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      sortKey: OrdinalSortKey(orden),
      child: FocusTraversalOrder(order: NumericFocusOrder(orden), child: child),
    );
  }
}

/// Columna desplazable de 19 y 19b, sin navegación inferior: el contenido
/// arriba y los botones al final (debajo del contenido si no cabe). Márgenes
/// laterales de 24 y 36 abajo. El foco sigue el orden de [ElementoOrdenado].
class ColumnaFinSprint extends StatelessWidget {
  const ColumnaFinSprint({required this.contenido, required this.botones, this.fondo, super.key});

  /// Separación mínima entre el contenido y los botones.
  static const double separacionBotones = 28;

  final List<Widget> contenido;
  final List<Widget> botones;

  /// Capa decorativa detrás del contenido, pegada arriba (el confeti).
  final Widget? fondo;

  @override
  Widget build(BuildContext context) {
    final columna = Column(
      children: [
        ...contenido,
        const SizedBox(height: separacionBotones),
        const Spacer(),
        ...botones,
      ],
    );
    final capaFondo = fondo;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(bottom: 36),
        child: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: CustomScrollView(
            key: const ValueKey('columna-fin-sprint'),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Stack(
                  children: [
                    if (capaFondo != null) Positioned(top: 0, left: 0, right: 0, child: capaFondo),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: columna),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
