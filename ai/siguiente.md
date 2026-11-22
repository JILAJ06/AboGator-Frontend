# T-15e · Corrección: acción de tocar en controles con `excludeSemantics`

**Rama:** `fix/15-accion-de-tocar-en-controles` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-15e-fix**).
**Figma:** no hace falta.

## Problema
En la revisión de la T-15e saliste con un hallazgo (D1): `BotonIconoCuadrado` (`lib/componentes/piezas_perfil.dart`) arma su semántica como `Semantics(button: true, label: …, excludeSemantics: true, child: hijo)` **sin `onTap`**. Con `excludeSemantics: true` se descartan las acciones del hijo, así que un lector de pantalla (TalkBack, VoiceOver) anuncia «botón» pero **no puede activarlo** con el gesto de doble toque. Hay al menos 4 piezas así: `BotonIconoCuadrado` (Perfil: ajustes; Ajustes: atrás; Examen: pausa), la fila de acción de `piezas_perfil.dart` (la del `peligro`, ~220), la segunda de `piezas_perfil.dart` (~273) y `BotonPrecio` de `piezas_tienda.dart` (~158, que además usa `enabled`).

Es un fallo de accesibilidad real que la auditoría WCAG de la T-13 no detectó porque revisa etiquetas, foco y desbordes, no que el control tenga la acción de tocar.

## Qué hacer
1. **Busca todos los casos** en `lib/` donde un `Semantics(button: true, …)` (o `link`) con `excludeSemantics: true` **no tenga `onTap`** (y tampoco el control dentro de un `AccionEnfocable` que ya lo agregue). Lista en el reporte cada archivo:línea con el estado antes/después. Revisa también los 3 que dejaste fuera en la T-15e por llevar `checked`, `toggled`, grupo o sin `onTap` (casilla, chip, opción de justificación, comodines, Ajustes ×3, Perfil ×2, Tienda ×1): confirma si **tienen** acción o no.
2. **Agrega la acción** a cada uno: `onTap: alPresionar` (con `null` si el control está deshabilitado: ya lo respetan `habilitado`/`cargando`). Donde coincida con `AccionEnfocable.boton`, úsalo en vez del `Semantics` a mano. **No cambies** etiqueta, `enabled`, `selected`, `checked`, `toggled`, orden de foco, medidas ni nada visible.
3. **Segunda parte de la D1 de la T-15e:** con la acción ya presente, pasa `BotonIconoCuadrado` a **envoltura de una línea de `BotonIconoCaja`** (conserva su nombre, sus claves y su aspecto: 48 × 48, radio 12, borde, ícono 20). Si algo difiere, `BotonIconoCaja` lo recibe por parámetro. Las otras 3 piezas se quedan como están salvo que sean exactamente iguales.
4. **Prueba que lo demuestre** (nueva, sin tocar las existentes):
   - En `test/componentes/` (o en `marcos_y_disposiciones_test.dart` si es más natural, agregando al final) para cada pieza arreglada: con `tester.ensureSemantics()`, el nodo del botón `hasAction(SemanticsAction.tap)` cuando está habilitado, y **no** cuando está deshabilitado; y `tester.semantics.tap(...)` ejecuta `alPresionar`.
   - **Prueba de auditoría nueva** `test/auditoria/acciones_de_tocar_test.dart` que recorra **las mismas escenas** de la auditoría actual (sin modificarlas ni sus ayudantes; reutilízalos) y compruebe que **todo nodo con bandera de botón o enlace que esté habilitado y tenga etiqueta tenga `SemanticsAction.tap`**. Si encuentra más casos, arréglalos en este mismo lote (si son muchos o delicados, lístalos como D# y no los toques). Si una escena no se puede recorrer sin cambiarla, di cuál y por qué.
5. **Documenta en `ai/conocimiento/08-accesibilidad.md`** una línea nueva: «Todo control con semántica de botón debe exponer la acción de tocar; la prueba `acciones_de_tocar_test.dart` lo vigila.»

## Reglas
- Cambios **solo de semántica** (más una envoltura). Cero cambios visibles: medidas, colores, claves, foco y orden de lectura iguales; todas las pruebas existentes verdes **sin cambiar**, y la auditoría actual sin tocar sus escenas.
- No toques reglas del juego, repositorios ni mocks. Sin dependencias nuevas.
- Grafo: nodos de los archivos tocados `en curso` → `hecho` al cerrar yo; agrega TEST-ACCIONES-TOCAR y el registro de cambios.

## Archivos permitidos
`lib/componentes/` (las piezas afectadas), las pantallas de `lib/funciones/` **solo si** un control está armado allí, `test/` (nuevos), `ai/conocimiento/08-accesibilidad.md`, `ai/grafo.md` y `ai/`.

## Criterios de aceptación
- [ ] Todos los controles con `excludeSemantics` y semántica de botón o enlace exponen la acción de tocar (deshabilitados, no).
- [ ] `BotonIconoCuadrado` es envoltura de `BotonIconoCaja`, sin cambios visibles.
- [ ] Pruebas por pieza y la auditoría nueva `acciones_de_tocar_test.dart`, verdes.
- [ ] `dart format`, `flutter analyze` limpios; suite completa verde (≥ 3052 pruebas + las nuevas); auditoría actual sin tocar.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Lista de controles afectados (antes y después), qué arregló la auditoría nueva, número de pruebas, y dudas numeradas (D1, D2…). Al mencionar el cambio, escríbelo así: «los controles exponen ahora la acción de tocar al lector de pantalla».
