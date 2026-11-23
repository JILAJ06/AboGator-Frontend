# T-15d · Ayudantes de pruebas y auditoría de acciones de tocar

**Rama:** `15d-ayudantes-de-pruebas` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15d**).
**Figma:** no hace falta. Último lote de la T-15: **solo `test/` y `ai/`; no toques `lib/`.** Mandan las reglas de `ai/conocimiento/09-duplicacion.md` y lo aprendido en los lotes anteriores.

## Objetivo
Quitar la duplicación de las pruebas con ayudantes comunes (T-01, T-02 y T-03 del catálogo) y, de paso, extender la auditoría de acciones de tocar a casillas e interruptores (D1 de la corrección de accesibilidad). **El número de pruebas y lo que cada una comprueba no cambian** (salvo lo que digan D1 de T-01 y la auditoría ampliada); la T-15d es para que las pruebas sean más cortas y sin copias.

## 1 · T-01 · `probarSinDesbordes`
`test/ayudantes/sin_desbordes.dart` con `probarSinDesbordes(String nombre, Future<void> Function(WidgetTester, Size) abrir, {List<(Size, double)> casos = casosMovil})` que arma el `group('sin desbordes')` con las 6 combinaciones (390×844, 360×640 y 320×640, a 1.0 y 2.0), `textScaleFactorTestValue` y la comprobación de que no hay excepciones. Úsalo en los 9 archivos del catálogo (`perfil_test`, `ajustes_test`, `buzon_test`, `juicio_test`, `inicio_test`, `comodines_test`, `fin_sprint_test`, `tienda_test` y el que falte).
- Si algún archivo comprueba algo **extra** dentro de su matriz (otra expectativa, otro tamaño), el ayudante lo recibe por parámetro o ese archivo conserva su propia versión; no pierdas ninguna comprobación. Cuenta las pruebas antes y después de cada archivo: deben coincidir.
- Resuelve la D1 que ya anotaste en el catálogo para T-01 y dilo en el reporte.

## 2 · T-02 · Falsos y datos repetidos
`test/ayudantes/falsos.dart` con `ProgresoFalso`, `ApelacionesFalsas` (y su lista de `Apelacion(...)` de ejemplo), `HapticaFalsa`, `CronometroFalso`, el usuario `ana` y `tocar`. Elimina las copias de `inicio_test`, `mapa_test`, `buzon_test`, `sin_vidas_test`, `ajustes_test`, `jefe_test`, `juicio_test`, `comodines_test` y `ayudante_juego.dart`. Si dos copias **no son idénticas** (un falso con una diferencia útil para una prueba), el ayudante recibe esa diferencia por parámetro; no cambies lo que la prueba comprueba.

## 3 · T-03 · Bloques de tablet repetidos
Suma a `test/ayudantes/tamano_pantalla.dart` el cierre de prueba de tamaño u orientación que repiten `buzon_tablet_test`, `examen_tablet_test`, `juego_tablet_test` y `resultados_tablet_test`.

## 4 · Auditoría ampliada (D1 de la corrección)
En `test/auditoria/acciones_de_tocar_test.dart` (sin cambiar las escenas ni sus ayudantes), amplía la comprobación para que **también** valga para nodos habilitados, visibles y con etiqueta que tengan `checked` (casillas, opciones de justificación, selector de tamaño) o `toggled` (interruptores): deben tener `SemanticsAction.tap`. Hoy todos la tienen, así que debe pasar; si encuentra alguno que no, **lístalo como D#** y no lo arregles aquí (iría a una corrección en `lib/`). Actualiza la línea de `08-accesibilidad.md` que describe la regla («todo control con semántica de botón, casilla o interruptor…»).

## Reglas
- **No toques `lib/`.** Si una prueba necesita un cambio en `lib/` para poder compartirse, déjala como está y anótalo.
- Mismo número de pruebas por archivo y misma cobertura; la auditoría de escenas sin tocar; `flutter analyze` y `dart format` limpios; suite completa verde (≥ 3324 pruebas, y las de la auditoría ampliada si agregas casos).
- Los ayudantes nuevos llevan un comentario de documentación breve y, si merece la pena, una prueba mínima de sí mismos (por ejemplo, que `probarSinDesbordes` registra las 6 pruebas); no pongas pruebas por pruebas.
- Medición: líneas de `test/` antes y después, y puntos de cambio (9 matrices → 1, 4 falsos duplicados → 1). Anótalo en «Resultados por lote» de `09` y marca la T-15d como hecha.
- Grafo: nodos de los ayudantes nuevos (si el grafo lleva ayudantes de pruebas; si no, no inventes nodos), registro de cambios y estado. **Al terminar, deja la T-15 completa:** actualiza la fila de la T-15 en el plan y el grafo para que yo cierre con el merge.

## Archivos permitidos
`test/` (incluido `test/ayudantes/` y `test/auditoria/acciones_de_tocar_test.dart`), `ai/conocimiento/08-accesibilidad.md`, `ai/conocimiento/09-duplicacion.md`, `ai/grafo.md`, `ai/conocimiento/04-plan-de-tareas.md` y `ai/reporte.md`.

## Criterios de aceptación
- [ ] `probarSinDesbordes`, falsos comunes y cierre de tablet creados y usados; sin copias en los archivos del catálogo (o cada excepción justificada).
- [ ] Mismo número de pruebas por archivo; cobertura intacta.
- [ ] Auditoría de acciones de tocar ampliada a `checked` y `toggled`, verde (o D# con los controles que falten).
- [ ] `lib/` sin cambios.
- [ ] Líneas de `test/` antes y después en `09`; T-15d hecha.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Líneas de `test/` antes y después, número de pruebas por archivo tocado (antes y después), qué quedó fuera y por qué, resultado de la auditoría ampliada y dudas numeradas (D1, D2…).
