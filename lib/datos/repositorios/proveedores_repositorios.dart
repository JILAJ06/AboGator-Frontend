import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks/mock_apelaciones.dart';
import '../mocks/mock_autenticacion.dart';
import '../mocks/mock_progreso.dart';
import '../mocks/mock_tarjetas.dart';
import '../mocks/mock_tienda.dart';
import '../mocks/mock_vidas.dart';
import '../mocks/onboarding_en_memoria.dart';
import 'repositorio_apelaciones.dart';
import 'repositorio_autenticacion.dart';
import 'repositorio_onboarding.dart';
import 'repositorio_progreso.dart';
import 'repositorio_tarjetas.dart';
import 'repositorio_tienda.dart';
import 'repositorio_vidas.dart';

// Único lugar donde se elige la implementación de cada repositorio.
// Las pantallas solo conocen la interfaz; en T-14 basta con cambiar
// aquí los mocks por las implementaciones HTTP.

final repositorioAutenticacionProvider = Provider<RepositorioAutenticacion>(
  (ref) => MockAutenticacion(),
);

final repositorioProgresoProvider = Provider<RepositorioProgreso>((ref) => MockProgreso());

final repositorioTarjetasProvider = Provider<RepositorioTarjetas>((ref) => MockTarjetas());

final repositorioVidasProvider = Provider<RepositorioVidas>((ref) => MockVidas());

final repositorioApelacionesProvider = Provider<RepositorioApelaciones>((ref) => MockApelaciones());

final repositorioTiendaProvider = Provider<RepositorioTienda>((ref) => MockTienda());

/// Estado "onboarding visto" (en memoria hasta T-08).
final repositorioOnboardingProvider = Provider<RepositorioOnboarding>(
  (ref) => OnboardingEnMemoria(),
);
