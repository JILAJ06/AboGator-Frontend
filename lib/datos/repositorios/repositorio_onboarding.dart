/// Recuerda si el usuario ya vio el onboarding (pantallas 02–04).
///
/// Hoy vive en memoria; en T-08 se guardará en SQLite sin cambiar la interfaz.
abstract interface class RepositorioOnboarding {
  Future<bool> fueVisto();

  Future<void> marcarVisto();
}
