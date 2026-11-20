/// Vidas del usuario. La regeneración la decide el servidor.
class Vidas {
  const Vidas({required this.cantidad, this.faltaParaProxima});

  /// Máximo de vidas.
  static const int maximo = 5;

  /// Cada cuánto se recupera una vida (lo controla el servidor).
  static const Duration intervaloRegeneracion = Duration(hours: 2);

  final int cantidad;

  /// Lo que falta, según el servidor en el momento de la respuesta, para
  /// recuperar la siguiente vida. Es `null` con las vidas completas. La UI lo
  /// descuenta con un reloj monótono, nunca con la hora del dispositivo.
  final Duration? faltaParaProxima;

  @override
  bool operator ==(Object other) =>
      other is Vidas && other.cantidad == cantidad && other.faltaParaProxima == faltaParaProxima;

  @override
  int get hashCode => Object.hash(cantidad, faltaParaProxima);

  @override
  String toString() => 'Vidas($cantidad, falta: $faltaParaProxima)';
}
