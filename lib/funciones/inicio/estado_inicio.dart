import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';

/// Datos que muestra el Inicio, pedidos en paralelo a los repositorios.
class DatosInicio {
  const DatosInicio({
    required this.modulos,
    required this.monedas,
    required this.vidas,
    required this.apelacionesPendientes,
  });

  final List<Modulo> modulos;
  final int monedas;
  final Vidas vidas;
  final int apelacionesPendientes;
}

/// Carga los datos del Inicio. Para reintentar: `ref.invalidate(datosInicioProvider)`.
final datosInicioProvider = FutureProvider.autoDispose<DatosInicio>((ref) async {
  final progreso = ref.watch(repositorioProgresoProvider);
  final tienda = ref.watch(repositorioTiendaProvider);
  final vidas = ref.watch(repositorioVidasProvider);
  final apelaciones = ref.watch(repositorioApelacionesProvider);

  final (modulos, monedas, vidasActuales, buzon) = await (
    progreso.obtenerModulos(),
    tienda.obtenerMonedas(),
    vidas.obtenerVidas(),
    apelaciones.obtenerBuzon(),
  ).wait;

  return DatosInicio(
    modulos: modulos,
    monedas: monedas,
    vidas: vidasActuales,
    // El botón Buzón muestra el total del Buzón.
    apelacionesPendientes: buzon.total,
  );
});
