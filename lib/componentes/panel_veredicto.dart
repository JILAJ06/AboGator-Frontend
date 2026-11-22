import 'package:material_ui/material_ui.dart';

import '../core/tema/efectos.dart';
import '../core/tema/iconos_app.dart';
import '../core/tema/tokens_color.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/tarjeta.dart';
import 'agarre_hoja.dart';
import 'bloque_lectura.dart';
import 'boton_app.dart';
import 'hoja_lateral.dart';
import 'icono_app.dart';
import 'impacto_startup.dart';
import 'indicadores_startup.dart';
import 'opcion_justificacion.dart';
import 'sarko_imagen.dart';

/// Las 5 variantes del panel de veredicto (Figma 37:2427, 37:2671, 37:4047,
/// 37:3287 y 38:5384).
enum TipoPanelVeredicto {
  /// 12 · ¡Veredicto correcto! (con micro-pregunta o con explicación).
  correcto,

  /// 12b · ¡Bonus ganado!
  bonus,

  /// 12c · Respuesta parcial.
  parcial,

  /// 14 · Veredicto incorrecto.
  incorrecto,

  /// 14b · ¡El Amparo te protegió!
  amparo,
}

/// Panel que sube tras un veredicto. Un solo componente con 5 variantes:
/// cambian el color, el ícono, los textos, la pose de Sarko, el contenido
/// central (micro-pregunta o "¿Por qué?") y el botón.
///
/// Contenedor fondo/superficie con esquinas superiores de 28, sombra elevada
/// y relleno 12/24/34 (más la zona segura inferior). Si no cabe, su contenido
/// se desplaza. Al abrirse, el foco va al título, que se anuncia con el
/// subtítulo y el impacto.
class PanelVeredicto extends StatelessWidget {
  const PanelVeredicto({
    required this.tipo,
    required this.subtitulo,
    required this.cambios,
    required this.alContinuar,
    this.explicacion,
    this.microPregunta,
    this.alElegirOpcion,
    super.key,
  }) : assert(explicacion != null || microPregunta != null);

  static const double radio = 28;
  static const double anchoSarko = 76.8;

  final TipoPanelVeredicto tipo;
  final String subtitulo;
  final Map<IndicadorStartup, int> cambios;

  /// Texto del "¿Por qué?". Se usa si no hay [microPregunta].
  final String? explicacion;

  /// Solo en la variante Correcto antes de responderla: reemplaza a la
  /// explicación y el botón pasa a ser "Saltar bonus".
  final MicroPregunta? microPregunta;
  final ValueChanged<int>? alElegirOpcion;

  /// Botón principal ("Saltar bonus", "Continuar" o "Entendido").
  final VoidCallback? alContinuar;

  bool get _conPregunta => tipo == TipoPanelVeredicto.correcto && microPregunta != null;

  static Color color(TipoPanelVeredicto tipo, TokensColor t) => switch (tipo) {
    TipoPanelVeredicto.correcto || TipoPanelVeredicto.bonus => t.estadoLegal,
    TipoPanelVeredicto.parcial => t.estadoEscalar,
    TipoPanelVeredicto.incorrecto => t.estadoIlegal,
    TipoPanelVeredicto.amparo => t.accionSecundaria,
  };

  static IconData icono(TipoPanelVeredicto tipo) => switch (tipo) {
    TipoPanelVeredicto.correcto => IconosApp.check,
    TipoPanelVeredicto.bonus => IconosApp.star,
    TipoPanelVeredicto.parcial => IconosApp.arrowDown,
    TipoPanelVeredicto.incorrecto => IconosApp.x,
    TipoPanelVeredicto.amparo => IconosApp.shieldCheck,
  };

  static String titulo(TipoPanelVeredicto tipo) => switch (tipo) {
    TipoPanelVeredicto.correcto => Textos.veredictoCorrectoTitulo,
    TipoPanelVeredicto.bonus => Textos.bonusGanadoTitulo,
    TipoPanelVeredicto.parcial => Textos.respuestaParcialTitulo,
    TipoPanelVeredicto.incorrecto => Textos.veredictoIncorrectoTitulo,
    TipoPanelVeredicto.amparo => Textos.amparoTitulo,
  };

  static PoseSarko pose(TipoPanelVeredicto tipo) => switch (tipo) {
    TipoPanelVeredicto.correcto || TipoPanelVeredicto.bonus => PoseSarko.alegre,
    TipoPanelVeredicto.parcial || TipoPanelVeredicto.amparo => PoseSarko.sorprendido,
    TipoPanelVeredicto.incorrecto => PoseSarko.triste,
  };

