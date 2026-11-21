import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/utilidades/contraste.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Tipo de par (WCAG 2.1): texto normal (1.4.3, ≥ 4.5:1) o componente y
/// gráfico (1.4.11, ≥ 3:1: bordes de controles, anillo de foco, rellenos de
/// barras).
enum TipoPar {
  texto(Contraste.minimoTexto),
  componente(Contraste.minimoNoTexto);

  const TipoPar(this.minimo);

  final double minimo;
}

/// Un par de tokens que la app pinta uno sobre otro y dónde se usa.
typedef ParTokens = ({String frente, String fondo, TipoPar tipo, String uso});

/// Todos los pares de tokens que se usan en la app (T-13). La tabla con las
/// razones calculadas está en `ai/conocimiento/08-accesibilidad.md`.
///
/// Fuera de la tabla: `borde/control` sobre `fondo/destacado` (2.6:1 en
/// oscuro) no se pinta en ninguna pantalla: las opciones de la micro-pregunta,
/// que viven en una caja destacada, llevan su radio sobre su propio
/// `fondo/superficie`.
final List<ParTokens> paresTokens = [
  // Texto sobre los cuatro fondos.
  (frente: 'texto/primario', fondo: 'fondo/app', tipo: TipoPar.texto, uso: 'títulos y cuerpo'),
  (frente: 'texto/primario', fondo: 'fondo/superficie', tipo: TipoPar.texto, uso: 'tarjetas'),
  (frente: 'texto/primario', fondo: 'fondo/superficie-alt', tipo: TipoPar.texto, uso: 'globo'),
  (frente: 'texto/primario', fondo: 'fondo/destacado', tipo: TipoPar.texto, uso: 'avisos'),
  (frente: 'texto/secundario', fondo: 'fondo/app', tipo: TipoPar.texto, uso: 'subtítulos'),
  (frente: 'texto/secundario', fondo: 'fondo/superficie', tipo: TipoPar.texto, uso: 'leyendas'),
  (
    frente: 'texto/secundario',
    fondo: 'fondo/superficie-alt',
    tipo: TipoPar.texto,
    uso: 'chip de plazo, botón deshabilitado',
  ),
  (
    frente: 'texto/secundario',
    fondo: 'fondo/destacado',
    tipo: TipoPar.texto,
    uso: 'recompensa del Buzón',
  ),
  (frente: 'texto/acento', fondo: 'fondo/app', tipo: TipoPar.texto, uso: 'enlaces'),
  (frente: 'texto/acento', fondo: 'fondo/superficie', tipo: TipoPar.texto, uso: 'etiquetas'),
  (frente: 'texto/acento', fondo: 'fondo/superficie-alt', tipo: TipoPar.texto, uso: 'etiquetas'),
  (
    frente: 'texto/acento',
    fondo: 'fondo/destacado',
    tipo: TipoPar.texto,
    uso: '"La fallaste hace N días", reto diario',
  ),
  // Estados (sellos, pistas de gesto, etiquetas de veredicto).
  for (final estado in ['estado/legal', 'estado/ilegal', 'estado/condicional', 'estado/escalar'])
    for (final fondo in ['fondo/app', 'fondo/superficie', 'fondo/superficie-alt'])
      (frente: estado, fondo: fondo, tipo: TipoPar.texto, uso: 'sellos, pistas y veredictos'),
  for (final fondo in ['fondo/app', 'fondo/superficie'])
    (frente: 'accion/secundaria', fondo: fondo, tipo: TipoPar.texto, uso: 'botón secundario'),
  (frente: 'accion/primaria', fondo: 'fondo/destacado', tipo: TipoPar.texto, uso: 'pestaña activa'),
  (frente: 'accion/primaria', fondo: 'fondo/superficie', tipo: TipoPar.texto, uso: 'textos'),
  // Texto sobre los rellenos de color.
  (
    frente: 'texto/en-primario',
    fondo: 'accion/primaria',
    tipo: TipoPar.texto,
    uso: 'botón primario',
  ),
  (frente: 'texto/en-primario', fondo: 'accion/acento', tipo: TipoPar.texto, uso: 'botón acento'),
  (
    frente: 'texto/en-primario',
    fondo: 'estado/ilegal',
    tipo: TipoPar.texto,
    uso: 'botón peligro, chip de hoy, insignia',
  ),
  (
    frente: 'texto/en-primario',
    fondo: 'accion/secundaria',
    tipo: TipoPar.texto,
    uso: 'insignia del Amparo, Buzón',
  ),
  (
    frente: 'texto/en-primario',
    fondo: 'estado/legal',
    tipo: TipoPar.texto,
    uso: 'insignia acierto',
  ),
  // Componentes y gráficos.
  for (final fondo in ['fondo/app', 'fondo/superficie', 'fondo/superficie-alt'])
    (
      frente: 'borde/control',
      fondo: fondo,
      tipo: TipoPar.componente,
      uso: 'campos, casillas, interruptor, puntos',
    ),
  for (final fondo in ['fondo/app', 'fondo/superficie', 'fondo/superficie-alt', 'fondo/destacado'])
    (frente: 'foco/anillo', fondo: fondo, tipo: TipoPar.componente, uso: 'anillo de foco'),
  (
    frente: 'accion/primaria',
    fondo: 'fondo/superficie-alt',
    tipo: TipoPar.componente,
    uso: 'barra de progreso',
  ),
  (
    frente: 'accion/secundaria',
    fondo: 'fondo/superficie-alt',
    tipo: TipoPar.componente,
    uso: 'barra del Examen',
  ),
  (
    frente: 'accion/acento',
    fondo: 'fondo/superficie-alt',
    tipo: TipoPar.componente,
    uso: 'barra de Presupuesto',
  ),
  // estado/ilegal sobre fondo/superficie-alt (barra de Riesgo legal) ya está
  // arriba con el mínimo de texto, que es más estricto.
];

void main() {
  for (final (modo, tokens) in [('claro', TokensColor.claro), ('oscuro', TokensColor.oscuro)]) {
    group('contraste de tokens en $modo', () {
      for (final par in paresTokens) {
        test('${par.frente} sobre ${par.fondo} (${par.uso}) ≥ ${par.tipo.minimo}:1', () {
          final frente = tokens.porNombre[par.frente];
          final fondo = tokens.porNombre[par.fondo];
          expect(frente, isNotNull, reason: 'token ${par.frente}');
          expect(fondo, isNotNull, reason: 'token ${par.fondo}');
          expect(Contraste.razon(frente!, fondo!), greaterThanOrEqualTo(par.tipo.minimo));
        });
      }
    });
  }

  test('la tabla no repite pares', () {
    final claves = {for (final p in paresTokens) '${p.frente}|${p.fondo}'};
    expect(claves, hasLength(paresTokens.length));
  });

  test('borde/control sobre fondo/destacado no cumple en oscuro (por eso no se usa)', () {
    const t = TokensColor.oscuro;
    expect(Contraste.razon(t.bordeControl, t.fondoDestacado), lessThan(Contraste.minimoNoTexto));
  });

  test('referencia: blanco sobre negro = 21:1', () {
    expect(Contraste.razon(const Color(0xFFFFFFFF), const Color(0xFF000000)), closeTo(21, 0.01));
  });
}
