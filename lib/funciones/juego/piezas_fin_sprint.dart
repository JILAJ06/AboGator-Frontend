import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/titulo_enfocado.dart';
import '../../core/adaptativo/clase_pantalla.dart';

/// Título de 19 y 19b: Título/H1 `texto/primario` centrado. Se anuncia al
/// abrir la pantalla y recibe el foco (sin anillo, como el panel de T-06).
class TituloFinSprint extends StatelessWidget {
  const TituloFinSprint(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return TituloEnfocado(
      texto,
      clave: const ValueKey('titulo-fin-sprint'),
      alineacion: TextAlign.center,
      enVivo: true,
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
///
/// En tablet horizontal (con [ilustracionTablet]) usa `DisposicionResultadoTablet`:
/// la ilustración en el panel izquierdo y [contenidoTablet] (o [contenido])
/// con los botones en la columna de 470 (T-12d).
class ColumnaFinSprint extends StatelessWidget {
  const ColumnaFinSprint({
    required this.contenido,
    required this.botones,
    this.fondo,
    this.ilustracionTablet,
    this.contenidoTablet,
    this.encabezadoTablet,
    super.key,
  });

  /// Separación entre el contenido y los botones en tablet (Figma: 16).
  static const double separacionBotonesTablet = 16;

  /// Separación mínima entre el contenido y los botones.
  static const double separacionBotones = 28;

  final List<Widget> contenido;
  final List<Widget> botones;

  /// Capa decorativa detrás del contenido, pegada arriba (el confeti).
  final Widget? fondo;

  /// Ilustración del panel izquierdo en tablet horizontal; sin ella, la
  /// columna del móvil también en tablet.
  final Widget? ilustracionTablet;

  /// Contenido de la columna de tablet (sin la ilustración); por defecto,
  /// [contenido].
  final List<Widget>? contenidoTablet;

  /// Arriba a la izquierda del panel en tablet (el botón Cerrar de T20).
  final Widget? encabezadoTablet;

  @override
  Widget build(BuildContext context) {
    final ilustracion = ilustracionTablet;
    if (ilustracion != null && context.clasePantalla.esAncho) {
      return Scaffold(
        body: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: DisposicionResultadoTablet(
            key: const ValueKey('resultado-tablet'),
            ilustracion: ilustracion,
            fondo: fondo,
            encabezado: encabezadoTablet,
            contenido: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...contenidoTablet ?? contenido,
                const SizedBox(height: separacionBotonesTablet),
                ...botones,
              ],
            ),
          ),
        ),
      );
    }
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
