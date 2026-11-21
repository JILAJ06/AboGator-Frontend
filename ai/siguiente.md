# T-13 · Accesibilidad y pulido (WCAG 2.1 AA)

**Rama:** `13-accesibilidad-y-pulido` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-13**).
**Figma:** solo si una corrección necesita una medida; el archivo es `SYNAyUal3xVk4k8SEBEb7f`. No se rediseña nada.

## Objetivo
Es la **auditoría de toda la app** (móvil y tablet) contra WCAG 2.1 AA, y el **pulido** que fuimos anotando. Hasta ahora cada tarea cuidó su accesibilidad; esta las revisa **todas juntas** con pruebas automáticas, corrige lo que falle y deja documentado el resultado. **No se agrega ninguna función nueva ni se cambian reglas del juego.**

## Parte A · Pulido pendiente (hazlo todo; cada punto con su prueba)
1. **Foco tras los diálogos de Tienda y Ajustes:** al cerrar el diálogo (confirmar o cancelar), el foco vuelve al control que lo abrió (la tarjeta de compra o la fila del ajuste).
2. **Diálogo "Salir del examen":** agrega "El tiempo sigue corriendo." (la misma regla que ya aplica el reloj); el botón fantasma "Seguir en el examen" lleva el foco inicial.
3. **Barra de progreso del examen:** el relleno va con `accionSecundaria` (hoy usa otro color); contraste ≥ 3:1 contra la pista.
4. **Verificar 26b (orden de foco del juego):** móvil: Salir → progreso/HUD → tarjeta → botones de veredicto (Ilegal, Escalar, Condicional, Legal) → comodines. Tablet: Salir → Pausa → tarjeta → botones → comodines (panel lateral solo lectura). Una prueba por pantalla de juego (juego, juicio, Examen) en móvil y en 1194×834.
5. **Onboarding en tablet:** además de los botones, se puede **deslizar** entre las páginas (como en móvil); con "Solo botones" activo, no.
6. **La tarjeta se queda con su sello mientras la hoja está abierta (tablet):** en Figma (T12, T14…) la tarjeta no sale volando al confirmar; se queda a la izquierda con su sello y se va **al cerrar la hoja**. Aplica solo con `ClasePantalla.ancho` y en el juego, el juicio y el Examen. **Es la única parte que toca `MazoSwipe`:** no cambies cuándo se calcula ni se guarda la respuesta (el estado, el veredicto y el orden de eventos son los mismos); solo cambia **cuándo se anima la salida**. En móvil y 600–959 todo igual. Con "Reducir animaciones" la tarjeta simplemente desaparece al cerrar la hoja. Prueba con el estado intermedio (hoja abierta, tarjeta visible con sello) y con teclado y "Solo botones".
7. **Chip del golpe en T28 (Examen, tablet):** vuelve a medir T28c `101:5420` y, si Figma lo muestra sobre la tarjeta "El Jefe" del panel lateral, colócalo ahí; si no lo muestra distinto, déjalo como está y dilo en el reporte.
8. **Confeti con ventanas angostas:** las piezas se colocan **en proporción al panel** (no en píxeles de 1194) para que ninguna quede fuera con paneles menores de 597.
9. **`saldoJuegoProvider`:** muévelo de `pantalla_juego.dart` a un archivo compartido (p. ej. `lib/funciones/juego/saldo_juego.dart`) y actualiza los imports (juego y Examen).
10. **Anuncio de selección en el Buzón:** que el anuncio "Seleccionada: …" no se repita cuando se vuelve a seleccionar la fila ya seleccionada ni cuando solo cambia el foco; una vez por cambio real.
11. **Consejo de la Tienda según el inventario** *(opcional, solo si cabe sin riesgo)*: hoy es un texto fijo; si el usuario ya tiene el máximo de un comodín, sugerir otro. Si no queda claro, no lo hagas y déjalo anotado.

