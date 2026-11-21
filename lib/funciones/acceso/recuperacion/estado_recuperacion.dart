import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/textos/textos.dart';
import '../../../datos/repositorios/proveedores_repositorios.dart';
import '../../../datos/repositorios/repositorio_autenticacion.dart';
import '../estado_inicio_sesion.dart' show ResultadoEnvio;
import '../validadores.dart';

/// Estado de "Recuperar contraseña" (31 y 31b, T-13b). Guarda el correo para
/// mostrarlo en 31b y para volver a escribirlo en 31 desde 31e.
class EstadoRecuperacion {
  const EstadoRecuperacion({
    this.correo = '',
    this.errorCorreo,
    this.errorGeneral,
    this.enviando = false,
  });

  final String correo;
  final String? errorCorreo;
  final String? errorGeneral;
  final bool enviando;

  EstadoRecuperacion copiar({
    String? correo,
    String? Function()? errorCorreo,
    String? Function()? errorGeneral,
    bool? enviando,
  }) => EstadoRecuperacion(
    correo: correo ?? this.correo,
    errorCorreo: errorCorreo != null ? errorCorreo() : this.errorCorreo,
    errorGeneral: errorGeneral != null ? errorGeneral() : this.errorGeneral,
    enviando: enviando ?? this.enviando,
  );
}

/// Campo de 31 (solo el correo).
enum CampoRecuperacion { correo }

class RecuperacionNotifier extends Notifier<EstadoRecuperacion> {
  @override
  EstadoRecuperacion build() => const EstadoRecuperacion();

  void limpiarError() => state = state.copiar(errorCorreo: () => null, errorGeneral: () => null);

  /// 31 · Valida el correo y pide el enlace. El repositorio responde igual
  /// exista o no la cuenta.
  Future<ResultadoEnvio<CampoRecuperacion>> enviar(String correo) async {
    if (state.enviando) return const ResultadoEnvio.ignorado();
    final limpio = correo.trim();
    final error = Validadores.correo(limpio);
    state = EstadoRecuperacion(correo: limpio, errorCorreo: error);
    if (error != null) return const ResultadoEnvio.errorEn(CampoRecuperacion.correo);
    return _pedir(limpio);
  }

  /// 31b · Reenvía el enlace al mismo correo.
  Future<ResultadoEnvio<CampoRecuperacion>> reenviar() {
    if (state.enviando || state.correo.isEmpty) {
      return Future.value(const ResultadoEnvio.ignorado());
    }
    return _pedir(state.correo);
  }

  Future<ResultadoEnvio<CampoRecuperacion>> _pedir(String correo) async {
    state = state.copiar(enviando: true, errorGeneral: () => null);
    try {
      await ref.read(repositorioAutenticacionProvider).solicitarRecuperacion(correo);
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      state = state.copiar(enviando: false);
      return const ResultadoEnvio.exito();
    } on Object {
      if (!ref.mounted) return const ResultadoEnvio.ignorado();
      state = state.copiar(enviando: false, errorGeneral: () => Textos.errorRecuperacion);
      return const ResultadoEnvio.errorGeneral();
    }
  }
}

/// Vive mientras dura la app: 31b y 31e leen el correo escrito en 31.
final recuperacionProvider = NotifierProvider<RecuperacionNotifier, EstadoRecuperacion>(
  RecuperacionNotifier.new,
);

/// Estado de 31c · Nueva contraseña. No guarda las contraseñas.
class EstadoNuevaContrasena {
  const EstadoNuevaContrasena({
    this.errorNueva,
    this.errorConfirmar,
    this.errorGeneral,
    this.enviando = false,
  });

  final String? errorNueva;
  final String? errorConfirmar;
  final String? errorGeneral;
  final bool enviando;
}

enum CampoNuevaContrasena { nueva, confirmar }

/// Resultado de guardar la contraseña nueva.
enum ResultadoRestablecer { listo, caducado, error, conErrores, ignorado }

class NuevaContrasenaNotifier extends Notifier<EstadoNuevaContrasena> {
  @override
  EstadoNuevaContrasena build() => const EstadoNuevaContrasena();

  void limpiarNueva() => state = EstadoNuevaContrasena(errorConfirmar: state.errorConfirmar);

  void limpiarConfirmar() => state = EstadoNuevaContrasena(errorNueva: state.errorNueva);

  /// Primer campo con error tras [guardar] (para mover el foco).
  CampoNuevaContrasena? get primerError => state.errorNueva != null
      ? CampoNuevaContrasena.nueva
      : state.errorConfirmar != null
      ? CampoNuevaContrasena.confirmar
      : null;

  Future<ResultadoRestablecer> guardar({
    required String token,
    required String nueva,
    required String confirmar,
  }) async {
    if (state.enviando) return ResultadoRestablecer.ignorado;
    final errorNueva = Validadores.contrasenaRegistro(nueva);
    final errorConfirmar = confirmar != nueva || confirmar.isEmpty
        ? Textos.errorContrasenasNoCoinciden
        : null;
    state = EstadoNuevaContrasena(errorNueva: errorNueva, errorConfirmar: errorConfirmar);
    if (errorNueva != null || errorConfirmar != null) return ResultadoRestablecer.conErrores;
    state = const EstadoNuevaContrasena(enviando: true);
    try {
      await ref.read(repositorioAutenticacionProvider).restablecer(token: token, nueva: nueva);
      if (!ref.mounted) return ResultadoRestablecer.ignorado;
      state = const EstadoNuevaContrasena();
      return ResultadoRestablecer.listo;
    } on ExcepcionEnlaceCaducado {
      if (!ref.mounted) return ResultadoRestablecer.ignorado;
      state = const EstadoNuevaContrasena();
      return ResultadoRestablecer.caducado;
    } on Object {
      if (!ref.mounted) return ResultadoRestablecer.ignorado;
      state = const EstadoNuevaContrasena(errorGeneral: Textos.errorRestablecer);
      return ResultadoRestablecer.error;
    }
  }
}

final nuevaContrasenaProvider =
    NotifierProvider.autoDispose<NuevaContrasenaNotifier, EstadoNuevaContrasena>(
      NuevaContrasenaNotifier.new,
    );
