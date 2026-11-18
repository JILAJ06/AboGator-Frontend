import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../funciones/bienvenida/galeria_componentes.dart';
import 'rutas.dart';

/// Enrutador de la app. Por ahora solo tiene la galería de componentes.
final enrutadorProvider = Provider<GoRouter>((ref) {
  final enrutador = GoRouter(
    initialLocation: Rutas.raiz,
    routes: [GoRoute(path: Rutas.raiz, builder: (context, state) => const GaleriaComponentes())],
  );
  ref.onDispose(enrutador.dispose);
  return enrutador;
});
