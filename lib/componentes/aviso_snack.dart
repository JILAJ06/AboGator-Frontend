import 'package:material_ui/material_ui.dart';

/// Aviso breve abajo con el `SnackBar` del tema (T-15b): quita el aviso
/// anterior, muestra [texto] y lo anuncia como región en vivo. [clave] va en
/// el `SnackBar` (las pruebas lo buscan por clave).
void mostrarAviso(BuildContext context, String texto, {Key? clave}) =>
    mostrarAvisoEn(ScaffoldMessenger.of(context), texto, clave: clave);

/// Igual que [mostrarAviso], con un [mensajero] guardado antes de un `await`.
void mostrarAvisoEn(ScaffoldMessengerState mensajero, String texto, {Key? clave}) {
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        key: clave,
        content: Semantics(liveRegion: true, child: Text(texto)),
      ),
    );
}
