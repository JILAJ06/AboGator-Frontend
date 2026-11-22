# Reporte
- **Tarea:** T-15e-fix · Acción de tocar en controles con `excludeSemantics`
- **Rama:** `fix/15-accion-de-tocar-en-controles`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Resumen
- **Los controles exponen ahora la acción de tocar al lector de pantalla.** Antes, en 5 controles, TalkBack y VoiceOver decían «botón» pero el doble toque no hacía nada.
- **Pruebas:** 3052 → **3309**: 5 por pieza y 252 de la auditoría nueva. No cambió ninguna prueba existente.
- **Auditoría actual:** verde y sin tocar sus escenas ni sus ayudantes.
- **Cero cambios visibles:** mismas medidas, colores, claves, foco, orden de lectura y banderas.
- **Líneas de `lib/`:** 35 373 → 35 355 (−18). **`test/`:** 20 253 → 20 452 (+199, solo pruebas nuevas).

## Controles afectados (antes → después)
| Control | Dónde se ve | Antes | Después |
|---|---|---|---|
| `FilaAjuste` (`piezas_ajustes.dart:229`) | **Todas las filas de Ajustes** y las 3 de Notificaciones de racha | `button` o `toggled` sin `onTap` | `onTap: accion` (sin acción si la fila no tiene `alPresionar`, como antes) |
| `OpcionTamano` (`piezas_ajustes.dart:287`) | Las 4 opciones del selector de tamaño de texto | `button` + `checked` + grupo, sin `onTap` | `onTap: alElegir` |
| `FilaMenu` (`piezas_perfil.dart:203`) | Menú del Perfil (incluido «Cerrar sesión») y de Ajustes | `button` sin `onTap` | `AccionEnfocable.boton` |
| `BotonIconoCuadrado` (`piezas_perfil.dart:258`) | Ajustes del Perfil, atrás de Ajustes y pausa del Examen | `button` sin `onTap` | **Envoltura de una línea de `BotonIconoCaja`** (48 × 48, radio 12, borde, ícono de 20) |
| `BotonPrecio` (`piezas_tienda.dart:104`) | Precio de cada artículo de la Tienda | `button` + `enabled`, sin `onTap` | `AccionEnfocable.boton` con `habilitado`; sin acción mientras compra o si está deshabilitado |

**Los que quedaron fuera en la T-15e ya tenían acción:** casilla, chip, opción de justificación, comodines y el interruptor de Ajustes (`piezas_ajustes.dart:93`). La única excepción en Ajustes es la fila sin acción (`:217`), que no es botón y se lee solo como texto.

## Cómo lo encontré
- **Búsqueda en el código:** todos los `Semantics` con `excludeSemantics: true` y semántica de botón, enlace, `checked` o `toggled`. Había 18; los 5 de la tabla no tenían `onTap`.
- **Auditoría nueva** `test/auditoria/acciones_de_tocar_test.dart`:
  - Recorre las mismas escenas de la auditoría con sus ayudantes, sin cambiarlos: 63 escenas en los 4 tamaños, 252 pruebas.
  - Falla si un nodo de botón o enlace, habilitado, visible y con etiqueta, no tiene `SemanticsAction.tap`.
  - Uso tema claro y texto al 100 %: la semántica no cambia con el tema ni con la escala.
  - **No encontró casos nuevos** además de los 5.
  - **Comprobación:** con el código de antes falla en 19 combinaciones (selector de tamaño, pausa del Examen, filas de Ajustes y de Notificaciones). Con la corrección pasan las 252.
  - Pude recorrer todas las escenas sin cambiar ninguna.
- **Pruebas por pieza** (`test/componentes/acciones_de_tocar_componentes_test.dart`, 5):
  - Para cada control, el nodo tiene la acción de tocar, y al usarla como lo hace el lector (`performAction(tap)`) llama a `alPresionar`.
  - Deshabilitados (`FilaAjuste` sin acción, `BotonPrecio` sin acción o comprando), no la tienen.
  - `BotonIconoCuadrado` sigue midiendo 48 × 48.

## Documentación
- `ai/conocimiento/08-accesibilidad.md`, en «Cómo se audita», tiene una línea nueva: todo control con semántica de botón debe exponer la acción de tocar; la prueba `acciones_de_tocar_test.dart` lo vigila.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3309 pruebas**.
```
+3309: All tests passed!
```

## Grafo actualizado
- **`en curso`:** COMP-PIEZAS-AJUSTES, COMP-PIEZAS-PERFIL, COMP-PIEZAS-TIENDA y DOC-08.
- **Nuevo:** TEST-ACCIONES-TOCAR.
- **Obsoletos:** ninguno.

## Dudas
- **D1.** La auditoría nueva no mira los controles sin etiqueta: esos ya los vigila `labeledTapTargetGuideline`. Tampoco los que no son botón ni enlace, como las casillas (`checked`) o los interruptores (`toggled`). Hoy todos tienen acción. ¿Extendemos la regla a casillas e interruptores?
- **D2.** La corrección cambia lo que oye el usuario con TalkBack y VoiceOver: los 5 controles ahora se pueden activar. Valdría la pena confirmarlo a mano en un dispositivo (Ajustes, Perfil, Tienda y la pausa del Examen) y anotarlo en la lista de verificación manual de `08`.
