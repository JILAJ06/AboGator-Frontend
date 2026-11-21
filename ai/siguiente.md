# T-12c · Tablet: zona de juego con panel lateral y hojas laterales

**Rama:** `12c-tablet-juego` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-12c**).
**Figma** (archivo `SYNAyUal3xVk4k8SEBEb7f`, página "Tablet · Vistas"). **T10 Tarjeta normal `97:772`** está detallada aquí. Las demás **las mides tú con el conector** y dejas las medidas en el reporte: T11 `97:1204`, T11b `97:3001`, T11c `97:3342`, T13 `97:2291` (arrastres), T12 `97:1563`, T12b `97:1922`, T12c `97:3711`, T14 `97:2660`, T14b `98:4644` (hojas de veredicto, bonus, parcial, incorrecto, Amparo), T15 `98:2569`, T16 `98:2894`, T16b `98:3207` (evidencia), T17 `98:3526`, T18 `98:3819` (justificación), T10b `98:4108` (Lupa), T10c `98:4367` (Abogado Senior). Reglas: `106:10163`.
**Ya mergeado de T-12 y T-12b que usas:** `ClasePantalla`, `Adaptativo`, `MedidasAdaptativas` (incluye `hojaLateral` = 376), `tamanoPantalla(tester, Tamano.…)` y el patrón de dos paneles de `_MapaConDetalle`.
**Nota:** T19 (Sprint completado) y T19b (Startup en quiebra) son pantallas de resultado y **pasan a la T-12d**; aquí no se tocan.

## Objetivo
El juego de un sprint en tablet: la **zona de juego** (tarjeta, botones de veredicto y comodines) a la izquierda y un **panel lateral** (indicadores, contexto y atajos de teclado) a la derecha; las **hojas laterales** de 376 para veredicto, evidencia, justificación, Abogado Senior y bonus. Misma lógica del juego (T-05 a T-09b); solo cambia la composición.

## Reglas de adaptación (Figma `106:10163`)
- **Modo foco:** en los sprints **no hay riel** (el juego ya está fuera de `MarcoPrincipal`; así se queda).
- Solo con `ClasePantalla.ancho` (≥ 960) se aplican las dos zonas y las hojas laterales. **En móvil y entre 600 y 959 el juego queda como hoy** (panel de veredicto inferior, etc.), centrado con ancho máximo si hace falta. Las pruebas existentes del juego siguen verdes sin cambiar de tamaño.
- La retroalimentación, la evidencia, la justificación, el Abogado Senior y el bonus se abren como **hoja de 376 a la derecha**; la tarjeta sigue visible con su sello y el velo baja al **40 %** (`#0B1220`, 280 ms, igual que el móvil; sin movimiento con "Reducir animaciones").

## Composición de T10 (`x` desde la izquierda de la ventana, `y` **sin** la barra de estado de 32, ya restada)
- **Barra de juego de tablet** (`BarraJuego` con medidas de tablet, Figma `93:528`): ancho `ventana − 48` (1146 a 1194), alto 64, x 24, y 8, separación 20. De izquierda a derecha: **Salir** (círculo 48, `fondoSuperficie`, borde 1, ícono `x` 22); **progreso** que ocupa el espacio sobrante (texto "Sprint 3 · Tarjeta 5 de 10" Etiqueta `textoSecundario` y barra de **12** de alto, radio 6, pista `fondoSuperficieAlt`, relleno `accionPrimaria`); **HUD** con tres chips (racha, monedas, vidas) separación 8; **Botón pausa** (círculo 48, ícono `pause` 22).
  - **El botón de pausa no existe en el móvil.** El sprint no tiene tiempo, así que decídelo así y repórtalo: abre un diálogo "Juego en pausa" (centrado, 440) con "Seguir jugando" (primario) y "Salir del sprint" (fantasma, abre la misma confirmación de Salir). No detiene nada porque no hay reloj; las respuestas no se pierden. En móvil no aparece.
- **Zona izquierda** (de x 24 a `ventana − 424`, es decir de 24 a 770 a 1194; la tarjeta va **centrada** en ella, centro en x ≈ 397 a 1194):
  - **Pila de tarjetas**, de atrás hacia adelante: "Pila 2" 332 × 470 con opacidad 50 % en (+24 , +20) respecto a la tarjeta, "Pila 1" 356 × 470 con 80 % en (+12, +10) y **la tarjeta 380 × 470** (radio 28) en (207, 108). Es `PilaTarjetas`/`TarjetaCaso` con medidas de tablet: **parametriza** (no dupliques); el contenido es el de la tarjeta móvil (etiqueta del caso, personaje, globo de texto, pista de gestos) en 380 de ancho.
  - **Sellos** (Legal, Ilegal, Condicional, Escalar) y **tintes** de pantalla completa: los mismos del móvil; el tinte cubre **toda la ventana** (sin riel que lo recorte).
  - **Botones de veredicto** en (230.5, 594), separación 14, **orden: Ilegal, Escalar, Condicional, Legal**, círculos de 68, borde 3 del color del veredicto, etiqueta Etiqueta del color. Centrados bajo la tarjeta.
  - **Barra de comodines** en (222.5, 700), separación 8, píldoras de alto 48 (Lupa ×2, Abogado ×1, Amparo ×1): la misma `BarraComodines`.
  - Si la ventana es más baja de 834, la tarjeta se encoge **como en el móvil** (mínimo 360 de alto) y la pantalla se desplaza si aun así no cabe.
