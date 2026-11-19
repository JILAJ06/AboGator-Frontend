import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/acciones_veredicto.dart';
import '../../componentes/anillo_foco.dart';
import '../../componentes/avatar_app.dart';
import '../../componentes/aviso_informativo.dart';
import '../../componentes/barra_comodines.dart';
import '../../componentes/barra_juego.dart';
import '../../componentes/barra_progreso.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_atras.dart';
import '../../componentes/boton_buzon.dart';
import '../../componentes/boton_veredicto.dart';
import '../../componentes/campo_texto_app.dart';
import '../../componentes/casilla_app.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/chip_seleccion.dart';
import '../../componentes/confeti_sprint.dart';
import '../../componentes/corazon_vida.dart';
import '../../componentes/encabezado_modulo.dart';
import '../../componentes/enlace_texto.dart';
import '../../componentes/estadisticas_sprint.dart';
import '../../componentes/estrellas_sprint.dart';
import '../../componentes/etiqueta_quiebra.dart';
import '../../componentes/fila_detalle_sprint.dart';
import '../../componentes/globo_sprint_actual.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/impacto_startup.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/logo_app.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/nodo_sprint.dart';
import '../../componentes/paginador_puntos.dart';
import '../../componentes/panel_veredicto.dart';
import '../../componentes/pila_tarjetas.dart';
import '../../componentes/sarko_imagen.dart';
import '../../componentes/sello_veredicto.dart';
import '../../componentes/tarjeta_caso.dart';
import '../../componentes/tarjeta_heroe_startup.dart';
import '../../componentes/tarjeta_modulo.dart';
import '../../componentes/tarjeta_reto_diario.dart';
import '../../core/recursos/imagenes_app.dart';
import '../../core/tema/colores_marca.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/tema/modo_tema.dart';
import '../../core/tema/tipografia.dart';
import '../../core/tema/tokens_color.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/estado_startup.dart';
import '../../datos/modelos/tarjeta.dart';

/// Galería temporal de componentes: todos los tipos y estados, con
/// interruptor claro/oscuro. Se elimina cuando existan las pantallas reales.
class GaleriaComponentes extends ConsumerStatefulWidget {
  const GaleriaComponentes({super.key});

  @override
  ConsumerState<GaleriaComponentes> createState() => _GaleriaComponentesState();
}

class _GaleriaComponentesState extends ConsumerState<GaleriaComponentes> {
  PestanaApp _pestana = PestanaApp.mapa;
  int _pagina = 1;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;

