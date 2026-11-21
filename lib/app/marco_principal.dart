import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../componentes/boton_buzon.dart';
import '../componentes/navegacion_inferior_app.dart';
import '../componentes/riel_navegacion.dart';
import '../core/adaptativo/clase_pantalla.dart';
import '../datos/repositorios/proveedores_repositorios.dart';
import '../funciones/acceso/sesion.dart';
import '../funciones/inicio/logica_inicio.dart';
import '../funciones/vidas/pantalla_sin_vidas.dart' show apelacionesPendientesProvider;
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

/// Total del Buzón para la insignia del riel (tablet), cuando la pantalla no lo
/// trae en sus propios datos. Para refrescarlo: `ref.invalidate(totalBuzonRielProvider)`.
///
/// Depende de `apelacionesPendientesProvider`, que ya se invalida al resolver
/// un juicio, al registrar fallos del juego y al terminar el Examen: así la
/// insignia se actualiza sola en esos casos.
final totalBuzonRielProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(apelacionesPendientesProvider);
  final buzon = await ref.watch(repositorioApelacionesProvider).obtenerBuzon();
  return buzon.total;
});

/// Marco de las pantallas con navegación principal (Inicio, Mapa, Buzón,
/// Tienda y Perfil).
///
/// - **Móvil** (< 600): el [cuerpo], la navegación inferior con [pestana]
///   activa y, si se conoce [apelacionesPendientes], el botón Buzón fijo a
///   [separacionBuzon] de la barra.
/// - **Tablet** (≥ 600): el riel de navegación a la izquierda y el [cuerpo] a
///   la derecha, sin barra inferior ni botón Buzón (el riel ya muestra el
///   contador del Buzón).
///
/// Con [focoOrdenado] el cuerpo usa `OrderedTraversalPolicy`: quien lo usa
/// marca el orden con `FocusTraversalOrder`; el Buzón va después de todo. En
/// tablet el riel va antes que el cuerpo.
class MarcoPrincipal extends ConsumerWidget {
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

  /// `true` si la pantalla actual se muestra con el riel (tablet). Las
  /// pantallas lo usan para no reservar el espacio del botón Buzón.
  static bool conRiel(BuildContext context) => context.clasePantalla.esTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final clase = ClasePantalla.deAncho(restricciones.maxWidth);
        return clase.esTablet ? _tablet(context, ref) : _movil(context);
      },
    );
  }

  Widget _cuerpoConFoco(Widget contenido) => focoOrdenado
      ? FocusTraversalGroup(policy: OrderedTraversalPolicy(), child: contenido)
      : contenido;

  Widget _movil(BuildContext context) {
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
      body: _cuerpoConFoco(contenido),
    );
  }

  Widget _tablet(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(sesionProvider);
    final pendientes = apelacionesPendientes ?? ref.watch(totalBuzonRielProvider).value;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            right: false,
            child: RielNavegacion(
              actual: pestana,
              pendientes: pendientes,
              iniciales: usuario == null ? '' : LogicaInicio.iniciales(usuario.nombre),
              nombreUsuario: usuario?.nombre,
              alSeleccionar: (destino) => irAPestana(context, destino),
              alAjustes: () => context.go(Rutas.ajustes),
              alPerfil: () => irAPestana(context, PestanaApp.perfil),
            ),
          ),
          Expanded(child: _cuerpoConFoco(cuerpo)),
        ],
      ),
    );
  }
}
