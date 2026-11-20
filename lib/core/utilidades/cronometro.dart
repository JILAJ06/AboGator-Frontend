/// Reloj monótono para cuentas regresivas: mide el tiempo transcurrido sin
/// depender de la hora del dispositivo (que el usuario puede cambiar).
abstract interface class Cronometro {
  Duration get transcurrido;

  /// Vuelve a 0 y empieza a contar.
  void reiniciar();
}

/// [Cronometro] con un `Stopwatch` del sistema.
class CronometroSistema implements Cronometro {
  final Stopwatch _reloj = Stopwatch()..start();

  @override
  Duration get transcurrido => _reloj.elapsed;

  @override
  void reiniciar() => _reloj
    ..reset()
    ..start();
}
