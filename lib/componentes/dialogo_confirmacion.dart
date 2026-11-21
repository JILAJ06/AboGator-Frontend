import 'package:material_ui/material_ui.dart';

import '../core/adaptativo/clase_pantalla.dart';
import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import 'bloque_lectura.dart';
import 'boton_app.dart';

/// Diálogo de confirmación (compra en la Tienda y "Cerrar sesión"):
/// fondo/superficie, radio 22, relleno 24, título en Título/H2 con el foco
/// inicial, texto en Cuerpo/Base, botón primario y fantasma "Cancelar" de alto
/// 48. Esc o tocar fuera cancelan (devuelve `false` o `null`).
class DialogoConfirmacion extends StatelessWidget {
  const DialogoConfirmacion({
    required this.titulo,
    required this.texto,
    required this.textoConfirmar,
    super.key,
  });

  /// Ancho máximo del diálogo (en tablet, [anchoMaximoTablet]).
  static const double anchoMaximo = 400;
  static const double anchoMaximoTablet = 440;

  final String titulo;
  final String texto;
  final String textoConfirmar;

  /// Muestra el diálogo; `true` solo si se confirmó.
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String texto,
    required String textoConfirmar,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) =>
          DialogoConfirmacion(titulo: titulo, texto: texto, textoConfirmar: textoConfirmar),
    );
    return confirmado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Dialog(
      key: const ValueKey('dialogo-confirmacion'),
      backgroundColor: tokens.fondoSuperficie,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      // En pantallas anchas no pasa de 400 (en 390 ocupa 342, como el resto).
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.clasePantalla.esTablet ? anchoMaximoTablet : anchoMaximo,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BloqueLectura(
                encabezado: true,
                autofocus: true,
                radio: 8,
                child: Text(titulo, style: estilos.h2.copyWith(color: tokens.textoPrimario)),
              ),
              const SizedBox(height: 8),
              Text(texto, style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario)),
              const SizedBox(height: 20),
              BotonApp(
                key: const ValueKey('boton-confirmar'),
                texto: textoConfirmar,
                altoMinimo: 48,
                alPresionar: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
              BotonApp(
                key: const ValueKey('boton-cancelar'),
                texto: Textos.cancelar,
                tipo: TipoBoton.fantasma,
                altoMinimo: 48,
                alPresionar: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
