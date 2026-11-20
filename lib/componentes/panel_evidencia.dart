import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';
import 'boton_app.dart';
import 'icono_app.dart';
import 'snippet_codigo.dart';

/// Contenedor de los paneles modales del juego (evidencia y justificación):
/// fondo/superficie, esquinas superiores de 28, sombra elevada, relleno
/// 12/24/34 (más la zona segura inferior), separación 14 y asa de 40×5
/// borde/default. Si no cabe, su contenido se desplaza en vertical.
class ContenedorPanelModal extends StatelessWidget {
  const ContenedorPanelModal({
    required this.hijos,
    this.alineacion = CrossAxisAlignment.center,
    super.key,
  });

  static const double radio = 28;
  static const double separacion = 14;

  final List<Widget> hijos;
  final CrossAxisAlignment alineacion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final abajo = 34 + MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(radio)),
        boxShadow: EfectosApp.sombraGlobo,
      ),
      child: SingleChildScrollView(
        key: const ValueKey('panel-modal-desplazable'),
        padding: EdgeInsets.fromLTRB(24, 12, 24, abajo),
        child: Column(
          crossAxisAlignment: alineacion,
          children: [
            Center(
              child: ExcludeSemantics(
                child: Container(
                  key: const ValueKey('agarre'),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: tokens.bordeDefault,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            for (final hijo in hijos) ...[const SizedBox(height: separacion), hijo],
          ],
        ),
      ),
    );
  }
}

/// Visor de evidencia (Figma 16 = 38:3956 y 16b = 38:4355).
///
/// - Sin marcar (16): `highlighter` + "Inspecciona la evidencia", la
///   instrucción, el snippet (cada línea se puede marcar) y el botón
///   deshabilitado "Marca una línea para continuar".
/// - Marcada (16b): `check` estado/legal + "Línea marcada", [mensajeAcierto], el snippet con
///   las líneas clave reveladas y las marcadas resaltadas, el chip "Evidencia
///   correcta: +5 XP…" y "Volver y decidir".
/// - Línea equivocada (no está en Figma, usa el layout de 16b): `x`
///   estado/ilegal + "Esa no es la línea clave", [mensajeFallo] y sin chip.
///
/// Al abrirse, el foco va al título; cuando cambia (al marcar) se anuncia.
class PanelEvidencia extends StatelessWidget {
  const PanelEvidencia({
    required this.archivo,
    required this.lineas,
    required this.lineasClave,
    required this.mensajeAcierto,
    required this.mensajeFallo,
    required this.alMarcar,
    required this.alVolver,
    this.marcadas,
    super.key,
  });

  final String archivo;
  final List<String> lineas;
  final List<int> lineasClave;
  final String mensajeAcierto;
  final String mensajeFallo;

  /// Líneas que marcó el jugador; `null` si aún no marca (16).
  final List<int>? marcadas;
  final ValueChanged<List<int>> alMarcar;
  final VoidCallback alVolver;

  bool get _marco => marcadas != null;
  bool get _acierta => marcadas?.any(lineasClave.contains) ?? false;

  String get titulo => !_marco
      ? Textos.inspeccionaTitulo
      : _acierta
      ? Textos.lineaMarcadaTitulo
      : Textos.lineaEquivocadaTitulo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final texto = !_marco
        ? Textos.inspeccionaInstruccion
        : _acierta
        ? mensajeAcierto
        : mensajeFallo;
    return ContenedorPanelModal(
      key: const ValueKey('panel-evidencia'),
      hijos: [
        BloqueLectura(
          key: const ValueKey('titulo-evidencia'),
          etiqueta: titulo,
          encabezado: true,
          enVivo: true,
          excluirHijos: true,
          autofocus: true,
          radio: 8,
          child: Row(
            children: [
              IconoApp(
                !_marco
                    ? IconosApp.highlighter
                    : _acierta
                    ? IconosApp.check
                    : IconosApp.x,
                tamano: 22,
                color: !_marco
                    ? tokens.textoPrimario
                    : _acierta
                    ? tokens.estadoLegal
                    : tokens.estadoIlegal,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(titulo, style: estilos.h2.copyWith(color: tokens.textoPrimario)),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            texto,
            key: const ValueKey('texto-evidencia'),
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
        ),
        SnippetCodigo(
          archivo: archivo,
          lineas: lineas,
          reveladas: _marco ? lineasClave.toSet() : const {},
          marcadas: marcadas?.toSet() ?? const {},
          alMarcar: _marco ? null : alMarcar,
        ),
        if (_marco && _acierta) const ChipBonusEvidencia(),
        BotonApp(
          texto: _marco ? Textos.volverYDecidir : Textos.marcaUnaLinea,
          alPresionar: _marco ? alVolver : null,
        ),
      ],
    );
  }
}

/// Chip de 16b (Figma 38:4545): fondo/destacado, radio 999, relleno
/// 10/12/6/6, separación 6, `star` de 16 y texto Etiqueta texto/primario.
class ChipBonusEvidencia extends StatelessWidget {
  const ChipBonusEvidencia({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: const ValueKey('chip-bonus-evidencia'),
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: tokens.fondoDestacado,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconoApp(IconosApp.star, tamano: 16, color: tokens.textoAcento),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              Textos.evidenciaCorrectaBonus,
              style: context.estilos.etiqueta.copyWith(color: tokens.textoPrimario),
            ),
          ),
        ],
      ),
    );
  }
}
