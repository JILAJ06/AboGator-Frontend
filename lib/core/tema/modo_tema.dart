import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../funciones/ajustes/estado_ajustes.dart';

/// Modo de color (sistema, claro u oscuro).
///
/// Desde T-10b sale de los ajustes del dispositivo (`ajustesProvider`):
/// [ModoTemaNotifier.establecer] lo cambia al instante y lo guarda, así que
/// se conserva al reabrir la app. Lo usan la app y la galería.
class ModoTemaNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(ajustesProvider.select((a) => a.modoTema));

  /// Cambia y guarda el modo. Devuelve `false` si no se pudo guardar (el modo
  /// vuelve al anterior).
  Future<bool> establecer(ThemeMode modo) {
    final ajustes = ref.read(ajustesProvider);
    return ref.read(ajustesProvider.notifier).cambiar(ajustes.copyWith(modoTema: modo));
  }
}

final modoTemaProvider = NotifierProvider<ModoTemaNotifier, ThemeMode>(ModoTemaNotifier.new);
