# Reporte
- **Tarea:** T-12c · Tablet: zona de juego con panel lateral y hojas laterales
- **Rama:** `12c-tablet-juego`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- **Comparé contra Figma** con el conector (solo lectura): T10 `97:772`, T12 `97:1563`, T14 `97:2660`, T16 `98:2894`, T18 `98:3819`, T10b `98:4108` y T10c `98:4367`.
- **Prueba en el navegador** (web compilada a 1194×834, cuenta de prueba del mock en localhost): el sprint 3 se ve como T10 y, al responder, la hoja de veredicto como T12. Ahí encontré y corregí que la hoja salía con subrayados amarillos (al diálogo le faltaba un `Material`).

## Qué se hizo
1. **Composición de tablet** (solo a partir de 960; `_JuegoTablet` en `pantalla_juego.dart`), sin riel:
   - **Barra de juego de tablet** (`BarraJuegoTablet`): x 24, y 8, ancho de la ventana − 48, alto 64, separación 20; Salir y **Pausa** circulares de 48 (ícono de 22), progreso con Etiqueta y barra de 12, y el HUD con racha, monedas y vidas.
   - **Zona izquierda** (de 24 a ventana − 424): la tarjeta de **380 × 470** con su pila (los 20 de la pila debajo) centrada; en 1194 queda en (207, 108). Debajo, los botones de veredicto (mismo orden y medidas) y, 16 más abajo, los comodines o las respuestas guardadas. Si la ventana es más baja, la tarjeta se encoge hasta el mínimo del móvil y la pantalla se desplaza.
   - **Panel lateral** de 376 a 24 del borde (x 794 en 1194), con separación 16: **Tu Startup** (indicadores con sus cambios y la nota), **contexto del sprint** ("MÓDULO 1 · SPRINT 3", título y objetivo real) y **atajos de teclado**.
   - El tinte del arrastre cubre toda la ventana; las flechas, Enter y Esc funcionan igual.
   - Con **texto grande (más de 150 %)** todo pasa a una columna que se desplaza: zona de juego y, debajo, el panel (hasta 640 de ancho).
2. **Hojas laterales** (`HojaLateral` en `lib/componentes/`): veredicto (correcto, bonus, parcial, incorrecto y Amparo), evidencia, justificación y Abogado Senior se abren a la derecha (376 de ancho, a 24 del borde derecho y 22 del inferior, con el alto de su contenido y hasta y 88). Se usa `showGeneralDialog` con el mismo velo, entrada desde la derecha de 280 ms (curva `easeOut`) y sin movimiento con "Reducir animaciones".
   - **El contenido no cambia:** los paneles leen `HojaLateral.enHoja` y solo cambian la forma (cuatro esquinas de 28 y borde de 1; relleno inferior de 34 sin la zona segura).
   - **Descarte igual que en móvil:** veredicto y justificación no se cierran con Esc, atrás ni tocando fuera; evidencia y Abogado sí, y el foco vuelve a su control de origen.
   - Cada hoja se anuncia como contenedor: "Retroalimentación", "Evidencia", "Justificación" o "Abogado Senior".
3. **Entre 600 y 959:** el juego del móvil centrado con ancho máximo de 440 y la hoja inferior de siempre, también de 440 como máximo y centrada. **En móvil no cambia nada.**
4. **Pausa** (solo tablet): "Juego en pausa" (centrado, 440) con "Seguir jugando" y "Salir del sprint", que abre la misma confirmación de Salir.
5. **Galería:** "Tu Startup", contexto, atajos y una `HojaLateral` con un panel.

## Medidas que tomé de Figma
- **Zona de juego** (igual en todos los marcos): barra en (24, 8) de 1146 × 64; tarjeta de 380 × 470 en (207, 108); pila 1 de 356 en (+12, +10) al 80 % y pila 2 de 332 en (+24, +20) al 50 %; acciones de 333 × 90 en (230.5, 594); comodines de 349 × 48 en (222.5, 700).
- **Panel lateral:** x 794, 376 de ancho. Tu Startup en y 88 (relleno 16, título H3, indicadores de 342 a 12, nota a 12; 154 de alto, 170 con cambios); contexto 16 debajo (relleno 20, separación 12, 142 de alto); atajos 16 debajo (relleno 16, separación 8, 130 de alto).
- **Hojas** (x 794, 376 de ancho, todas terminan 22 arriba del borde inferior): T12 veredicto con bonus en y 291 (489 de alto); T14 incorrecto en y 339 (441); T16 evidencia en y 311 (469: asa, título de 26, instrucción de 60, snippet de 222 y botón de 52 con separación 14); T18 justificación en y 250 (530; opciones de 342 de ancho); T10c Abogado en y 353 (427). Relleno 24 por lado (25 con el borde).
- **Velo:** de pantalla completa (Figma lo pone sobre toda la ventana, también sobre la tarjeta).
- **T10b Lupa:** no tiene hoja; la etiqueta "Lupa de Auditor: palabras trampa resaltadas" (308 × 28) va sobre el borde de la tarjeta, como en el móvil.
- No medí aparte T11, T11b, T11c, T13, T12b, T12c, T14b, T15, T16b ni T17: comparten la misma composición y su contenido es el del panel móvil que ya se reutiliza.

