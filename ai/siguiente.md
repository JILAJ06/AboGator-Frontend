# T-05 · Tarjeta swipe (pantallas 10, 11, 11b, 11c y 13)

**Rama:** `05-tarjeta-swipe` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Implementar la pantalla de juego: la tarjeta de caso que se arrastra en 4 direcciones (→ Legal, ← Ilegal, ↑ Condicional, ↓ Escalar) con sellos, tintes y animaciones, y sus equivalentes por botones y teclado. Las pantallas 11, 11b, 11c y 13 **no son pantallas distintas**: son la misma pantalla 10 mientras se arrastra la tarjeta. El **veredicto** (panel de correcto/incorrecto, XP, vidas, indicadores) es T-06: aquí, al confirmar una dirección, la tarjeta sale volando, se registra la respuesta y entra la siguiente.

## Antes de empezar
- `git fetch`, `git checkout 05-tarjeta-swipe`, `git pull`. Leer `ai/conocimiento/` (00 a 07), sobre todo `05-reglas-y-seguridad.md` (el swipe siempre tiene equivalente por botones; la información no depende solo del color), `03-pantallas.md` (flujo 3) y `07-componentes.md` ("Componentes del juego").
- Comparar con Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 10 = `37:1676`, 11 = `37:2043`, 11b = `37:3376`, 11c = `37:3605`, 13 = `37:2845` y el orden de foco 26b = `79:9056`. Con el conector leer además: ángulo y posición de los sellos (`37:2132` Ilegal, `37:2134` Legal, `37:3469` Condicional, `37:3700` Escalar), sombra de la tarjeta (`10:5`) y el ángulo de la pila.

## Estructura de la pantalla 10 (marco 390×844, fondo `fondoApp`)
Ruta: `Rutas.juego` (`/juego/:sprintId`), en `lib/funciones/juego/`. Sin navegación inferior.
1. **Barra de juego** (`BarraJuego`, y=48, alto 56): Salir, "Sprint N · Tarjeta k de n" con la barra de progreso (reusar `BarraProgreso`) y el `ChipHud` de vidas. El número de sprint sale del orden dentro del módulo; `k` y `n` de las tarjetas cargadas.
2. **Indicadores de la Startup** (reusar `IndicadoresStartup`, en (24,106), 342×46) con `obtenerEstadoStartup()`. Ajustar el mock a Presupuesto 70, Reputación 60, Velocidad 50 y Riesgo legal 25 (como en Figma).
3. **Zona de la tarjeta** desde y=164 hasta y≈604: `PilaTarjetas`, `TarjetaCaso` (342×440 en (24,164)), sellos y tintes (los tintes cubren toda la pantalla, **detrás** de la tarjeta y delante del fondo).
4. **Acciones** (`AccionesVeredicto`, (28.5,622), 333×90): los 4 `BotonVeredicto` ya existentes, en orden Ilegal, Escalar, Condicional, Legal.
5. **Barra de comodines** (`BarraComodines`, (20.5,736), 349×48): solo presentación (no tocable, se lee como texto "Lupa, 2 disponibles"); se activa en T-07. Datos: cantidades de `RepositorioTienda` o fijas si el mock no las da (Lupa 2, Abogado 1, Amparo 1).
- **Diseño adaptable.** Las medidas de arriba son del marco de 390×844. La zona de la tarjeta se estira o encoge entre los indicadores y las acciones (alto mínimo de la tarjeta 260; el texto del globo se desplaza dentro de la tarjeta si no cabe). Si en pantallas muy bajas o con texto al 200 % todo no cabe, la pantalla entera se vuelve desplazable **sin interferir con el gesto de la tarjeta** (el gesto lo captura la tarjeta; el desplazamiento se hace desde fuera de ella). Nunca debe haber desbordes.

