import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/modulo.dart';
import '../../datos/modelos/tarjeta.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../mapa/logica_mapa.dart';

/// Datos que necesita la pantalla de juego de un sprint.
class DatosJuego {
  const DatosJuego({
    required this.vidas,
    this.tarjetas = const [],
    this.estadoStartup,
    this.modulo,
    this.sprint,
    this.numeroSprint = 1,
  });

  final Vidas vidas;

  /// Vacía si el sprint no existe o no tiene tarjetas.
  final List<Tarjeta> tarjetas;

  /// `null` solo cuando no se cargó el juego (sin vidas).
  final EstadoStartup? estadoStartup;

  /// Módulo al que pertenece el sprint (color del chip del caso y regreso al
  /// mapa); `null` si no se encontró.
  final Modulo? modulo;
  final Sprint? sprint;

  /// Número del sprint dentro de su módulo (sin contar el Examen final).
  final int numeroSprint;

  /// Con 0 vidas no se carga el juego (marcador de "Sin vidas", T-08).
  bool get sinVidas => vidas.cantidad <= 0;
}

/// Comodines que se muestran en la barra mientras el repositorio no da las
/// cantidades (se activan en T-07).
abstract final class ComodinesJuego {
  static const int lupa = 2;
  static const int abogado = 1;
  static const int amparo = 1;
}

/// Carga primero las vidas: con 0 no carga el juego. Si hay vidas, pide en
/// paralelo las tarjetas, el estado de la Startup y los módulos (para el
/// número del sprint y el color del módulo). Un sprint inexistente da una
/// lista de tarjetas vacía.
final datosJuegoProvider = FutureProvider.autoDispose.family<DatosJuego, String>((
  ref,
  sprintId,
) async {
  final repoVidas = ref.watch(repositorioVidasProvider);
  final repoTarjetas = ref.watch(repositorioTarjetasProvider);
  final repoProgreso = ref.watch(repositorioProgresoProvider);

  final vidas = await repoVidas.obtenerVidas();
  if (vidas.cantidad <= 0) return DatosJuego(vidas: vidas);

  Future<List<Tarjeta>> tarjetas() async {
    try {
      return await repoTarjetas.obtenerTarjetasDelSprint(sprintId);
    } on StateError {
      return const [];
    }
  }

  final (lista, estado, modulos) = await (
    tarjetas(),
    repoProgreso.obtenerEstadoStartup(),
    repoProgreso.obtenerModulos(),
  ).wait;

  Modulo? modulo;
  Sprint? sprint;
  for (final m in modulos) {
    final s = LogicaMapa.sprintPorId(m, sprintId);
    if (s != null) {
      modulo = m;
      sprint = s;
      break;
    }
  }

  return DatosJuego(
    vidas: vidas,
    tarjetas: lista,
    estadoStartup: estado,
    modulo: modulo,
    sprint: sprint,
    numeroSprint: modulo == null || sprint == null ? 1 : LogicaMapa.numeroDe(modulo, sprint) ?? 1,
  );
});

/// Respuesta del jugador a una tarjeta (sin calificar todavía; T-06).
class RespuestaJuego {
  const RespuestaJuego({required this.tarjetaId, required this.veredicto});

  final String tarjetaId;
  final Veredicto veredicto;

  @override
  bool operator ==(Object other) =>
      other is RespuestaJuego && other.tarjetaId == tarjetaId && other.veredicto == veredicto;

  @override
  int get hashCode => Object.hash(tarjetaId, veredicto);

  @override
  String toString() => 'RespuestaJuego($tarjetaId, ${veredicto.name})';
}

/// Avance del sprint: índice de la tarjeta actual y respuestas dadas.
class EstadoJuego {
  const EstadoJuego({this.indice = 0, this.respuestas = const []});

  final int indice;
  final List<RespuestaJuego> respuestas;
}

/// Lleva el avance del juego de un sprint.
class JuegoNotifier extends Notifier<EstadoJuego> {
  JuegoNotifier(this.sprintId);

  final String sprintId;

  @override
  EstadoJuego build() => const EstadoJuego();

  /// Registra la respuesta y pasa a la siguiente tarjeta.
  void responder(Tarjeta tarjeta, Veredicto veredicto) {
    state = EstadoJuego(
      indice: state.indice + 1,
      respuestas: [
        ...state.respuestas,
        RespuestaJuego(tarjetaId: tarjeta.id, veredicto: veredicto),
      ],
    );
  }
}

final juegoProvider = NotifierProvider.autoDispose.family<JuegoNotifier, EstadoJuego, String>(
  JuegoNotifier.new,
);
