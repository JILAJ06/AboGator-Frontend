import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/ajustes_notificaciones.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';

/// Preferencias de notificaciones de racha (pantalla 34, T-13b), guardadas con
/// el repositorio de ajustes. Cada cambio se guarda al instante; si no se
/// puede, se revierte.
class NotificacionesNotifier extends AsyncNotifier<AjustesNotificaciones> {
  @override
  Future<AjustesNotificaciones> build() =>
      ref.watch(repositorioAjustesProvider).cargarNotificaciones();

  /// Guarda [nuevas]; devuelve `false` (y deja las anteriores) si falla.
  Future<bool> cambiar(AjustesNotificaciones nuevas) async {
    final previas = state.value ?? const AjustesNotificaciones();
    state = AsyncData(nuevas);
    try {
      await ref.read(repositorioAjustesProvider).guardarNotificaciones(nuevas);
      return true;
    } on Object {
      if (ref.mounted) state = AsyncData(previas);
      return false;
    }
  }
}

final ajustesNotificacionesProvider =
    AsyncNotifierProvider<NotificacionesNotifier, AjustesNotificaciones>(
      NotificacionesNotifier.new,
    );
