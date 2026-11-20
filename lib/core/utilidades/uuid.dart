import 'dart:math';

final Random _aleatorio = Random.secure();

/// UUID versión 4 (aleatorio) con el formato 8-4-4-4-12 en minúsculas, sin
/// paquetes externos. Lo genera el cliente para cada respuesta: el servidor
/// lo usa para no contarla dos veces (idempotencia).
String generarUuidV4([Random? aleatorio]) {
  final r = aleatorio ?? _aleatorio;
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  // Versión 4 (0100 en los 4 bits altos del byte 6) y variante RFC 4122
  // (10 en los 2 bits altos del byte 8).
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
