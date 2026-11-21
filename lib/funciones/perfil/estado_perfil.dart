import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;
import 'package:material_ui/material_ui.dart';

import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/resumen_perfil.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../acceso/sesion.dart';
import '../apelaciones/pantalla_buzon.dart';
import '../apelaciones/pantalla_juicio.dart';
import '../apelaciones/sesion_apelaciones.dart';
import '../inicio/estado_inicio.dart';
import '../juego/estado_juego.dart';
import '../mapa/estado_mapa.dart';
import '../tienda/estado_tienda.dart';
import '../vidas/pantalla_sin_vidas.dart';

/// Lo que muestra el Perfil: el resumen del servidor y el color de cada
/// módulo (para las medallas).
class DatosPerfil {
  const DatosPerfil({
    required this.resumen,
    this.coloresModulo = const {},
    this.modulos = const [],
  });

  final ResumenPerfil resumen;
  final Map<String, Color> coloresModulo;

  /// Módulos con sus sprints (para "Progreso por módulo" en tablet).
  final List<Modulo> modulos;
}

/// Carga el Perfil. Para reintentar: `ref.invalidate(datosPerfilProvider)`.
final datosPerfilProvider = FutureProvider.autoDispose<DatosPerfil>((ref) async {
  final (resumen, modulos) = await (
    ref.watch(repositorioPerfilProvider).obtenerPerfil(),
    ref.watch(repositorioProgresoProvider).obtenerModulos(),
  ).wait;
  return DatosPerfil(
    resumen: resumen,
    coloresModulo: {for (final m in modulos) m.id: m.color},
    modulos: modulos,
  );
});

/// Proveedores que guardan datos de la persona; se descartan al cerrar
/// sesión. No incluye la cola local de respuestas (se envía al volver a
/// entrar) ni el onboarding visto.
List<ProviderOrFamily> get proveedoresDeLaPersona => [
  datosInicioProvider,
  datosModuloProvider,
  datosBuzonProvider,
  datosJuicioProvider,
  sesionApelacionesProvider,
  vidasActualesProvider,
  apelacionesPendientesProvider,
  datosJuegoProvider,
  juegoProvider,
  datosTiendaProvider,
  datosPerfilProvider,
];

/// Cierra la sesión en el servidor y, si lo logra, borra la sesión local y
/// los datos de la persona. Si falla, lanza y no cambia nada.
Future<void> cerrarSesion(WidgetRef ref) async {
  await ref.read(repositorioAutenticacionProvider).cerrarSesion();
  ref.read(sesionProvider.notifier).cerrar();
  for (final p in proveedoresDeLaPersona) {
    ref.invalidate(p);
  }
}
