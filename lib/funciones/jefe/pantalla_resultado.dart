import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/aviso_snack.dart';
import '../../componentes/bloque_lectura.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/confeti_sprint.dart';
import '../../componentes/cuenta_regresiva_vida.dart';
import '../../componentes/disposicion_resultado_tablet.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/ilustracion_sarko.dart';
import '../../componentes/piezas_resultado.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/resultado_examen.dart';
import '../ajustes/estado_ajustes.dart';
import 'estado_examen.dart';
import 'logica_resultado.dart';
import 'reloj_crisis.dart';

/// Base de 29 y 30: registra el resultado al abrir (una sola vez, aunque se
/// vuelva a entrar), anuncia y vibra al terminar, y manda atrás al mapa del
/// módulo (nunca al examen).
abstract class _EstadoResultado<T extends ConsumerStatefulWidget> extends ConsumerState<T> {
  String get moduloId;

  bool _anunciado = false;

  @override
  void initState() {
    super.initState();
    unawaited(Future.microtask(_registrar));
  }

  Future<void> _registrar() async {
    if (!mounted) return;
    await ref.read(examenProvider.notifier).registrarResultado();
  }

  /// Lo que se anuncia al terminar de registrar.
  String anuncio(EstadoExamenJefe examen, ResultadoRegistrado registro);

  /// Vibración al terminar de registrar.
  Future<void> vibrar();

