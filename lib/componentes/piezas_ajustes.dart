import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'accion_enfocable.dart';
import 'caja_superficie.dart';
import 'icono_app.dart';

/// Interruptor de los ajustes (Figma 26): 48×28, radio 14 y pulgar de 22.
/// Encendido: pista accion/primaria con el pulgar a la derecha; apagado:
/// borde/control con el pulgar a la izquierda. El pulgar es
/// fondo/superficie. Es decorativo: lo maneja y lo anuncia la fila.
///
/// Con [grande] mide 52×32 con pulgar de 26 (Figma 34, Notificaciones; T-13b).
class InterruptorApp extends StatelessWidget {
  const InterruptorApp({required this.valor, this.grande = false, super.key});

  static const double ancho = 48;
  static const double alto = 28;
  static const double pulgar = 22;

  static const double anchoGrande = 52;
  static const double altoGrande = 32;
  static const double pulgarGrande = 26;

  final bool valor;
  final bool grande;

  /// Color de la pista según [valor].
  static Color colorPista(bool valor, BuildContext context) =>
      valor ? context.tokens.accionPrimaria : context.tokens.bordeControl;

  @override
  Widget build(BuildContext context) {
    final sinAnimaciones = MediaQuery.disableAnimationsOf(context);
    final duracion = sinAnimaciones ? Duration.zero : const Duration(milliseconds: 150);
    final anchoPista = grande ? anchoGrande : ancho;
    final altoPista = grande ? altoGrande : alto;
    final ladoPulgar = grande ? pulgarGrande : pulgar;
    return ExcludeSemantics(
      child: AnimatedContainer(
        key: const ValueKey('interruptor'),
        duration: duracion,
        width: anchoPista,
        height: altoPista,
        padding: EdgeInsets.all((altoPista - ladoPulgar) / 2),
        decoration: BoxDecoration(
          color: colorPista(valor, context),
          borderRadius: BorderRadius.circular(altoPista / 2),
        ),
        child: AnimatedAlign(
          duration: duracion,
          alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: ladoPulgar,
            height: ladoPulgar,
            decoration: BoxDecoration(
              color: context.tokens.fondoSuperficie,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Interruptor que se toca por sí solo (T-13b): el [InterruptorApp] grande en
/// una zona de 48 de alto, con anillo de foco y semántica de interruptor
/// ("Recordatorio diario, activado"). Para filas en las que tocar la fila hace
/// otra cosa (el recordatorio abre el selector de hora).
class InterruptorTocable extends StatelessWidget {
  const InterruptorTocable({
    required this.valor,
    required this.etiqueta,
    required this.alCambiar,
    super.key,
  });

  final bool valor;
  final String etiqueta;
  final ValueChanged<bool>? alCambiar;

  @override
  Widget build(BuildContext context) {
    final cambiar = alCambiar;
    final accion = cambiar == null ? null : () => cambiar(!valor);
    return AccionEnfocable(
      alPresionar: accion,
      radio: 16,
      semantica: (hijo) => Semantics(
        toggled: valor,
        label: etiqueta,
        onTap: accion,
        excludeSemantics: true,
        child: hijo,
      ),
      child: SizedBox(
        width: 64,
        height: 48,
        child: Center(child: InterruptorApp(valor: valor, grande: true)),
      ),
    );
  }
}

/// Chip de valor (Figma 26): fondo/superficie-alt, radio 10, relleno 10×6 y
/// Etiqueta texto/primario ("Aa 120 %", "Activo").
class ChipValor extends StatelessWidget {
  const ChipValor({required this.texto, super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return CajaSuperficie(
      relleno: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      fondo: FondoCaja.superficieAlt,
      radio: 10,
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: context.estilos.etiqueta.copyWith(color: tokens.textoPrimario),
      ),
    );
  }
}

/// Fila de ajuste (Figma 26): relleno 16×12, separación 12, ícono de 22,
/// título (Cuerpo/Énfasis) y detalle (Leyenda texto/secundario), y el
/// [control] a la derecha. Alto ≥ 56 y el toque abarca toda la fila.
///
/// Semántica: una sola etiqueta "Título, detalle"; con [interruptor] se lee
/// como interruptor con su estado, con [valorSemantico] como botón con valor;
/// sin [alPresionar] no es tocable ni recibe foco.
class FilaAjuste extends StatelessWidget {
  const FilaAjuste({
    required this.titulo,
    required this.detalle,
    required this.control,
    this.alPresionar,
    this.interruptor,
    this.valorSemantico,
    this.etiquetaSemantica,
    this.nodoFoco,
    this.icono,
    this.rellenoHorizontal = 16,
    super.key,
  });

  static const double altoMinimo = 56;

  /// Ícono de 22 a la izquierda; sin él, el texto empieza en el relleno
  /// (filas de Notificaciones, Figma 34; T-13b).
  final IconData? icono;

  /// Relleno a los lados (16; 20 en las Notificaciones de tablet).
  final double rellenoHorizontal;
  final String titulo;
  final String detalle;
  final Widget control;
  final VoidCallback? alPresionar;

  /// Estado del interruptor (`null` si la fila no es un interruptor).
  final bool? interruptor;
  final String? valorSemantico;

  /// Lo que lee el lector (por defecto, "Título, detalle").
  final String? etiquetaSemantica;

  /// Nodo de foco propio (el foco vuelve aquí al cerrar el selector; T-13).
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final contenido = Container(
      constraints: const BoxConstraints(minHeight: altoMinimo),
      padding: EdgeInsets.symmetric(horizontal: rellenoHorizontal, vertical: 12),
      child: LayoutBuilder(
        builder: (context, restricciones) => Row(
          children: [
            if (icono case final icono?) ...[
              IconoApp(icono, tamano: 22, color: tokens.textoPrimario),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario)),
                  const SizedBox(height: 2),
                  Text(detalle, style: estilos.leyenda.copyWith(color: tokens.textoSecundario)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Con texto grande en pantallas angostas el chip parte su texto en
            // lugar de desbordarse (el interruptor siempre cabe).
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: math.max(InterruptorApp.ancho, restricciones.maxWidth * 0.4),
              ),
              child: control,
            ),
          ],
        ),
      ),
    );
    final etiqueta = etiquetaSemantica ?? Textos.filaAjusteSemantica(titulo, detalle);
    final accion = alPresionar;
    if (accion == null) {
      return Semantics(container: true, label: etiqueta, excludeSemantics: true, child: contenido);
    }
    return AccionEnfocable(
      alPresionar: accion,
      radio: 12,
      nodoFoco: nodoFoco,
      semantica: (hijo) => Semantics(
        container: true,
        button: interruptor == null,
        toggled: interruptor,
        label: etiqueta,
        value: valorSemantico,
        excludeSemantics: true,
        child: hijo,
      ),
      child: contenido,
    );
  }
}

/// Encabezado de sección de los ajustes (Figma 26): Etiqueta texto/secundario
/// a 4 del borde de la tarjeta.
class EncabezadoSeccionAjustes extends StatelessWidget {
  const EncabezadoSeccionAjustes(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Semantics(
      header: true,
      child: Text(
        texto,
        style: context.estilos.etiqueta.copyWith(color: context.tokens.textoSecundario),
      ),
    ),
  );
}

/// Opción del selector de tamaño: radio, "Aa" a ese tamaño y "120 %"; alto
/// ≥ 48. Se lee "120 por ciento" y si está elegida.
class OpcionTamano extends StatelessWidget {
  const OpcionTamano({
    required this.porcentaje,
    required this.elegida,
    required this.alElegir,
    this.nodoFoco,
    super.key,
  });

  final int porcentaje;
  final bool elegida;
  final VoidCallback alElegir;
  final FocusNode? nodoFoco;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return AccionEnfocable(
      alPresionar: alElegir,
      radio: 12,
      nodoFoco: nodoFoco,
      semantica: (hijo) => Semantics(
        inMutuallyExclusiveGroup: true,
        checked: elegida,
        button: true,
        label: Textos.porcentajeSemantica(porcentaje),
        excludeSemantics: true,
        child: hijo,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: elegida ? tokens.accionPrimaria : tokens.bordeControl,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: elegida
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.accionPrimaria,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                Textos.muestraTamano,
                // La muestra a ese tamaño (además de la escala del sistema).
                style: estilos.cuerpoEnfasis.copyWith(
                  color: tokens.textoPrimario,
                  fontSize: (estilos.cuerpoEnfasis.fontSize ?? 14) * porcentaje / 100,
                ),
              ),
            ),
            Text(
              Textos.porcentaje(porcentaje),
              style: estilos.etiqueta.copyWith(color: tokens.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Vista previa" de los ajustes en tablet (Figma 101:4888): fondo/superficie-alt,
/// radio 20, relleno 20 y separación 10. "VISTA PREVIA · TEXTO AL N %" (Leyenda
/// en texto/secundario), la pregunta de ejemplo (Título/H2) y el texto (Cuerpo/Base
/// en texto/secundario). Se ve con el tamaño de texto elegido.
class VistaPreviaTexto extends StatelessWidget {
  const VistaPreviaTexto({required this.porcentaje, super.key});

  final int porcentaje;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return CajaSuperficie(
      clave: const ValueKey('vista-previa'),
      relleno: const EdgeInsets.all(20),
      fondo: FondoCaja.superficieAlt,
      radio: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Textos.vistaPreviaEtiqueta(porcentaje),
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
          const SizedBox(height: 10),
          Text(Textos.vistaPreviaPregunta, style: estilos.h2.copyWith(color: tokens.textoPrimario)),
          const SizedBox(height: 10),
          Text(
            Textos.vistaPreviaTexto,
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
        ],
      ),
    );
  }
}
