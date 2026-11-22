# T-15g · Teclado y tinte del mazo

**Rama:** `15g-teclado-y-tinte-del-mazo` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15g**).
**Figma:** no hace falta. Lote de **cero cambios visibles ni de comportamiento** y el **más delicado de la T-15** (teclado y foco del juego, el Examen y el juicio). Mandan las reglas de `ai/conocimiento/09-duplicacion.md` y lo aprendido en los lotes anteriores.

## Qué se repite (ya lo leí en el código)
Las tres pantallas con mazo tienen **`_alTeclear` casi idéntico** y **el mismo tinte detrás de la tarjeta**:
- `lib/funciones/juego/pantalla_juego.dart:376` (`_alTeclear`) y `:648` (`_envolver`).
- `lib/funciones/apelaciones/pantalla_juicio.dart:264` y `:372-384`.
- `lib/funciones/jefe/pantalla_jefe.dart:564` y `:787-810`.

La lógica compartida: ignorar eventos que no sean `KeyDown`/`KeyRepeat`; **flechas** (← ilegal, → legal, ↑ condicional, ↓ escalar) llaman a `mazo.previsualizar(...)` y devuelven `handled`; con `mazo.previa` no nula, **Enter o NumpadEnter** → `mazo.confirmar(previa)` (handled) y **Esc** → `mazo.cancelarPrevia()` (handled); en cualquier otro caso `ignored`. Y el tinte: `Positioned.fill(ValueListenableBuilder<ArrastreVisible>(valueListenable: _arrastre, builder: TinteVeredicto(veredicto: arrastre.veredicto, opacidad: arrastre.progreso * LogicaSwipe.opacidadTinte)))`.

**Diferencias que NO pueden cambiar:**
- **Juicio:** devuelve `ignored` si `_resolviendo` (antes de mirar flechas).
- **Examen:** devuelve `ignored` si `examenProvider.fase != FaseJefe.decision`; maneja la **tecla P** (solo `KeyDownEvent`, solo con `tiempoExtendido`, llama a `_examen.pausar()`) **antes** de las flechas; y en el `Stack` tiene un **tinte de urgencia** (`ColoredBox` con `estadoIlegal` y `EfectosApp.opacidadUrgencia`, clave `tinte-urgencia`) **antes** del `TinteVeredicto`. Ese tinte de urgencia es del Examen y se queda donde está.
- **Juego:** devuelve `ignored` si el mazo no existe (`_mazo.currentState == null`); el comentario de Enter/Esc («sin previsualización siguen su camino: Enter activa el botón de veredicto con foco») debe seguir valiendo.

## Diseño recomendado (más simple que `MarcoMazo` del catálogo)
No metas un widget que envuelva todo. Hazlo con **dos piezas pequeñas** en `lib/funciones/juego/mazo_swipe.dart` (o un archivo junto a él), que conservan cada guardia en su pantalla:
1. **`KeyEventResult teclearMazo(MazoSwipeState mazo, KeyEvent evento)`**: la parte común (flechas, Enter, Esc). Cada `_alTeclear` queda con **sus guardias y extras propios** (`_resolviendo`, fase del Examen, tecla P, mazo nulo) y termina llamando a `teclearMazo`. El orden de las comprobaciones debe ser **exactamente** el de hoy (por ejemplo, la tecla P del Examen va antes de las flechas).
2. **`TinteArrastre({required ValueListenable<ArrastreVisible> arrastre})`**: el `Positioned.fill` con `ValueListenableBuilder` y `TinteVeredicto`. Las tres pantallas lo usan dentro de su `Stack`; el tinte de urgencia del Examen se queda como está, delante.
Si prefieres otra forma (por ejemplo el `MarcoMazo` del catálogo) hazla solo si cumple lo anterior sin tocar el orden de foco ni las guardias; explica por qué en el reporte.

## Reglas del lote
- **Cero cambios de comportamiento.** Mismas teclas, mismas guardias, mismo orden de comprobación, mismo foco (`Focus(autofocus: true, skipTraversal: true)` se queda en cada pantalla), mismas claves y mismo árbol de widgets (la clave `pantalla-decision`, `tinte-urgencia`, etc.).
- Las pruebas existentes **no cambian** (`juego_test`, `veredicto_test`, `jefe_test` con la tecla P, `juicio_test`, `pulido_test`, la auditoría de teclado y todas las demás), **y la auditoría (incluida `acciones_de_tocar_test.dart`) pasa sin tocar sus escenas.**
- **Pruebas nuevas** para las dos piezas: `teclearMazo` con cada flecha (previsualiza y devuelve handled), Enter y NumpadEnter con y sin previsualización, Esc con y sin previsualización, eventos `KeyUp` y teclas ajenas (ignored); y `TinteArrastre` con veredicto y opacidad (tema claro y oscuro). Un mazo de prueba mínimo o un doble de `MazoSwipeState` según lo que ya usen las pruebas del mazo.
- No toques las reglas del juego (`logica_swipe`, estados), repositorios ni mocks. Sin dependencias nuevas. No cambies la API pública de `MazoSwipe` más de lo necesario.
- Mide como siempre (líneas antes y después de `lib/`, ahorro neto y puntos de cambio: **teclado y tinte 3 → 1**). Si el ahorro neto es ≤ 0, no importa: el beneficio es un solo lugar para cambiar el teclado del mazo; dilo en el reporte.
- Grafo: COMP/PANT afectados, el nodo nuevo (si lo hay) y «Resultados por lote» en `09`; marca el P-14 como hecho.

## Archivos permitidos
`lib/funciones/juego/mazo_swipe.dart` (o un archivo nuevo junto a él), `pantalla_juego.dart`, `lib/funciones/apelaciones/pantalla_juicio.dart`, `lib/funciones/jefe/pantalla_jefe.dart`, la galería solo si la pieza es visible (no lo es), `test/` (pruebas nuevas) y `ai/`.

## Criterios de aceptación
- [ ] `teclearMazo` y `TinteArrastre` (o la forma que justifiques) usados en las **tres** pantallas; las guardias y extras propios de cada una intactos y en el mismo orden.
- [ ] Todas las pruebas existentes verdes **sin cambiar**; auditoría sin tocar escenas.
- [ ] Pruebas nuevas de las piezas.
- [ ] Líneas antes y después, ahorro neto y puntos de cambio en `09`; P-14 hecho.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde (≥ 3309 pruebas).
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas antes y después, ahorro neto, qué dejaste en cada pantalla y por qué, número de pruebas y dudas numeradas (D1, D2…).
