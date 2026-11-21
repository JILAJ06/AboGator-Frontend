import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/rutas.dart';
import '../../../componentes/boton_app.dart';
import '../../../componentes/boton_atras.dart';
import '../../../componentes/boton_cerrar.dart';
import '../../../componentes/campo_texto_app.dart';
import '../../../componentes/ilustracion_insignia.dart';
import '../../../componentes/sarko_imagen.dart';
import '../../../core/adaptativo/clase_pantalla.dart';
import '../../../core/tema/iconos_app.dart';
import '../../../core/textos/textos.dart';
import '../../../core/utilidades/extensiones_contexto.dart';
import '../aviso_error.dart';
import 'estado_recuperacion.dart';
import 'marco_recuperacion.dart';

/// Token que abre "Abrir correo" mientras no hay correo real.
// T-14: el enlace profundo del correo trae el token real.
const String tokenDemoRecuperacion = 'demo';

/// 31 · Recuperar contraseña (Figma "7 · Cuenta…", T-13b).
class PantallaRecuperar extends ConsumerStatefulWidget {
  const PantallaRecuperar({super.key});

  @override
  ConsumerState<PantallaRecuperar> createState() => _PantallaRecuperarState();
}

class _PantallaRecuperarState extends ConsumerState<PantallaRecuperar> {
  late final _correo = TextEditingController(text: ref.read(recuperacionProvider).correo);
  final _focoCorreo = FocusNode();