    return Scaffold(
      appBar: AppBar(
        title: Text(Textos.galeriaTitulo, style: estilos.h2),
        backgroundColor: tokens.fondoSuperficie,
      ),
      bottomNavigationBar: NavegacionInferiorApp(
        actual: _pestana,
        alSeleccionar: (p) => setState(() => _pestana = p),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            SwitchListTile(
              title: Text(Textos.galeriaModoOscuro, style: estilos.cuerpoEnfasis),
              value: context.esModoOscuro,
              onChanged: (activo) => ref
                  .read(modoTemaProvider.notifier)
                  .establecer(activo ? ThemeMode.dark : ThemeMode.light),
            ),
            _Seccion(
              titulo: Textos.galeriaBotones,
              hijos: [
                BotonApp(texto: Textos.botonPrimario, alPresionar: () {}),
                BotonApp(
                  texto: Textos.botonSecundario,
                  tipo: TipoBoton.secundario,
                  iconoInicio: IconosApp.back,
                  alPresionar: () {},
                ),
                BotonApp(
                  texto: Textos.botonAcento,
                  tipo: TipoBoton.acento,
                  iconoFin: IconosApp.coin,
                  alPresionar: () {},
                ),
                BotonApp(texto: Textos.botonPeligro, tipo: TipoBoton.peligro, alPresionar: () {}),
                BotonApp(texto: Textos.botonFantasma, tipo: TipoBoton.fantasma, alPresionar: () {}),
                const BotonApp(texto: Textos.botonDeshabilitado, alPresionar: null),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaVeredictos,
              hijos: [
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: [for (final v in Veredicto.values) BotonVeredicto(veredicto: v)],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    for (final v in Veredicto.values)
                      BotonVeredicto(veredicto: v, alPresionar: () {}),
                  ],
                ),
              ],
            ),
            const _Seccion(
              titulo: Textos.galeriaCampos,
              hijos: [
                CampoTextoApp(
                  etiqueta: Textos.campoCorreo,
                  textoAyuda: Textos.campoCorreoAyuda,
                  tipo: TipoCampo.correo,
                  iconoInicio: IconosApp.mail,
                ),
                CampoTextoApp(
                  etiqueta: Textos.campoCorreo,
                  textoAyuda: Textos.campoCorreoAyuda,
                  tipo: TipoCampo.correo,
                  iconoInicio: IconosApp.mail,
                  error: Textos.campoCorreoError,
                ),
                CampoTextoApp(
                  etiqueta: Textos.campoContrasena,
                  textoAyuda: Textos.campoContrasenaAyuda,
                  tipo: TipoCampo.contrasena,
                  iconoInicio: IconosApp.lock,
                ),
                _CampoConValor(),
              ],
            ),
            const _Seccion(titulo: Textos.galeriaAcceso, hijos: [_DemoAcceso()]),
            _Seccion(
              titulo: Textos.galeriaInicio,
              hijos: [
                const AvatarApp(iniciales: 'AL'),
                TarjetaHeroeStartup(
                  titulo: Textos.tramosStartup[0],
                  subtitulo: Textos.heroeSubtitulo(3, 5, Textos.modulosCortos[0]),
                  alContinuar: () {},
                ),
                TarjetaRetoDiario(
                  titulo: Textos.retoTitulo,
                  subtitulo: Textos.retoSubtitulo(7, 15),
                  actual: 1,
                  total: 3,
                ),
                for (final (i, estado) in EstadoModulo.values.indexed)
                  TarjetaModulo(
                    numero: i + 1,
                    nombreCorto: Textos.modulosCortos[i],
                    titulo: Textos.tramosStartup[i],
                    estado: estado,
                    completados: switch (estado) {
                      EstadoModulo.completado => 5,
                      EstadoModulo.enCurso => 2,
                      _ => 0,
                    },
                    total: 5,
                    color: ColoresModulo.enOrden[i],
                    icono: IconosApp.shield,
                    alPresionar: () {},
                  ),
                Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    BotonBuzon(pendientes: 6, alPresionar: () {}),
                    BotonBuzon(pendientes: 0, alPresionar: () {}),
                  ],
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaMapa,
              hijos: [
                // Módulo 1 (color tal cual) y módulo 2 (fondo oscurecido por contraste).
                for (final i in [0, 1])
                  EncabezadoModulo(
                    numero: i + 1,
                    nombreCorto: Textos.modulosCortos[i],
                    titulo: Textos.tramosStartup[i],
                    color: ColoresModulo.enOrden[i],
                    vidas: 4,
                    completados: 2 - i * 2,
                    total: 5,
                    alAtras: () {},
                  ),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    for (final tipo in TipoNodoSprint.values)
                      NodoSprint(
                        tipo: tipo,
                        estrellas: 3,
                        etiquetaSemantica: tipo.name,
                        alPresionar: tipo == TipoNodoSprint.bloqueado ? null : () {},
                      ),
                    NodoSprint(
                      tipo: TipoNodoSprint.completado,
                      estrellas: 1,
                      etiquetaSemantica: Textos.estrellasSemantica(1, 3),
                      alPresionar: () {},
                    ),
                  ],
                ),
                GloboSprintActual(
                  titulo: Textos.globoTitulo(3, 'Aviso de privacidad'),
                  detalle: Textos.globoDetalle(10, 4),
                  alComenzar: () {},
                ),
                TarjetaDetallesSprint(
                  filas: [
                    FilaDetalleSprint(
                      icono: IconosApp.doc,
                      titulo: Textos.tarjetasCantidad(10),
                      texto: Textos.tarjetasDesglose(6, 3, 1),
                    ),
                    FilaDetalleSprint(
                      icono: IconosApp.coin,
                      titulo: Textos.monedasHasta(60),
                      texto: Textos.monedasDilema,
                    ),
                    const FilaDetalleSprint(
                      icono: IconosApp.zap,
                      titulo: Textos.indicadoresTitulo,
                      texto: Textos.indicadoresLista,
                    ),
                  ],
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaJuego,
              hijos: [
                BarraJuego(numeroSprint: 3, actual: 5, total: 10, vidas: 4, alSalir: () {}),
                SizedBox(
                  height: TarjetaCaso.alto + 20,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: PilaTarjetas(restantes: 2)),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: TarjetaCaso.alto,
                        child: TarjetaCaso(
                          etiquetaCaso: Textos.casoEtiqueta,
                          colorModulo: ColoresModulo.enOrden[1],
                          iniciales: Textos.casoIniciales,
                          personaje: Textos.casoPersona,
                          rol: Textos.casoEquipo,
                          texto: Textos.casoPregunta,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: [for (final v in Veredicto.values) SelloVeredicto(veredicto: v)],
                ),
                AccionesVeredicto(alElegir: (_) {}),
                const BarraComodines(lupa: 2, abogado: 1, amparo: 1),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaVeredicto,
              hijos: [
                for (final (tipo, subtitulo, cambios, explicacion) in [
                  (
                    TipoPanelVeredicto.correcto,
                    Textos.correctoSubtitulo(10, 5),
                    {IndicadorStartup.reputacion: 5, IndicadorStartup.riesgoLegal: -10},
                    null,
                  ),
                  (
                    TipoPanelVeredicto.bonus,
                    Textos.bonusSubtitulo(15, 5),
                    {IndicadorStartup.reputacion: 5, IndicadorStartup.riesgoLegal: -10},
                    Textos.galeriaExplicacion,
                  ),
                  (
                    TipoPanelVeredicto.parcial,
                    Textos.parcialSubtitulo(3),
                    {IndicadorStartup.presupuesto: -5, IndicadorStartup.velocidad: -10},
                    Textos.galeriaExplicacion,
                  ),
                  (
                    TipoPanelVeredicto.incorrecto,
                    Textos.incorrectoSubtitulo,
                    {IndicadorStartup.velocidad: 10, IndicadorStartup.riesgoLegal: 25},
                    Textos.galeriaExplicacion,
                  ),
                  (
                    TipoPanelVeredicto.amparo,
                    Textos.amparoSubtitulo,
                    {IndicadorStartup.velocidad: 10, IndicadorStartup.riesgoLegal: 20},
                    Textos.galeriaExplicacion,
                  ),
                ])
                  PanelVeredicto(
                    tipo: tipo,
                    subtitulo: subtitulo,
                    cambios: cambios,
                    explicacion: explicacion,
                    microPregunta: explicacion == null
                        ? const MicroPregunta(
                            enunciado: Textos.galeriaMicroEnunciado,
                            opciones: [Textos.galeriaMicroOpcion1, Textos.galeriaMicroOpcion2],
                            indiceCorrecto: 0,
                          )
                        : null,
                    alElegirOpcion: (_) {},
                    alContinuar: () {},
                  ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaFinSprint,
              hijos: [
                const ConfetiSprint(),
                for (var n = 1; n <= EstrellasSprint.total; n++) EstrellasSprint(ganadas: n),
                const EstadisticasSprint(aciertos: 8, total: 10, xp: 95, monedas: 45),
                AvisoInformativo(icono: IconosApp.inbox, texto: Textos.avisoBuzon(2)),
                AvisoInformativo(
                  icono: IconosApp.info,
                  colorIcono: context.tokens.textoAcento,
                  rellenoVertical: 12,
                  texto: Textos.avisoReinicio,
                ),
                const EtiquetaQuiebra(causa: CausaQuiebra.riesgoLegal),
                const EtiquetaQuiebra(causa: CausaQuiebra.presupuesto),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaChips,
              hijos: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChipHud.vidas(4),
                    ChipHud.monedas(240),
                    ChipHud.racha(7),
                    ChipHud.comodines(3),
                    ChipHud.amparo(1),
                  ],
                ),
              ],
            ),
            const _Seccion(
              titulo: Textos.galeriaVidas,
              hijos: [
                FilaVidas(cantidad: 3),
                FilaVidas(cantidad: 5, tamano: 33.6, hueco: 11.2),
                FilaVidas(cantidad: 0, tamano: 33.6, hueco: 11.2),
              ],
            ),
            const _Seccion(
              titulo: Textos.galeriaIndicadores,
              hijos: [
                IndicadoresStartup(
                  estado: EstadoStartup(
                    presupuesto: 70,
                    reputacion: 60,
                    velocidad: 50,
                    riesgoLegal: 25,
                  ),
                ),
                ImpactoStartup(
                  cambios: {
                    IndicadorStartup.presupuesto: -5,
                    IndicadorStartup.reputacion: 5,
                    IndicadorStartup.riesgoLegal: 10,
                  },
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaProgreso,
              hijos: [
                for (final (actual, total) in [(1, 10), (5, 10), (8, 10), (10, 10)])
                  SizedBox(
                    width: 240,
                    child: BarraProgreso(
                      valor: actual / total,
                      etiquetaSemantica: Textos.progresoTarjeta(actual, total),
                    ),
                  ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaPaginador,
              hijos: [
                GestureDetector(
                  onTap: () => setState(() => _pagina = (_pagina + 1) % 4),
                  child: PaginadorPuntos(total: 4, actual: _pagina),
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaFoco,
              hijos: [
                Padding(
                  padding: const EdgeInsets.all(AnilloFoco.margen),
                  child: AnilloFoco(
                    visible: true,
                    radio: BotonApp.radio,
                    child: BotonApp(texto: Textos.botonPrimario, alPresionar: () {}),
                  ),
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaSarko,
              hijos: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final pose in PoseSarko.values) SarkoImagen(pose: pose, ancho: 120),
                  ],
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaLogos,
              hijos: [
                for (final tono in TonoLogo.values)
                  for (final forma in FormaLogo.values) _MuestraLogo(forma: forma, tono: tono),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaIconos,
              hijos: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final MapEntry(key: nombre, value: icono) in IconosApp.porNombre.entries)
                      SizedBox(
                        width: 64,
                        child: Column(
                          children: [
                            IconoApp(icono, color: tokens.textoPrimario),
                            const SizedBox(height: 4),
                            Text(
                              nombre,
                              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaTokens,
              hijos: [
                for (final MapEntry(key: nombre, value: color) in tokens.porNombre.entries)
                  _MuestraColor(nombre: nombre, color: color),
              ],
            ),
            _Seccion(
              titulo: Textos.galeriaTipografia,
              hijos: [
                for (final (nombre, estilo) in _estilosConNombre(estilos))
                  Text(
                    '$nombre · ${identical(estilo, estilos.codigo) ? Textos.galeriaCodigoEjemplo : Textos.galeriaTextoEjemplo}',
                    style: estilo,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                Textos.galeriaNavegacion,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<(String, TextStyle)> _estilosConNombre(EstilosTexto e) => [
    (Textos.estiloDisplay, e.display),
    (Textos.estiloH1, e.h1),
    (Textos.estiloH2, e.h2),
    (Textos.estiloH3, e.h3),
    (Textos.estiloCuerpoGrande, e.cuerpoGrande),
    (Textos.estiloCuerpoBase, e.cuerpoBase),
    (Textos.estiloCuerpoEnfasis, e.cuerpoEnfasis),
    (Textos.estiloEtiqueta, e.etiqueta),
    (Textos.estiloLeyenda, e.leyenda),
    (Textos.estiloBoton, e.boton),
    (Textos.estiloCodigo, e.codigo),
  ];
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(titulo, style: context.estilos.h3)),
          for (final hijo in hijos) ...[const SizedBox(height: 12), hijo],
        ],
      ),
    );
  }
}

class _CampoConValor extends StatefulWidget {
  const _CampoConValor();

  @override
  State<_CampoConValor> createState() => _CampoConValorState();
}

class _CampoConValorState extends State<_CampoConValor> {
  final _controlador = TextEditingController(text: Textos.campoNombreValor);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CampoTextoApp(
      etiqueta: Textos.campoNombre,
      textoAyuda: Textos.campoNombreAyuda,
      tipo: TipoCampo.nombre,
      iconoInicio: IconosApp.user,
      controlador: _controlador,
    );
  }
}

class _MuestraColor extends StatelessWidget {
  const _MuestraColor({required this.nombre, required this.color});

  final String nombre;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tokens.bordeDefault),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(nombre, style: estilos.cuerpoEnfasis)),
        Text(color.comoHex, style: estilos.codigo.copyWith(color: tokens.textoSecundario)),
      ],
    );
  }
}

/// Un logo sobre el fondo para el que está pensado su tono. Los fondos de
/// marca (azul, verde y superficie oscura) son fijos en ambos modos.
class _MuestraLogo extends StatelessWidget {
  const _MuestraLogo({required this.forma, required this.tono});

  final FormaLogo forma;
  final TonoLogo tono;

  static Color fondo(TonoLogo tono, TokensColor actual) => switch (tono) {
    TonoLogo.color || TonoLogo.negro => actual.fondoApp,
    TonoLogo.negativo => TokensColor.oscuro.fondoSuperficie,
    TonoLogo.sobreAzul => TokensColor.claro.accionSecundaria,
    TonoLogo.sobreVerde => TokensColor.claro.accionPrimaria,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final ancho = forma == FormaLogo.isotipo ? 96.0 : 240.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo(tono, tokens),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LogoApp(forma: forma, tono: tono, ancho: ancho, decorativo: true),
          const SizedBox(height: 8),
          Text(
            Textos.galeriaLogo(forma.name, tono.name),
            style: context.estilos.leyenda.copyWith(
              color: tono == TonoLogo.color || tono == TonoLogo.negro
                  ? tokens.textoSecundario
                  : TokensColor.claro.textoEnPrimario,
            ),
          ),
        ],
      ),
    );
  }
}

/// Casillas, chips de perfil, enlace y botón de regreso, con estado local.
class _DemoAcceso extends StatefulWidget {
  const _DemoAcceso();

