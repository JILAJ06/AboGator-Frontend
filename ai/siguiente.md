# T-12d · Tablet: resultados del sprint, Sin vidas, Buzón + Juicio, Sin conexión y Examen Final

**Rama:** `12d-tablet-buzon-y-examen` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-12d**).
**Figma** (archivo `SYNAyUal3xVk4k8SEBEb7f`, página "Tablet · Vistas"). **T19 `98:5016` y T21 `100:4028` están detalladas aquí.** Las demás **las mides tú con el conector** y dejas las medidas en el reporte: T19b Startup en quiebra `98:2433`, T20 Sin vidas `100:3887`, T21b Buzón vacío `100:3950`, T22 Juicio `100:4212`, T22b Resultado del juicio `100:4281`, T23 Sin conexión `100:4342`, y el Examen: T27 `101:4895`, T28 `101:5001`, T28b `101:5194`, T28c `101:5420`, T29 `101:5592`, T30 `101:5666`. Reglas de adaptación: `106:10163`.
**Ya mergeado que usas:** `ClasePantalla`, `Adaptativo`, `MedidasAdaptativas` (columnaFormulario 470, hojaLateral 376…), `tamanoPantalla(tester, Tamano.…)`, `RielNavegacion` en `MarcoPrincipal`, el patrón lista-detalle de `_MapaConDetalle` (T-12b), `HojaLateral` y `BarraJuegoTablet` (T-12c, ver el reporte anterior), diálogos centrados de 440.

## Objetivo
Terminar la versión de tablet: las pantallas de resultado del sprint, Sin vidas, el Buzón con el Juicio en lista-detalle, Sin conexión y el Examen Final. **Misma lógica que en móvil**; solo cambia la composición. Con esta tarea todas las vistas de Figma de tablet quedan hechas.

## Reglas generales (Figma `106:10163`)
- Solo con `ClasePantalla.ancho` (≥ 960) se aplican las composiciones de abajo. **En móvil y entre 600 y 959 las pantallas quedan como hoy** (en 600–959 con ancho máximo y centradas, como en T-12 y T-12b). Las pruebas existentes siguen verdes sin cambiar de tamaño.
- Las `y` de abajo ya tienen **restados los 32 de la barra de estado** (que es del sistema y no se dibuja). Los `x` son desde la izquierda de la ventana de 1194; si la ventana es más ancha o más angosta, las zonas **se reparten proporcionalmente como en T-12b** (no uses posiciones fijas absolutas).
- **Pantallas de resultado** (T19, T19b, T20, T29, T30): sin riel (modo foco). Sarko en la **mitad izquierda** (panel `fondoSuperficie` de 597 de ancho a toda la altura, borde derecho si Figma lo muestra) y el contenido en una **columna centrada de 470** en la mitad derecha.
- **Buzón y Juicio:** con riel (el Buzón es destino del riel), en **lista-detalle**.

## T19 · Sprint completado (`98:5016`, ancho)
- **Panel izquierdo:** `fondoSuperficie`, x 0, y 0, 597 × toda la altura. Dentro, la ilustración de 357 × 476 en (≈120, 147): fondo de 340 × 340 en (+8.5, +17) con la ilustración de fondo actual, **Sarko alegre** de 272 × 340 en (+42.5, +23.8) y las **tres estrellas** debajo, en (+68, +380.8), separación 10.2, tamaños 61.2 / **78.2** / 61.2 (la del medio más grande). Todo es lo que ya usa la pantalla móvil; **solo se reescala y se coloca**.
- **Confeti** de 12 × 6 (radio 2) sobre el panel izquierdo, siete piezas en las posiciones de Figma (cuenta con `ConfetiSprint(piezas:)` de T-11b: reutilízalo, no dibujes aparte; con "Reducir animaciones", estático como hoy). Colores `#B86B23`, `#68B678`, `#2B5FA8`, `#B52426`, `#E0A060`.
- **Columna de contenido** (470 de ancho, centrada en la mitad derecha: x ≈ 661, arriba y 155; separación 16): 
  1. Título "¡Sprint completado!" Fredoka Bold 26/32 `textoPrimario`, centrado.
  2. Texto de cierre (el real del sprint) Cuerpo/Base 14/20 `textoSecundario`, centrado.
  3. **Estadísticas:** tres tarjetas `fondoSuperficie`, borde 1, radio 18, relleno vertical 12, separación 10, ícono de 20, valor Fredoka SemiBold 20/26 `textoPrimario` y etiqueta Leyenda `textoSecundario`: Aciertos ("8/10"), XP (con bonus) ("+95"), Monedas ("+45"). **Reparte el ancho de 470 en tres iguales** (Figma las deja a 107; con la columna de 470 se ven angostas y sobra espacio: usa tres `Expanded` y repórtalo si el frame muestra otra cosa).
  4. "Estado final de tu Startup" Etiqueta `textoSecundario`, centrado.
  5. **Indicadores de Startup** a ancho completo (470): `fondoSuperficie`, borde 1, radio 16, relleno 10, los cuatro indicadores con su delta del sprint (+15 reputación, +5 riesgo, etc.).
  6. **Aviso del buzón** (solo si hay tarjetas falladas): `fondoDestacado`, radio 16, relleno 14 × 10, separación 10, ícono `inbox` 20 y texto Leyenda `textoPrimario` ("2 tarjetas falladas irán a apelación en 3 y 7 días. Resuélvelas para recuperar vidas.").
  7. Botón primario "Continuar al mapa" (alto 52, ancho completo) y fantasma "Repasar mis fallos" (alto 48, texto `textoAcento`).
