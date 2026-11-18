/// Espera corta para imitar la latencia de red en los mocks.
const Duration esperaSimuladaPorDefecto = Duration(milliseconds: 300);

Future<void> esperar(Duration espera) => Future<void>.delayed(espera);