## Gesto de arrastre
- La tarjeta sigue al dedo o al ratón (`GestureDetector` con pan o equivalente). El eje se decide al pasar unos 12 dp de arrastre y se bloquea hasta soltar: horizontal (con rotación) o vertical (sin rotación).
- **Horizontal:** la tarjeta se mueve con el dedo y se inclina hasta **12°** (a la izquierda, ángulo negativo; a la derecha, positivo; Figma muestra ya los 12° en un arrastre corto, así que la inclinación llega al tope pronto). **Vertical:** la tarjeta se mueve solo en y, sin inclinación (Figma 11b: unos 68 dp hacia arriba; 11c: unos 86 hacia abajo).
- **Umbral para confirmar:** horizontal ≥ 28 % del ancho, vertical ≥ 80 dp, o un lanzamiento (fling) de velocidad ≥ 800 dp/s en esa dirección. Si no se alcanza, la tarjeta regresa a su lugar con un resorte corto (≈ 250 ms).
- **Sello y tinte mientras se arrastra:** la opacidad crece de 0 al máximo conforme se acerca al umbral. Sello: Legal aparece a la izquierda (al arrastrar a la derecha) e Ilegal a la derecha (al arrastrar a la izquierda), como en Figma 13 y 11; Condicional arriba y Escalar abajo, con las posiciones de reposo y final de Figma (Condicional de (70,190) a (40,124); Escalar de (105,540) a (91,560)). Tinte: del color del veredicto, de 0 a **0.10**.
- **Confirmar:** la tarjeta sale volando en esa dirección (≈ 280 ms; horizontal con inclinación hasta ≈ 24°, como en 12 y 14), la pila avanza (Pila 1 pasa a ser la tarjeta actual con una animación corta), se registra la respuesta y se muestra la siguiente tarjeta.
- **Reducir animaciones:** si `MediaQuery.disableAnimationsOf(context)` es verdadero, no hay vuelo ni resorte ni inclinación animada: la tarjeta se confirma o regresa de inmediato y los sellos aparecen sin transición.

## Equivalentes por botón, teclado y lector de pantalla
- **Botones:** tocar uno de los 4 `BotonVeredicto` hace lo mismo que confirmar esa dirección, con la misma animación de vuelo.
- **Teclado** (leyenda del Figma 26b): las flechas ← → ↑ ↓ **previsualizan** la dirección (la tarjeta se coloca como en el arrastre al umbral, con su sello y tinte); **Enter confirma**; **Esc cancela** la previsualización. Otra flecha cambia la previsualización. Con el foco en un botón de veredicto, Enter o Espacio lo confirman directamente.
- **Orden de foco** (26b): Salir → Indicadores de la Startup (un solo bloque de lectura) → Ilegal → Escalar → Condicional → Legal → Comodines (barra). La tarjeta no recibe foco propio.
- **Lector de pantalla:** la tarjeta se anuncia como "Tarjeta k de n. {personaje}, {rol}: {texto del caso}". Debe tener las 4 acciones personalizadas (`customSemanticsActions`) "Legal", "Ilegal", "Legal con condiciones" y "Escalar a jurídico", además de los botones. Al aparecer una tarjeta nueva se anuncia (región en vivo). Los sellos, tintes, pila y pistas de gesto no se leen.
- Zonas táctiles ≥ 48; nada depende solo del color (los sellos, pistas y botones llevan texto).

## Datos y estado
- **Modelo `Tarjeta`:** agregar `personaje`, `rol` y `etiquetaCaso` (ej. "CASO 4 · LICENCIAS OSS"). Las iniciales del avatar se calculan con `LogicaInicio.iniciales`. Actualizar `MockTarjetas`: el sprint en curso del mock (`spr-1-3`) debe tener **10 tarjetas** (6 normales, 3 con evidencia y 1 de justificación, como dice la intro); también completar las tarjetas de los otros sprints que ya existen en el mock. Por ahora **todos los tipos se muestran con la misma tarjeta normal**; la evidencia y la justificación se resuelven en T-07.
- **Estado del juego** (`EstadoJuego`, proveedor de Riverpod por `sprintId`): carga las tarjetas del sprint (`RepositorioTarjetas`), el estado de la Startup y las vidas; guarda el índice de la tarjeta actual y la lista de respuestas (id de tarjeta y veredicto). Sin calificar todavía. Al responder la última tarjeta navega a `Rutas.sprintCompletado` (marcador pendiente hasta T-06).
- **Salir:** muestra un diálogo de confirmación "¿Salir del sprint?" con "Seguir jugando" y "Salir" (no está en Figma; texto mínimo en `Textos`). "Salir" regresa a la intro o al mapa con `pop` (si no hay pila, `go` al mapa del módulo).
- **Estados:** cargando (esqueleto con las mismas medidas), error con "Reintentar" y sprint sin tarjetas o no encontrado (mensaje y botón para volver). Con 0 vidas (solo si `Vidas.cantidad == 0` al entrar) mostrar el marcador de "Sin vidas" (T-08) sin cargar el juego.
- **Conexión con la intro:** "Comenzar sprint" (09) y "Comenzar" (08) ya navegan a `Rutas.juegoDe(sprintId)`; reemplazar el marcador.

