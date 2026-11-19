import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/usuario.dart';
import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/repositorios/repositorio_autenticacion.dart';
import 'estado_inicio_sesion.dart' show ResultadoEnvio;
import 'sesion.dart';
import 'validadores.dart';

/// Campos del registro en su orden visual (para mover el foco al primer error).
enum CampoRegistro { perfil, nombre, correo, contrasena, avisoPrivacidad, terminos }

/// Estado del formulario de registro (pantalla 06).
///
/// No guarda nombre, correo ni contraseña: la pantalla los pasa al enviar.
/// Los dos consentimientos son independientes y empiezan sin marcar.
class EstadoRegistro {
  const EstadoRegistro({
    this.perfil,
    this.aceptaAvisoPrivacidad = false,
    this.aceptaTerminos = false,
    this.errores = const {},
    this.errorGeneral,
    this.enviando = false,
  });

  /// Sin selección inicial.
  final PerfilUsuario? perfil;
  final bool aceptaAvisoPrivacidad;
  final bool aceptaTerminos;
  final Map<CampoRegistro, String> errores;
  final String? errorGeneral;
  final bool enviando;

  String? errorDe(CampoRegistro campo) => errores[campo];

  EstadoRegistro copiar({
    PerfilUsuario? perfil,
    bool? aceptaAvisoPrivacidad,
    bool? aceptaTerminos,
    Map<CampoRegistro, String>? errores,
    String? Function()? errorGeneral,
    bool? enviando,
  }) {
    return EstadoRegistro(
      perfil: perfil ?? this.perfil,
      aceptaAvisoPrivacidad: aceptaAvisoPrivacidad ?? this.aceptaAvisoPrivacidad,
      aceptaTerminos: aceptaTerminos ?? this.aceptaTerminos,
      errores: errores ?? this.errores,
      errorGeneral: errorGeneral != null ? errorGeneral() : this.errorGeneral,
      enviando: enviando ?? this.enviando,
    );
  }
}

class RegistroNotifier extends Notifier<EstadoRegistro> {
  @override
  EstadoRegistro build() => const EstadoRegistro();

  Map<CampoRegistro, String> _sin(CampoRegistro campo) => Map.of(state.errores)..remove(campo);

  void limpiarError(CampoRegistro campo) =>
      state = state.copiar(errores: _sin(campo), errorGeneral: () => null);

  void elegirPerfil(PerfilUsuario perfil) =>
      state = state.copiar(perfil: perfil, errores: _sin(CampoRegistro.perfil));

  void cambiarAvisoPrivacidad(bool valor) => state = state.copiar(
    aceptaAvisoPrivacidad: valor,
    errores: _sin(CampoRegistro.avisoPrivacidad),
  );

  void cambiarTerminos(bool valor) =>
      state = state.copiar(aceptaTerminos: valor, errores: _sin(CampoRegistro.terminos));

  /// Valida todo y, si está bien, registra en el repositorio.
  Future<ResultadoEnvio<CampoRegistro>> enviar({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    if (state.enviando) return const ResultadoEnvio.ignorado();
    final errores = <CampoRegistro, String>{
      for (final (campo, error) in [
        (CampoRegistro.perfil, Validadores.perfil(state.perfil)),
        (CampoRegistro.nombre, Validadores.nombre(nombre)),
        (CampoRegistro.correo, Validadores.correo(correo)),
        (CampoRegistro.contrasena, Validadores.contrasenaRegistro(contrasena)),
        (CampoRegistro.avisoPrivacidad, Validadores.avisoPrivacidad(state.aceptaAvisoPrivacidad)),
        (CampoRegistro.terminos, Validadores.terminos(state.aceptaTerminos)),
      ])
        campo: ?error,
    };
    state = state.copiar(errores: errores, errorGeneral: () => null);
    if (errores.isNotEmpty) {
      final primero = CampoRegistro.values.firstWhere(errores.containsKey);
      return ResultadoEnvio.errorEn(primero);
    }

    state = state.copiar(enviando: true);
    try {
      final usuario = await ref
          .read(repositorioAutenticacionProvider)
          .registrar(
            nombre: nombre.trim(),
            correo: correo.trim(),
            contrasena: contrasena,
            perfil: state.perfil!,
            aceptaAvisoPrivacidad: state.aceptaAvisoPrivacidad,
            aceptaTerminos: state.aceptaTerminos,
          );
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      ref.read(sesionProvider.notifier).iniciar(usuario);
      state = state.copiar(enviando: false);
      return const ResultadoEnvio.exito();
    } on ExcepcionAutenticacion catch (e) {
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      state = state.copiar(enviando: false, errorGeneral: () => e.mensaje);
      return const ResultadoEnvio.errorGeneral();
    }
  }
}

final registroProvider = NotifierProvider.autoDispose<RegistroNotifier, EstadoRegistro>(
  RegistroNotifier.new,
);