- **Panel lateral derecho** (x = `ventana − 400`, es decir 794 a 1194, ancho **376**, margen derecho 24), tres tarjetas con separación de 20 aprox. (y 88, 266 y 424):
  1. **"Tu Startup"** (y 88): `fondoSuperficie`, borde 1, radio 20, relleno 16 × 20, separación 12; título Fredoka SemiBold 17 `textoPrimario`; **los indicadores** (los de `IndicadoresStartup`, a ancho completo, con sus deltas tras cada respuesta como en el móvil); nota Leyenda `textoSecundario`: "Cada veredicto mueve los indicadores. Si el Riesgo legal llega a 100 % o el Presupuesto a 0, la Startup quiebra."
  2. **Contexto del sprint** (y 266): `fondoSuperficie`, borde 1, radio 20, relleno 20, separación 12; "MÓDULO N · SPRINT k" (Leyenda `textoAcento`), título del sprint (Fredoka SemiBold 17) y el objetivo del sprint (Cuerpo/Base `textoSecundario`). Figma usa un texto de ejemplo ("Revisa licencias, datos personales y avisos antes del lanzamiento del viernes."); **usa el objetivo real del sprint** (con la primera letra en mayúscula, sin el "Objetivo: ") y repórtalo.
  3. **Atajos de teclado** (y 424): `fondoSuperficieAlt`, radio 20, relleno 16, separación 8; "TECLADO / SWITCH CONTROL" (Leyenda `textoSecundario`) y tres líneas Cuerpo/Base `textoPrimario`: "←  Ilegal        →  Legal", "↑  Condicional   ↓  Escalar" y "Enter confirma · Esc cierra el panel". Se muestran siempre en ancho (no solo con teclado físico). Las flechas, Enter y Esc **ya funcionan** en el móvil (T-05, T-06): verifica que siguen funcionando aquí.
- Con **"Solo botones"** activo (T-10b) el arrastre se desactiva y la pila no se mueve, como hoy.
- **Estados** de carga, error con reintento, sin tarjetas, sin vidas y sin conexión (23): se ven bien en tablet (a ancho de contenido, centrados); el aviso de conexión va **sobre la tarjeta** como en el móvil y las respuestas guardadas ocupan el lugar de los comodines.

## Hojas laterales (T12, T12b, T12c, T14, T14b, T15 a T18, T10b y T10c)
- **Hoja de 376** a la derecha (x 794 a 1170, margen 24), con la forma del panel móvil: `fondoSuperficie`, borde 1, radio 28, sombra elevada, relleno 12 24 34, **agarre de 40 × 5**, separación 14. Mide **su posición vertical, su alto y sus contenidos en los marcos T12, T14, T16, T17, T18, T10b y T10c** y respétalos. La tarjeta (con su sello) sigue visible a la izquierda y el panel lateral derecho queda **debajo** de la hoja (la hoja lo cubre en su zona).
- Una sola **`HojaLateral`** reutilizable (en `lib/componentes/`) que envuelve el contenido actual de cada panel móvil: veredicto (correcto, incorrecto, parcial, Amparo), bonus con micro-pregunta, **visor de evidencia** (T16, T16b), **justificación** (T18), **Abogado Senior** y el aviso de la **Lupa**. **No dupliques la lógica ni los textos**: lo que cambia es el contenedor, no el contenido. El comportamiento de descarte es el mismo que en el móvil (el veredicto y el panel de justificación **no se descartan**; la evidencia y el Abogado sí: atrás, Esc o tocar fuera) y el foco vuelve al control de origen como hoy.
- **Entrada:** la hoja entra deslizándose desde la derecha (280 ms, curva de salida suave); con "Reducir animaciones", aparece sin movimiento. El velo: 40 % de opacidad sobre toda la ventana excepto la tarjeta y su sello si Figma así lo muestra (mídelo en T12; si no, velo completo).
- **Accesibilidad:** al abrirse, el foco pasa al encabezado de la hoja; la hoja es un `Semantics` de contenedor "Retroalimentación"/"Evidencia"/"Justificación"/etc. con el mismo texto que en el móvil; Tab no sale de la hoja mientras es modal; Esc la cierra si es descartable; al cerrarse, el foco vuelve al control de origen. El orden de foco en la pantalla: Salir → progreso/HUD → Pausa → tarjeta → botones de veredicto → comodines → (panel lateral, solo lectura).
- Entre 600 y 959 y en móvil, estos paneles siguen siendo la hoja inferior de hoy (en tablet vertical, con ancho máximo de 440 centrada); no cambies su contenido.