## Componentes nuevos (`lib/componentes/`, con pruebas y en la galería)
`BarraJuego`, `TarjetaCaso`, `PilaTarjetas`, `SelloVeredicto`, `TinteVeredicto`, `AccionesVeredicto` y `BarraComodines`; la lógica de gesto vive en `lib/funciones/juego/` (por ejemplo `MazoSwipe` y `LogicaSwipe` pura: eje, umbral, progreso, ángulo). Especificaciones en `ai/conocimiento/07-componentes.md` ("Componentes del juego"). Solo tokens del tema; ningún color suelto (los sellos, pistas y tintes usan `estadoLegal`, `estadoIlegal`, `estadoCondicional`, `estadoEscalar`; el chip del caso usa el color del módulo al 14 %). Agregar a la galería: la tarjeta de caso, los 4 sellos y las acciones.

## Pruebas
- **Lógica pura** (`LogicaSwipe`): decisión de eje, umbrales horizontal y vertical, fling, progreso 0–1, ángulo con tope de 12°, dirección → veredicto.
- **Componentes** (claro y oscuro): medidas, semántica, solo colores del tema, contraste de las pistas de gesto y del texto del chip del caso sobre su fondo en ambos modos (≥ 4.5:1).
- **Pantalla** con repositorios de prueba: arrastrar a cada dirección por debajo del umbral regresa; por encima confirma y pasa a la siguiente (respuesta registrada con el veredicto correcto); sellos y tintes con opacidad proporcional; fling; botones; teclado (flecha previsualiza, Enter confirma, Esc cancela); acciones de semántica; anuncio de la tarjeta nueva; última tarjeta navega a `sprintCompletado`; Salir con confirmación; estados cargando, error con reintento, sin tarjetas y con 0 vidas; `disableAnimations` sin animación.
- Orden de foco = 26b. Sin desbordes con texto al 200 % en 390×844 y 360×640 y a 320 de ancho, en claro y oscuro (la pantalla desplazable no rompe el gesto).
- Actualizar las pruebas afectadas (mock de progreso/estado de la Startup, modelo de tarjeta, galería).

## Archivos permitidos
`lib/funciones/juego/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**` (modelo `Tarjeta`, `MockTarjetas` y el estado de la Startup del mock), `lib/funciones/bienvenida/galeria_componentes.dart`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] La pantalla 10 y los estados de arrastre 11, 11b, 11c y 13 coinciden con Figma (medidas, tokens, tipografías, sellos, tintes, pila), en claro y oscuro.
- [ ] Las 4 direcciones funcionan con dedo, ratón, botones y teclado; el umbral, el regreso con resorte y el vuelo se sienten bien en Chrome.
- [ ] Respuestas registradas con el veredicto correcto; última tarjeta navega al marcador de sprint completado.
- [ ] Lector de pantalla: tarjeta anunciada, 4 acciones personalizadas, anuncio de la tarjeta nueva, orden de foco 26b.
- [ ] Reduce animaciones respetado; cargando, error y vacío resueltos; sin desbordes a 200 % de texto y 320 dp.
- [ ] Ajustes pequeños de T-04b (D1, D2 y D6): título largo en la intro ("Aviso de privacidad en el MVP": campo nuevo `tituloIntro` en `Sprint` y mock), objetivo con minúscula tras "Objetivo:" ("el MVP sale…"), y saludo del Inicio que ya no se corta en "Hola, A…" (en 390 el nombre debe caber con los chips; si no cabe, que los chips pasen a la segunda fila como ya se hace con texto grande).
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI en verde.
- [ ] Grafo actualizado (nodos de código: PANT-10 con su ruta y las demás dejan anotado que son estados de la misma pantalla; CODIGO-PANT-10, EST-JUEGO, LOGICA-SWIPE, COMP-BARRA-JUEGO, COMP-TARJETA-CASO, COMP-PILA, COMP-SELLO, COMP-TINTE, COMP-ACCIONES, COMP-COMODINES, TEST-JUEGO; cambios en MOD, MOCK-TARJ, MOCK-PROG, ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, PANT-GALERIA, CODIGO-PANT-07, CODIGO-PANT-09) y `reporte.md` con ID **T-05**, rama `05-tarjeta-swipe`, dudas numeradas (D1, D2…).
- [ ] Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisar con `git log -1 --format=%B`). Pull Request hacia `develop`, sin menciones a Claude. No hacer merge.
