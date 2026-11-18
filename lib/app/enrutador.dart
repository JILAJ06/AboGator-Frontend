import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/textos/textos.dart';
import '../funciones/bienvenida/galeria_componentes.dart';
import '../funciones/bienvenida/pantalla_onboarding.dart';
import '../funciones/bienvenida/pantalla_splash.dart';
import 'pantalla_pendiente.dart';
import 'rutas.dart';

/// Enrutador de la app. Arranca en el Splash.
final enrutadorProvider = Provider<GoRouter>((ref) {
  final enrutador = GoRouter(
    initialLocation: Rutas.splash,
    routes: [
      GoRoute(path: Rutas.raiz, redirect: (context, state) => Rutas.splash),
      GoRoute(path: Rutas.splash, builder: (context, state) => const PantallaSplash()),
      GoRoute(path: Rutas.onboarding, builder: (context, state) => const PantallaOnboarding()),
      // Marcador hasta T-03.
      GoRoute(
        path: Rutas.inicioSesion,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteInicioSesion),
      ),
      if (kDebugMode)
        GoRoute(path: Rutas.galeria, builder: (context, state) => const GaleriaComponentes()),
    ],
  );
  ref.onDispose(enrutador.dispose);
  return enrutador;
});
