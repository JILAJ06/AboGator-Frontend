# T-06b · Ajustes tras la revisión (misma rama)

**Rama:** `06b-fin-de-sprint` (la misma; no crear otra)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

La T-06b está aprobada salvo estos dos ajustes pequeños. Hacerlos, reescribir `reporte.md` (ID **T-06b**, misma rama, con una sección "Ajustes de la revisión") y subir.

## 1. Regla de estrellas (respuesta a D1)
Figma 19 muestra **8/10 aciertos con 2 estrellas llenas**, así que la regla cambia: **≥ 90 % = 3 estrellas, ≥ 60 % = 2, menos = 1**. Actualizar `LogicaFinSprint` (`porcentajeTresEstrellas = 90`), su documentación, las pruebas (límites 89/90 % y 59/60 %, y el caso 8/10 = 2 estrellas) y cualquier prueba de pantalla que dependa de ello. Los mocks de progreso que ya traen estrellas (sprints 1 y 2 completados con 3) no cambian.

## 2. Cifra legal sin verificar (D5)
La tarjeta 3 de `spr-1-4` dice "lleva más de **dos meses** sin respuesta". La ley cambió en 2025 y no hay forma de confirmar ese plazo aquí. Reescribir el texto de la tarjeta sin cifra (por ejemplo "lleva semanas sin respuesta y ya venció el plazo legal"), con la misma respuesta correcta y la misma explicación sin números. Revisar que **ninguna otra tarjeta** de `MockTarjetas` mencione plazos, días, meses o montos legales concretos; si hay alguno, quitarlo igual y listarlo en el reporte.

## Respuestas a las demás dudas (sin cambios de código)
- D2: se queda el contorno en `borde/control` para la estrella no ganada.
- D3: los íconos de las estadísticas se quedan de contorno, como el resto de la app.
- D4: la caída del confeti queda como está.
- D6: "CASO 5" para la GPL está bien.

## Criterios de aceptación
- [ ] Estrellas con la regla 90/60 y pruebas actualizadas.
- [ ] Ninguna tarjeta con plazos o cifras legales concretas.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios.
- [ ] `reporte.md` reescrito. Commits: una frase en español, sin prefijo y **sin mencionar a Claude**. No hacer merge; el PR #10 ya existe.
