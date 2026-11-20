import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/articulo_tienda.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../inicio/estado_inicio.dart';
import '../juego/estado_juego.dart';
import '../mapa/estado_mapa.dart';

/// Lo que muestra la Tienda: catálogo, saldo, comodines y congeladores.
class DatosTienda {
  const DatosTienda({
    required this.articulos,
    required this.monedas,
    required this.comodines,
    required this.congeladores,
  });

  final List<ArticuloTienda> articulos;
  final int monedas;
  final Map<Comodin, int> comodines;
  final int congeladores;

  /// Unidades que tiene de [a].
  int cantidad(ArticuloTienda a) {
    final c = a.comodin;
    return c == null ? congeladores : (comodines[c] ?? 0);
  }
}

/// Carga la Tienda. Para refrescar: `ref.invalidate(datosTiendaProvider)`.
final datosTiendaProvider = FutureProvider.autoDispose<DatosTienda>((ref) async {
  final tienda = ref.watch(repositorioTiendaProvider);
  final (articulos, monedas, comodines, congeladores) = await (
    tienda.obtenerArticulos(),
    tienda.obtenerMonedas(),
    tienda.obtenerComodines(),
    tienda.obtenerCongeladoresRacha(),
  ).wait;
  return DatosTienda(
    articulos: articulos,
    monedas: monedas,
    comodines: comodines,
    congeladores: congeladores,
  );
});

/// Tras una compra: la Tienda, el Inicio, el mapa y el juego leen monedas o
/// comodines. El juego solo se recarga al entrar (su proveedor se descarta al
/// salir), así que uno en curso no se rompe.
void refrescarTrasCompra(WidgetRef ref) {
  ref
    ..invalidate(datosTiendaProvider)
    ..invalidate(datosInicioProvider)
    ..invalidate(datosModuloProvider)
    ..invalidate(datosJuegoProvider);
}
