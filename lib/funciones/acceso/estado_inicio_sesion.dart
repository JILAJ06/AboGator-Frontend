import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/repositorios/proveedores_repositorios.dart';
import '../../datos/repositorios/repositorio_autenticacion.dart';
import 'sesion.dart';
import 'validadores.dart';

/// Estado del formulario de inicio de sesión (pantalla 05).
///
/// No guarda la contraseña: la pantalla la pasa solo al enviar.
class EstadoInicioSesion {
  const EstadoInicioSesion({
    this.errorCorreo,
    this.errorContrasena,
    this.errorGeneral,
    this.enviando = false,
  });

  final String? errorCorreo;
  final String? errorContrasena;

  /// Error del repositorio (por ejemplo, credenciales incorrectas).
  final String? errorGeneral;
  final bool enviando;

  EstadoInicioSesion copiar({
    String? Function()? errorCorreo,
    String? Function()? errorContrasena,
    String? Function()? errorGeneral,
    bool? enviando,
  }) {
    return EstadoInicioSesion(
      errorCorreo: errorCorreo != null ? errorCorreo() : this.errorCorreo,
      errorContrasena: errorContrasena != null ? errorContrasena() : this.errorContrasena,
      errorGeneral: errorGeneral != null ? errorGeneral() : this.errorGeneral,
      enviando: enviando ?? this.enviando,
    );
  }
}

/// Campo con el primer error tras enviar (para mover el foco ahí).
enum CampoInicioSesion { correo, contrasena }

class InicioSesionNotifier extends Notifier<EstadoInicioSesion> {
  @override
  EstadoInicioSesion build() => const EstadoInicioSesion();

  void limpiarErrorCorreo() =>
      state = state.copiar(errorCorreo: () => null, errorGeneral: () => null);

  void limpiarErrorContrasena() =>
      state = state.copiar(errorContrasena: () => null, errorGeneral: () => null);

  /// Valida y llama al repositorio. Devuelve `null` si inició sesión, o el
  /// primer campo con error (`null` también si el error fue del repositorio,
  /// que queda en [EstadoInicioSesion.errorGeneral]).
  Future<ResultadoEnvio<CampoInicioSesion>> enviar({
    required String correo,
    required String contrasena,
  }) async {
    if (state.enviando) return const ResultadoEnvio.ignorado();
    final errorCorreo = Validadores.correo(correo);
    final errorContrasena = Validadores.contrasenaInicio(contrasena);
    state = EstadoInicioSesion(errorCorreo: errorCorreo, errorContrasena: errorContrasena);
    if (errorCorreo != null) return const ResultadoEnvio.errorEn(CampoInicioSesion.correo);
    if (errorContrasena != null) {
      return const ResultadoEnvio.errorEn(CampoInicioSesion.contrasena);
    }

    state = state.copiar(enviando: true);
    try {
      final usuario = await ref
          .read(repositorioAutenticacionProvider)
          .iniciarSesion(correo: correo.trim(), contrasena: contrasena);
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      ref.read(sesionProvider.notifier).iniciar(usuario);
      state = const EstadoInicioSesion();
      return const ResultadoEnvio.exito();
    } on ExcepcionAutenticacion catch (e) {
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      state = EstadoInicioSesion(errorGeneral: e.mensaje);
      return const ResultadoEnvio.errorGeneral();
    }
  }
}

final inicioSesionProvider = NotifierProvider.autoDispose<InicioSesionNotifier, EstadoInicioSesion>(
  InicioSesionNotifier.new,
);

/// Resultado de enviar un formulario.
class ResultadoEnvio<C> {
  const ResultadoEnvio.exito() : exitoso = true, campoConError = null, ignorado = false;
  const ResultadoEnvio.errorEn(C campo) : exitoso = false, campoConError = campo, ignorado = false;
  const ResultadoEnvio.errorGeneral() : exitoso = false, campoConError = null, ignorado = false;
  const ResultadoEnvio.ignorado() : exitoso = false, campoConError = null, ignorado = true;

  final bool exitoso;

  /// Primer campo con error, en el orden visual.
  final C? campoConError;

  /// El envío no se hizo (ya había uno en curso o la pantalla se cerró).
  final bool ignorado;
}