  @override
  State<_DemoAcceso> createState() => _DemoAccesoState();
}

class _DemoAccesoState extends State<_DemoAcceso> {
  bool _aviso = false;
  bool _terminos = true;
  int? _perfil = 1;
  bool _cargando = false;

  static const _perfiles = [
    (Textos.perfilEstudianteVisible, Textos.perfilEstudiante),
    (Textos.perfilDesarrolladorVisible, Textos.perfilDesarrollador),
    (Textos.perfilLegalVisible, Textos.perfilLegal),
  ];

  Future<void> _simularCarga() async {
    setState(() => _cargando = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final (i, (visible, nombre)) in _perfiles.indexed)
              ChipSeleccion(
                texto: visible,
                etiquetaSemantica: Textos.perfilSemantica(nombre, i + 1, _perfiles.length),
                seleccionado: _perfil == i,
                alPresionar: () => setState(() => _perfil = i),
              ),
          ],
        ),
        CasillaApp(
          texto: Textos.aceptoAvisoPrivacidad,
          marcada: _aviso,
          error: _aviso ? null : Textos.errorAvisoPrivacidad,
          alCambiar: (v) => setState(() => _aviso = v),
        ),
        CasillaApp(
          texto: Textos.aceptoTerminos,
          marcada: _terminos,
          alCambiar: (v) => setState(() => _terminos = v),
        ),
        Row(
          children: [
            BotonAtras(alPresionar: () {}),
            const SizedBox(width: 16),
            Flexible(
              child: EnlaceTexto(texto: Textos.olvidasteContrasena, alPresionar: () {}),
            ),
          ],
        ),
        // Tócalo para ver el estado de carga durante 2 s.
        BotonApp(
          texto: Textos.botonIniciarSesion,
          alPresionar: _simularCarga,
          cargando: _cargando,
          textoCargando: Textos.iniciandoSesion,
        ),
      ],
    );
  }
}
