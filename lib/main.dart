import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'funciones/ajustes/estado_ajustes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Solo vertical en móvil; la tablet se atiende en T-12.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final contenedor = await crearContenedor();
  runApp(UncontrolledProviderScope(container: contenedor, child: const AppAbogator()));
}

/// Contenedor de la app con los ajustes del dispositivo ya cargados, para
/// que el tema y el tamaño de texto salgan bien desde el primer cuadro.
Future<ProviderContainer> crearContenedor({List<Override> overrides = const []}) async {
  final contenedor = ProviderContainer(overrides: overrides);
  final ajustes = await cargarAjustes(contenedor);
  contenedor.read(ajustesProvider.notifier).cargados(ajustes);
  return contenedor;
}
