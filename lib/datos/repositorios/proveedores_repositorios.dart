import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/base_local.dart';
import '../local/cola_respuestas_sqlite.dart';
import '../local/onboarding_sqlite.dart';
import '../mocks/cola_respuestas_en_memoria.dart';
import '../mocks/mock_apelaciones.dart';
import '../mocks/mock_autenticacion.dart';
import '../mocks/mock_perfil.dart';
import '../mocks/mock_progreso.dart';
import '../mocks/mock_respuestas.dart';
import '../mocks/mock_tarjetas.dart';
import '../mocks/mock_tienda.dart';
import '../mocks/mock_vidas.dart';
import '../mocks/onboarding_en_memoria.dart';
import '../sincronizacion/servicio_conexion.dart';
import 'cola_respuestas.dart';
import 'repositorio_apelaciones.dart';
import 'repositorio_autenticacion.dart';
import 'repositorio_onboarding.dart';
import 'repositorio_perfil.dart';
import 'repositorio_progreso.dart';
import 'repositorio_respuestas.dart';
import 'repositorio_tarjetas.dart';
import 'repositorio_tienda.dart';
import 'repositorio_vidas.dart';

// Único lugar donde se elige la implementación de cada repositorio.
// Las pantallas solo conocen la interfaz; en T-14 basta con cambiar
// aquí los mocks por las implementaciones HTTP.

/// SQLite solo en Android e iOS: en web (sqflite no corre en el navegador)
/// y en `flutter test` se usa memoria.
final bool usarBaseLocal = !kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST');

final repositorioAutenticacionProvider = Provider<RepositorioAutenticacion>(
  (ref) => MockAutenticacion(),
);

final repositorioProgresoProvider = Provider<RepositorioProgreso>((ref) => MockProgreso());

final repositorioTarjetasProvider = Provider<RepositorioTarjetas>((ref) => MockTarjetas());

final repositorioVidasProvider = Provider<RepositorioVidas>((ref) => MockVidas());

final repositorioApelacionesProvider = Provider<RepositorioApelaciones>((ref) => MockApelaciones());

final repositorioTiendaProvider = Provider<RepositorioTienda>((ref) => MockTienda());

final repositorioPerfilProvider = Provider<RepositorioPerfil>(
  (ref) => MockPerfil(autenticacion: ref.watch(repositorioAutenticacionProvider)),
);

/// Lado del servidor de las respuestas del juego (mock hasta T-14).
final repositorioRespuestasProvider = Provider<RepositorioRespuestas>((ref) => MockRespuestas());

/// Base SQLite del dispositivo (se abre en la primera operación).
final baseLocalProvider = Provider<BaseLocal>((ref) {
  final base = BaseLocal();
  ref.onDispose(base.cerrar);
  return base;
});

/// Estado "onboarding visto": SQLite en el dispositivo, memoria en web y
/// en pruebas.
final repositorioOnboardingProvider = Provider<RepositorioOnboarding>(
  (ref) => usarBaseLocal ? OnboardingSqlite(ref.watch(baseLocalProvider)) : OnboardingEnMemoria(),
);

/// Cola local de respuestas: SQLite en el dispositivo, memoria en web y en
/// pruebas.
final repositorioColaRespuestasProvider = Provider<ColaRespuestas>(
  (ref) => usarBaseLocal
      ? ColaRespuestasSqlite(ref.watch(baseLocalProvider))
      : ColaRespuestasEnMemoria(),
);

/// Conexión con el servidor (simulada hasta T-14).
final servicioConexionProvider = Provider<ServicioConexion>((ref) {
  final conexion = ConexionSimulada();
  ref.onDispose(conexion.cerrar);
  return conexion;
});
