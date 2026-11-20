/// Recuerda si el usuario ya vio el onboarding (pantallas 02–04).
///
/// En el dispositivo se guarda en SQLite (`OnboardingSqlite`); en web y en
/// pruebas, en memoria (`OnboardingEnMemoria`).
abstract interface class RepositorioOnboarding {
  Future<bool> fueVisto();

  Future<void> marcarVisto();
}
