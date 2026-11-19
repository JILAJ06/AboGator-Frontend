import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../componentes/boton_buzon.dart';
import '../componentes/navegacion_inferior_app.dart';
import 'rutas.dart';

/// Lleva a la pantalla de una pestaña de la barra inferior. "Mapa" vuelve al
/// Inicio, salvo que ya se esté en él.
void irAPestana(BuildContext context, PestanaApp pestana) {
  final enrutador = GoRouter.of(context);
  final destino = switch (pestana) {
    PestanaApp.mapa => Rutas.inicio,
    PestanaApp.buzon => Rutas.buzon,
    PestanaApp.tienda => Rutas.tienda,
    PestanaApp.perfil => Rutas.perfil,
  };
  if (enrutador.routerDelegate.currentConfiguration.uri.path == destino) return;
  enrutador.go(destino);
}

/// Marco de las pantallas con barra inferior (07 Inicio y 08 Mapa de sprints):
/// el [cuerpo], la navegación inferior con [pestana] activa y, si se conoce
/// [apelacionesPendientes], el botón Buzón fijo a [separacionBuzon] de la barra.
///
/// Con [focoOrdenado] el cuerpo usa `OrderedTraversalPolicy`: quien lo usa
/// marca el orden con `FocusTraversalOrder`; el Buzón va después de todo.
class MarcoPrincipal extends StatelessWidget {
  const MarcoPrincipal({
    required this.pestana,
    required this.cuerpo,
    this.apelacionesPendientes,
    this.focoOrdenado = false,
    super.key,
  });

  /// Espacio entre el botón Buzón y la barra inferior (Figma: 760 − 732).
  static const double separacionBuzon = 28;

  /// Reserva al final del contenido para que el Buzón no tape nada.
  static const double reservaBuzon = BotonBuzon.lado + separacionBuzon + 16;

  /// Orden de foco del Buzón dentro de un cuerpo ordenado (después de todo).
  static const double ordenBuzon = 1000;

  final PestanaApp pestana;
  final Widget cuerpo;
  final int? apelacionesPendientes;
  final bool focoOrdenado;

  @override
  Widget build(BuildContext context) {
    final pendientes = apelacionesPendientes;
    final contenido = Stack(
      children: [
        Positioned.fill(child: cuerpo),
        if (pendientes != null)
          Positioned(
            right: 24,
            bottom: separacionBuzon,
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(ordenBuzon),
              child: BotonBuzon(
                pendientes: pendientes,
                alPresionar: () => irAPestana(context, PestanaApp.buzon),
              ),
            ),
          ),
      ],
    );
    return Scaffold(
      bottomNavigationBar: NavegacionInferiorApp(
        actual: pestana,
        alSeleccionar: (destino) => irAPestana(context, destino),
      ),
      body: focoOrdenado
          ? FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: contenido)
          : contenido,
    );
  }
}
