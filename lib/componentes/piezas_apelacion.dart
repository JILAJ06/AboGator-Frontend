import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../funciones/apelaciones/logica_apelacion.dart';
import 'icono_app.dart';
import 'pildora.dart';

/// Píldora de vidas de la apelación, radio 999:
/// - en la barra de 22: relleno 10/6, separación 4, `heart` 14 y Leyenda;
/// - [grande] (insignia de 22b): relleno 12/6, separación 6, `heart` 16 y
///   Etiqueta.
///
/// [destacada]: estado/ilegal y texto/en-primario ("+1 vida", "+1 vida
/// recuperada"); si no, fondo/superficie-alt y texto/secundario ("Vidas al
/// máximo", "No pierdes vidas"; no están en Figma). El corazón va siempre en
/// la destacada y en la neutra solo con [conIcono].
class InsigniaVida extends StatelessWidget {
  const InsigniaVida({
    required this.texto,
    required this.destacada,
    this.grande = false,
    this.conIcono,
    this.etiquetaSemantica,
    super.key,
  });

  final String texto;
  final bool destacada;
  final bool grande;

  /// Por defecto, solo la destacada lleva corazón.
  final bool? conIcono;

  /// Lo que lee el lector (por defecto, [texto]).
  final String? etiquetaSemantica;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorTexto = destacada ? tokens.textoEnPrimario : tokens.textoSecundario;
    final estilo = grande ? context.estilos.etiqueta : context.estilos.leyenda;
    return Semantics(
      container: true,
      label: etiquetaSemantica ?? texto,
      excludeSemantics: true,
      child: Pildora(
        fondo: destacada ? tokens.estadoIlegal : tokens.fondoSuperficieAlt,
        relleno: EdgeInsets.symmetric(horizontal: grande ? 12 : 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (conIcono ?? destacada) ...[
              IconoApp(IconosApp.heart, tamano: grande ? 16 : 14, color: colorTexto),
              SizedBox(width: grande ? 6 : 4),
            ],
            Flexible(
              child: Text(texto, style: estilo.copyWith(color: colorTexto)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "La fallaste hace N días" dentro de la tarjeta (Figma 22): píldora
/// fondo/destacado, relleno 10/6, `clock` de 14 y Leyenda texto/acento.
class AvisoFallo extends StatelessWidget {
  const AvisoFallo({required this.dias, super.key});

  final int dias;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Pildora(
      clave: const ValueKey('aviso-fallo'),
      fondo: tokens.fondoDestacado,
      relleno: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(IconosApp.clock, tamano: 14, color: tokens.textoAcento),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              Textos.falladaHace(dias),
              style: context.estilos.leyenda.copyWith(color: tokens.textoAcento),
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora de un día de repaso (Figma 22b; relleno 10/6, Etiqueta): hecho en estado/legal con
/// `check` y texto/en-primario; pendiente en fondo/superficie-alt con `clock`
/// y texto/secundario. Lleva ícono y texto, no solo color.
class PildoraRepaso extends StatelessWidget {
  const PildoraRepaso({required this.dia, required this.hecho, super.key});

  final int dia;
  final bool hecho;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = hecho ? tokens.textoEnPrimario : tokens.textoSecundario;
    return Semantics(
      container: true,
      label: Textos.diaRepasoSemantica(dia, hecho: hecho),
      excludeSemantics: true,
      child: Pildora(
        clave: ValueKey('repaso-$dia'),
        fondo: hecho ? tokens.estadoLegal : tokens.fondoSuperficieAlt,
        relleno: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconoApp(hecho ? IconosApp.check : IconosApp.clock, tamano: 14, color: color),
            const SizedBox(width: 6),
            Text(Textos.diaRepaso(dia), style: context.estilos.etiqueta.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// Las tres píldoras Día 3 · Día 7 · Día 14, separadas 8 (bajan de línea si
/// no caben).
class FilaRepaso extends StatelessWidget {
  const FilaRepaso({required this.hechos, super.key});

  /// Uno por día de [LogicaApelacion.dias] (los que falten, pendientes).
  final List<bool> hechos;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('fila-repaso'),
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (i, dia) in LogicaApelacion.dias.indexed)
          PildoraRepaso(dia: dia, hecho: i < hechos.length && hechos[i]),
      ],
    );
  }
}
