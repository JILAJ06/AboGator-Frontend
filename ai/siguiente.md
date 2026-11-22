# T-15b · Limpieza y piezas pequeñas

**Rama:** `15b-limpieza-y-piezas-pequenas` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15b**).
**Figma:** no hace falta. Es un lote de **cero cambios visibles**: las reglas 1 a 8 de `ai/conocimiento/09-duplicacion.md` mandan. Léelas antes de empezar.

## Objetivo
Primer lote de la T-15: borrar el código muerto y pasar a componentes las piezas pequeñas que se repiten (agarre de hoja, botón cuadrado con ícono, píldora, aviso). Debe quedar **menos código, la misma app y las mismas pruebas en verde** (suite completa, auditoría sin tocar sus escenas).

## Decisiones ya tomadas (respuestas a D1–D6 de la T-15a)
- **P-03 (color de texto redundante) NO se hace:** se conserva el `copyWith(color: tokens.textoPrimario)` por claridad y por seguridad en modo oscuro (D6). Sácalo del lote.
- **D2:** `mostrarAviso` usa el estilo `SnackBar` actual del tema; `mostrarAvisoBreve` se borra.
- **D3:** `mostrarAviso` queda exenta de la galería.
- **D4:** las 21 clases públicas de `lib/componentes/` que solo usa su propio archivo se vuelven **privadas** (`_Nombre`), siempre que `flutter analyze` y las pruebas sigan limpios. Si alguna prueba o la galería la importa, déjala pública y anótala en el reporte.
- **D5:** no se crea nada para «Ahora no» (solo 2 usos).

## 1 · Código muerto (borrar)
Según la tabla de `09-duplicacion.md`:
- `lib/app/pantalla_pendiente.dart` completo, y su nodo **PANT-PENDIENTE** en el grafo (déjalo `obsoleto` con la nota «borrado en T-15b» o quítalo según la regla de `06-grafo-de-conocimiento.md`).
- `mostrarAvisoBreve` (`lib/funciones/acceso/aviso_error.dart:41`).
- Textos sin uso: `buzonApelaciones`, `veredictoAnuncio`, `sinCambios`, `noSeleccionada`, `noMarcada`, `lineaClave`, `notificacionApelacionPie`. **Antes de borrar cada uno** vuelve a buscar referencias en `lib/` **y en `test/`**; si una prueba lo usa, avísalo como D# en vez de borrarlo.
- `MedidasAdaptativas.lienzoTablet` y `Rutas.juicioApelacion` (esta última puede quedar como comentario si documenta el patrón de la ruta).
- Las 21 clases públicas que pasan a privadas (arriba, D4).

## 2 · P-02 · `mostrarAviso`
Un solo ayudante (`lib/componentes/aviso_snack.dart` o donde ya viva `aviso_error.dart`) que reemplace los 9 bloques `ScaffoldMessenger…hideCurrentSnackBar()..showSnackBar(SnackBar(key, content: Semantics(liveRegion: true, child: Text(…))))` (buzón, juicio, Examen ×2, resultado, tienda, perfil, ajustes y los que encuentres). Firma sugerida: `mostrarAviso(BuildContext, String texto, {Key? clave})`. Conserva las **claves** que usan las pruebas y el anuncio en región en vivo.

## 3 · P-06 · `AgarreHoja`
`AgarreHoja()` (40 × 5, radio 3, `bordeDefault`, excluido de la semántica, **clave `agarre`**) en `panel_evidencia`, `panel_veredicto`, `piezas_jefe` y `selector_hora`.

## 4 · P-07 · `BotonIconoCaja`
`BotonIconoCaja({icono, etiqueta, alPresionar, clave?})`: `AccionEnfocable` + semántica de botón + caja de 48 con radio 12, `fondoSuperficie` y borde. Úsalo en `boton_atras`, `boton_cerrar`, `encabezado_modulo` y el de `selector_hora`; `BotonAtras` y `BotonCerrar` quedan como envoltorios de una línea (conservan sus nombres y claves porque muchas pruebas los usan). Si alguno difiere en un detalle (por ejemplo tamaño del ícono o foco), el componente lo recibe por parámetro; **no cambies ningún valor visible**.

## 5 · P-18 · `Pildora`
`Pildora({fondo, relleno, hijo})` (radio 999) para las píldoras de `piezas_tienda`, `panel_evidencia`, `piezas_apelacion`, `piezas_jefe` y `pantalla_jefe` (2). `PildoraComodin`, `PildoraPlazo` y `PildoraRepaso` pueden quedar como envoltorios o usarla por dentro si coincide exactamente; si no, déjalas.

## Reglas del lote
- Un componente nuevo solo se crea con **3 usos o más** (aquí los 4 patrones lo cumplen). Cada uno con su comentario de documentación y **una entrada en la galería** (`AgarreHoja`, `BotonIconoCaja` y `Pildora`; `mostrarAviso` está exenta).
- No cambies medidas, colores, textos, foco, semántica ni animaciones. La auditoría (`test/auditoria/`) debe pasar **sin tocar sus escenas**; las demás pruebas solo cambian si un símbolo borrado o hecho privado lo exige (anótalo).
- No toques reglas del juego, repositorios ni mocks. Sin dependencias nuevas.
- Actualiza el grafo: nodos COMP-* nuevos (`AgarreHoja`, `BotonIconoCaja`, `Pildora`, `mostrarAviso`), obsoletos y el registro de cambios; y la tabla de líneas de `09-duplicacion.md` (sección «Resultados por lote», nueva, con **líneas de `lib/` antes y después** del lote).

## Archivos permitidos
`lib/componentes/`, `lib/core/textos/textos.dart`, `lib/core/adaptativo/clase_pantalla.dart`, `lib/app/` (rutas y la pantalla pendiente), las pantallas de `lib/funciones/` solo para llamar a los componentes nuevos, la galería, `test/` solo para lo que un símbolo borrado o privado exija y para pruebas nuevas de los componentes, y `ai/`.

## Criterios de aceptación
- [ ] Código muerto borrado (con la comprobación de referencias en `lib/` y `test/`).
- [ ] `mostrarAviso`, `AgarreHoja`, `BotonIconoCaja` y `Pildora` creados, usados en todos los lugares del catálogo y con pruebas y galería (salvo `mostrarAviso`).
- [ ] Las 21 clases públicas solo-locales ahora privadas (o anotadas las excepciones).
- [ ] Líneas de `lib/` antes y después en `09-duplicacion.md` (ahorro esperado ≈ 200–280).
- [ ] `dart format`, `flutter analyze` limpios y toda la suite verde (≥ 3025 pruebas); auditoría sin tocar.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas antes y después, número de pruebas, qué clases públicas no se pudieron hacer privadas y por qué, textos que no se borraron por usarlos una prueba, y dudas numeradas (D1, D2…).
