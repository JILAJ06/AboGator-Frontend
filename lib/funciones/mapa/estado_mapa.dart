import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import 'logica_mapa.dart';

/// Datos del mapa de sprints y de la intro de un módulo.
class DatosModulo {
  const DatosModulo({
    required this.modulo,
    required this.vidas,
    required this.apelacionesPendientes,
  });

  /// `null` si el módulo no existe.
  final Modulo? modulo;
  final Vidas vidas;
  final int apelacionesPendientes;
}

/// Carga en paralelo los módulos, las vidas y las apelaciones pendientes, y
/// elige el módulo pedido. Para reintentar: `ref.invalidate(datosModuloProvider(id))`.
final datosModuloProvider = FutureProvider.autoDispose.family<DatosModulo, String>((
  ref,
  moduloId,
) async {
  final progreso = ref.watch(repositorioProgresoProvider);
  final vidas = ref.watch(repositorioVidasProvider);
  final apelaciones = ref.watch(repositorioApelacionesProvider);

  final (modulos, vidasActuales, buzon) = await (
    progreso.obtenerModulos(),
    vidas.obtenerVidas(),
    apelaciones.obtenerBuzon(),
  ).wait;

  return DatosModulo(
    modulo: LogicaMapa.moduloPorId(modulos, moduloId),
    vidas: vidasActuales,
    // El botón Buzón muestra el total del Buzón.
    apelacionesPendientes: buzon.total,
  );
});
