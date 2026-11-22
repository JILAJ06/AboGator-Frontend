# Reporte
- **Tarea:** T-15g · Teclado y tinte del mazo
- **Rama:** `15g-teclado-y-tinte-del-mazo`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge a `develop`.

## Resumen
- **El teclado y el tinte del mazo viven ahora en un solo lugar**, compartido por el juego, el Examen y el juicio:
  - `teclearMazo(MazoSwipeState mazo, KeyEvent evento)` maneja las flechas, Enter y Esc.
  - `TinteArrastre(arrastre:)` pinta el tinte del arrastre.
  - Las dos piezas están al final de `lib/funciones/juego/mazo_swipe.dart`.
- **Cada pantalla conserva sus guardias y extras, en el mismo orden.** El `Focus(autofocus: true, skipTraversal: true)` y el `Stack` siguen donde estaban.
- **Cero cambios de comportamiento:** mismas teclas, mismo foco, mismas claves (`pantalla-decision`, `tinte-urgencia`, `tinte-<veredicto>`).
- **Líneas de `lib/`:** 35 263 → **35 226 (−37)**. **Puntos de cambio:** teclado del mazo 3 → 1 y tinte del arrastre 3 → 1.
- **Pruebas:** 3309 → **3324** (15 nuevas). No cambió ninguna prueba existente, y la auditoría (incluida `acciones_de_tocar_test.dart`) pasa sin tocar sus escenas.

## Antes de empezar: la rama no tenía la T-15f
- `15g-teclado-y-tinte-del-mazo` se creó desde `develop` antes de que entrara el PR #33 (T-15f): su base era `77814c3`.
- Traje `origin/develop` a la rama con el commit «Trae a la rama la T-15f ya integrada en develop».
- Hubo conflictos en `ai/grafo.md` y en `ai/siguiente.md`:
  - **`siguiente.md`:** me quedé con la T-15g.
  - **Grafo:** me quedé con las filas de la rama (T-15f hecha, T-15g en curso y T-15d).
  - **Registro de cambios:** conservé las tres entradas en orden.
- Así, el PR no choca con `develop` y las líneas se miden desde el estado real (35 263, con la T-15f).

## Qué quedó en cada pantalla
| Pantalla | `_alTeclear` (en este orden) | `Stack` |
|---|---|---|
| Juego (`pantalla_juego.dart`) | solo pulsar o mantener → mazo sin montar → `teclearMazo`. El comentario «Enter activa el botón de veredicto con foco» sigue arriba y sigue valiendo. | `_envolver`: `TinteArrastre` y el cuerpo |
| Juicio (`pantalla_juicio.dart`) | solo pulsar o mantener → mazo sin montar o `_resolviendo` → `teclearMazo` | `TinteArrastre` y la composición |
| Examen (`pantalla_jefe.dart`) | solo pulsar o mantener → mazo sin montar o fase distinta de `decision` → tecla P (solo `KeyDownEvent` y con tiempo extendido) → `teclearMazo` | tinte de urgencia (sin cambios, primero) → `TinteArrastre` → composición |

- `teclearMazo` vuelve a comprobar «solo pulsar o mantener». En las pantallas es redundante, pero así la función vale sola y se puede probar sola; el orden de cada pantalla no cambia.
- `TinteArrastre` es un `StatelessWidget` que devuelve el mismo `Positioned.fill` con `ValueListenableBuilder` y `TinteVeredicto`. El `Stack` lo trata igual que antes.

## Por qué no `MarcoMazo`
- El catálogo proponía un widget que envolviera `Focus` y `Stack`. No lo hice:
  - En el Examen, el `Focus` va dentro del `Scaffold` con la clave `pantalla-decision`, y el tinte de urgencia va antes del de arrastre.
  - En el juego, el `Focus` está en `_envolver`; en el juicio, directo en el `build`.
- Envolver todo obligaba a meter esas diferencias como parámetros. Con dos piezas pequeñas, cada `Focus` y cada `Stack` se quedan donde estaban, como pide `siguiente.md`.

