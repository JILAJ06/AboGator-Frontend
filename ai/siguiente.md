# T-13b · Correcciones tras la revisión

**Rama:** `13b-pantallas-cuenta-y-legal` (la misma; el PR sigue abierto o se abre al terminar)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-13b**, ronda 2: reescríbelo completo).

Todo lo demás de la T-13b está aprobado. Solo hay que corregir lo siguiente, que salió de volver a medir Figma (T34 `150:5709`).

## Respuestas a tus dudas
- **D1** Bien: 34 tras el primer registro, una vez.
- **D2** Bien: ruta de primer nivel.
- **D3** Bien: los enlaces bajo las casillas.
- **D4** **No coincide con Figma; corrígelo (A).**
- **D5** Figma **no** lleva íconos en las filas de 34: quítalos (B).
- **D6** Bien: "Ahora no" conserva los interruptores como estén.
- **D7** Las filas PANT-31 a PANT-34 ya las agregué yo al grafo. `PantallaPendiente` se borra en la T-15.
- **D8** No hay dirección real todavía: deja "el correo del equipo del proyecto"; el usuario la pondrá al validar el texto legal.
- Tus decisiones propias (insignia de 96 en la columna de recuperación en tablet, 31d/31e sin atrás, íconos aparte, `DEC-NOTIF-RUTA`) están aprobadas, salvo el ícono de las filas.

## A · Notificaciones de racha en tablet (T34): panel de marca, no columna sola
Figma 1194×834 (horizontal):
- **Panel izquierdo de 597 × 834** (`fondo/destacado`, igual que el panel de ilustración del onboarding): círculo de 340 centrado (x128, y250), Sarko `Alegre` de **230 × 301** (x183, y262) y una **insignia de 84** `accionPrimaria` con el ícono `flame` de 40 (x385, y232, arriba a la derecha del círculo). Sin logo ni lema.
- **Columna de 470** a la derecha (x661, y200, alto 466), **sin** Sarko ni botón atrás dentro de ella: Título "Protege tu racha" (y0), descripción (y48), tarjeta de 3 filas (y104; filas de 65, ancho 470; texto en x20 con ancho 364; interruptor de 52 × 32 en x396), nota (y316), "Activar notificaciones" (y346) y "Ahora no" fantasma (y414).
- **Atrás en tablet:** como no hay botón dentro de la columna, ponlo en el panel izquierdo (esquina superior izquierda, 48 × 48, con margen 32), igual que en el Registro de tablet.
- Reutiliza `DisposicionAccesoTablet`/el panel de ilustración si encaja; si no, haz el panel como pieza propia en `lib/componentes/` y dilo en el reporte (T-15).
- **Tablet vertical (834×1194) y 600–959:** el panel pasa a franja arriba (como el Login) con la misma ilustración reducida, y la columna de 470 debajo; usa el mismo patrón que ya aplicaste en Recuperar.
- La hoja del selector (34c) en tablet sigue siendo el diálogo de 440 centrado sobre un velo de 40 %; ya está bien.

## B · Filas de 34 sin íconos
Quita `flame`, `gavel` y `clock` de las tres filas (móvil y tablet). Móvil: texto en x16 con ancho 244 e interruptor en x272; tablet: texto en x20 con ancho 364 e interruptor en x396. Deja el parámetro de ícono si `FilaAjuste` lo comparte con Ajustes (solo no lo pases aquí). Actualiza las pruebas y la auditoría.

## Archivos permitidos
`lib/funciones/notificaciones/`, `lib/componentes/` (solo el panel de ilustración si lo extraes), `panel_marca.dart` si hace falta, galería, `test/` y `ai/`. Nada más.

## Criterios de aceptación
- [ ] T34 en tablet horizontal: panel de 597 con círculo, Sarko 230 × 301 e insignia de 84 con flame; columna de 470 a la derecha, atrás en el panel; vertical y 600–959 con franja arriba.
- [ ] Filas de 34 sin íconos en móvil y tablet.
- [ ] Auditoría (4 tamaños × claro/oscuro × 100/160/200 %) y foco visible siguen verdes con los cambios; análisis y formato limpios; todas las pruebas verdes.
- [ ] Commits sin prefijo y sin menciones a Claude.

## Para el reporte
Reescribe `reporte.md` completo (ID T-13b), con lo corregido, el número de pruebas y cualquier D# nuevo.
