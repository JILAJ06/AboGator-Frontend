import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'accion_enfocable.dart';
import 'avatar_app.dart';
import 'icono_app.dart';

/// Tarjeta de caso del juego (Figma 10:5): 342×440 (el alto lo da quien la
/// usa), fondo/superficie, borde 1 borde/default, radio 28 y sombra de la
/// tarjeta. Relleno 24/22/20/22 y separación 18 entre: etiqueta del caso (chip
/// con el color del módulo al 14 % y texto/acento), personaje (avatar 48 con
/// iniciales, nombre y rol), globo del caso (fondo/superficie-alt, esquinas
/// 6/20/20/20, Fredoka SemiBold 17/25), un espacio flexible y la pista de
/// gesto, que lleva texto además de color.
///
/// Por [tipo] (Figma 10:22 y 10:50):
/// - evidencia (15): chip "Evidencia" a la derecha del encabezado y, bajo el
///   globo, el botón "Toca la tarjeta para inspeccionar" ([alInspeccionar]);
/// - justificación (17): chip "Dilema ×2" y el aviso de monedas dobles.
///
/// Si el texto del globo no cabe, se desplaza dentro de la tarjeta.
class TarjetaCaso extends StatelessWidget {
  const TarjetaCaso({
    required this.etiquetaCaso,
    required this.colorModulo,
    required this.iniciales,
    required this.personaje,
    required this.rol,
    required this.texto,
    this.tipo = TipoTarjeta.normal,
    this.alInspeccionar,
    this.nodoFocoEvidencia,
    this.palabrasTrampa = const [],
    super.key,
  });

  static const double ancho = 342;
  static const double alto = 440;
  static const double radio = 28;

  /// Alto mínimo (la zona de la tarjeta se encoge hasta aquí).
  static const double altoMinimo = 260;

  /// Alto mínimo con el texto dinámico: lo que ocupan el relleno, la
  /// etiqueta, el personaje, una línea del globo y la pista (≈ 260 al 100 %). Con texto
  /// grande la zona pide más alto y la pantalla se vuelve desplazable.
  static double altoMinimoPara(TextScaler escala, {TipoTarjeta tipo = TipoTarjeta.normal}) {
    double s(double tamano) => escala.scale(tamano);
    final contenido =
        24 +
        20 + // relleno
        s(14) +
        10 + // etiqueta
        18 +
        math.max(48, s(20) + 2 + s(14)) + // personaje
        18 +
        36 +
        s(25) + // globo con una línea
        18 +
        math.max(s(16), s(14) * 2 + 2) + // pista
        switch (tipo) {
          TipoTarjeta.normal => 0,
          TipoTarjeta.evidencia => 18 + math.max(48, s(20) + 12), // botón
          TipoTarjeta.justificacion => 18 + 24 + math.max(20, s(14) * 3), // aviso
        };
    return math.max(altoMinimo, contenido);
  }

  final String etiquetaCaso;
  final Color colorModulo;
  final String iniciales;
  final String personaje;
  final String rol;
  final String texto;
  final TipoTarjeta tipo;

  /// Abre el visor de evidencia (botón de la tarjeta con evidencia).
  final VoidCallback? alInspeccionar;

  /// Foco del botón de evidencia (vuelve aquí al cerrar el visor).
  final FocusNode? nodoFocoEvidencia;

  /// Palabras trampa resaltadas por la Lupa (10b); vacía si no se usó.
  final List<String> palabrasTrampa;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;