## Medición (P-14)
| Pieza | Quitado en las pantallas | Pieza nueva | Neto | Puntos de cambio |
|---|---|---|---|---|
| `teclearMazo` | −66 (22 por pantalla) | +34 | **−32** | 3 → 1 |
| `TinteArrastre` | −24 (8 por pantalla) | +22 | **−2** | 3 → 1 |
| Importaciones | −6 (`tinte_veredicto` y `logica_swipe`, en cada pantalla) | +3 (`foundation`, `services` y `tinte_veredicto` en `mazo_swipe.dart`) | **−3** | — |
| **Total** | | | **−37** | 6 → 2 |

- **Estimado en `09`: ≈ −75.** Salió menos porque cada pantalla conserva sus guardias y porque las dos piezas llevan documentación. El beneficio principal es tener un solo lugar para cambiar el teclado del mazo.
- **`test/`:** 20 452 → 20 629 (+177, solo la prueba nueva).

## Pruebas nuevas
- **Archivo:** `test/funciones/juego/teclado_mazo_test.dart` (15 pruebas).
- **`teclearMazo`**, con un doble de `MazoSwipeState` (`Fake`) que anota lo que se le pide, sin cambiar la API de `MazoSwipe`:
  - Cada flecha previsualiza su veredicto al pulsar y al mantener, y devuelve `handled`. También previsualiza si ya había una previsualización.
  - Enter y NumpadEnter confirman la previsualización; sin ella, devuelven `ignored` y no hacen nada.
  - Esc cancela la previsualización; sin ella, devuelve `ignored`.
  - Soltar cualquiera de esas teclas y pulsar teclas ajenas (P, espacio, Tab) devuelve `ignored`, con o sin previsualización.
- **`TinteArrastre`**, en tema claro y oscuro:
  - Sin tinte en reposo.
  - Con cada veredicto, la clave `tinte-<veredicto>`, el color del veredicto con opacidad `progreso × 0.10` y el tamaño de toda la zona.
  - Sin tinte otra vez al soltar.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3324 pruebas**.
```
+3324: All tests passed!
```
- Antes de la suite completa corrí juego, Examen, apelaciones y la auditoría: 2434 pruebas en verde, con `jefe_test` (tecla P), `veredicto_test`, `juicio_test` y la auditoría de teclado.

## Documentación y grafo
- **`ai/conocimiento/09-duplicacion.md`:**
  - P-14 marcado como hecho.
  - La fila de la T-15g queda con la rama y el resultado reales.
  - En «Resultados por lote» agregué la T-15g con la tabla por pieza, por qué no se hizo `MarcoMazo` y las pruebas nuevas.
- **`ai/grafo.md`:**
  - MAZO-SWIPE `en curso`: su descripción suma las dos piezas, y sus relaciones, las tres pantallas y la prueba. CODIGO-PANT-10, CODIGO-PANT-22, CODIGO-PANT-27 y DOC-09 ya estaban `en curso`.
  - **Nodo nuevo:** TEST-TECLADO-MAZO.
  - **Obsoletos:** ninguno.
  - Entrada nueva en el registro de cambios.

## Dudas
- **D1.** La rama se creó antes de que la T-15f entrara a `develop`. La integré con un commit de merge («Trae a la rama la T-15f ya integrada en develop»). Si prefieres que las ramas se creen después del merge, o que use rebase, dímelo.
- **D2.** `teclearMazo` repite la comprobación de «solo pulsar o mantener» que cada pantalla ya hace primero. Quitarla de las pantallas ahorraría 3 líneas, pero cambiaría el orden de las guardias. Aunque esas guardias no tienen efectos, la dejé por la regla del orden exacto. ¿La quitamos?
- **D3.** Con la T-15g, la T-15 suma −326 en `lib/` (T-15b −76, T-15c −23, T-15e −80, corrección −18, T-15f −92, T-15g −37). Solo queda la T-15d, que toca únicamente `test/`.
