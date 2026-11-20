import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/servicios/servicio_haptico.dart';
import '../../datos/modelos/ajustes.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';

/// Ajustes de accesibilidad vivos (pantalla 26). El estado inicial ya viene
/// cargado (`main` lo pone con [AjustesNotifier.cargados] antes del primer
/// cuadro), así que el tema y el tamaño correctos salen sin parpadeo.
class AjustesNotifier extends Notifier<Ajustes> {
  @override
  Ajustes build() => const Ajustes();

  /// Pone los ajustes leídos del dispositivo (al arrancar).
  void cargados(Ajustes ajustes) => state = ajustes;

  /// Aplica [nuevos] al instante y los guarda. Si guardar falla, vuelve a lo
  /// anterior y devuelve `false` (quien llama avisa).
  Future<bool> cambiar(Ajustes nuevos) async {
    final antes = state;
    if (nuevos == antes) return true;
    state = nuevos;
    try {
      await ref.read(repositorioAjustesProvider).guardar(nuevos);
      return true;
    } on Object {
      if (ref.mounted && state == nuevos) state = antes;
      return false;
    }
  }
}

final ajustesProvider = NotifierProvider<AjustesNotifier, Ajustes>(AjustesNotifier.new);

/// Lee los ajustes del dispositivo; si falla, los por defecto.
Future<Ajustes> cargarAjustes(ProviderContainer contenedor) async {
  try {
    return await contenedor.read(repositorioAjustesProvider).cargar();
  } on Object {
    return const Ajustes();
  }
}

/// Vibración de la app; respeta el ajuste "Vibración háptica" y no vibra en
/// web. Sustituible en pruebas.
final servicioHapticoProvider = Provider<ServicioHaptico>(
  (ref) => ServicioHapticoSistema(activo: () => ref.read(ajustesProvider).haptica),
);
