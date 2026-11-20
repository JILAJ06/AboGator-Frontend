import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/apelacion.dart';
import '../../datos/modelos/resultado_apelacion.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../inicio/estado_inicio.dart';
import '../juego/estado_juego.dart';
import '../mapa/estado_mapa.dart';
import '../vidas/pantalla_sin_vidas.dart';
import 'logica_apelacion.dart';
import 'pantalla_buzon.dart';

/// En qué parte de la apelación actual está la sesión.
enum FaseApelacion { juicio, resultado }

/// Sesión de apelaciones: la cola de ids, la actual y, tras resolverla, su
/// resultado y las vidas antes y después.
class SesionApelaciones {
  const SesionApelaciones({
    required this.ids,
    this.indice = 0,
    this.fase = FaseApelacion.juicio,
    this.resultado,
    this.apelacion,
    this.tarjeta,
    this.vidasAntes,
    this.vidasDespues,
  });

  final List<String> ids;
  final int indice;
  final FaseApelacion fase;

  /// Lo de la apelación ya resuelta (para mostrar su resultado).
  final ResultadoApelacion? resultado;
  final Apelacion? apelacion;
  final Tarjeta? tarjeta;
  final int? vidasAntes;
  final int? vidasDespues;

  String get actual => ids[indice];
  int get total => ids.length;

  /// La siguiente de la cola; `null` si esta es la última.
  String? get siguiente => indice + 1 < ids.length ? ids[indice + 1] : null;

  bool get esUltima => siguiente == null;
}

/// Sesión de apelaciones viva entre rutas hasta terminar o salir; `null`
/// sin sesión.
class SesionApelacionesNotifier extends Notifier<SesionApelaciones?> {
  @override
  SesionApelaciones? build() => null;

  /// Empieza una sesión con [ids] (todas las de hoy o una sola).
  void iniciar(List<String> ids) {
    if (ids.isEmpty) return;
    state = SesionApelaciones(ids: List.unmodifiable(ids));
  }

  /// Para el enlace profundo: si [id] no está en la sesión, empieza una de
  /// una; si está, la pone como actual.
  void asegurar(String id) {
    final s = state;
    if (s == null || !s.ids.contains(id)) {
      iniciar([id]);
    } else if (s.actual != id) {
      state = SesionApelaciones(ids: s.ids, indice: s.ids.indexOf(id));
    }
  }

  /// Resuelve la apelación actual con [veredicto]: la manda al servidor y,
  /// si se ganó con menos de 5 vidas, recupera una. Pasa al resultado y
  /// refresca los contadores. Si falla, lanza y la sesión no cambia.
  Future<void> resolver({
    required Apelacion apelacion,
    required Tarjeta tarjeta,
    required Veredicto veredicto,
  }) async {
    final ganada = LogicaApelacion.gana(tarjeta, veredicto);
    final repoVidas = ref.read(repositorioVidasProvider);
    final resultado = await ref
        .read(repositorioApelacionesProvider)
        .resolverApelacion(apelacion.id, ganada: ganada);
    final antes = (await repoVidas.obtenerVidas()).cantidad;
    final despues = ganada && antes < Vidas.maximo
        ? (await repoVidas.recuperarVida()).cantidad
        : antes;
    final s = state;
    if (!ref.mounted || s == null) return;
    state = SesionApelaciones(
      ids: s.ids,
      indice: s.indice,
      fase: FaseApelacion.resultado,
      resultado: resultado,
      apelacion: apelacion,
      tarjeta: tarjeta,
      vidasAntes: antes,
      vidasDespues: despues,
    );
    refrescar();
  }

  /// Pasa a la siguiente apelación; devuelve su id (o `null` si no hay).
  String? avanzar() {
    final s = state;
    final siguiente = s?.siguiente;
    if (s == null || siguiente == null) return null;
    state = SesionApelaciones(ids: s.ids, indice: s.indice + 1);
    return siguiente;
  }

  /// Termina la sesión (al volver al Buzón o salir).
  void terminar() {
    state = null;
    refrescar();
  }

  /// Contadores y vidas al día: Buzón, Inicio, mapa, "Sin vidas" y juego.
  void refrescar() {
    ref
      ..invalidate(datosBuzonProvider)
      ..invalidate(datosInicioProvider)
      ..invalidate(datosModuloProvider)
      ..invalidate(apelacionesPendientesProvider)
      ..invalidate(vidasActualesProvider)
      ..invalidate(datosJuegoProvider);
  }
}

final sesionApelacionesProvider = NotifierProvider<SesionApelacionesNotifier, SesionApelaciones?>(
  SesionApelacionesNotifier.new,
);
