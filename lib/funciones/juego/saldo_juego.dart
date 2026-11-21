import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/repositorios/proveedores_repositorios.dart';

/// Saldo de monedas al abrir el juego o el Examen (HUD de tablet; T-12c).
///
/// Lo comparten el juego y el Examen Final; antes vivía en
/// `pantalla_juego.dart` (T-13).
final saldoJuegoProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(repositorioTiendaProvider).obtenerMonedas(),
);
