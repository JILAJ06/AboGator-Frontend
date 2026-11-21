import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_cerrar.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/modulo.dart';
import 'detalle_sprint.dart';
import 'estado_mapa.dart';
import 'logica_mapa.dart';
import 'pantalla_mapa_sprints.dart';

/// Pantalla 09 · Intro del sprint (Figma 13:776). Sin navegación inferior.
///
/// Cerrar y vidas arriba; Sarko sobre una elipse fondo/destacado; sprint y
/// módulo, título, objetivo y la tarjeta de detalles. "Comenzar sprint" queda
/// fijo abajo y el resto se desplaza si no cabe.
class PantallaIntroSprint extends ConsumerWidget {
  const PantallaIntroSprint({required this.moduloId, required this.sprintId, super.key});

  final String moduloId;
  final String sprintId;

  void _cerrar(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.mapaSprintsDe(moduloId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // En tablet horizontal la intro es el panel de detalle del mapa (T08): la
    // misma ruta muestra la vista combinada con este sprint seleccionado.
    if (context.clasePantalla.esAncho) {
      return PantallaMapaSprints(moduloId: moduloId, sprintId: sprintId);
    }
    final datos = ref.watch(datosModuloProvider(moduloId));
    return Scaffold(
      body: switch (datos) {
        AsyncData(:final value) => _contenido(context, value),
        AsyncError() => MensajePantalla(
          texto: Textos.introErrorCarga,
          textoBoton: Textos.reintentar,
          alPresionar: () => ref.invalidate(datosModuloProvider(moduloId)),
        ),
        _ => const _EsqueletoIntro(),
      },
    );
  }

  Widget _contenido(BuildContext context, DatosModulo datos) {
    final modulo = datos.modulo;
    final sprint = modulo == null ? null : LogicaMapa.sprintPorId(modulo, sprintId);
    if (modulo == null || sprint == null) {
      return MensajePantalla(
        texto: Textos.errorSprintNoEncontrado,
        textoBoton: modulo == null ? Textos.volverAlInicio : Textos.volverAlMapa,
        alPresionar: () =>
            context.go(modulo == null ? Rutas.inicio : Rutas.mapaSprintsDe(modulo.id)),
      );
    }
    return _Intro(
      modulo: modulo,
      sprint: sprint,
      vidas: datos.vidas.cantidad,
      alCerrar: () => _cerrar(context),
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro({
    required this.modulo,
    required this.sprint,
    required this.vidas,
    required this.alCerrar,
  });

  final Modulo modulo;
  final Sprint sprint;
  final int vidas;
  final VoidCallback alCerrar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abierto = LogicaMapa.puedeAbrir(modulo, sprint);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('intro-sprint'),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BotonCerrar(alPresionar: alCerrar),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ChipHud.vidas(vidas),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DetalleSprint(modulo: modulo, sprint: sprint),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: BotonApp(
              texto: Textos.comenzarSprint,
              alPresionar: abierto ? () => comenzarSprint(context, ref, modulo, sprint) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _EsqueletoIntro extends StatelessWidget {
  const _EsqueletoIntro();

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.fondoSuperficieAlt;
    Widget bloque(double alto, {double? ancho, double radio = 18}) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radio)),
    );
    return Semantics(
      label: Textos.cargandoIntro,
      liveRegion: true,
      excludeSemantics: true,
      child: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('esqueleto-intro'),
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 62, 24, 0),
          child: Column(
            children: [
              bloque(230, ancho: 230, radio: 115),
              const SizedBox(height: 20),
              bloque(16, ancho: 140, radio: 8),
              const SizedBox(height: 6),
              bloque(64, radio: 8),
              const SizedBox(height: 8),
              bloque(60, radio: 8),
              const SizedBox(height: 14),
              bloque(180),
            ],
          ),
        ),
      ),
    );
  }
}
