import 'package:material_ui/material_ui.dart';

import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'bloque_lectura.dart';
import 'boton_app.dart';
import 'icono_app.dart';
import 'opcion_justificacion.dart';
import 'panel_evidencia.dart';

/// Panel de justificación (Figma 18 = 38:4737): se abre tras dictar el
/// veredicto en una tarjeta de dilema, antes del panel de veredicto.
///
/// Chip "Dictaste: …" del color del veredicto, "¿Por qué es …?" (Título/H1
/// centrado), el subtítulo, las 3 opciones (elegir solo selecciona) y
/// "Confirmar justificación", deshabilitado hasta elegir una. Al abrirse, el
/// foco va al título, que anuncia "Dictaste ILEGAL. ¿Por qué es ilegal?".
class PanelJustificacion extends StatefulWidget {
  const PanelJustificacion({
    required this.veredicto,
    required this.justificacion,
    required this.alConfirmar,
    super.key,
  });

  final Veredicto veredicto;
  final Justificacion justificacion;

  /// Recibe el índice de la opción elegida.
  final ValueChanged<int> alConfirmar;

  static Color color(Veredicto v, TokensColor t) => switch (v) {
    Veredicto.legal => t.estadoLegal,
    Veredicto.ilegal => t.estadoIlegal,
    Veredicto.condicional => t.estadoCondicional,
    Veredicto.escalar => t.estadoEscalar,
  };

  static IconData icono(Veredicto v) => switch (v) {
    Veredicto.legal => IconosApp.check,
    Veredicto.ilegal => IconosApp.x,
    Veredicto.condicional => IconosApp.arrowUp,
    Veredicto.escalar => IconosApp.arrowDown,
  };

  /// "ILEGAL", "LEGAL", "CON CONDICIONES" o "A JURÍDICO" (como los sellos).
  static String nombre(Veredicto v) => switch (v) {
    Veredicto.legal => Textos.selloLegal,
    Veredicto.ilegal => Textos.selloIlegal,
    Veredicto.condicional => Textos.selloCondicional,
    Veredicto.escalar => Textos.selloEscalar,
  };

  static String pregunta(Veredicto v) => switch (v) {
    Veredicto.legal => Textos.porQueLegal,
    Veredicto.ilegal => Textos.porQueIlegal,
    Veredicto.condicional => Textos.porQueCondicional,
    Veredicto.escalar => Textos.porQueEscalar,
  };

  @override
  State<PanelJustificacion> createState() => _PanelJustificacionState();
}

class _PanelJustificacionState extends State<PanelJustificacion> {
  int? _elegida;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final v = widget.veredicto;
    final pregunta = PanelJustificacion.pregunta(v);
    final opciones = widget.justificacion.opciones;
    final elegida = _elegida;
    return ContenedorPanelModal(
      key: const ValueKey('panel-justificacion'),
      hijos: [
        BloqueLectura(
          key: const ValueKey('titulo-justificacion'),
          etiqueta: Textos.justificacionAnuncio(PanelJustificacion.nombre(v), pregunta),
          encabezado: true,
          enVivo: true,
          excluirHijos: true,
          autofocus: true,
          radio: 8,
          child: Column(
            children: [
              Container(
                key: const ValueKey('chip-veredicto'),
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                decoration: BoxDecoration(
                  color: PanelJustificacion.color(v, tokens),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconoApp(
                      PanelJustificacion.icono(v),
                      tamano: 14,
                      color: tokens.textoEnPrimario,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        Textos.dictaste(PanelJustificacion.nombre(v)),
                        style: estilos.etiqueta.copyWith(color: tokens.textoEnPrimario),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                pregunta,
                textAlign: TextAlign.center,
                style: estilos.h1.copyWith(color: tokens.textoPrimario),
              ),
            ],
          ),
        ),
        Text(
          Textos.justificacionSubtitulo,
          textAlign: TextAlign.center,
          style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
        ),
        Column(
          key: const ValueKey('opciones-justificacion'),
          children: [
            for (final (i, opcion) in opciones.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              OpcionJustificacion(
                texto: opcion,
                posicion: i + 1,
                total: opciones.length,
                seleccionada: elegida == i,
                alElegir: () => setState(() => _elegida = i),
              ),
            ],
          ],
        ),
        BotonApp(
          texto: Textos.confirmarJustificacion,
          alPresionar: elegida == null ? null : () => widget.alConfirmar(elegida),
        ),
      ],
    );
  }
}
