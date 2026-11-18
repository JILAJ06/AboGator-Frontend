/// Vidas del usuario. La regeneración la decide el servidor.
class Vidas {
  const Vidas({required this.cantidad, this.proximaEn});

  /// Máximo de vidas.
  static const int maximo = 5;

  final int cantidad;

  /// Momento (dado por el servidor) en que se recupera la siguiente vida.
  /// Es `null` cuando las vidas están completas.
  final DateTime? proximaEn;
}
