import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'barra_progreso.dart';
import 'boton_cerrar.dart';
import 'chip_hud.dart';
import 'icono_app.dart';

/// Barra de juego (Figma 11:244): alto 56, relleno horizontal 20, separación
/// 14. Botón Salir de 48, columna con "Sprint N · Tarjeta k de n" (Leyenda
/// texto/secundario) y `BarraProgreso`, y el chip de vidas.
class BarraJuego extends StatelessWidget {
  const BarraJuego({
    required this.numeroSprint,
    required this.actual,
    required this.total,
    required this.vidas,
    required this.alSalir,
    this.paso,
    this.colorProgreso,
    super.key,
  });

  static const double alto = 56;

  final int numeroSprint;

  /// Tarjeta actual (1 a [total]).
  final int actual;
  final int total;
  final int vidas;
  final VoidCallback? alSalir;

  /// Texto del paso en lugar de "Sprint N · Tarjeta k de n" (el Examen
  /// Final: "Crisis · Decisión k de 10").
  final String? paso;

  /// Relleno de la barra de progreso (el Examen: accion/secundaria).
  final Color? colorProgreso;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textoPaso = paso ?? Textos.juegoPaso(numeroSprint, actual, total);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: alto),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            BotonCerrar(alPresionar: alSalir, etiqueta: Textos.salir),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      textoPaso,
                      style: context.estilos.leyenda.copyWith(color: tokens.textoSecundario),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BarraProgreso(
                    valor: total == 0 ? 0 : actual / total,
                    etiquetaSemantica: textoPaso,
                    colorRelleno: colorProgreso,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            ChipHud.vidas(vidas),
          ],
        ),
      ),
    );
  }
}

/// Barra de juego de tablet (Figma `93:528`): alto 64 y separación 20. Salir
/// (círculo de 48 con `x` de 22), el progreso que ocupa el espacio sobrante
/// ("Sprint N · Tarjeta k de n" en Etiqueta texto/secundario y la barra de 12),
/// el HUD con racha, monedas y vidas (separación 8) y Pausa (círculo de 48 con
/// `pause` de 22). La pausa no existe en el móvil.
class BarraJuegoTablet extends StatelessWidget {
  const BarraJuegoTablet({
    required this.numeroSprint,
    required this.actual,
    required this.total,
    required this.vidas,
    required this.racha,
    required this.monedas,
    required this.alSalir,
    required this.alPausar,
    this.paso,
    this.colorProgreso,
    super.key,
  });

  static const double alto = 64;
  static const double separacion = 20;
  static const double ladoBoton = 48;

  final int numeroSprint;
  final int actual;
  final int total;
  final int vidas;
  final int racha;
  final int monedas;
  final VoidCallback? alSalir;

  /// Sin valor, no hay botón de pausa (el Examen solo pausa con tiempo
  /// extendido).
  final VoidCallback? alPausar;

  /// Texto del paso en lugar de "Sprint N · Tarjeta k de n" (el Examen).
  final String? paso;

  /// Relleno de la barra de progreso (el Examen: accion/secundaria).
  final Color? colorProgreso;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textoPaso = paso ?? Textos.juegoPaso(numeroSprint, actual, total);
    final pausar = alPausar;
    return ConstrainedBox(
      key: const ValueKey('barra-juego-tablet'),
      constraints: const BoxConstraints(minHeight: alto),
      child: Row(
        children: [
          _BotonCircular(
            key: const ValueKey('boton-salir-tablet'),
            icono: IconosApp.x,
            etiqueta: Textos.salir,
            alPresionar: alSalir,
          ),
          const SizedBox(width: separacion),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Text(
                    textoPaso,
                    style: context.estilos.etiqueta.copyWith(color: tokens.textoSecundario),
                  ),
                ),
                const SizedBox(height: 8),
                BarraProgreso(
                  valor: total == 0 ? 0 : actual / total,
                  etiquetaSemantica: textoPaso,
                  colorRelleno: colorProgreso,
                ),
              ],
            ),
          ),
          const SizedBox(width: separacion),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [ChipHud.racha(racha), ChipHud.monedas(monedas), ChipHud.vidas(vidas)],
          ),
          if (pausar != null) ...[
            const SizedBox(width: separacion),
            _BotonCircular(
              key: const ValueKey('boton-pausa'),
              icono: IconosApp.pause,
              etiqueta: Textos.pausa,
              alPresionar: pausar,
            ),
          ],
        ],
      ),
    );
  }
}

class _BotonCircular extends StatelessWidget {
  const _BotonCircular({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
    super.key,
  });

  final IconData icono;
  final String etiqueta;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const lado = BarraJuegoTablet.ladoBoton;
    return AccionEnfocable(
      alPresionar: alPresionar,
      radio: lado / 2,
      semantica: (hijo) => Semantics(
        button: true,
        label: etiqueta,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        width: lado,
        height: lado,
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          shape: BoxShape.circle,
          border: Border.all(color: tokens.bordeDefault),
        ),
        child: Center(child: IconoApp(icono, tamano: 22, color: tokens.textoPrimario)),
      ),
    );
  }
}
