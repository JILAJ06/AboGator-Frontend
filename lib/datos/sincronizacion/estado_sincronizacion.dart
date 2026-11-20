import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/respuesta_pendiente.dart';
import '../repositorios/proveedores_repositorios.dart';
import 'servicio_conexion.dart';
import 'sincronizador_respuestas.dart';

/// Estado de la conexión, al día con [ServicioConexion.cambios].
class ConexionNotifier extends Notifier<EstadoConexion> {
  @override
  EstadoConexion build() {
    final servicio = ref.watch(servicioConexionProvider);
    final suscripcion = servicio.cambios.listen((estado) => state = estado);
    ref.onDispose(suscripcion.cancel);
    return servicio.estado;
  }
}

final conexionProvider = NotifierProvider<ConexionNotifier, EstadoConexion>(ConexionNotifier.new);

final sincronizadorProvider = Provider<SincronizadorRespuestas>(
  (ref) => SincronizadorRespuestas(
    cola: ref.watch(repositorioColaRespuestasProvider),
    servidor: ref.watch(repositorioRespuestasProvider),
  ),
);

/// Cuántas respuestas esperan en la cola local. Se refresca al agregar, al
/// enviar y al volver la conexión.
///
/// También dispara la sincronización: al guardar una respuesta estando en
/// línea, al volver la conexión y al crearse (al abrir la app).
class RespuestasPendientesNotifier extends Notifier<int> {
  @override
  int build() {
    ref.listen(conexionProvider, (antes, ahora) {
      if (ahora == EstadoConexion.enLinea && antes != EstadoConexion.enLinea) {
        unawaited(sincronizar());
      } else {
        unawaited(refrescar());
      }
    });
    // Al abrir la app: lo que haya quedado de la sesión anterior.
    Future.microtask(sincronizar);
    return 0;
  }

  /// Guarda [respuesta] en la cola y, si hay conexión, intenta enviarla sin
  /// que nadie tenga que esperar a la red.
  Future<void> agregar(RespuestaPendiente respuesta) async {
    await ref.read(repositorioColaRespuestasProvider).agregar(respuesta);
    await refrescar();
    if (ref.read(conexionProvider) == EstadoConexion.enLinea) await sincronizar();
  }

  /// Envía la cola (solo con conexión) y refresca la cantidad.
  Future<void> sincronizar() async {
    if (ref.read(conexionProvider) == EstadoConexion.enLinea) {
      await ref.read(sincronizadorProvider).sincronizar();
    }
    await refrescar();
  }

  Future<void> refrescar() async {
    final cantidad = await ref.read(repositorioColaRespuestasProvider).cantidadPendientes();
    if (ref.mounted) state = cantidad;
  }
}

final respuestasPendientesProvider = NotifierProvider<RespuestasPendientesNotifier, int>(
  RespuestasPendientesNotifier.new,
);
