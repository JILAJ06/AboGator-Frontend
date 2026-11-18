import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Modo de color elegido por el usuario.
///
/// Por defecto sigue al sistema. En T-10 se podrá forzar desde Ajustes
/// (y entonces se guardará en el dispositivo).
class ModoTemaNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void establecer(ThemeMode modo) {
    state = modo;
  }
}

final modoTemaProvider = NotifierProvider<ModoTemaNotifier, ThemeMode>(ModoTemaNotifier.new);
