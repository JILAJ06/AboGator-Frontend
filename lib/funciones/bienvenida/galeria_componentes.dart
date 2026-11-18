import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../componentes/anillo_foco.dart';
import '../../componentes/barra_progreso.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_veredicto.dart';
import '../../componentes/campo_texto_app.dart';
import '../../componentes/chip_hud.dart';
import '../../componentes/corazon_vida.dart';
import '../../componentes/icono_app.dart';
import '../../componentes/impacto_startup.dart';
import '../../componentes/indicadores_startup.dart';
import '../../componentes/logo_app.dart';
import '../../componentes/navegacion_inferior_app.dart';
import '../../componentes/paginador_puntos.dart';
import '../../componentes/sarko_imagen.dart';
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
            const _Seccion(
              titulo: Textos.galeriaLogos,
              hijos: [
                LogoApp(),
                LogoApp(variante: VarianteLogo.horizontal, alto: 56),
                LogoApp(variante: VarianteLogo.isotipo, alto: 64),
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
