import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/accion_enfocable.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_atras.dart';
import '../../componentes/foco_retorno.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/mensaje_pantalla.dart';
import '../../componentes/piezas_ajustes.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/ajustes_notificaciones.dart';
import '../ajustes/estado_ajustes.dart';
import 'estado_notificaciones.dart';
import 'selector_hora.dart';

/// 34 · Notificaciones de racha (T-13b).
///
/// Atrás, el título con Sarko alegre, la descripción, la tarjeta de tres
/// filas (racha en riesgo, juicios de apelación y recordatorio diario, cuya
/// fila abre el selector de hora 34c), la nota y "Activar notificaciones" /
/// "Ahora no", que guardan y cierran. Cada interruptor se guarda al instante.
///
/// [desdeRegistro]: se abrió tras el primer registro; al cerrar va al Inicio.
class PantallaNotificaciones extends ConsumerWidget {
  const PantallaNotificaciones({this.desdeRegistro = false, super.key});

  final bool desdeRegistro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(ajustesNotificacionesProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (datos) {
          AsyncData(:final value) => _Notificaciones(
            preferencias: value,
            desdeRegistro: desdeRegistro,
          ),
          AsyncError() => MensajePantalla(
            texto: Textos.errorGuardarNotificaciones,
            textoBoton: Textos.reintentar,
            alPresionar: () => ref.invalidate(ajustesNotificacionesProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _Notificaciones extends ConsumerStatefulWidget {
  const _Notificaciones({required this.preferencias, required this.desdeRegistro});

  final AjustesNotificaciones preferencias;
  final bool desdeRegistro;

  @override
  ConsumerState<_Notificaciones> createState() => _NotificacionesState();
}

class _NotificacionesState extends ConsumerState<_Notificaciones> {
  /// La fila del recordatorio: el foco vuelve aquí al cerrar el selector.
  final _focoRecordatorio = FocusNode(debugLabel: 'fila recordatorio diario');

  @override
  void dispose() {
    _focoRecordatorio.dispose();
    super.dispose();
  }

  AjustesNotificaciones get _p => widget.preferencias;

  Future<bool> _cambiar(AjustesNotificaciones nuevas) async {
    final ok = await ref.read(ajustesNotificacionesProvider.notifier).cambiar(nuevas);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            key: const ValueKey('error-guardar-notificaciones'),
            content: Semantics(
              liveRegion: true,
              child: const Text(Textos.errorGuardarNotificaciones),
            ),
          ),
        );
    }
    return ok;
  }

  Future<void> _elegirHora() async {
    final soloBotones = ref.read(ajustesProvider).soloBotones;
    final elegida = await mostrarSelectorHora(
      context,
      inicial: _p.minutosRecordatorio,
      soloBotones: soloBotones,
    );
    if (!mounted) return;
    devolverFoco(_focoRecordatorio);
    if (elegida == null) return;
    // Elegir una hora enciende el recordatorio.
    final ok = await _cambiar(_p.copyWith(minutosRecordatorio: elegida, recordatorioDiario: true));
    if (!ok || !mounted) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        Textos.recordatorioGuardado(LogicaHora.formatear(elegida)),
        TextDirection.ltr,
      ),
    );
  }