    return Semantics(
      label: palabrasTrampa.isEmpty
          ? Textos.casoSemantica(personaje, rol, texto)
          : '${Textos.casoSemantica(personaje, rol, texto)} '
                '(${Textos.palabrasTrampaSemantica(palabrasTrampa)})',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('tarjeta-caso'),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficie,
          borderRadius: BorderRadius.circular(radio),
          border: Border.all(color: tokens.bordeDefault),
          boxShadow: EfectosApp.sombraTarjetaCaso,
        ),
        // Si todo cabe, el globo ocupa el espacio libre y la pista queda al
        // pie; si no (texto grande o tarjeta baja), el contenido se desplaza
        // dentro de la tarjeta.
        child: CustomScrollView(
          key: const ValueKey('contenido-caso'),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta a la izquierda y chip del tipo a la derecha, como en
                  // Figma (space-between, sin hueco fijo). Si no caben en una
                  // línea (texto grande), el chip baja.
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        Container(
                          key: const ValueKey('etiqueta-caso'),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorModulo.withValues(alpha: EfectosApp.opacidadEtiquetaCaso),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            etiquetaCaso,
                            style: estilos.leyenda.copyWith(color: tokens.textoAcento),
                          ),
                        ),
                        if (tipo != TipoTarjeta.normal) ChipTipoTarjeta(tipo: tipo),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      AvatarApp(iniciales: iniciales, tamano: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personaje,
                              style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rol,
                              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    key: const ValueKey('globo-caso'),
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: tokens.fondoSuperficieAlt,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: TextoConTrampas(
                      texto: texto,
                      trampas: palabrasTrampa,
                      estilo: estilos.h3.copyWith(color: tokens.textoPrimario, height: 25 / 17),
                    ),
                  ),
                  if (tipo == TipoTarjeta.evidencia) ...[
                    const SizedBox(height: 18),
                    BotonEvidencia(alPresionar: alInspeccionar, nodoFoco: nodoFocoEvidencia),
                  ],
                  if (tipo == TipoTarjeta.justificacion) ...[
                    const SizedBox(height: 18),
                    const AvisoDilema(),
                  ],
                  const Spacer(),
                  const SizedBox(height: 18),
                  const PistaGesto(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Texto del globo con las palabras trampa marcadas (Figma 38:4914): un
/// subrayado grueso (11 a tamaño normal) de #FFD84D al 65 % detrás de cada
/// trampa, como un marcador; en oscuro al 35 % para que el texto siga en AA.
/// Sin [trampas] es un texto normal. El subrayado se calcula con las cajas
/// del texto, así que sigue a las trampas aunque cambien de línea.
class TextoConTrampas extends StatelessWidget {
  const TextoConTrampas({
    required this.texto,
    required this.estilo,
    this.trampas = const [],
    super.key,
  });

  final String texto;
  final TextStyle estilo;
  final List<String> trampas;

  /// Rangos (inicio, fin) de cada aparición de las [trampas] en [texto].
  static List<(int, int)> rangos(String texto, List<String> trampas) {
    final rangos = <(int, int)>[];
    for (final t in trampas) {
      if (t.isEmpty) continue;
      var desde = 0;
      while (true) {
        final i = texto.indexOf(t, desde);
        if (i < 0) break;
        rangos.add((i, i + t.length));
        desde = i + t.length;
      }
    }
    return rangos;
  }

  @override
  Widget build(BuildContext context) {
    final texto = Text(this.texto, style: estilo);
    if (trampas.isEmpty) return texto;
    // El pintor repite el acomodo del texto: mismo estilo efectivo (con el
    // DefaultTextStyle) y mismo ancho (el texto ocupa todo el globo).
    final porDefecto = DefaultTextStyle.of(context);
    return CustomPaint(
      key: const ValueKey('trampas-globo'),
      painter: PintorTrampas(
        texto: this.texto,
        estilo: porDefecto.style.merge(estilo),
        alturaTexto: porDefecto.textHeightBehavior,
        escala: MediaQuery.textScalerOf(context),
        rangos: rangos(this.texto, trampas),
        color: EfectosApp.trampa(Theme.of(context).brightness),
      ),
      child: SizedBox(width: double.infinity, child: texto),
    );
  }
}

/// Pinta el subrayado de las trampas detrás del texto, centrado en la línea
/// base (de 6 por encima a 5 por debajo, escalado con el texto).
class PintorTrampas extends CustomPainter {
  const PintorTrampas({
    required this.texto,
    required this.estilo,
    required this.escala,
    required this.rangos,
    required this.color,
    this.alturaTexto,
  });

  final String texto;
  final TextStyle estilo;
  final TextHeightBehavior? alturaTexto;
  final TextScaler escala;
  final List<(int, int)> rangos;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
      textScaler: escala,
      textHeightBehavior: alturaTexto,
    )..layout(maxWidth: size.width);
    final lineas = pintor.computeLineMetrics();
    final grosor = escala.scale(EfectosApp.grosorTrampa);
    final pincel = Paint()..color = color;
    for (final (inicio, fin) in rangos) {
      final cajas = pintor.getBoxesForSelection(
        TextSelection(baseOffset: inicio, extentOffset: fin),
      );
      for (final caja in cajas) {
        final centro = (caja.top + caja.bottom) / 2;
        final linea = lineas.firstWhere(
          (l) => centro >= l.baseline - l.ascent && centro <= l.baseline + l.descent,
          orElse: () => lineas.last,
        );
        final arriba = linea.baseline - grosor * 6 / 11;
        canvas.drawRect(Rect.fromLTRB(caja.left, arriba, caja.right, arriba + grosor), pincel);
      }
    }
    pintor.dispose();
  }

  @override
  bool shouldRepaint(PintorTrampas oldDelegate) =>
      oldDelegate.texto != texto ||
      oldDelegate.estilo != estilo ||
      oldDelegate.escala != escala ||
      oldDelegate.color != color ||
      oldDelegate.rangos.length != rangos.length;
}