  void _alCambiar(EstadoExamenJefe? antes, EstadoExamenJefe? ahora) {
    final registro = ahora?.registro;
    if (_anunciado || ahora == null || registro == null || !ahora.apelacionesEnviadas) return;
    _anunciado = true;
    unawaited(vibrar());
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        anuncio(ahora, registro),
        TextDirection.ltr,
      ),
    );
  }

  /// Sale a [ruta] y deja el examen listo para empezar de cero.
  void salirA(String ruta) {
    final examen = ref.read(examenProvider.notifier);
    context.go(ruta);
    examen.reiniciar();
  }

  void volverAlMapa() => salirA(Rutas.mapaSprintsDe(moduloId));

  /// Marco común: atrás va al mapa; contenido desplazable y botones fijos.
  /// En tablet horizontal (con [ilustracionTablet]) usa la composición de
  /// resultado: la ilustración a la izquierda y [contenidoTablet] con los
  /// botones en la columna de 470 (T29 y T30, T-12d).
  Widget marco({
    required Widget contenido,
    required List<Widget> botones,
    Widget? ilustracionTablet,
    List<Widget>? contenidoTablet,
    Widget? fondoTablet,
  }) {
    final tablet = ilustracionTablet != null && context.clasePantalla.esAncho;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (hecho, _) {
        if (!hecho) volverAlMapa();
      },
      child: Scaffold(
        body: tablet
            ? DisposicionResultadoTablet(
                key: const ValueKey('resultado-tablet'),
                ilustracion: ilustracionTablet,
                fondo: fondoTablet,
                contenido: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...?contenidoTablet,
                    const SizedBox(height: 16),
                    Column(
                      key: const ValueKey('botones-resultado'),
                      mainAxisSize: MainAxisSize.min,
                      children: botones,
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        key: const ValueKey('resultado-desplazable'),
                        padding: const EdgeInsets.only(bottom: 16),
                        child: contenido,
                      ),
                    ),
                    Padding(
                      key: const ValueKey('botones-resultado'),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Column(mainAxisSize: MainAxisSize.min, children: botones),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Título de 29 y 30: encabezado con el foco al abrir.
class _TituloResultado extends StatelessWidget {
  const _TituloResultado(this.texto, {required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => BloqueLectura(
    key: const ValueKey('titulo-resultado'),
    encabezado: true,
    autofocus: true,
    radio: 8,
    child: Text(
      texto,
      textAlign: TextAlign.center,
      style: context.estilos.h1.copyWith(color: color),
    ),
  );
}

/// Bloque de error con "Reintentar" (dentro del contenido desplazable).
class _ErrorResultado extends StatelessWidget {
  const _ErrorResultado({required this.texto, required this.alReintentar});

  final String texto;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('error-resultado'),
    children: [
      Semantics(
        liveRegion: true,
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: context.estilos.cuerpoGrande.copyWith(color: context.tokens.textoPrimario),
        ),
      ),
      const SizedBox(height: 12),
      BotonApp(
        key: const ValueKey('boton-reintentar-resultado'),
        texto: Textos.reintentar,
        tipo: TipoBoton.secundario,
        expandido: false,
        alPresionar: alReintentar,
      ),
    ],
  );
}

Widget _bloque(BuildContext context, double alto, {double? ancho}) => Container(
  width: ancho,
  height: alto,
  decoration: BoxDecoration(
    color: context.tokens.fondoSuperficieAlt,
    borderRadius: BorderRadius.circular(8),
  ),
);

// =========================================================================
// 29 · Auditoría superada
// =========================================================================

/// Pantalla 29 · Auditoría superada (Figma 18:2916): confeti, trofeo, Sarko
/// alegre, título, el módulo desbloqueado, la tarjeta del certificado (con su
/// folio) y "Ir al Módulo N" / "Compartir certificado".
class PantallaAuditoriaSuperada extends ConsumerStatefulWidget {
  const PantallaAuditoriaSuperada({required this.moduloId, super.key});

  final String moduloId;

  @override
  ConsumerState<PantallaAuditoriaSuperada> createState() => _AuditoriaSuperadaState();
}

class _AuditoriaSuperadaState extends _EstadoResultado<PantallaAuditoriaSuperada> {
  @override
  String get moduloId => widget.moduloId;

  @override
  String anuncio(EstadoExamenJefe examen, ResultadoRegistrado registro) =>
      Textos.anuncioAprobado(registro.siguienteModulo?.numero);

  @override
  Future<void> vibrar() => ref.read(servicioHapticoProvider).acierto();

  Future<void> _compartir(Certificado c) async {
    final mensajero = ScaffoldMessenger.of(context);
    final vista = View.of(context);
    await Clipboard.setData(ClipboardData(text: LogicaResultado.textoCompartir(c)));
    mostrarAvisoEn(
      mensajero,
      Textos.certificadoCopiado,
      clave: const ValueKey('aviso-certificado-copiado'),
    );
    unawaited(
      SemanticsService.sendAnnouncement(vista, Textos.certificadoCopiado, TextDirection.ltr),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoExamenJefe?>(examenProvider, _alCambiar);
    final examen = ref.watch(examenProvider);
    final tokens = context.tokens;
    final estilos = context.estilos;
    final registro = examen?.apelacionesEnviadas ?? false ? examen?.registro : null;
    final certificado = registro?.certificado;
    final error = examen?.errorRegistro != null && registro == null;
    final siguiente = registro?.siguienteModulo;

    final encabezado = SizedBox(
      height: 282,
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final centro = restricciones.maxWidth / 2;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: ConfetiSprint(
                  key: ValueKey('confeti-auditoria'),
                  piezas: ConfetiSprint.piezasAuditoria,
                ),
              ),
              Positioned(left: centro - 135, top: 62, child: const TrofeoCertificado()),
              // Sarko de Figma: caja 176×220 en (170, 90) menos la barra de estado.
              Positioned(
                left: centro - 25,
                top: 42,
                child: const SarkoImagen(pose: PoseSarko.alegre, ancho: 176, decorativa: true),
              ),
            ],
          );
        },
      ),
    );

    final Widget cuerpo;
    if (error) {
      cuerpo = _ErrorResultado(
        texto: Textos.errorGuardarResultado,
        alReintentar: () => ref.read(examenProvider.notifier).registrarResultado(),
      );
    } else if (certificado == null) {
      cuerpo = Column(
        children: [
          _bloque(context, 40, ancho: 300),
          const SizedBox(height: 24),
          const EsqueletoCertificado(),
        ],
      );
    } else {
      cuerpo = Column(
        children: [
          Text(
            LogicaResultado.textoAprobado(siguiente),
            key: const ValueKey('texto-aprobado'),
            textAlign: TextAlign.center,
            style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
          const SizedBox(height: 24),
          TarjetaCertificado(
            modulo: certificado.nombreModulo,
            detalle: LogicaResultado.detalleCertificado(certificado),
            folio: certificado.folio,
            etiquetaSemantica: LogicaResultado.semanticaCertificado(certificado),
          ),
        ],
      );
    }

    final contenido = Column(
      children: [
        encabezado,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _TituloResultado(Textos.auditoriaSuperada, color: tokens.textoPrimario),
              const SizedBox(height: 4),
              cuerpo,
            ],
          ),
        ),
      ],
    );

    final List<Widget> botones;
    if (error) {
      botones = [
        BotonApp(
          key: const ValueKey('boton-volver-mapa'),
          texto: Textos.volverAlMapa,
          alPresionar: volverAlMapa,
        ),
      ];
    } else {
      botones = [
        BotonApp(
          key: const ValueKey('boton-ir-modulo'),
          texto: siguiente == null ? Textos.volverAlMapa : Textos.irAlModulo(siguiente.numero),
          iconoFin: siguiente == null ? null : IconosApp.chevron,
          alPresionar: certificado == null
              ? null
              : siguiente == null
              ? volverAlMapa
              : () => salirA(Rutas.mapaSprintsDe(siguiente.id)),
        ),
        const SizedBox(height: 8),
        BotonApp(
          key: const ValueKey('boton-compartir'),
          texto: Textos.compartirCertificadoBoton,
          tipo: TipoBoton.fantasma,
          altoMinimo: 48,
          alPresionar: certificado == null ? null : () => _compartir(certificado),
        ),
      ];
    }
    return marco(
      contenido: contenido,
      botones: botones,
      // T29 (Figma 101:5592): trofeo y Sarko × 1.6 a la izquierda y el
      // confeti sobre el panel.
      fondoTablet: const ConfetiSprint(
        key: ValueKey('confeti-auditoria'),
        piezas: ConfetiSprint.piezasAuditoriaTablet,
        anchoLienzo: DisposicionResultadoTablet.anchoPanel,
        proporcional: true,
      ),
      ilustracionTablet: const IlustracionAmpliada(
        anchoBase: 296,
        escala: 1.6,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrofeoCertificado(),
            SizedBox(width: 14),
            SarkoImagen(pose: PoseSarko.alegre, ancho: 176, decorativa: true),
          ],
        ),
      ),
      contenidoTablet: [
        _TituloResultado(Textos.auditoriaSuperada, color: tokens.textoPrimario),
        const SizedBox(height: 16),
        cuerpo,
      ],
    );
  }
}

