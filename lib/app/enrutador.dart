import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../funciones/bienvenida/pantalla_prueba.dart';
import 'rutas.dart';

/// Enrutador de la app. En T-00 solo tiene la pantalla de prueba.
final enrutadorProvider = Provider<GoRouter>((ref) {
  final enrutador = GoRouter(
    initialLocation: Rutas.raiz,
    routes: [GoRoute(path: Rutas.raiz, builder: (context, state) => const PantallaPrueba())],
  );
  ref.onDispose(enrutador.dispose);
  return enrutador;
});