/// Chip del tipo de tarjeta, a la derecha del encabezado: píldora con
/// relleno 8/10/4/4, separación 4, ícono de 14 y texto Leyenda
/// texto/en-primario. Evidencia: accion/secundaria con `eye`; dilema:
/// accion/acento con `star` y "Dilema ×2".
class ChipTipoTarjeta extends StatelessWidget {
  const ChipTipoTarjeta({required this.tipo, super.key}) : assert(tipo != TipoTarjeta.normal);

  final TipoTarjeta tipo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final evidencia = tipo == TipoTarjeta.evidencia;
    return Container(
      key: const ValueKey('chip-tipo'),
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: evidencia ? tokens.accionSecundaria : tokens.accionAcento,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(
            evidencia ? IconosApp.eye : IconosApp.star,
            tamano: 14,
            color: tokens.textoEnPrimario,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              evidencia ? Textos.tipoEvidencia : Textos.tipoDilema,
              style: context.estilos.leyenda.copyWith(color: tokens.textoEnPrimario),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de evidencia (Figma 10:40): ancho completo, alto 48, radio 14, borde
/// 2 discontinuo accion/secundaria y sin fondo; ícono `code` de 20 y "Toca la
/// tarjeta para inspeccionar" (Cuerpo/Énfasis accion/secundaria). Es un botón
/// real (foco, Enter y Espacio); con el lector se usa la acción "Inspeccionar
/// evidencia" de la tarjeta.
class BotonEvidencia extends StatelessWidget {
  const BotonEvidencia({required this.alPresionar, this.nodoFoco, super.key});

  static const double radio = 14;

  final VoidCallback? alPresionar;
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final color = context.tokens.accionSecundaria;
    return AccionEnfocable(
      alPresionar: alPresionar,
      nodoFoco: nodoFoco,
      radio: radio,
      semantica: (hijo) => Semantics(
        button: true,
        enabled: alPresionar != null,
        label: Textos.accionInspeccionar,
        onTap: alPresionar,
        excludeSemantics: true,
        child: hijo,
      ),
      child: CustomPaint(
        key: const ValueKey('boton-evidencia'),
        painter: _BordeDiscontinuo(color: color),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconoApp(IconosApp.code, tamano: 20, color: color),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  Textos.inspeccionarEvidencia,
                  textAlign: TextAlign.center,
                  style: context.estilos.cuerpoEnfasis.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borde de 2 discontinuo con el radio de [BotonEvidencia].
class _BordeDiscontinuo extends CustomPainter {
  const _BordeDiscontinuo({required this.color});

  final Color color;

  static const double guion = 6;
  static const double hueco = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final borde = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      const Radius.circular(BotonEvidencia.radio - 1),
    );
    for (final metrica in (Path()..addRRect(borde)).computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += guion + hueco) {
        canvas.drawPath(metrica.extractPath(d, d + guion), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_BordeDiscontinuo oldDelegate) => oldDelegate.color != color;
}

/// Aviso de la tarjeta de dilema (Figma 10:67): fondo/destacado, radio 14,
/// relleno 14/12, separación 10, `star` de 20 y texto Leyenda texto/primario.
class AvisoDilema extends StatelessWidget {
  const AvisoDilema({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: const ValueKey('aviso-dilema'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.fondoDestacado,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconoApp(IconosApp.star, tamano: 20, color: tokens.textoAcento),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Textos.avisoDilema,
              style: context.estilos.leyenda.copyWith(color: tokens.textoPrimario),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pista de gesto al pie de la tarjeta: "← ILEGAL" (estado/ilegal), "↑
/// CONDICIONAL" sobre "↓ ESCALAR" (estado/condicional y estado/escalar) y
/// "LEGAL →" (estado/legal). Decorativa: los botones dicen lo mismo.
class PistaGesto extends StatelessWidget {
  const PistaGesto({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return ExcludeSemantics(
      child: Row(
        key: const ValueKey('pista-gesto'),
        children: [
          Expanded(
            child: Text(
              Textos.casoPistaIlegal,
              style: estilos.etiqueta.copyWith(color: tokens.estadoIlegal),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Textos.casoPistaCondicional,
                  textAlign: TextAlign.center,
                  style: estilos.leyenda.copyWith(color: tokens.estadoCondicional),
                ),
                const SizedBox(height: 2),
                Text(
                  Textos.casoPistaEscalar,
                  textAlign: TextAlign.center,
                  style: estilos.leyenda.copyWith(color: tokens.estadoEscalar),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              Textos.casoPistaLegal,
              textAlign: TextAlign.right,
              style: estilos.etiqueta.copyWith(color: tokens.estadoLegal),
            ),
          ),
        ],
      ),
    );
  }
}
