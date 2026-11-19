import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/textos/textos.dart';
import '../funciones/acceso/pantalla_inicio_sesion.dart';
import '../funciones/acceso/pantalla_registro.dart';
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
      GoRoute(path: Rutas.inicioSesion, builder: (context, state) => const PantallaInicioSesion()),
      GoRoute(path: Rutas.registro, builder: (context, state) => const PantallaRegistro()),
      // Marcador hasta T-04.
      GoRoute(
        path: Rutas.inicio,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteInicio),
      ),
      if (kDebugMode)
        GoRoute(path: Rutas.galeria, builder: (context, state) => const GaleriaComponentes()),
    ],
  );
  ref.onDispose(enrutador.dispose);
  return enrutador;
});