- Todo lo demás (mensajes según desempeño, XP, regreso al mapa, guardado) **igual que hoy**; archivo `pantalla_sprint_completado.dart`.

## T21 · Buzón de Apelaciones (`100:4028`, ancho): lista-detalle
- **Riel** a la izquierda (el Buzón activo, con su insignia, como en T-12).
- **Columna de lista** (x ≈ 136 = 8.33 % + 36.5, **ancho 500**):
  - Título "Buzón de Apelaciones" Fredoka Bold 26/32 en y 20; texto "Tus fallos regresan a los 3 y 7 días para que no se te olviden." Cuerpo/Base `textoSecundario` en y 60.
  - **Recompensa** en y 108: `fondoDestacado`, radio 18, relleno 14 × 12, separación 12; ícono de 40 × 40 radio 12 `estadoIlegal` con `heart` 22 blanco; "2 juicios de apelación hoy" (Cuerpo/Énfasis) y "Gana cada apelación y recupera 1 vida" (Leyenda `textoSecundario`).
  - **Lista de tarjetas falladas** en y 188: contenedor `fondoSuperficie`, borde 1, radio 20, filas con borde inferior 1; cada fila: relleno 14 × 12, separación 12, **barra de 6 × 40 (radio 3) con el color del módulo de la tarjeta**, texto (título Cuerpo/Énfasis, módulo Leyenda `textoSecundario`, **chip de plazo**) y chevron de 18. Chip de plazo: si toca hoy, `estadoIlegal` con ícono `gavel` 12 y texto blanco "Día 3 · hoy · +1 vida"; si no, `fondoSuperficieAlt` con ícono `clock` 12 y texto `textoSecundario` ("Día 3 · mañana", "Día 7 · en 2 días"). **La fila seleccionada** (la primera al abrir) lleva fondo `fondoDestacado`.
  - Botón primario "Iniciar apelaciones de hoy" (500 × 52) en y 562 y, debajo en y 626, "No consume vidas · No avanza el mapa" Leyenda `textoSecundario` centrada.
- **Panel de detalle** (x ≈ 668 = 50 % + 71, **ancho 526**, toda la altura, `fondoSuperficie`, borde izquierdo 1): sin lista = el panel muestra la vista previa del juicio de la tarjeta **seleccionada**:
  - "PRÓXIMO JUICIO · DÍA 3" (Leyenda `textoAcento`) en (39, 24) y el título de la tarjeta en Fredoka SemiBold 20/26 en (39, 46).
  - **Tarjeta de caso** de 342 × 440 en (91, 108) con la etiqueta "APELACIÓN · LICENCIAS OSS", personaje, globo con el texto del caso y pista de gestos (es la `TarjetaCaso` con el tamaño del móvil; no la ensanches).
  - Aviso "La fallaste hace 3 días" (`fondoDestacado`, píldora, ícono `clock` 14, Leyenda `textoAcento`) en (113, 456).
  - **Sarko** de 96 × 120 en (405, 8) (el actual de la pantalla de Juicio).
  - Botón primario "Iniciar juicio" (342 × 52) en (91, 568).
- **Comportamiento:** tocar una fila **selecciona** y actualiza el detalle (no abre nada). "Iniciar juicio" abre el Juicio (T22) de **esa** tarjeta; "Iniciar apelaciones de hoy" empieza la sesión de hoy como en móvil. Las filas se recorren con flechas arriba/abajo; Enter selecciona (y con el foco en "Iniciar juicio", lo inicia).
- **Vacío (T21b):** el Buzón vacío también lleva el riel; el panel de detalle muestra el estado vacío (mide `100:3950`). Sin tarjetas seleccionables.
- **En 600–959 y móvil:** como hoy (lista; tocar una fila abre el Juicio). En tablet vertical, lista a ancho máximo de 640 centrada.

## T22 / T22b · Juicio y su resultado, T20, T23, T19b y Examen
Mide con el conector y aplica las reglas generales; respeta estas intenciones:
- **T22 Juicio de apelación:** es la mecánica del juego con la tarjeta; **usa la misma composición que el juego de T-12c** si Figma la muestra así (zona de juego + panel lateral con la hoja de 376) y, si es una columna distinta, la de Figma. El resultado (T22b) usa la **hoja lateral** de 376 si Figma lo muestra así; si no, la columna de 470. Repórtalo.
- **T19b Startup en quiebra** y **T20 Sin vidas:** pantalla de resultado (Sarko triste a la izquierda, columna de 470). T20 con vidas en 0 muestra la hora de la próxima vida y los accesos a Buzón y Tienda como hoy.
- **T23 Sin conexión:** mide si es a pantalla completa o un aviso sobre el contenido; mismo comportamiento de la cola offline que en móvil.
- **Examen Final (T27–T30):** T27 intro, T28 las preguntas (T28b y T28c, sus estados) y T29 y T30 los resultados (Aprobado y No aprobado, con el certificado). Sin riel. **El contraargumento del Jefe usa `HojaLateral`**, como dice el reporte de T-12c (si su panel usa `ContenedorPanelModal`, o lee `HojaLateral.radioDe/bordeDe/rellenoInferior`, se adapta solo). Los comodines siguen desactivados; el reloj de crisis y las reglas del examen **no cambian**. La barra del examen puede reutilizar `BarraJuegoTablet` (con su paso propio) si Figma la muestra igual.

