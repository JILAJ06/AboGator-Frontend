import 'package:material_ui/material_ui.dart';

import '../core/textos/textos.dart';
import '../core/utilidades/extensiones_contexto.dart';
import '../datos/modelos/estado_startup.dart';
import 'indicadores_startup.dart';

/// "Tu Startup" del panel lateral del juego en tablet (Figma `97:1814`):
/// fondo/superficie, borde 1, radio 20, relleno 16 y separación 12. Título
/// (H3), los indicadores con sus cambios tras cada respuesta y la nota en
/// Leyenda texto/secundario.
class TarjetaTuStartup extends StatelessWidget {
  const TarjetaTuStartup({required this.estado, this.cambios = const {}, super.key});

  final EstadoStartup estado;
  final Map<IndicadorStartup, int> cambios;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return _Tarjeta(
      key: const ValueKey('tarjeta-tu-startup'),
      relleno: 16,
      hijos: [
        Semantics(
          header: true,
          child: Text(Textos.tuStartup, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
        ),
        // Solo lectura (T-13): el lector la lee, pero no es parada de Tab; el
        // orden del teclado en tablet es Salir → Pausa → tarjeta → botones →
        // comodines.
        Semantics(
          container: true,
          label: Textos.indicadoresSemantica,
          child: MergeSemantics(
            child: IndicadoresStartup(estado: estado, cambios: cambios),
          ),
        ),
        Text(
          Textos.notaIndicadores,
          style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
        ),
      ],
    );
  }
}

/// Contexto del sprint (Figma `97:1859`): fondo/superficie, borde 1, radio 20,
/// relleno 20 y separación 12. "MÓDULO N · SPRINT k" (Leyenda texto/acento),
/// el título (H3) y el objetivo (Cuerpo/Base texto/secundario). Se lee como un
/// solo bloque.
class TarjetaContextoSprint extends StatelessWidget {
  const TarjetaContextoSprint({
    required this.etiqueta,
    required this.titulo,
    required this.objetivo,
    super.key,
  });

  final String etiqueta;
  final String titulo;
  final String objetivo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return MergeSemantics(
      child: _Tarjeta(
        key: const ValueKey('tarjeta-contexto-sprint'),
        relleno: 20,
        hijos: [
          Text(etiqueta, style: estilos.leyenda.copyWith(color: tokens.textoAcento)),
          Text(titulo, style: estilos.h3.copyWith(color: tokens.textoPrimario)),
          Text(objetivo, style: estilos.cuerpoBase.copyWith(color: tokens.textoSecundario)),
        ],
      ),
    );
  }
}

/// Atajos de teclado (Figma `97:1863`): fondo/superficie-alt, radio 20, relleno
/// 16 y separación 8; "TECLADO / SWITCH CONTROL" (Leyenda texto/secundario) y
/// tres líneas en Cuerpo/Base texto/primario. Solo lectura.
class TarjetaAtajos extends StatelessWidget {
  const TarjetaAtajos({this.lineas = Textos.atajosLineas, super.key});

  /// Las tres líneas (el Examen cambia la última por "P pausa · Esc…").
  final List<String> lineas;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final linea = estilos.cuerpoBase.copyWith(color: tokens.textoPrimario);
    return MergeSemantics(
      child: Container(
        key: const ValueKey('tarjeta-atajos'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.fondoSuperficieAlt,
          borderRadius: BorderRadius.circular(_Tarjeta.radio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Textos.atajosTitulo,
              style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
            ),
            for (final texto in lineas) ...[const SizedBox(height: 8), Text(texto, style: linea)],
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.relleno, required this.hijos, super.key});

  static const double radio = 20;
  static const double separacion = 12;

  final double relleno;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.all(relleno),
      decoration: BoxDecoration(
        color: tokens.fondoSuperficie,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: tokens.bordeDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, h) in hijos.indexed) ...[if (i > 0) const SizedBox(height: separacion), h],
        ],
      ),
    );
  }
}
