import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_cerrar.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/esqueleto_pantalla.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/vista_asincrona.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/textos/textos.dart';
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
      body: VistaAsincrona(
        valor: datos,
        datos: (value) => _contenido(context, value),
        textoError: Textos.introErrorCarga,
        alReintentar: () => ref.invalidate(datosModuloProvider(moduloId)),
        esqueleto: const _EsqueletoIntro(),
      ),
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
  Widget build(BuildContext context) => const EsqueletoPantalla(
    etiqueta: Textos.cargandoIntro,
    clave: ValueKey('esqueleto-intro'),
    areaSegura: true,
    relleno: EdgeInsets.fromLTRB(24, 62, 24, 0),
    alineacion: CrossAxisAlignment.center,
    hijos: [
      BloqueEsqueleto(230, ancho: 230, radio: 115),
      SizedBox(height: 20),
      BloqueEsqueleto(16, ancho: 140, radio: 8),
      SizedBox(height: 6),
      BloqueEsqueleto(64, radio: 8),
      SizedBox(height: 8),
      BloqueEsqueleto(60, radio: 8),
      SizedBox(height: 14),
      BloqueEsqueleto(180, radio: 18),
    ],
  );
}
