import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/rutas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/repositorios/repositorio_onboarding.dart';

/// Reglas del flujo de bienvenida (Splash → Onboarding → Inicio de sesión).
/// Las pantallas solo piden el destino y navegan.
class FlujoBienvenida {
  const FlujoBienvenida(this._onboarding);

  /// Tiempo que se muestra el Splash antes de avanzar.
  static const Duration duracionSplash = Duration(seconds: 2);

  final RepositorioOnboarding _onboarding;

  /// A dónde ir al terminar el Splash: al onboarding la primera vez y
  /// directo al inicio de sesión si ya se vio.
  Future<String> destinoTrasSplash() async =>
      await _onboarding.fueVisto() ? Rutas.inicioSesion : Rutas.onboarding;

  /// "Omitir" o "¡Comenzar!": marca el onboarding como visto y devuelve el destino.
  Future<String> terminarOnboarding() async {
    await _onboarding.marcarVisto();
    return Rutas.inicioSesion;
  }
}

final flujoBienvenidaProvider = Provider<FlujoBienvenida>(
  (ref) => FlujoBienvenida(ref.watch(repositorioOnboardingProvider)),
);
