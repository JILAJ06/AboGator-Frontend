# Reporte
- **Tarea:** T-15a · Auditoría de duplicación (solo análisis)
- **Rama:** `15a-auditoria-de-duplicacion`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Qué se hizo
- **Nuevo** `ai/conocimiento/09-duplicacion.md`, con:
  - la medición inicial;
  - un catálogo de 20 patrones de `lib/` y 3 de `test/`, con su ubicación (archivo:línea), las líneas repetidas, la API propuesta, el riesgo y las pruebas que lo cubren;
  - la lista de código muerto;
  - cinco lotes, de la T-15b a la T-15f;
  - las 8 reglas de la T-15.
- **Grafo:** fila nueva DOC-09 (`en curso`, para que la revises) y una línea en el registro de cambios. No hay más índice de conocimiento que las filas DOC-* del grafo.
- **Sin cambios en `lib/` ni `test/`** (`git diff --stat` solo muestra `ai/`). Sin dependencias nuevas.

## Medición inicial
- `lib/` tiene **35 552 líneas** en 211 archivos:
  - `componentes` 10 861;
  - `datos` 4 955;
  - `core` 2 646;
  - `app` 656;
  - `funciones` 16 405 (la carpeta más grande es `juego`, con 3 093).
- `test/` tiene **19 673 líneas** en 82 archivos.
- Pruebas: **3025** (879 declaraciones `test`/`testWidgets`; el resto sale de los bucles).
- Los archivos más largos son `mock_tarjetas.dart` (1 429), `galeria_componentes.dart` (1 234), `pantalla_jefe.dart` (1 182) y `textos.dart` (1 124). La tabla de los 20 está en `09`.
- Detector de clones (ventanas de 6 líneas normalizadas): **1 780 líneas** en tramos repetidos en `lib/` y **828** en `test/`.

## Hallazgo general
La app ya reutiliza bien los controles: **no hay botones, campos ni casillas hechos a mano**, ni colores o `TextStyle` sueltos fuera del tema. La duplicación está en tres sitios:
- piezas visuales pequeñas copiadas;
- contenido armado dos veces (móvil y tablet, o las dos listas de `ColumnaFinSprint`);
- lógica de pantalla repetida (el teclado del mazo, las hojas adaptativas y el `switch` de carga, error y datos).

## Los 5 patrones que más ahorran
1. **P-01 · Esqueletos de carga** (≈ 150 líneas, riesgo bajo): 10 clases `_Esqueleto*` con el mismo armazón. Propuesta: `EsqueletoPantalla` + `BloqueEsqueleto`.
2. **P-04 · Caja de superficie** (≈ 120, bajo): 39 `BoxDecoration` con fondo, radio y borde opcional copiados. Propuesta: `CajaSuperficie(fondo:, radio:, conBorde:)`.
3. **P-11 · Contenido doble en `ColumnaFinSprint`** (≈ 100, medio): Sprint completado, Quiebra y el resultado del juicio arman las mismas piezas para móvil y para tablet.
4. **P-14 · Teclado del mazo y tinte** (≈ 100, alto): `_alTeclear` y `_envolver` están copiados en el juego, el Examen y el juicio. Propuesta: `MarcoMazo`, al final.
5. **P-08 · Semántica de botón en `AccionEnfocable`** (≈ 90, medio): 18 copias de `Semantics(button, label, onTap, excludeSemantics)`. Propuesta: `AccionEnfocable.boton(etiqueta:)`.

También ahorran bastante: P-15 (Examen móvil/tablet, ≈ 90), T-02 (falsos de prueba repetidos, ≈ 130 en `test/`) y T-01 (matriz «sin desbordes» en 9 archivos, ≈ 90 en `test/`).

## Código muerto
- `lib/app/pantalla_pendiente.dart` (49 líneas; ninguna ruta la usa).
- `mostrarAvisoBreve` (`aviso_error.dart:41`).
- 7 textos sin uso: `buzonApelaciones`, `veredictoAnuncio`, `sinCambios`, `noSeleccionada`, `noMarcada`, `lineaClave` y `notificacionApelacionPie`.
- `MedidasAdaptativas.lienzoTablet` y `Rutas.juicioApelacion`.
- No hay imports sobrantes.

## Plan de lotes
| Lote | Patrones | Ahorro | Riesgo |
|---|---|---|---|
| T-15b `15b-limpieza-y-piezas-pequenas` | código muerto, P-03, P-02, P-06, P-07, P-18 | ≈ 280 | bajo |
| T-15c `15c-superficies-y-estados` | P-04, P-05, P-01, P-09, P-10 | ≈ 385 | bajo-medio |
| T-15d `15d-ayudantes-de-pruebas` | T-01, T-02, T-03 (solo `test/`) | ≈ 240 en `test/` | bajo |
| T-15e `15e-marcos-y-disposiciones` | P-08, P-13, P-12, P-17, P-16, P-19 | ≈ 310 | medio |
| T-15f `15f-juego-examen-y-fin-de-sprint` | P-11, P-15, P-14 (al final, sola si hace falta), P-20 | ≈ 335 | medio-alto |

- **Total estimado:** ≈ 1 310 líneas menos en `lib/` (≈ 3,7 %) y ≈ 240 en `test/`.
- Es menos de lo que sugiere el tamaño de la app, porque la base ya está bien componentizada. Gran parte del volumen es contenido (mocks, textos y la galería), no duplicación.
- Las pruebas que protegen cada lote están en `09`.

## Verificación
- `git diff --stat develop`: solo `ai/conocimiento/09-duplicacion.md`, `ai/grafo.md` y `ai/reporte.md`.
- No corrí la suite: no cambió código. Las 3025 pruebas son las de `develop` tras la T-13b.

## Dudas
- **D1.** La matriz «sin desbordes» de 9 archivos de pruebas (6 combinaciones cada uno) se cruza con la auditoría de `test/auditoria/`, que ya revisa desbordes en 4 tamaños × 3 escalas. Hay dos opciones:
  - pasarla a un ayudante común y conservar las mismas pruebas (es lo que propongo);
  - borrarla por redundante, con lo que bajaría el número de pruebas.
- **D2.** `mostrarAvisoBreve` (sin uso) tiene otro estilo: flotante y con `accionSecundaria`. Los 9 avisos reales usan el `SnackBar` del tema. Propongo que `mostrarAviso` use el estilo actual y borrar `mostrarAvisoBreve`. ¿De acuerdo?
- **D3.** La regla «entrada en la galería» no tiene sentido para lo que no tiene vista propia (`mostrarAviso`, `mostrarHojaAdaptativa`, `VistaAsincrona` y `DesplazableAltoMinimo`). Lo dejé como excepción en las reglas; confírmalo.
- **D4.** 21 clases públicas de `lib/componentes/` solo se usan en su propio archivo (pintores y subpiezas). ¿Las volvemos privadas en la T-15b para que la API pública muestre solo lo reutilizable? No ahorra líneas.
- **D5.** El `TextButton` «Ahora no» del Examen (48 de alto, color crisis) se repite 2 veces en `pantalla_jefe.dart`. Si aparece un tercer uso con otro color, propongo `BotonApp(tipo: TipoBoton.texto)`. ¿Existe ya un tipo de texto en el diseño (Figma) que deba usar?
- **D6.** Quitar el `copyWith(color: tokens.textoPrimario)` redundante (P-03) no cambia nada visible, pero deja implícito el color. ¿Prefieres conservarlo por claridad? Si se conserva, el ahorro de la T-15b baja ≈ 40 líneas.
