import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';
import 'pildora.dart';

/// Píldora de plazo de una apelación (Figma 21): radio 999, relleno 8×2,
/// separación 4.
/// - de hoy ([dias] ≤ 0): estado/ilegal con `gavel` de 12 y "Día 3 · hoy ·
///   +1 vida" en texto/en-primario;
/// - futura: fondo/superficie-alt con `clock` de 12 y "Día 3 · mañana" o
///   "Día 7 · en 2 días" en texto/secundario.
class _PildoraPlazo extends StatelessWidget {
  const _PildoraPlazo({required this.dia, required this.dias});

  /// Día de repaso (3, 7 o 14).
  final int dia;

  /// Días que faltan (0 o menos: hoy).
  final int dias;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hoy = dias <= 0;
    final fondo = hoy ? tokens.estadoIlegal : tokens.fondoSuperficieAlt;
    final color = hoy ? tokens.textoEnPrimario : tokens.textoSecundario;
    return Pildora(
      clave: const ValueKey('pildora-plazo'),
      fondo: fondo,
      relleno: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(hoy ? IconosApp.gavel : IconosApp.clock, tamano: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              Textos.plazoApelacion(dia, dias),
              style: context.estilos.leyenda.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila del Buzón (Figma 21): relleno 14×12, separación 12; franja de 6×40
/// (radio 3) en el color del módulo, título (Cuerpo/Énfasis, hasta 2 líneas),
/// tema (Leyenda) y la píldora de plazo (separación 3), y `chevron` de 18.
///
/// Es un botón: las de hoy abren el juicio y las futuras avisan cuándo se
/// abren. Se lee "Título, tema, día 3, disponible hoy, +1 vida si la ganas".
class FilaApelacion extends StatelessWidget {
  const FilaApelacion({
    required this.titulo,
    required this.tema,
    required this.dia,
    required this.dias,
    required this.colorModulo,
    required this.alPresionar,
    this.seleccionada,
    this.nodoFoco,
    super.key,
  });

  final String titulo;
  final String tema;

  /// Solo en la lista-detalle de tablet (T21): `true` le pone fondo/destacado
  /// y la anuncia como seleccionada. `null` en móvil.
  final bool? seleccionada;
  final FocusNode? nodoFoco;
  final int dia;
  final int dias;

  /// Color de la franja (el del módulo de la tarjeta).
  final Color colorModulo;
  final VoidCallback? alPresionar;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return AccionEnfocable.boton(
      alPresionar: alPresionar,
      radio: 12,
      nodoFoco: nodoFoco,
      etiqueta: Textos.filaApelacionSemantica(titulo, tema, dia, dias),
      habilitado: alPresionar != null,
      seleccionado: seleccionada,
      child: Container(
        color: seleccionada == true ? tokens.fondoDestacado : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              key: const ValueKey('franja-modulo'),
              width: 6,
              height: 40,
              decoration: BoxDecoration(color: colorModulo, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                  ),
                  const SizedBox(height: 3),
                  Text(tema, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
                  const SizedBox(height: 3),
                  _PildoraPlazo(dia: dia, dias: dias),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconoApp(IconosApp.chevron, tamano: 18, color: tokens.textoSecundario),
          ],
        ),
      ),
    );
  }
}

/// Recompensa del Buzón (Figma 21): fondo/destacado, radio 18, relleno 14×12,
/// separación 12; cuadrado de 40 estado/ilegal (radio 12) con `heart` de 22, y
/// "N juicios de apelación hoy" sobre "Gana cada apelación y recupera 1 vida".
class TarjetaRecompensaBuzon extends StatelessWidget {
  const TarjetaRecompensaBuzon({required this.deHoy, super.key});

  final int deHoy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return MergeSemantics(
      child: CajaSuperficie(
        clave: const ValueKey('recompensa-buzon'),
        ancho: double.infinity,
        relleno: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        fondo: FondoCaja.destacado,
        radio: 18,
        child: Row(
          children: [
            Container(
              key: const ValueKey('icono-recompensa'),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.estadoIlegal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: IconoApp(IconosApp.heart, tamano: 22, color: tokens.textoEnPrimario),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Textos.juiciosHoy(deHoy),
                    style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                  ),
                  Text(
                    deHoy > 0 ? Textos.recompensaApelacion : Textos.proximasApelaciones,
                    style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