## Accesibilidad
- WCAG 2.1 AA, objetivos ≥ 48, y todo lo existente (lector de pantalla, "Solo botones", "Reducir animaciones", háptica, tamaño de texto).
- Orden de foco: en lista-detalle, riel → título → lista (una parada por fila, flechas ↑ ↓) → botón de la lista → detalle → "Iniciar juicio". La fila seleccionada se anuncia como "seleccionada"; al seleccionar, anunciar el título del juicio (`liveRegion` discreta).
- Resultados: el título se anuncia al abrir y el foco inicial va a él; las estadísticas se leen como una frase ("8 de 10 aciertos, 95 de experiencia, 45 monedas").
- Texto al 200 % sin desbordes en **1194×834, 834×1194 y 600×960**, claro y oscuro: cuando no caben las dos zonas, el detalle pasa debajo de la lista (una columna que se desplaza) y Sarko se achica o sube arriba como en móvil.
- Contrastes AA verificados en pruebas: `textoSecundario` sobre `fondoDestacado` y sobre `fondoSuperficieAlt` (chips de plazo), blanco sobre `estadoIlegal` (chip de hoy y insignia) y `textoAcento` sobre `fondoDestacado`.

## Archivos permitidos
`lib/funciones/juego/` (solo `pantalla_sprint_completado.dart`, `pantalla_startup_quiebra.dart`, `piezas_fin_sprint.dart`), `lib/funciones/apelaciones/`, `lib/funciones/vidas/`, `lib/funciones/jefe/` (pantallas y piezas de composición, **no** `estado_examen.dart`, `logica_*` ni `reloj_crisis.dart`), el aviso de conexión que hoy usa T23, `lib/componentes/` (piezas de las pantallas anteriores y nuevas, p. ej. `FilaApelacion`, `PanelDetalleJuicio`, `ColumnaResultado`), `lib/core/adaptativo/`, `lib/core/tema/efectos.dart`, `iconos_app.dart`, `lib/core/textos/textos.dart`, galería, pruebas y documentación de `ai/`. **No toques** reglas de juego, estado, repositorios ni mocks; **sin dependencias nuevas**.

## Pruebas
- **T19 en 1194×834:** panel izquierdo de 597 con Sarko y tres estrellas (la del medio mayor), columna de 470 con todos los elementos y medidas; tres estadísticas iguales; aviso del buzón solo con fallos; botones; sin riel. Lo mismo para T19b y T20 (sus medidas de Figma) y T29/T30.
- **T21:** riel con insignia, lista (500) y detalle (526); fila seleccionada con `fondoDestacado`; chips de hoy y de otro día; seleccionar actualiza el detalle; "Iniciar juicio" abre el Juicio de la tarjeta seleccionada; flechas y Enter; vacío (T21b).
- **T22/T22b, T23 y Examen:** las composiciones de Figma, contraargumento en `HojaLateral`, y un recorrido completo del Examen y de un Juicio en tablet. Las reglas (no consume vidas, no avanza el mapa, comodines desactivados, apelaciones 3 → 7 → 14 → dominada, reloj de crisis) siguen verdes.
- **600×960, 834×1194 y móvil:** como hoy; las pruebas existentes siguen verdes sin cambiar su tamaño.
- **Accesibilidad:** semántica, orden de foco, anuncios, contrastes y desbordes (1194×834, 834×1194, 600×960 al 100 % y 200 %, claro y oscuro).
- La galería suma las piezas nuevas; `TEST-GALERIA` actualiza su cuenta.
- Las 1219 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] En 1194×834 las pantallas de T19, T19b, T20, T21, T21b, T22, T22b, T23 y T27–T30 se ven como Figma, sin cambiar ninguna regla.
- [ ] El Buzón funciona como lista-detalle (seleccionar actualiza el detalle; "Iniciar juicio" abre el Juicio de esa tarjeta).
- [ ] En móvil y en 600–959 nada cambia.
- [ ] Lo que no viene de Figma (tres estadísticas iguales, selección inicial, flechas en la lista, comportamiento de tablet vertical) y las medidas que tomaste de T19b, T20, T21b, T22, T22b, T23 y T27–T30 quedan en el reporte.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Dudas numeradas (D1, D2…), decisiones propias, las medidas tomadas y una nota para T-13 con lo que viste de pulido en tablet (foco, anuncios, la tarjeta que sale volando al confirmar en el juego, etc.).