  Future<void> _cerrar({required bool activar}) async {
    final ok = await _cambiar(_p.copyWith(activadas: activar, decidido: true));
    // T-14: permiso del sistema y alta del dispositivo para los avisos.
    if (!ok || !mounted) return;
    if (widget.desdeRegistro) {
      context.go(Rutas.inicio);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.ajustes);
    }
  }

  void _volver() {
    if (widget.desdeRegistro) {
      context.go(Rutas.inicio);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.ajustes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final hora = LogicaHora.formatear(_p.minutosRecordatorio);

    final tarjeta = Container(
      key: const ValueKey('tarjeta-notificaciones'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilaAjuste(
            key: const ValueKey('notif-racha'),
            icono: IconosApp.flame,
            titulo: Textos.rachaEnRiesgo,
            detalle: Textos.rachaEnRiesgoDetalle,
            interruptor: _p.rachaEnRiesgo,
            control: InterruptorApp(valor: _p.rachaEnRiesgo, grande: true),
            alPresionar: () => _cambiar(_p.copyWith(rachaEnRiesgo: !_p.rachaEnRiesgo)),
          ),
          Divider(height: 1, thickness: 1, color: tokens.bordeDefault),
          FilaAjuste(
            key: const ValueKey('notif-apelaciones'),
            icono: IconosApp.gavel,
            titulo: Textos.juiciosApelacion,
            detalle: Textos.juiciosApelacionDetalle,
            interruptor: _p.apelaciones,
            control: InterruptorApp(valor: _p.apelaciones, grande: true),
            alPresionar: () => _cambiar(_p.copyWith(apelaciones: !_p.apelaciones)),
          ),
          Divider(height: 1, thickness: 1, color: tokens.bordeDefault),
          _FilaRecordatorio(
            hora: hora,
            activo: _p.recordatorioDiario,
            nodoFoco: _focoRecordatorio,
            alAbrir: _elegirHora,
            alCambiar: (v) => _cambiar(_p.copyWith(recordatorioDiario: v)),
          ),
        ],
      ),
    );

    final contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BotonAtras(alPresionar: _volver),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: BloqueLectura(
                  key: const ValueKey('titulo-notificaciones'),
                  encabezado: true,
                  autofocus: true,
                  radio: 8,
                  child: Text(
                    Textos.protegeTuRacha,
                    style: estilos.h1.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const SarkoImagen(pose: PoseSarko.alegre, ancho: 96, decorativa: true),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          Textos.notificacionesDescripcion,
          style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
        ),
        const SizedBox(height: 20),
        tarjeta,
        const SizedBox(height: 12),
        Text(
          Textos.notificacionesNota,
          style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
        ),
      ],
    );
    final botones = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        BotonApp(
          key: const ValueKey('boton-activar-notificaciones'),
          texto: Textos.activarNotificaciones,
          alPresionar: () => _cerrar(activar: true),
        ),
        const SizedBox(height: 8),
        BotonApp(
          key: const ValueKey('boton-ahora-no'),
          texto: Textos.ahoraNo,
          tipo: TipoBoton.fantasma,
          altoMinimo: 48,
          alPresionar: () => _cerrar(activar: false),
        ),
      ],
    );

    final tablet = context.clasePantalla.esTablet;
    final arriba = tablet ? 24.0 : 8.0;
    // Contenido arriba y botones abajo sin medidas intrínsecas (las filas usan
    // LayoutBuilder): la columna mide al menos el alto disponible.
    return LayoutBuilder(
      builder: (context, restricciones) => SingleChildScrollView(
        key: const ValueKey('notificaciones-desplazable'),
        padding: EdgeInsets.fromLTRB(24, arriba, 24, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: tablet ? MedidasAdaptativas.columnaFormulario : double.infinity,
              minHeight: math.max(0, restricciones.maxHeight - arriba - 24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [contenido, botones],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila del recordatorio diario: tocarla abre el selector de hora (34c); el
/// interruptor de la derecha lo enciende o apaga por separado. Son dos
/// controles con su propio nombre para el lector.
class _FilaRecordatorio extends StatelessWidget {
  const _FilaRecordatorio({
    required this.hora,
    required this.activo,
    required this.nodoFoco,
    required this.alAbrir,
    required this.alCambiar,
  });

  final String hora;
  final bool activo;
  final FocusNode nodoFoco;
  final VoidCallback alAbrir;
  final ValueChanged<bool> alCambiar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Row(
      key: const ValueKey('notif-recordatorio'),
      children: [
        Expanded(
          child: AccionEnfocable(
            key: const ValueKey('fila-hora-recordatorio'),
            alPresionar: alAbrir,
            nodoFoco: nodoFoco,
            radio: 12,
            semantica: (hijo) => Semantics(
              button: true,
              label: Textos.cambiarHoraSemantica(hora),
              onTap: alAbrir,
              excludeSemantics: true,
              child: hijo,
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: FilaAjuste.altoMinimo),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  IconoApp(IconosApp.clock, tamano: 22, color: tokens.textoPrimario),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Textos.recordatorioDiario,
                          style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Textos.recordatorioDiarioDetalle(hora),
                          style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InterruptorTocable(
            key: const ValueKey('interruptor-recordatorio'),
            valor: activo,
            etiqueta: Textos.recordatorioDiario,
            alCambiar: alCambiar,
          ),
        ),
      ],
    );
  }
}