  /// "Impacto: Reputación +5, Riesgo legal −10".
  static String anuncioImpacto(Map<IndicadorStartup, int> cambios) => Textos.impactoAnuncio([
    for (final i in IndicadorStartup.values)
      if ((cambios[i] ?? 0) != 0) Textos.impactoSemantica(i.nombre, cambios[i]!),
  ]);

  /// Lo que se anuncia al abrir: "{título}. {subtítulo}. Impacto: …".
  String get anuncio => Textos.panelAnuncio(titulo(tipo), subtitulo, anuncioImpacto(cambios));

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final color = PanelVeredicto.color(tipo, tokens);
    final separacion = tipo == TipoPanelVeredicto.incorrecto ? 16.0 : 14.0;
    final abajo = HojaLateral.rellenoInferior(context);

    final (textoBoton, tipoBoton) = switch (tipo) {
      _ when _conPregunta => (Textos.saltarBonus, TipoBoton.fantasma),
      TipoPanelVeredicto.correcto ||
      TipoPanelVeredicto.bonus ||
      TipoPanelVeredicto.parcial => (Textos.continuar, TipoBoton.primario),
      TipoPanelVeredicto.incorrecto => (Textos.entendido, TipoBoton.peligro),
      TipoPanelVeredicto.amparo => (Textos.entendido, TipoBoton.secundario),
    };

    return Container(
      key: const ValueKey('panel-veredicto'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        // En tablet (hoja lateral): las cuatro esquinas y borde de 1.
        borderRadius: HojaLateral.radioDe(context, radio),
        border: HojaLateral.bordeDe(context, tokens.bordeDefault),
        boxShadow: EfectosApp.sombraGlobo,
      ),
      child: SingleChildScrollView(
        key: const ValueKey('panel-desplazable'),
        padding: EdgeInsets.fromLTRB(24, 12, 24, abajo),
        child: Column(
          children: [
            const AgarreHoja(),
            SizedBox(height: separacion),
            Row(
              children: [
                Expanded(
                  child: BloqueLectura(
                    key: const ValueKey('titulo-panel'),
                    etiqueta: anuncio,
                    encabezado: true,
                    enVivo: true,
                    excluirHijos: true,
                    autofocus: true,
                    radio: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              key: const ValueKey('insignia'),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              child: Center(
                                child: IconoApp(
                                  icono(tipo),
                                  tamano: 18,
                                  color: tokens.textoEnPrimario,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(titulo(tipo), style: estilos.h2.copyWith(color: color)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Text(subtitulo, style: estilos.etiqueta.copyWith(color: color)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SarkoImagen(pose: pose(tipo), ancho: anchoSarko, decorativa: true),
              ],
            ),
            SizedBox(height: separacion),
            BloqueLectura(
              key: const ValueKey('impacto-panel'),
              radio: 8,
              child: ImpactoStartup(cambios: cambios),
            ),
            SizedBox(height: separacion),
            if (_conPregunta)
              _MicroPregunta(pregunta: microPregunta!, alElegir: alElegirOpcion)
            else
              BloqueLectura(
                key: const ValueKey('explicacion-panel'),
                child: _Explicacion(texto: explicacion ?? ''),
              ),
            SizedBox(height: separacion),
            BotonApp(texto: textoBoton, tipo: tipoBoton, alPresionar: alContinuar),
          ],
        ),
      ),
    );
  }
}

/// "¿Por qué?" con su texto: fondo/superficie-alt, radio 16, relleno 16×14,
/// separación 6.
class _Explicacion extends StatelessWidget {
  const _Explicacion({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Container(
      key: const ValueKey('caja-explicacion'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficieAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Textos.porQue, style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario)),
          const SizedBox(height: 6),
          Text(texto, style: estilos.cuerpoBase.copyWith(color: tokens.textoPrimario)),
        ],
      ),
    );
  }
}

/// Micro-pregunta de bonus: fondo/destacado, radio 16, relleno 16×14,
/// separación 10; título con star de 18 y las opciones.
class _MicroPregunta extends StatelessWidget {
  const _MicroPregunta({required this.pregunta, required this.alElegir});

  final MicroPregunta pregunta;
  final ValueChanged<int>? alElegir;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final total = pregunta.opciones.length;
    final elegir = alElegir;
    return Container(
      key: const ValueKey('caja-micro-pregunta'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.fondoDestacado,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                IconoApp(IconosApp.star, tamano: 18, color: tokens.textoAcento),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    Textos.bonusPregunta(5, pregunta.enunciado),
                    style: context.estilos.cuerpoEnfasis.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ],
            ),
          ),
          for (final (i, opcion) in pregunta.opciones.indexed) ...[
            const SizedBox(height: 10),
            OpcionJustificacion(
              texto: opcion,
              posicion: i + 1,
              total: total,
              alElegir: elegir == null ? null : () => elegir(i),
            ),
          ],
        ],
      ),
    );
  }
}
