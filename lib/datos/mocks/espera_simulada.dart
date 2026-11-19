/// Espera corta para imitar la latencia de red en los mocks.
const Duration esperaSimuladaPorDefecto = Duration(milliseconds: 300);

/// Con [espera] cero no crea un temporizador (las pruebas no dejan
/// temporizadores pendientes si una pantalla vuelve a pedir datos al final).
Future<void> esperar(Duration espera) =>
    espera == Duration.zero ? Future<void>.value() : Future<void>.delayed(espera);
