import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/campo_texto_app.dart';
import '../../componentes/enlace_texto.dart';
import '../../componentes/logo_app.dart';
import '../../componentes/sarko_imagen.dart';
import '../../core/adaptativo/clase_pantalla.dart';
import '../../core/recursos/imagenes_app.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import 'aviso_error.dart';
import 'estado_inicio_sesion.dart';
import 'panel_marca.dart';

/// Pantalla 05 · Inicio de sesión.
class PantallaInicioSesion extends ConsumerStatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  ConsumerState<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends ConsumerState<PantallaInicioSesion> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _focoCorreo = FocusNode();
  final _focoContrasena = FocusNode();

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    _focoCorreo.dispose();
    _focoContrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final resultado = await ref
        .read(inicioSesionProvider.notifier)
        .enviar(correo: _correo.text, contrasena: _contrasena.text);
    if (!mounted) return;
    if (resultado.exitoso) {
      context.go(Rutas.inicio);
      return;
    }
    switch (resultado.campoConError) {
      case CampoInicioSesion.correo:
        _focoCorreo.requestFocus();
      case CampoInicioSesion.contrasena:
        _focoContrasena.requestFocus();
      case null:
        break;
    }
  }

  /// Campos de correo y contraseña (los mismos en móvil y en tablet).
  Widget _campos(EstadoInicioSesion estado, InicioSesionNotifier notifier) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampoTextoApp(
            etiqueta: Textos.campoCorreoInicio,
            textoAyuda: Textos.campoCorreoAyuda,
            tipo: TipoCampo.correo,
            iconoInicio: IconosApp.mail,
            controlador: _correo,
            nodoFoco: _focoCorreo,
            error: estado.errorCorreo,
            accionTeclado: TextInputAction.next,
            alCambiar: (_) {
              if (estado.errorCorreo != null || estado.errorGeneral != null) {
                notifier.limpiarErrorCorreo();
              }
            },
          ),
          const SizedBox(height: 16),
          CampoTextoApp(
            etiqueta: Textos.campoContrasenaInicio,
            tipo: TipoCampo.contrasena,
            iconoInicio: IconosApp.lock,
            controlador: _contrasena,
            nodoFoco: _focoContrasena,
            error: estado.errorContrasena,
            accionTeclado: TextInputAction.done,
            alEnviar: (_) => _enviar(),
            alCambiar: (_) {
              if (estado.errorContrasena != null || estado.errorGeneral != null) {
                notifier.limpiarErrorContrasena();
              }
            },
          ),
        ],
      ),
    );
  }

  /// 05 en tablet (Figma T05, 94:456): el panel de marca y el formulario en
  /// una columna de 470 con separación 16 y los controles a todo el ancho.
  Widget _tablet(BuildContext context, EstadoInicioSesion estado, InicioSesionNotifier notifier) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    const hueco = SizedBox(height: 16);
    return Scaffold(
      body: DisposicionAccesoTablet(
        variante: VariantePanelMarca.inicioSesion,
        formulario: Column(
          key: const ValueKey('formulario-tablet'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    Textos.inicioSesionTitulo,
                    style: estilos.h1.copyWith(color: tokens.textoPrimario),
                  ),
                ),
              ),
            ),
            hueco,
            Text(
              Textos.inicioSesionSubtitulo,
              style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
            ),
            hueco,
            _campos(estado, notifier),
            Align(
              alignment: Alignment.centerLeft,
              child: EnlaceTexto(
                texto: Textos.olvidasteContrasena,
                alPresionar: () => mostrarAvisoBreve(context, Textos.recuperacionPronto),
              ),
            ),
            if (estado.errorGeneral != null) ...[
              const SizedBox(height: 8),
              AvisoError(mensaje: estado.errorGeneral!),
            ],
            hueco,
            BotonApp(
              texto: Textos.botonIniciarSesion,
              alPresionar: _enviar,
              cargando: estado.enviando,
              textoCargando: Textos.iniciandoSesion,
            ),
            hueco,
            const _Separador(anchoLinea: double.infinity),
            hueco,
            BotonApp(
              texto: Textos.botonCrearUnaCuenta,
              tipo: TipoBoton.secundario,
              alPresionar: estado.enviando ? null : () => context.go(Rutas.registro),
            ),
            hueco,
            Text(
              Textos.notaSeguridad,
              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(inicioSesionProvider);
    final notifier = ref.read(inicioSesionProvider.notifier);
    final tokens = context.tokens;
    final estilos = context.estilos;

    if (context.clasePantalla.esTablet) return _tablet(context, estado, notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo horizontal a color, ≈ 306.9×74.4, parte superior en y=96.
              const Center(child: LogoApp(forma: FormaLogo.horizontal, ancho: 306.9)),
              const SizedBox(height: 19.6),
              // Título y subtítulo a la izquierda (ancho 220); Sarko a la derecha.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                Textos.inicioSesionTitulo,
                                style: estilos.h1.copyWith(color: tokens.textoPrimario),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Textos.inicioSesionSubtitulo,
                              style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SarkoImagen(pose: PoseSarko.alegre, ancho: 96, decorativa: true),
                ],
              ),
              const SizedBox(height: 30),
              _campos(estado, notifier),
              Align(
                alignment: Alignment.centerLeft,
                child: EnlaceTexto(
                  texto: Textos.olvidasteContrasena,
                  alPresionar: () => mostrarAvisoBreve(context, Textos.recuperacionPronto),
                ),
              ),
              if (estado.errorGeneral != null) ...[
                const SizedBox(height: 8),
                AvisoError(mensaje: estado.errorGeneral!),
              ],
              const SizedBox(height: 8),
              BotonApp(
                texto: Textos.botonIniciarSesion,
                alPresionar: _enviar,
                cargando: estado.enviando,
                textoCargando: Textos.iniciandoSesion,
              ),
              const SizedBox(height: 20),
              const _Separador(),
              const SizedBox(height: 16),
              BotonApp(
                texto: Textos.botonCrearUnaCuenta,
                tipo: TipoBoton.secundario,
                alPresionar: estado.enviando ? null : () => context.go(Rutas.registro),
              ),
              const SizedBox(height: 30),
              Text(
                Textos.notaSeguridad,
                style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Línea de 140 – "o" – línea de 140, hueco 12. En tablet las líneas llenan
/// el ancho de la columna ([anchoLinea] infinito).
class _Separador extends StatelessWidget {
  const _Separador({this.anchoLinea = 140});

  final double anchoLinea;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final linea = Flexible(
      fit: anchoLinea.isFinite ? FlexFit.loose : FlexFit.tight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoLinea),
        child: Container(height: 1, color: tokens.bordeDefault),
      ),
    );
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          linea,
          const SizedBox(width: 12),
          Text(
            Textos.separadorO,
            style: context.estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
          ),
          const SizedBox(width: 12),
          linea,
        ],
      ),
    );
  }
}
