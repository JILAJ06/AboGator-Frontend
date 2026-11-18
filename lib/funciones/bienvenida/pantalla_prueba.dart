import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/tema/modo_tema.dart';
import '../../core/tema/tipografia.dart';
import '../../core/tema/tokens_color.dart';
import '../../core/textos/textos.dart';
import '../../core/utilidades/extensiones_contexto.dart';

/// Pantalla temporal "Tema de prueba": muestra los 14 tokens de color,
/// los 11 estilos de texto y permite alternar claro/oscuro.
///
/// Se elimina en T-02.
class PantallaPrueba extends ConsumerWidget {
  const PantallaPrueba({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final estilos = context.estilos;

    return Scaffold(
      appBar: AppBar(
        title: Text(Textos.pruebaTitulo, style: estilos.h2),
        backgroundColor: tokens.fondoSuperficie,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: Text(Textos.pruebaModoOscuro, style: estilos.cuerpoEnfasis),
                value: context.esModoOscuro,
                onChanged: (activo) => ref
                    .read(modoTemaProvider.notifier)
                    .establecer(activo ? ThemeMode.dark : ThemeMode.light),
              ),
              const SizedBox(height: 16),
              Semantics(header: true, child: Text(Textos.pruebaSeccionColores, style: estilos.h3)),
              const SizedBox(height: 8),
              for (final (nombre, color) in _tokensConNombre(tokens))
                _MuestraColor(nombre: nombre, color: color),
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(Textos.pruebaSeccionTipografia, style: estilos.h3),
              ),
              const SizedBox(height: 8),
              for (final (nombre, estilo) in _estilosConNombre(estilos))
                _MuestraEstilo(nombre: nombre, estilo: estilo),
            ],
          ),
        ),
      ),
    );
  }

  static List<(String, Color)> _tokensConNombre(TokensColor t) => [
    (Textos.tokenFondoApp, t.fondoApp),
    (Textos.tokenFondoSuperficie, t.fondoSuperficie),
    (Textos.tokenFondoSuperficieAlt, t.fondoSuperficieAlt),
    (Textos.tokenFondoDestacado, t.fondoDestacado),
    (Textos.tokenTextoPrimario, t.textoPrimario),
    (Textos.tokenTextoSecundario, t.textoSecundario),
    (Textos.tokenTextoEnPrimario, t.textoEnPrimario),
    (Textos.tokenTextoAcento, t.textoAcento),
    (Textos.tokenBordeDefault, t.bordeDefault),
    (Textos.tokenAccionPrimaria, t.accionPrimaria),
    (Textos.tokenAccionSecundaria, t.accionSecundaria),
    (Textos.tokenAccionAcento, t.accionAcento),
    (Textos.tokenEstadoLegal, t.estadoLegal),
    (Textos.tokenEstadoIlegal, t.estadoIlegal),
  ];

  static List<(String, TextStyle)> _estilosConNombre(EstilosTexto e) => [
    (Textos.estiloDisplay, e.display),
    (Textos.estiloH1, e.h1),
    (Textos.estiloH2, e.h2),
    (Textos.estiloH3, e.h3),
    (Textos.estiloCuerpoGrande, e.cuerpoGrande),
    (Textos.estiloCuerpoBase, e.cuerpoBase),
    (Textos.estiloCuerpoEnfasis, e.cuerpoEnfasis),
    (Textos.estiloEtiqueta, e.etiqueta),
    (Textos.estiloLeyenda, e.leyenda),
    (Textos.estiloBoton, e.boton),
    (Textos.estiloCodigo, e.codigo),
  ];
}

class _MuestraColor extends StatelessWidget {
  const _MuestraColor({required this.nombre, required this.color});

  final String nombre;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: tokens.bordeDefault),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(nombre, style: estilos.cuerpoEnfasis)),
          Text(color.comoHex, style: estilos.codigo.copyWith(color: tokens.textoSecundario)),
        ],
      ),
    );
  }
}

class _MuestraEstilo extends StatelessWidget {
  const _MuestraEstilo({required this.nombre, required this.estilo});

  final String nombre;
  final TextStyle estilo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final estilos = context.estilos;
    final tamano = estilo.fontSize!.round();
    final interlineado = (estilo.fontSize! * estilo.height!).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nombre · $tamano/$interlineado',
            style: estilos.leyenda.copyWith(color: tokens.textoSecundario),
          ),
          Text(
            identical(estilo, estilos.codigo)
                ? Textos.pruebaCodigoEjemplo
                : Textos.pruebaTextoEjemplo,
            style: estilo,
          ),
        ],
      ),
    );
  }
}