## Decisiones propias (no vienen de Figma)
- **Pausa:** solo en tablet; no detiene nada (el sprint no tiene reloj). Texto: "Tus respuestas están guardadas. Sigue cuando quieras: este sprint no tiene reloj."
- **Contexto del sprint:** el objetivo real del sprint con la primera letra en mayúscula (`LogicaJuegoTablet.objetivo`); Figma trae un texto de ejemplo.
- **Monedas del HUD:** el saldo al abrir el sprint (de la Tienda) más lo ganado en el sprint, porque el saldo real solo se actualiza al guardar el resultado.
- **Entrada de la hoja:** desde la derecha en 280 ms con `easeOut`; sin movimiento con "Reducir animaciones".
- **600 a 959:** juego y hoja inferior de 440 como máximo, centrados (no hay panel lateral).
- **Texto grande:** con más de 150 % el panel lateral pasa debajo y la pantalla se desplaza.

## Accesibilidad
- Orden de foco: Salir → Pausa → tarjeta → botones de veredicto → comodines (el panel lateral es de solo lectura). La barra de progreso conserva su semántica ("Sprint 3 · Tarjeta 1 de 10").
- Las hojas son modales (la ruta encierra el foco) y se anuncian con su etiqueta; el foco inicial va al título del panel, como en el móvil.
- **Contrastes AA verificados en pruebas (claro y oscuro):** `textoSecundario` y `textoPrimario` sobre `fondoSuperficieAlt` (atajos), `textoAcento` sobre `fondoSuperficie` (contexto) y los cuatro colores de veredicto sobre `fondoSuperficie`.
- **Sin desbordes** en 1194×834, 834×1194 y 600×960 al 100 % y 200 %, claro y oscuro, también con la hoja abierta.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (1219 pruebas; antes de T-12c, 1188):
```
+1219: All tests passed!
```
- **Pruebas nuevas en `juego_tablet_test.dart` (31):** barra de tablet (posición, Salir y Pausa de 48, texto del paso), zona de 380 × 490 en x 207 con su pila y botones centrados en el orden de Figma, panel lateral con objetivo real y atajos, objetivo con mayúscula; hoja de veredicto (posición, etiqueta, no se descarta con Esc ni tocando fuera, sigue al cerrarla), evidencia (Esc y tocar fuera), justificación (no se descarta y lleva al veredicto en la misma hoja), Abogado (atrás), "Reducir animaciones", flecha + Enter; pausa (seguir y salir con confirmación); **un sprint completo en tablet con los tres tipos de tarjeta hasta "Sprint completado"**; 834×1194, 600×960 y móvil con hoja inferior (≤ 440 centrada en tablet); sin desbordes (12 casos); contrastes; `HojaLateral.enHoja`.
- **Ajustes en pruebas existentes:** solo la galería (2 `IndicadoresStartup` y las piezas nuevas). Las pruebas del juego móvil siguen verdes **sin cambiar de tamaño**.

## Grafo
- **Actualizados (`en curso`):** CODIGO-PANT-10, COMP-BARRA-JUEGO, COMP-PANEL-VEREDICTO, COMP-PANEL-EVIDENCIA, TEXTOS, PANT-GALERIA y TEST-GALERIA.
- **Nuevos:** COMP-HOJA-LATERAL, COMP-PANEL-LATERAL-JUEGO, TEST-JUEGO-TABLET y DEC-PAUSA.
- PANT-10 a PANT-18, 10b y 10c anotan su vista de tablet.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Para T-12d
- **`HojaLateral(etiqueta:, child:)`** aloja cualquier panel a la derecha. Para el contraargumento del Jefe: si su panel usa `ContenedorPanelModal`, o lee `HojaLateral.radioDe/bordeDe/rellenoInferior`, se adapta solo. Para mostrarla: `showGeneralDialog` con `barrierColor: EfectosApp.colorVelo`, la duración `EfectosApp.duracionPanel` y la entrada desde la derecha (ver `_mostrarPanel` en `pantalla_juego.dart`).
- **`BarraJuegoTablet`** ya tiene la forma de la barra de tablet; el Examen puede reutilizarla (le falta un texto de paso propio, como `paso` en `BarraJuego`).
- Las pantallas de resultado (19, 19b, 20) siguen como en el móvil: les toca a T-12d.

## Dudas
- **D1.** En Figma (T12, T14…) la tarjeta **sigue visible con su sello** mientras está abierta la hoja; en la app la tarjeta sale volando al confirmar (es la lógica de `MazoSwipe`, la misma del móvil) y no la cambié para no tocar la mecánica del juego. ¿Se cambia el vuelo en tablet (la tarjeta se queda con el sello hasta cerrar la hoja)?
- **D2.** El HUD de tablet muestra saldo + ganado en el sprint. ¿Prefieres solo el saldo de la Tienda?
- **D3.** Figma no muestra la pausa en ningún diálogo; ¿el texto del diálogo te parece bien?
- **D4.** Figma pone el velo también sobre la tarjeta (y lo seguí). La tarea mencionaba dejar libre la tarjeta "si Figma así lo muestra"; Figma no lo muestra. ¿Correcto?
