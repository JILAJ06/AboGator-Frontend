import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../datos/modelos/examen.dart';
import '../datos/sincronizacion/estado_sincronizacion.dart';
import '../funciones/acceso/pantalla_inicio_sesion.dart';
import '../funciones/acceso/pantalla_registro.dart';
import '../funciones/acceso/recuperacion/pantallas_recuperacion.dart';
import '../funciones/acceso/sesion.dart';
import '../funciones/ajustes/pantalla_ajustes.dart';
import '../funciones/apelaciones/pantalla_buzon.dart';
import '../funciones/apelaciones/pantalla_juicio.dart';
import '../funciones/bienvenida/galeria_componentes.dart';
import '../funciones/bienvenida/pantalla_onboarding.dart';
import '../funciones/bienvenida/pantalla_splash.dart';
import '../funciones/inicio/pantalla_inicio.dart';
import '../funciones/jefe/estado_examen.dart';
import '../funciones/jefe/pantalla_jefe.dart';
import '../funciones/jefe/pantalla_resultado.dart';
import '../funciones/juego/pantalla_juego.dart';
import '../funciones/juego/pantalla_sprint_completado.dart';
import '../funciones/juego/pantalla_startup_quiebra.dart';
import '../funciones/legal/pantalla_legal.dart';
import '../funciones/mapa/pantalla_intro_sprint.dart';
import '../funciones/mapa/pantalla_mapa_sprints.dart';
import '../funciones/notificaciones/pantalla_notificaciones.dart';
import '../funciones/perfil/pantalla_perfil.dart';
import '../funciones/tienda/pantalla_tienda.dart';
import '../funciones/vidas/pantalla_sin_vidas.dart';
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
      // T-13b · 31 a 31e Recuperar contraseña (sin sesión).
      GoRoute(
        path: Rutas.recuperar,
        builder: (context, state) => const PantallaRecuperar(),
        routes: [
          GoRoute(
            path: Rutas.segmentoEnviado,
            builder: (context, state) => const PantallaCorreoEnviado(),
          ),
          GoRoute(
            path: Rutas.segmentoNueva,
            // T-14: el token llega en el enlace profundo del correo.
            builder: (context, state) =>
                PantallaNuevaContrasena(token: state.uri.queryParameters['token'] ?? ''),
          ),
          GoRoute(
            path: Rutas.segmentoListo,
            builder: (context, state) => const PantallaResultadoRecuperacion(caducado: false),
          ),
          GoRoute(
            path: Rutas.segmentoCaducado,
            builder: (context, state) => const PantallaResultadoRecuperacion(caducado: true),
          ),
        ],
      ),
      // T-13b · 32 Aviso de Privacidad y 33 Términos de uso (sin sesión: los
      // abre también el Registro).
      GoRoute(
        path: Rutas.legalAviso,
        builder: (context, state) => const PantallaLegal(tipo: TipoDocumentoLegal.avisoPrivacidad),
      ),
      GoRoute(
        path: Rutas.legalTerminos,
        builder: (context, state) => const PantallaLegal(tipo: TipoDocumentoLegal.terminos),
      ),
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
      // 27 a 28c en la misma ruta; 29 y 30 son sus hijas.
      GoRoute(
        path: Rutas.crisisJefe,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => PantallaJefe(moduloId: state.pathParameters['moduloId']!),
        routes: [
          GoRoute(
            path: Rutas.segmentoAuditoriaSuperada,
            redirect: (context, state) =>
                _redirigirResultado(ref, state.pathParameters['moduloId']!, aprobado: true),
            builder: (context, state) =>
                PantallaAuditoriaSuperada(moduloId: state.pathParameters['moduloId']!),
          ),
          GoRoute(
            path: Rutas.segmentoInspectoraGano,
            redirect: (context, state) =>
                _redirigirResultado(ref, state.pathParameters['moduloId']!, aprobado: false),
            builder: (context, state) =>
                PantallaInspectoraGano(moduloId: state.pathParameters['moduloId']!),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.buzon,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => const PantallaBuzon(),
        routes: [
          // 22 Juicio y su resultado (también el enlace profundo de 21b).
          GoRoute(
            path: ':apelacionId',
            builder: (context, state) =>
                PantallaJuicio(apelacionId: state.pathParameters['apelacionId']!),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.tienda,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => const PantallaTienda(),
      ),
      GoRoute(
        path: Rutas.perfil,
        // La redirección sin sesión cubre también las rutas hijas.
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) => const PantallaPerfil(),
        routes: [
          // Sin navegación inferior: 26 Ajustes.
          GoRoute(
            path: Rutas.segmentoAjustes,
            builder: (context, state) => const PantallaAjustes(),
          ),
        ],
      ),
      // T-13b · 34 Notificaciones de racha (con sesión).
      GoRoute(
        path: Rutas.notificacionesRacha,
        redirect: (context, state) => ref.read(sesionProvider) == null ? Rutas.inicioSesion : null,
        builder: (context, state) =>
            PantallaNotificaciones(desdeRegistro: state.uri.queryParameters['desde'] == 'registro'),
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

/// 29 y 30 solo se abren con el examen de [moduloId] terminado: sin él van al
/// mapa del módulo y, si el resultado no coincide, a la pantalla que le toca.
String? _redirigirResultado(Ref ref, String moduloId, {required bool aprobado}) {
  final examen = ref.read(examenProvider);
  if (examen == null || examen.moduloId != moduloId || examen.fase != FaseJefe.terminado) {
    return Rutas.mapaSprintsDe(moduloId);
  }
  final fueAprobado = examen.resultado == EstadoExamen.aprobado;
  if (fueAprobado == aprobado) return null;
  return fueAprobado ? Rutas.auditoriaSuperadaDe(moduloId) : Rutas.inspectoraGanoDe(moduloId);
}
