import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/textos/textos.dart';
import '../funciones/acceso/pantalla_inicio_sesion.dart';
import '../funciones/acceso/pantalla_registro.dart';
import '../funciones/acceso/sesion.dart';
import '../funciones/bienvenida/galeria_componentes.dart';
import '../funciones/bienvenida/pantalla_onboarding.dart';
import '../funciones/bienvenida/pantalla_splash.dart';
import '../funciones/inicio/pantalla_inicio.dart';
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
      GoRoute(
        path: Rutas.inicio,
        // Sin sesión (no debería pasar) se vuelve al inicio de sesión.
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => const PantallaInicio(),
      ),
      // Marcadores hasta T-04b, T-09 y T-10.
      GoRoute(
        path: Rutas.mapaSprints,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteMapaSprints),
      ),
      GoRoute(
        path: Rutas.introSprint,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteIntroSprint),
      ),
      GoRoute(
        path: Rutas.buzon,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteBuzon),
      ),
      GoRoute(
        path: Rutas.tienda,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteTienda),
      ),
      GoRoute(
        path: Rutas.perfil,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendientePerfil),
      ),
      if (kDebugMode)
        GoRoute(path: Rutas.galeria, builder: (context, state) => const GaleriaComponentes()),
    ],
  );
  ref.onDispose(enrutador.dispose);
  return enrutador;
});
