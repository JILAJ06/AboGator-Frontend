import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/textos/textos.dart';
import '../datos/sincronizacion/estado_sincronizacion.dart';
import '../funciones/acceso/pantalla_inicio_sesion.dart';
import '../funciones/acceso/pantalla_registro.dart';
import '../funciones/acceso/sesion.dart';
import '../funciones/bienvenida/galeria_componentes.dart';
import '../funciones/bienvenida/pantalla_onboarding.dart';
import '../funciones/bienvenida/pantalla_splash.dart';
import '../funciones/inicio/pantalla_inicio.dart';
import '../funciones/juego/pantalla_juego.dart';
import '../funciones/juego/pantalla_sprint_completado.dart';
import '../funciones/juego/pantalla_startup_quiebra.dart';
import '../funciones/mapa/pantalla_intro_sprint.dart';
import '../funciones/mapa/pantalla_mapa_sprints.dart';
import '../funciones/vidas/pantalla_sin_vidas.dart';
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
        // Sin sesión (no debería pasar) se vuelve al inicio de sesión. También
        // aplica al mapa y a la intro, que cuelgan de esta ruta.
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => const PantallaInicio(),
        routes: [
          GoRoute(
            path: Rutas.segmentoMapa,
            builder: (context, state) =>
                PantallaMapaSprints(moduloId: state.pathParameters['moduloId']!),
            routes: [
              GoRoute(
                path: Rutas.segmentoIntro,
                builder: (context, state) => PantallaIntroSprint(
                  moduloId: state.pathParameters['moduloId']!,
                  sprintId: state.pathParameters['sprintId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Rutas.juego,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => PantallaJuego(sprintId: state.pathParameters['sprintId']!),
      ),
      GoRoute(
        path: Rutas.sprintCompletado,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) =>
            PantallaSprintCompletado(sprintId: state.pathParameters['sprintId']!),
      ),
      GoRoute(
        path: Rutas.startupQuiebra,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) =>
            PantallaStartupQuiebra(sprintId: state.pathParameters['sprintId']!),
      ),
      GoRoute(
        path: Rutas.sinVidas,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) =>
            PantallaSinVidas(moduloId: state.uri.queryParameters['modulo']),
      ),
      // Marcadores hasta T-09, T-10 y T-11.
      GoRoute(
        path: Rutas.crisisJefe,
        builder: (context, state) => const PantallaPendiente(texto: Textos.pendienteJefe),
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
  // Al abrir la app se envía lo que haya quedado en la cola local.
  ref.read(respuestasPendientesProvider);
  return enrutador;
});
