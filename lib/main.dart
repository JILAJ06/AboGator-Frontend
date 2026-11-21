import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'core/adaptativo/clase_pantalla.dart';
import 'funciones/ajustes/estado_ajustes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Solo vertical en el teléfono; la tablet gira libremente (WCAG 1.3.4).
  final vista = PlatformDispatcher.instance.implicitView;
  final tamano = vista == null ? Size.zero : vista.physicalSize / vista.devicePixelRatio;
  await SystemChrome.setPreferredOrientations(orientacionesPermitidas(tamano));
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