  @override
  void dispose() {
    _correo.dispose();
    _focoCorreo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final r = await ref.read(recuperacionProvider.notifier).enviar(_correo.text);
    if (!mounted) return;
    if (r.exitoso) {
      context.go(Rutas.recuperarEnviado);
    } else if (r.campoConError != null) {
      _focoCorreo.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(recuperacionProvider);
    final tablet = context.clasePantalla.esTablet;
    return MarcoRecuperacion(
      pose: PoseSarko.sorprendido,
      cabecera: BotonAtras(alPresionar: () => context.go(Rutas.inicioSesion)),
      cuerpo: [
        SizedBox(height: tablet ? 8 : 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: TituloRecuperacion(Textos.recuperarTitulo)),
            if (!tablet) ...[
              const SizedBox(width: 12),
              const SarkoImagen(pose: PoseSarko.sorprendido, ancho: 96, decorativa: true),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const TextoRecuperacion(Textos.recuperarDescripcion),
        const SizedBox(height: 20),
        CampoTextoApp(
          key: const ValueKey('campo-correo-recuperacion'),
          etiqueta: Textos.campoCorreoInicio,
          textoAyuda: Textos.campoCorreoAyuda,
          tipo: TipoCampo.correo,
          iconoInicio: IconosApp.mail,
          controlador: _correo,
          nodoFoco: _focoCorreo,
          error: estado.errorCorreo,
          accionTeclado: TextInputAction.send,
          alEnviar: (_) => _enviar(),
          alCambiar: (_) {
            if (estado.errorCorreo != null || estado.errorGeneral != null) {
              ref.read(recuperacionProvider.notifier).limpiarError();
            }
          },
        ),
        const SizedBox(height: 8),
        const NotaRecuperacion(Textos.recuperarNota),
        if (estado.errorGeneral != null) ...[
          const SizedBox(height: 8),
          AvisoError(mensaje: estado.errorGeneral!),
        ],
        const SizedBox(height: 24),
        BotonApp(
          key: const ValueKey('boton-enviar-enlace'),
          texto: Textos.enviarEnlace,
          alPresionar: _enviar,
          cargando: estado.enviando,
          textoCargando: Textos.enviandoEnlace,
        ),
        const SizedBox(height: 8),
        BotonApp(
          key: const ValueKey('boton-volver-inicio-sesion'),
          texto: Textos.volverAIniciarSesion,
          tipo: TipoBoton.fantasma,
          altoMinimo: 48,
          alPresionar: estado.enviando ? null : () => context.go(Rutas.inicioSesion),
        ),
      ],
      pie: const NotaRecuperacion(Textos.enlaceCaducaEn, centrada: true),
    );
  }
}

/// 31b · Revisa tu correo, con la cuenta atrás de 45 s para reenviar.
class PantallaCorreoEnviado extends ConsumerStatefulWidget {
  const PantallaCorreoEnviado({super.key});

  /// Segundos antes de poder reenviar el enlace.
  static const int esperaReenvio = 45;

  @override
  ConsumerState<PantallaCorreoEnviado> createState() => _PantallaCorreoEnviadoState();
}

class _PantallaCorreoEnviadoState extends ConsumerState<PantallaCorreoEnviado> {
  int _restantes = PantallaCorreoEnviado.esperaReenvio;
  Timer? _reloj;

  @override
  void initState() {
    super.initState();
    _iniciarCuenta();
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  void _iniciarCuenta() {
    _reloj?.cancel();
    setState(() => _restantes = PantallaCorreoEnviado.esperaReenvio);
    _reloj = Timer.periodic(const Duration(seconds: 1), (reloj) {
      if (!mounted) return;
      setState(() => _restantes--);
      if (_restantes <= 0) {
        reloj.cancel();
        // Se anuncia una sola vez, al quedar disponible.
        _anunciar(Textos.reenvioDisponible);
      }
    });
  }

  void _anunciar(String texto) {
    unawaited(SemanticsService.sendAnnouncement(View.of(context), texto, TextDirection.ltr));
  }

  Future<void> _reenviar() async {
    final r = await ref.read(recuperacionProvider.notifier).reenviar();
    if (!mounted || !r.exitoso) return;
    _anunciar(Textos.enlaceReenviado);
    _iniciarCuenta();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(recuperacionProvider);
    final tablet = context.clasePantalla.esTablet;
    final insignia = InsigniaCircular(
      icono: IconosApp.mail,
      color: context.tokens.accionPrimaria,
      diametro: tablet ? 96 : 64,
      etiqueta: Textos.insigniaCorreo,
    );
    final disponible = _restantes <= 0;
    return MarcoRecuperacion(
      pose: PoseSarko.alegre,
      cabecera: BotonAtras(alPresionar: () => context.go(Rutas.recuperar)),
      cuerpo: [
        SizedBox(height: tablet ? 8 : 2),
        if (tablet)
          Align(alignment: Alignment.centerLeft, child: insignia)
        else
          Center(
            child: IlustracionInsignia(pose: PoseSarko.alegre, insignia: insignia),
          ),
        const SizedBox(height: 24),
        const TituloRecuperacion(Textos.revisaTuCorreo),
        const SizedBox(height: 12),
        TextoRecuperacion(Textos.enlaceEnviadoA(estado.correo)),
        if (estado.errorGeneral != null) ...[
          const SizedBox(height: 8),
          AvisoError(mensaje: estado.errorGeneral!),
        ],
        const SizedBox(height: 24),
        BotonApp(
          key: const ValueKey('boton-abrir-correo'),
          texto: Textos.abrirCorreo,
          // T-14: abrir la app de correo; el enlace profundo trae el token.
          alPresionar: () => context.go(Rutas.recuperarNuevaCon(tokenDemoRecuperacion)),
        ),
        const SizedBox(height: 8),
        BotonApp(
          key: const ValueKey('boton-reenviar'),
          texto: disponible ? Textos.reenviarEnlace : Textos.reenviarEnlaceEn(_restantes),
          tipo: TipoBoton.fantasma,
          altoMinimo: 48,
          cargando: estado.enviando,
          textoCargando: Textos.enviandoEnlace,
          alPresionar: disponible ? _reenviar : null,
        ),
        const SizedBox(height: 16),
        const NotaRecuperacion(Textos.revisaSpam, centrada: true),
      ],
    );
  }
}

/// 31c · Nueva contraseña, con el [token] del enlace.
class PantallaNuevaContrasena extends ConsumerStatefulWidget {
  const PantallaNuevaContrasena({required this.token, super.key});

  final String token;

  @override
  ConsumerState<PantallaNuevaContrasena> createState() => _PantallaNuevaContrasenaState();
}

class _PantallaNuevaContrasenaState extends ConsumerState<PantallaNuevaContrasena> {
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  final _focoNueva = FocusNode();
  final _focoConfirmar = FocusNode();

  @override
  void dispose() {
    _nueva.dispose();
    _confirmar.dispose();
    _focoNueva.dispose();
    _focoConfirmar.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final notifier = ref.read(nuevaContrasenaProvider.notifier);
    final r = await notifier.guardar(
      token: widget.token,
      nueva: _nueva.text,
      confirmar: _confirmar.text,
    );
    if (!mounted) return;
    switch (r) {
      case ResultadoRestablecer.listo:
        context.go(Rutas.recuperarListo);
      case ResultadoRestablecer.caducado:
        context.go(Rutas.recuperarCaducado);
      case ResultadoRestablecer.conErrores:
        switch (notifier.primerError) {
          case CampoNuevaContrasena.nueva:
            _focoNueva.requestFocus();
          case CampoNuevaContrasena.confirmar:
            _focoConfirmar.requestFocus();
          case null:
            break;
        }
      case ResultadoRestablecer.error || ResultadoRestablecer.ignorado:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(nuevaContrasenaProvider);
    final notifier = ref.read(nuevaContrasenaProvider.notifier);
    final tablet = context.clasePantalla.esTablet;
    return MarcoRecuperacion(
      pose: PoseSarko.sorprendido,
      cabecera: BotonCerrar(alPresionar: () => context.go(Rutas.inicioSesion)),
      cuerpo: [
        SizedBox(height: tablet ? 8 : 32),
        const TituloRecuperacion(Textos.nuevaContrasenaTitulo),
        const SizedBox(height: 12),
        const TextoRecuperacion(Textos.nuevaContrasenaDescripcion),
        const SizedBox(height: 20),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoTextoApp(
                key: const ValueKey('campo-nueva-contrasena'),
                etiqueta: Textos.campoNuevaContrasena,
                tipo: TipoCampo.contrasena,
                iconoInicio: IconosApp.lock,
                controlador: _nueva,
                nodoFoco: _focoNueva,
                error: estado.errorNueva,
                accionTeclado: TextInputAction.next,
                pistasAutocompletado: const [AutofillHints.newPassword],
                alCambiar: (_) {
                  if (estado.errorNueva != null) notifier.limpiarNueva();
                },
              ),
              if (estado.errorNueva == null) ...[
                const SizedBox(height: 6),
                const NotaRecuperacion(Textos.ayudaNuevaContrasena),
              ],
              const SizedBox(height: 16),
              CampoTextoApp(
                key: const ValueKey('campo-confirmar-contrasena'),
                etiqueta: Textos.campoConfirmarContrasena,
                tipo: TipoCampo.contrasena,
                iconoInicio: IconosApp.lock,
                controlador: _confirmar,
                nodoFoco: _focoConfirmar,
                error: estado.errorConfirmar,
                accionTeclado: TextInputAction.done,
                pistasAutocompletado: const [AutofillHints.newPassword],
                alEnviar: (_) => _guardar(),
                alCambiar: (_) {
                  if (estado.errorConfirmar != null) notifier.limpiarConfirmar();
                },
              ),
            ],
          ),
        ),
        if (estado.errorGeneral != null) ...[
          const SizedBox(height: 8),
          AvisoError(mensaje: estado.errorGeneral!),
        ],
        const SizedBox(height: 24),
        BotonApp(
          key: const ValueKey('boton-guardar-contrasena'),
          texto: Textos.guardarContrasena,
          alPresionar: _guardar,
          cargando: estado.enviando,
          textoCargando: Textos.guardandoContrasena,
        ),
      ],
    );
  }
}

/// 31d · Contraseña actualizada y 31e · Enlace caducado.
class PantallaResultadoRecuperacion extends StatelessWidget {
  const PantallaResultadoRecuperacion({required this.caducado, super.key});