## Parte B · Auditoría automática de toda la app
Crea **un conjunto de pruebas de auditoría** (`test/auditoria/`) que recorra **todas las pantallas** (las 30 vistas de Figma en sus estados principales, más Ajustes y las hojas/diálogos) y verifique, cada una en **360×640 y 390×844 (móvil), 834×1194 y 1194×834 (tablet)**, **claro y oscuro**, y **texto al 100 % y 200 %** (más el 160 % de Ajustes):
- **Sin desbordes** (`RenderFlex overflowed`, excepciones de layout).
- **Objetivos táctiles**: `androidTapTargetGuideline` (≥ 48) e `iOSTapTargetGuideline` (≥ 44) en todo lo interactivo. Lo que no llegue (íconos pequeños, chips) debe tener `MaterialTapTargetSize`/relleno táctil; no cambies el diseño visual, amplía la zona táctil.
- **Etiquetas**: `labeledTapTargetGuideline`: ningún control sin nombre accesible. Imágenes decorativas excluidas de la semántica; Sarko con descripción solo si aporta.
- **Contraste**: `textContrastGuideline` donde se pueda y, además, una **prueba de contraste de todos los pares de tokens usados** (texto sobre fondo, estados sobre superficie, foco sobre fondo) en claro y oscuro: texto ≥ 4.5:1, texto grande y componentes ≥ 3:1. Un solo archivo con la tabla de pares y su razón calculada.
- **No depender solo del color**: cada veredicto, indicador y estado lleva también texto o ícono (sello, etiqueta, flecha).
- **Foco visible**: anillo de foco en todo control enfocable (teclado) y que no quede oculto por una barra o una hoja.
- **Teclado**: recorrido con Tab / Shift+Tab sin trampas (modales encierran y devuelven el foco); Enter/Espacio activan; Esc cierra lo descartable; flechas en el juego y en la lista del Buzón.
- **Reducir animaciones, háptica y "Solo botones"**: ninguna pantalla depende del arrastre ni del movimiento para funcionar (cada gesto tiene alternativa de un toque).
- **Orientación**: ninguna pantalla se bloquea en una sola orientación en tablet; al rotar a mitad del Buzón, del juego o del Examen se **conserva el estado** (prueba con `tester.view` cambiando de 1194×834 a 834×1194).
- **Tiempo**: el Examen con "Tiempo extendido" ofrece pausa; ningún otro límite de tiempo nuevo.

Cada fallo encontrado se **corrige** (sin cambiar el diseño visual salvo lo mínimo para cumplir) y la prueba queda como regresión. Lo que no se pueda corregir sin rediseñar va al reporte como **D#** con la razón.

## Parte C · Documento de accesibilidad
Crea `ai/conocimiento/08-accesibilidad.md` con: la **matriz WCAG 2.1 AA** (criterio → cómo se cumple → pantallas/pruebas que lo verifican, y cuáles quedan **solo manuales**), la tabla de **contrastes** de tokens, el **orden de foco** de cada pantalla compleja, las **alternativas al gesto** y los **atajos de teclado**. Incluye una **lista de verificación manual** para el usuario (TalkBack en Android, VoiceOver en iOS, teclado físico en tablet, texto grande del sistema, rotación y modo oscuro) con los pasos concretos por flujo (acceso, un sprint, Buzón, Examen). Añádelo al índice de conocimiento si existe uno.

## Archivos permitidos
Todo `lib/` (solo para corregir lo que la auditoría o los puntos A pidan), `lib/core/textos/textos.dart`, `test/` (incluye `test/auditoria/` y el ayudante `tamano_pantalla.dart`), la galería y la documentación de `ai/`. **No toques** las reglas del juego, los repositorios ni los mocks, ni el diseño (colores, tamaños, textos) salvo lo estrictamente necesario para cumplir el criterio y lo que pidan los puntos A. **Sin dependencias nuevas.**

## Criterios de aceptación
- [ ] Los puntos 1 a 10 de la parte A están hechos y probados (el 11 es opcional).
- [ ] La auditoría automática recorre todas las pantallas en los 4 tamaños × 2 temas × 100 % y 200 % de texto y pasa.
- [ ] Una tabla de contrastes con todos los pares de tokens y su razón; todos cumplen AA o están explicados en el reporte.
- [ ] `08-accesibilidad.md` con la matriz, el orden de foco y la lista de verificación manual.
- [ ] La tarjeta del juego en tablet se queda con su sello hasta cerrar la hoja, y las 1281 pruebas previas siguen verdes (las del móvil sin cambiar de tamaño).
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Dudas numeradas (D1, D2…), decisiones propias, **la lista de fallos que encontró la auditoría y cómo se corrigieron**, lo que queda solo para prueba manual y una nota para la T-14 con lo que viste que depende del servidor (hora, conectividad, fechas, etc.).
