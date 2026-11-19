import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/rutas.dart';
import '../../componentes/boton_app.dart';
import '../../componentes/boton_atras.dart';
import '../../componentes/campo_texto_app.dart';
import '../../componentes/casilla_app.dart';
import '../../componentes/chip_seleccion.dart';
import '../../componentes/enlace_texto.dart';
import '../../core/tema/iconos_app.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';
import '../../datos/modelos/usuario.dart';
import 'aviso_error.dart';
import 'estado_registro.dart';

/// Opciones de perfil: texto visible (con emoji) y nombre para el lector.
const List<(PerfilUsuario, String, String)> opcionesPerfil = [
  (PerfilUsuario.estudiante, Textos.perfilEstudianteVisible, Textos.perfilEstudiante),
  (PerfilUsuario.desarrollador, Textos.perfilDesarrolladorVisible, Textos.perfilDesarrollador),
  (PerfilUsuario.legal, Textos.perfilLegalVisible, Textos.perfilLegal),
];

/// Pantalla 06 · Registro.
class PantallaRegistro extends ConsumerStatefulWidget {
  const PantallaRegistro({super.key});

  @override
  ConsumerState<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends ConsumerState<PantallaRegistro> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  late final Map<CampoRegistro, FocusNode> _focos = {
    for (final campo in CampoRegistro.values) campo: FocusNode(),
  };

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    for (final foco in _focos.values) {
      foco.dispose();
    }
    super.dispose();
  }

  Future<void> _enviar() async {
    final resultado = await ref
        .read(registroProvider.notifier)
        .enviar(nombre: _nombre.text, correo: _correo.text, contrasena: _contrasena.text);
    if (!mounted) return;
    if (resultado.exitoso) {
      context.go(Rutas.inicio);
      return;
    }
    final campo = resultado.campoConError;
    if (campo != null) {
      _focos[campo]!.requestFocus();
    }
  }

  void _limpiarAlEscribir(EstadoRegistro estado, CampoRegistro campo) {
    if (estado.errorDe(campo) != null || estado.errorGeneral != null) {
      ref.read(registroProvider.notifier).limpiarError(campo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(registroProvider);
    final notifier = ref.read(registroProvider.notifier);
    final tokens = context.tokens;
    final estilos = context.estilos;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  // En Figma el botón está en x=20 (4 menos que el margen de 24).
                  offset: const Offset(-4, 0),
                  child: BotonAtras(alPresionar: () => context.go(Rutas.inicioSesion)),
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                header: true,
                child: Text(
                  Textos.registroTitulo,
                  style: estilos.h1.copyWith(color: tokens.textoPrimario),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Textos.registroSubtitulo,
                style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario),
              ),
              const SizedBox(height: 16),
              // Grupo de selección única, sin selección inicial.
              Wrap(
                spacing: 8,
                children: [
                  for (final (i, (perfil, visible, nombre)) in opcionesPerfil.indexed)
                    ChipSeleccion(
                      texto: visible,
                      etiquetaSemantica: Textos.perfilSemantica(
                        nombre,
                        i + 1,
                        opcionesPerfil.length,
                      ),
                      seleccionado: estado.perfil == perfil,
                      nodoFoco: i == 0 ? _focos[CampoRegistro.perfil] : null,
                      alPresionar: estado.enviando ? null : () => notifier.elegirPerfil(perfil),
                    ),
                ],
              ),
              if (estado.errorDe(CampoRegistro.perfil) != null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    estado.errorDe(CampoRegistro.perfil)!,
                    style: estilos.leyenda.copyWith(color: tokens.estadoIlegal),
                  ),
                ),
              const SizedBox(height: 12),
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CampoTextoApp(
                      etiqueta: Textos.campoNombreRegistro,
                      textoAyuda: Textos.campoNombreAyuda,
                      tipo: TipoCampo.nombre,
                      iconoInicio: IconosApp.user,
                      controlador: _nombre,
                      nodoFoco: _focos[CampoRegistro.nombre],
                      error: estado.errorDe(CampoRegistro.nombre),
                      accionTeclado: TextInputAction.next,
                      alCambiar: (_) => _limpiarAlEscribir(estado, CampoRegistro.nombre),
                    ),
                    const SizedBox(height: 14),
                    CampoTextoApp(
                      etiqueta: Textos.campoCorreoInicio,
                      textoAyuda: Textos.campoCorreoAyuda,
                      tipo: TipoCampo.correo,
                      iconoInicio: IconosApp.mail,
                      controlador: _correo,
                      nodoFoco: _focos[CampoRegistro.correo],
                      error: estado.errorDe(CampoRegistro.correo),
                      accionTeclado: TextInputAction.next,
                      pistasAutocompletado: const [AutofillHints.email],
                      alCambiar: (_) => _limpiarAlEscribir(estado, CampoRegistro.correo),
                    ),
                    const SizedBox(height: 14),
                    CampoTextoApp(
                      etiqueta: Textos.campoContrasenaInicio,
                      tipo: TipoCampo.contrasena,
                      iconoInicio: IconosApp.lock,
                      controlador: _contrasena,
                      nodoFoco: _focos[CampoRegistro.contrasena],
                      error: estado.errorDe(CampoRegistro.contrasena),
                      accionTeclado: TextInputAction.done,
                      pistasAutocompletado: const [AutofillHints.newPassword],
                      alEnviar: (_) => _enviar(),
                      alCambiar: (_) => _limpiarAlEscribir(estado, CampoRegistro.contrasena),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Dos consentimientos independientes y sin marcar por defecto.
              CasillaApp(
                texto: Textos.aceptoAvisoPrivacidad,
                marcada: estado.aceptaAvisoPrivacidad,
                nodoFoco: _focos[CampoRegistro.avisoPrivacidad],
                error: estado.errorDe(CampoRegistro.avisoPrivacidad),
                alCambiar: estado.enviando ? null : notifier.cambiarAvisoPrivacidad,
              ),
              CasillaApp(
                texto: Textos.aceptoTerminos,
                marcada: estado.aceptaTerminos,
                nodoFoco: _focos[CampoRegistro.terminos],
                error: estado.errorDe(CampoRegistro.terminos),
                alCambiar: estado.enviando ? null : notifier.cambiarTerminos,
              ),
              if (estado.errorGeneral != null) ...[
                const SizedBox(height: 8),
                AvisoError(mensaje: estado.errorGeneral!),
              ],
              const SizedBox(height: 12),
              BotonApp(
                texto: Textos.botonCrearCuenta,
                alPresionar: _enviar,
                cargando: estado.enviando,
                textoCargando: Textos.creandoCuenta,
              ),
              const SizedBox(height: 16),
              Center(
                child: EnlaceTexto(
                  texto: Textos.yaTienesCuenta,
                  alPresionar: estado.enviando ? null : () => context.go(Rutas.inicioSesion),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
