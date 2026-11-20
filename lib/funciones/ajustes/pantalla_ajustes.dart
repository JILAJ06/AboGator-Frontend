import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/piezas_ajustes.dart';
import '../../componentes/piezas_perfil.dart';
import '../../core/tema/efectos.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/ajustes.dart';
import 'estado_ajustes.dart';
import 'logica_ajustes.dart';

/// Pantalla 26 · Ajustes de accesibilidad (Figma 18:2634), hija del Perfil y
/// sin navegación inferior.
///
/// Atrás y "Accesibilidad", el subtítulo y tres secciones (Visual, Motor y
/// auditiva, Cognitiva). Cada cambio se aplica al instante y se guarda en el
/// dispositivo; si no se puede guardar, se revierte y se avisa.
class PantallaAjustes extends ConsumerWidget {
  const PantallaAjustes({super.key});

  /// Vuelve al Perfil (o a la pantalla anterior si la hay).
  static void volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Rutas.perfil);
    }
  }

  Future<void> _cambiar(BuildContext context, WidgetRef ref, Ajustes nuevos) async {
    final mensajero = ScaffoldMessenger.of(context);
    final guardado = await ref.read(ajustesProvider.notifier).cambiar(nuevos);
    if (guardado) return;
    mensajero
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('error-guardar-ajuste'),
          content: Semantics(liveRegion: true, child: const Text(Textos.errorGuardarAjuste)),
        ),
      );
  }

  Future<void> _elegirTamano(BuildContext context, WidgetRef ref) async {
    final actual = ref.read(ajustesProvider).escalaTexto;
    final elegido = await showModalBottomSheet<int>(
      context: context,
      // El fondo lo pinta el selector con los tokens del tema vigente.
      backgroundColor: const Color(0x00000000),
      elevation: 0,
      barrierColor: EfectosApp.colorVelo,
      isScrollControlled: true,
      builder: (contexto) => SelectorTamano(actual: actual),
    );
    if (elegido == null || !context.mounted) return;
    await _cambiar(context, ref, ref.read(ajustesProvider).copyWith(escalaTexto: elegido));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);
    final tokens = context.tokens;
    final estilos = context.estilos;
    final oscuro = LogicaAjustes.oscuroEfectivo(
      ajustes.modoTema,
      MediaQuery.platformBrightnessOf(context),
    );
    final lectorActivo = MediaQuery.accessibleNavigationOf(context);

    void alternar(Ajustes nuevos) => unawaited(_cambiar(context, ref, nuevos));

    final visual = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-modo-oscuro'),
          icono: IconosApp.moon,
          titulo: Textos.modoOscuro,
          detalle: Textos.modoOscuroDetalle,
          interruptor: oscuro,
          control: InterruptorApp(valor: oscuro),
          alPresionar: () =>
              alternar(ajustes.copyWith(modoTema: oscuro ? ThemeMode.light : ThemeMode.dark)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-tamano'),
          icono: IconosApp.type,
          titulo: Textos.tamanoTexto,
          detalle: Textos.tamanoTextoDetalle,
          valorSemantico: Textos.porcentajeSemantica(ajustes.escalaTexto),
          control: ChipValor(texto: Textos.tamanoValor(ajustes.escalaTexto)),
          alPresionar: () => _elegirTamano(context, ref),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-lector'),
          icono: IconosApp.eye,
          titulo: Textos.etiquetasLector,
          detalle: Textos.etiquetasLectorDetalle,
          etiquetaSemantica: Textos.lectorSemantica(lectorActivo),
          control: ChipValor(texto: lectorActivo ? Textos.lectorActivo : Textos.lectorDisponible),
        ),
      ],
    );

    final motora = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-solo-botones'),
          icono: IconosApp.check,
          titulo: Textos.soloBotones,
          detalle: Textos.soloBotonesDetalle,
          interruptor: ajustes.soloBotones,
          control: InterruptorApp(valor: ajustes.soloBotones),
          alPresionar: () => alternar(ajustes.copyWith(soloBotones: !ajustes.soloBotones)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-haptica'),
          icono: IconosApp.vibrate,
          titulo: Textos.vibracion,
          detalle: Textos.vibracionDetalle,
          interruptor: ajustes.haptica,
          control: InterruptorApp(valor: ajustes.haptica),
          alPresionar: () async {
            final encender = !ajustes.haptica;
            await _cambiar(context, ref, ajustes.copyWith(haptica: encender));
            // Muestra de cómo se siente.
            if (encender) await ref.read(servicioHapticoProvider).suave();
          },
        ),
      ],
    );

    final cognitiva = MenuAgrupado(
      filas: [
        FilaAjuste(
          key: const ValueKey('ajuste-tiempo'),
          icono: IconosApp.clock,
          titulo: Textos.tiempoExtendido,
          detalle: Textos.tiempoExtendidoDetalle,
          interruptor: ajustes.tiempoExtendido,
          control: InterruptorApp(valor: ajustes.tiempoExtendido),
          alPresionar: () => alternar(ajustes.copyWith(tiempoExtendido: !ajustes.tiempoExtendido)),
        ),
        FilaAjuste(
          key: const ValueKey('ajuste-animaciones'),
          icono: IconosApp.pause,
          titulo: Textos.reducirAnimaciones,
          detalle: Textos.reducirAnimacionesDetalle,
          interruptor: ajustes.reducirAnimaciones,
          control: InterruptorApp(valor: ajustes.reducirAnimaciones),
          alPresionar: () =>
              alternar(ajustes.copyWith(reducirAnimaciones: !ajustes.reducirAnimaciones)),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('ajustes-desplazable'),
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  // El botón va en x 20 (4 antes del margen de 24), como en Figma.
                  Transform.translate(
                    offset: const Offset(-4, 0),
                    child: BotonIconoCuadrado(
                      key: const ValueKey('boton-atras-ajustes'),
                      icono: IconosApp.back,
                      etiqueta: Textos.atras,
                      alPresionar: () => volver(context),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: BloqueLectura(
                      key: const ValueKey('titulo-ajustes'),
                      encabezado: true,
                      autofocus: true,
                      radio: 8,
                      child: Text(
                        Textos.ajustesTitulo,
                        style: estilos.h1.copyWith(color: tokens.textoPrimario),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                Textos.ajustesSubtitulo,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionVisual),
              const SizedBox(height: 6),
              visual,
              if (ajustes.modoTema != ThemeMode.system)
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotonApp(
                    key: const ValueKey('usar-modo-sistema'),
                    texto: Textos.usarModoSistema,
                    tipo: TipoBoton.fantasma,
                    expandido: false,
                    altoMinimo: 48,
                    alPresionar: () => alternar(ajustes.copyWith(modoTema: ThemeMode.system)),
                  ),
                ),
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionMotora),
              const SizedBox(height: 6),
              motora,
              const SizedBox(height: 22),
              const EncabezadoSeccionAjustes(Textos.seccionCognitiva),
              const SizedBox(height: 6),
              cognitiva,
            ],
          ),
        ),
      ),
    );
  }
}

/// Hoja "Tamaño de texto": título y las cuatro opciones; se cierra al elegir
/// (devuelve el porcentaje). El foco empieza en la opción actual.
class SelectorTamano extends StatefulWidget {
  const SelectorTamano({required this.actual, super.key});

  final int actual;

  @override
  State<SelectorTamano> createState() => _SelectorTamanoState();
}

class _SelectorTamanoState extends State<SelectorTamano> {
  final _focoActual = FocusNode(debugLabel: 'tamaño actual');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focoActual.requestFocus();
    });
  }

  @override
  void dispose() {
    _focoActual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      key: const ValueKey('fondo-selector-tamano'),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey('selector-tamano'),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  Textos.tamanoTexto,
                  style: context.estilos.h2.copyWith(color: tokens.textoPrimario),
                ),
              ),
              const SizedBox(height: 12),
              for (final p in Ajustes.escalas)
                OpcionTamano(
                  key: ValueKey('tamano-$p'),
                  porcentaje: p,
                  elegida: p == widget.actual,
                  nodoFoco: p == widget.actual ? _focoActual : null,
                  alElegir: () => Navigator.of(context).pop(p),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
