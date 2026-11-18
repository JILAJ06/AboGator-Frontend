import '../repositorios/repositorio_onboarding.dart';

/// Estado "onboarding visto" en memoria: dura mientras la app esté abierta.
class OnboardingEnMemoria implements RepositorioOnboarding {
  OnboardingEnMemoria({this.vistoAlInicio = false});

  /// Valor inicial (útil en pruebas).
  final bool vistoAlInicio;
  late bool _visto = vistoAlInicio;

  @override
  Future<bool> fueVisto() async => _visto;

  @override
  Future<void> marcarVisto() async {
    _visto = true;
  }
}
