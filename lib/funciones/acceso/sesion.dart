import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../datos/modelos/usuario.dart';

/// Usuario con sesión iniciada (o `null`). Lo usará el Inicio en T-04.
///
/// Solo guarda el `Usuario`; nunca credenciales.
class SesionNotifier extends Notifier<Usuario?> {
  @override
  Usuario? build() => null;

  void iniciar(Usuario usuario) => state = usuario;

  void cerrar() => state = null;
}

final sesionProvider = NotifierProvider<SesionNotifier, Usuario?>(SesionNotifier.new);