  final bool caducado;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tablet = context.clasePantalla.esTablet;
    final pose = caducado ? PoseSarko.triste : PoseSarko.alegre;
    final insignia = InsigniaCircular(
      icono: caducado ? IconosApp.alert : IconosApp.check,
      color: caducado ? tokens.accionAcento : tokens.accionPrimaria,
      diametro: tablet ? 96 : 64,
      etiqueta: caducado ? Textos.insigniaAlerta : Textos.insigniaListo,
    );
    return MarcoRecuperacion(
      key: ValueKey(caducado ? 'recuperacion-caducado' : 'recuperacion-listo'),
      pose: pose,
      cuerpo: [
        SizedBox(height: tablet ? 8 : 60),
        if (tablet)
          Align(alignment: Alignment.centerLeft, child: insignia)
        else
          Center(
            child: IlustracionInsignia(pose: pose, insignia: insignia),
          ),
        const SizedBox(height: 24),
        TituloRecuperacion(
          caducado ? Textos.enlaceCaducadoTitulo : Textos.contrasenaActualizadaTitulo,
        ),
        const SizedBox(height: 12),
        TextoRecuperacion(
          caducado ? Textos.enlaceCaducadoTexto : Textos.contrasenaActualizadaTexto,
        ),
        const SizedBox(height: 24),
        if (caducado) ...[
          BotonApp(
            key: const ValueKey('boton-pedir-enlace'),
            texto: Textos.pedirEnlaceNuevo,
            alPresionar: () => context.go(Rutas.recuperar),
          ),
          const SizedBox(height: 8),
          BotonApp(
            key: const ValueKey('boton-iniciar-sesion-recuperacion'),
            texto: Textos.botonIniciarSesion,
            tipo: TipoBoton.fantasma,
            altoMinimo: 48,
            alPresionar: () => context.go(Rutas.inicioSesion),
          ),
        ] else
          BotonApp(
            key: const ValueKey('boton-iniciar-sesion-recuperacion'),
            texto: Textos.botonIniciarSesion,
            alPresionar: () => context.go(Rutas.inicioSesion),
          ),
      ],
    );
  }
}
