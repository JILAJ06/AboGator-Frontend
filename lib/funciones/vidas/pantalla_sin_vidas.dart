import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_cerrar.dart';
import '../../componentes/corazon_vida.dart';
import '../../componentes/cuenta_regresiva_vida.dart';
import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/ilustracion_sarko.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/cronometro.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/vidas.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../juego/piezas_fin_sprint.dart';

/// Vidas según el servidor (se vuelve a pedir al terminar la cuenta).
final vidasActualesProvider = FutureProvider.autoDispose<Vidas>(
  (ref) => ref.watch(repositorioVidasProvider).obtenerVidas(),
);

/// Apelaciones que se pueden hacer hoy (para la sugerencia de 20).
final apelacionesPendientesProvider = FutureProvider.autoDispose<int>(
  (ref) async => (await ref.watch(repositorioApelacionesProvider).obtenerBuzon()).deHoy.length,
);

/// Pantalla 20 · Sin vidas (Figma 17:2072).
///
/// Cuenta regresiva a la próxima vida con lo que manda el servidor (y un reloj
/// monótono), sugerencia de ir al Buzón (N apelaciones, de los datos) y
/// regreso al mapa de [moduloId] (o al Inicio). Cuando la cuenta llega a 0 y
/// el servidor devuelve vidas, los corazones se llenan, el texto cambia a
/// "¡Recuperaste una vida!" y se anuncia (no está en Figma).
class PantallaSinVidas extends ConsumerStatefulWidget {
  const PantallaSinVidas({this.moduloId, this.crearCronometro = CronometroSistema.new, super.key});

  final String? moduloId;

  /// Reloj monótono de la cuenta regresiva (en las pruebas, uno falso).
  final Cronometro Function() crearCronometro;

  @override
  ConsumerState<PantallaSinVidas> createState() => _PantallaSinVidasState();
}

class _PantallaSinVidasState extends ConsumerState<PantallaSinVidas> {
  void _volverAlMapa() {
    final modulo = widget.moduloId;
    context.go(modulo == null ? Rutas.inicio : Rutas.mapaSprintsDe(modulo));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final vidas = ref.watch(vidasActualesProvider).value;
    final apelaciones = ref.watch(apelacionesPendientesProvider).value ?? 0;
    final cantidad = vidas?.cantidad ?? 0;
    final recuperada = cantidad > 0;
    final falta = vidas?.faltaParaProxima;

    ref.listen(vidasActualesProvider, (antes, ahora) {
      final previas = antes?.value?.cantidad ?? 0;
      final nuevas = ahora.value?.cantidad ?? 0;
      if (nuevas > previas) {
        unawaited(
          SemanticsService.sendAnnouncement(
            View.of(context),
            Textos.vidaRecuperada,
            TextDirection.ltr,
          ),
        );
      }
    });

    final cerrar = ElementoOrdenado(orden: 5, child: BotonCerrar(alPresionar: _volverAlMapa));
    final textos = <Widget>[
      const ElementoOrdenado(orden: 1, child: TituloFinSprint(Textos.sinVidasTitulo)),
      const SizedBox(height: 8),
      ElementoOrdenado(
        orden: 2,
        child: Column(
          children: [
            Semantics(
              liveRegion: recuperada,
              child: Text(
                recuperada ? Textos.vidaRecuperada : Textos.proximaVidaEn,
                key: const ValueKey('estado-proxima-vida'),
                textAlign: TextAlign.center,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
            ),
            const SizedBox(height: 2),
            // Si faltan más vidas, se muestra la siguiente cuenta; con 5 no.
            if (falta != null && (!recuperada || cantidad < Vidas.maximo))
              CuentaRegresivaVida(
                // Cada respuesta del servidor empieza una cuenta nueva (aunque
                // traiga el mismo tiempo).
                key: ObjectKey(vidas),
                falta: falta,
                crearCronometro: widget.crearCronometro,
                alTerminar: () => ref.invalidate(vidasActualesProvider),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconoApp(IconosApp.clock, tamano: 16, color: tokens.textoSecundario),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    Textos.notaVidasServidor,
                    textAlign: TextAlign.center,
                    style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
    final sugerencia = apelaciones > 0
        ? ElementoOrdenado(
            orden: 3,
            child: SugerenciaBuzon(pendientes: apelaciones, alIr: () => context.go(Rutas.buzon)),
          )
        : null;

    final contenido = Column(
      children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: cerrar),
              // Corazones: vacíos sin vidas; se llenan si el servidor
              // devuelve alguna.
              FilaVidas(
                key: const ValueKey('vidas-sin-vidas'),
                cantidad: cantidad,
                tamano: 31.2,
                hueco: 10.4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        IlustracionSarko(
          pose: PoseSarko.triste,
          diametro: 220,
          anchoSarko: 176,
          colorFondo: tokens.fondoSuperficieAlt,
        ),
        const SizedBox(height: 16),
        ...textos,
        if (sugerencia != null) ...[const SizedBox(height: 30), sugerencia],
      ],
    );

    return ColumnaFinSprint(
      contenido: [contenido],
      // T20 (Figma 100:3887): corazones y Sarko triste × 1.7 en el panel
      // izquierdo, Cerrar arriba a la izquierda y los textos a la derecha.
      encabezadoTablet: cerrar,
      ilustracionTablet: IlustracionAmpliada(
        anchoBase: 230,
        escala: 1.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilaVidas(
              key: const ValueKey('vidas-sin-vidas'),
              cantidad: cantidad,
              tamano: 31.2,
              hueco: 10.4,
            ),
            const SizedBox(height: 18),
            IlustracionSarko(
              pose: PoseSarko.triste,
              diametro: 220,
              anchoSarko: 176,
              colorFondo: tokens.fondoSuperficieAlt,
            ),
          ],
        ),
      ),
      contenidoTablet: [
        ...textos,
        if (sugerencia != null) ...[const SizedBox(height: 16), sugerencia],
      ],
      botones: [
        ElementoOrdenado(
          orden: 4,
          child: BotonApp(
            texto: Textos.volverAlMapa,
            tipo: TipoBoton.fantasma,
            altoMinimo: 48,
            alPresionar: _volverAlMapa,
          ),
        ),
      ],
    );
  }
}

/// Sugerencia del Buzón (Figma 20): fondo/destacado, radio 22, relleno 18,
/// separación 12; cuadrado de 44 accion/secundaria (radio 14) con `inbox` de
/// 22, "Mientras tanto, repasa" y "N apelaciones pendientes…", y el botón
/// "Ir al Buzón de Apelaciones".
class SugerenciaBuzon extends StatelessWidget {
  const SugerenciaBuzon({required this.pendientes, required this.alIr, super.key});

  final int pendientes;
  final VoidCallback alIr;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Container(
      key: const ValueKey('sugerencia-buzon'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tokens.fondoDestacado,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          MergeSemantics(
            child: Row(
              children: [
                Container(
                  key: const ValueKey('icono-buzon'),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tokens.accionSecundaria,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: IconoApp(IconosApp.inbox, tamano: 22, color: tokens.textoEnPrimario),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Textos.mientrasTantoRepasa,
                        style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Textos.apelacionesPendientesSugerencia(pendientes),
                        style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BotonApp(texto: Textos.irAlBuzon, alPresionar: alIr),
        ],
      ),
    );
  }
}