## Accesibilidad general
- Mismos criterios WCAG 2.1 AA, objetivos ≥ 48 (botones de veredicto de 68), alternativa de un toque al swipe y atajos de teclado documentados en cada sprint.
- Texto al 200 % sin desbordes en **1194×834, 834×1194 y 600×960**, claro y oscuro: el panel lateral derecho pasa **debajo** de la zona de juego (una columna que se desplaza) cuando el texto grande no cabe; la hoja lateral se desplaza por dentro.
- Contrastes AA verificados en pruebas: `textoSecundario` sobre `fondoSuperficieAlt` (atajos), `textoAcento` sobre `fondoSuperficie` (contexto), los colores de veredicto sobre `fondoSuperficie` y los de las hojas ya verificados en el móvil.
- "Solo botones", "Reducir animaciones", háptica y tamaño de texto (T-10b) se respetan igual.

## Archivos permitidos
`lib/funciones/juego/` (pantalla de juego y composición de tablet), `lib/componentes/` (`BarraJuego`, `TarjetaCaso`, `PilaTarjetas`, `IndicadoresStartup`, `BarraComodines`, los paneles `PanelVeredicto`, `PanelEvidencia`, `PanelJustificacion`, `PanelAbogado` solo para que se puedan alojar en la hoja; `HojaLateral` y las tres tarjetas del panel lateral nuevas), `lib/core/adaptativo/` solo para ayudantes nuevos, `lib/core/tema/efectos.dart`, `iconos_app.dart`, `lib/core/textos/textos.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **No toques** el estado ni las reglas del juego (`estado_juego.dart`, `logica_*`), las pantallas de resultado (19, 19b, 20), el mapa, el Buzón ni el Examen; **sin dependencias nuevas**.

## Pruebas
- **Zona de juego en ancho (1194×834):** barra de tablet (salir, progreso, HUD, pausa) y sus medidas; pila de 3 con opacidades y desplazamientos; tarjeta de 380 × 470 centrada en la zona; botones de veredicto en el orden y con las medidas de Figma; comodines; panel lateral con sus tres tarjetas y textos; "Tu Startup" con indicadores y deltas; contexto con el objetivo real; atajos.
- **Mecánica igual que en móvil:** arrastre en 4 direcciones con sellos y tintes de pantalla completa, botones, teclado (flechas, Enter, Esc), "Solo botones", calificación, vidas, XP, monedas, bonus, evidencia, justificación, comodines y Amparo, quiebra y fin del sprint (los resultados usan las pantallas actuales). Un recorrido de un sprint completo en tablet con cada tipo de tarjeta.
- **Hojas laterales:** posición, ancho 376 y contenido de cada una; velo al 40 %; modal y descarte (veredicto y justificación no se descartan; evidencia y Abogado con atrás, Esc y tocar fuera); entrada con y sin "Reducir animaciones"; foco al abrir y al cerrar.
- **Pausa:** el diálogo, "Seguir jugando" y "Salir del sprint" con su confirmación; no existe en móvil.
- **600×960, 834×1194 y móvil:** el juego como hoy (hoja inferior); las pruebas existentes siguen verdes sin cambiar su tamaño; en 834×1194 la tarjeta y los botones centrados sin panel lateral.
- **Estados:** carga, error, sin tarjetas, sin vidas, sin conexión (aviso sobre la tarjeta).
- **Accesibilidad:** semántica de la barra y de la hoja, orden de foco, anuncios, contrastes, desbordes (1194×834, 834×1194, 600×960 al 100 % y 200 %, claro y oscuro).
- La galería suma `HojaLateral` y las tres tarjetas del panel lateral; `TEST-GALERIA` actualiza su cuenta.
- Las 1188 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] En 1194×834 el sprint se juega como T10 a T18 (zona de juego a la izquierda y panel lateral a la derecha, hojas laterales de 376), con arrastre, botones y teclado, sin cambiar ninguna regla del juego.
- [ ] En móvil y en 600–959 el juego no cambia.
- [ ] Todas las hojas (veredicto, bonus, evidencia, justificación, Abogado, Lupa, Amparo) funcionan como hoja lateral, con el mismo contenido y comportamiento que en el móvil.
- [ ] Lo que no viene de Figma (botón de pausa, objetivo real en el contexto, entrada de la hoja, 600–959, texto grande) queda en el reporte, igual que las medidas que tomaste de T11 a T18 y T10b y T10c.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Dudas numeradas (D1, D2…), decisiones propias, las medidas tomadas de los marcos de arriba y una nota para T-12d con lo que ya ofrece `HojaLateral` (el Examen usa la misma hoja para el contraargumento del Jefe).