// =========================================================================
// 30 · La Inspectora ganó
// =========================================================================

/// Pantalla 30 · La Inspectora ganó (Figma 18:3036): Sarko triste, título,
/// el motivo, el resumen del intento, la próxima vida (o las que quedan) y
/// "Repasar en el Buzón" / "Volver al mapa".
class PantallaInspectoraGano extends ConsumerStatefulWidget {
  const PantallaInspectoraGano({required this.moduloId, super.key});

  final String moduloId;

  @override
  ConsumerState<PantallaInspectoraGano> createState() => _InspectoraGanoState();
}

class _InspectoraGanoState extends _EstadoResultado<PantallaInspectoraGano> {
  @override
  String get moduloId => widget.moduloId;

  @override
  String anuncio(EstadoExamenJefe examen, ResultadoRegistrado registro) =>
      Textos.anuncioReprobado(LogicaResultado.apelaciones(examen.falladas, examen.moduloId).length);

  @override
  Future<void> vibrar() => ref.read(servicioHapticoProvider).error();

  @override
  Widget build(BuildContext context) {
    ref.listen<EstadoExamenJefe?>(examenProvider, _alCambiar);
    final examen = ref.watch(examenProvider);
    if (examen == null) return const Scaffold(body: SizedBox.shrink());
    final tokens = context.tokens;
    final estilos = context.estilos;
    final crear = ref.watch(crearCronometroJefeProvider);
    final registro = examen.apelacionesEnviadas ? examen.registro : null;
    final error = examen.errorRegistro != null && registro == null;
    final resumen = examen.resumen;
    final sinVidas = LogicaResultado.sinVidas(examen.vidas);
    final hayApelaciones = examen.falladas.isNotEmpty;

    final Widget proximaVida;
    if (!sinVidas) {
      proximaVida = _TarjetaVida(texto: Textos.vidasRestantesExamen(examen.vidas));
    } else if (registro == null) {
      proximaVida = error ? const SizedBox.shrink() : _bloque(context, 44);
    } else if (registro.faltaParaProximaVida == null) {
      proximaVida = const SizedBox.shrink();
    } else {
      proximaVida = RelojCrisis(
        key: const ValueKey('reloj-proxima-vida'),
        limite: registro.faltaParaProximaVida!,
        ronda: 'vida',
        crearCronometro: crear,
        constructor: (context, restante) => _TarjetaVida(
          reloj: true,
          texto: Textos.proximaVidaExamen(CuentaRegresivaVida.formato(restante)),
        ),
      );
    }

    final ilustracion = IlustracionSarko(
      pose: PoseSarko.triste,
      diametro: 230,
      anchoSarko: 184,
      colorFondo: tokens.fondoSuperficieAlt,
    );
    final titulo = _TituloResultado(Textos.inspectoraGano, color: tokens.estadoIlegal);
    final texto = Text(
      sinVidas ? Textos.reprobadoSinVidas : Textos.reprobadoSinDecisiones,
      key: const ValueKey('texto-reprobado'),
      textAlign: TextAlign.center,
      style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
    );
    final filaResumen = FilaResumenExamen(
      jugadas: resumen.decisionesJugadas,
      total: examen.total,
      aciertos: resumen.aciertos,
      porTiempo: resumen.porTiempo,
    );
    final contenido = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 42),
          ilustracion,
          const SizedBox(height: 16),
          titulo,
          const SizedBox(height: 4),
          texto,
          const SizedBox(height: 24),
          filaResumen,
          const SizedBox(height: 20),
          proximaVida,
        ],
      ),
    );

    final botones = <Widget>[
      if (error) ...[
        Row(
          key: const ValueKey('aviso-error-apelaciones'),
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  Textos.errorGuardarApelaciones,
                  style: estilos.leyenda.copyWith(color: tokens.textoPrimario),
                ),
              ),
            ),
            TextButton(
              key: const ValueKey('boton-reintentar-resultado'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => ref.read(examenProvider.notifier).registrarResultado(),
              child: Text(
                Textos.reintentar,
                style: estilos.cuerpoEnfasis.copyWith(color: tokens.textoAcento),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
      if (hayApelaciones) ...[
        BotonApp(
          key: const ValueKey('boton-repasar-buzon'),
          texto: Textos.repasarEnBuzon,
          alPresionar: () => salirA(Rutas.buzon),
        ),
        const SizedBox(height: 8),
      ],
      BotonApp(
        key: const ValueKey('boton-volver-mapa'),
        texto: Textos.volverAlMapa,
        tipo: hayApelaciones ? TipoBoton.fantasma : TipoBoton.primario,
        altoMinimo: hayApelaciones ? 48 : BotonApp.alto,
        alPresionar: volverAlMapa,
      ),
    ];
    return marco(
      contenido: contenido,
      botones: botones,
      // T30 (Figma 101:5666): Sarko triste × 1.7 a la izquierda; separación 16.
      ilustracionTablet: IlustracionAmpliada(anchoBase: 230, escala: 1.7, child: ilustracion),
      contenidoTablet: [
        titulo,
        const SizedBox(height: 16),
        texto,
        const SizedBox(height: 16),
        filaResumen,
        const SizedBox(height: 16),
        proximaVida,
      ],
    );
  }
}

/// "Próxima vida en …" (con reloj) o "Aún tienes N vidas…" (Figma 18:3110):
/// fondo/destacado, radio 16, relleno 14×12, separación 10, `clock` de 20 y
/// Leyenda texto/primario.
class _TarjetaVida extends StatelessWidget {
  const _TarjetaVida({required this.texto, this.reloj = false});

  final String texto;
  final bool reloj;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: ValueKey(reloj ? 'proxima-vida' : 'vidas-restantes'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tokens.fondoDestacado,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (reloj) ...[
            IconoApp(IconosApp.clock, tamano: 20, color: tokens.textoAcento),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              texto,
              style: context.estilos.leyenda.copyWith(color: tokens.textoPrimario),
            ),
          ),
        ],
      ),
    );
  }
}
