# T-06 · Veredictos (pantallas 12, 12b, 12c, 14 y 14b)

**Rama:** `06-veredictos` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Calificar cada respuesta del juego y mostrar el **panel de veredicto** (5 variantes) que sube tras lanzar la tarjeta: acierto con micro-pregunta (12), bonus ganado (12b), respuesta parcial (12c), error (14) y error con Amparo (14b). Actualiza indicadores de la Startup, vidas, XP y monedas del sprint en curso. **Sprint completado (19) y Startup en quiebra (19b) son T-06b**: aquí solo se navega a sus rutas, que siguen siendo marcadores.

## Antes de empezar
- `git fetch origin 06-veredictos`, `git checkout 06-veredictos`, `git pull`. Leer `ai/conocimiento/` (00 a 07), sobre todo `05-reglas-y-seguridad.md`, `03-pantallas.md` (flujo 3) y `07-componentes.md` ("Componentes del veredicto").
- Comparar con Figma (`SYNAyUal3xVk4k8SEBEb7f`): pantallas completas 12 = `37:2287`, 12b = `37:2531`, 12c = `37:3907`, 14 = `37:3147`, 14b = `38:5240`; paneles 37:2427, 37:2671, 37:4047, 37:3287, 38:5384. Con el conector verificar lo que aquí no se pudo ver: cómo queda la pantalla de fondo (¿velo?, posición y ángulo de la tarjeta que sale, estado de los indicadores) y la altura real de cada panel.

## Reglas de calificación (`LogicaVeredicto`, función pura en `lib/funciones/juego/`)
`calificar(tarjeta, veredicto, {amparoActivo = false})` devuelve un `ResultadoVeredicto` con: tipo (`correcto`, `parcial`, `incorrecto`, `amparo`), `xp`, `monedas`, `pierdeVida` e `impacto`.
- **Correcto** (veredicto == `respuestaCorrecta`): +10 XP, +5 monedas, impacto `impactoAcierto` de la tarjeta.
- **Bonus:** solo si la tarjeta trae `microPregunta` y el jugador elige la opción correcta: +5 XP más (15 en total), mismas monedas e impacto.
- **Parcial:** el jugador eligió **Escalar** y la correcta **no** era Escalar: +3 XP, 0 monedas, **no pierde vida**, impacto `impactoParcial`. Cualquier otra combinación equivocada es incorrecta. (Decisión de Chat: no hay parcial para Condicional.)
- **Incorrecto:** 0 XP, 0 monedas, −1 vida, impacto `impactoFallo`; la tarjeta queda en la lista de falladas (irán al Buzón de Apelaciones en T-09).
- **Amparo** (error con `amparoActivo`): no pierde vida y el Riesgo legal sube 5 puntos menos que en el fallo normal (mínimo 0), según Figma 14 (+25) y 14b (+20); el resto del impacto igual. Sigue contando como fallada. El comodín Amparo se activa en T-07: aquí solo existe el parámetro, el estado `amparoActivo` (falso por defecto) y la variante visual; probarla sobreescribiendo el estado.
- Los indicadores se mantienen entre 0 y 100. **Quiebra:** Riesgo legal = 100 o Presupuesto = 0 (`haQuebrado`). Prioridad al terminar el panel: quiebra → `Rutas.startupQuiebraDe(sprintId)`; luego vidas = 0 → `Rutas.sinVidas`; luego última tarjeta → `Rutas.sprintCompletadoDe(sprintId)`; si nada de eso, siguiente tarjeta. Agregar `startupQuiebraDe` a `Rutas` si no existe. Las tres rutas siguen mostrando `PANT-PENDIENTE`.

## Datos
- `Tarjeta`: agregar `impactoAcierto`, `impactoFallo`, `impactoParcial` (modelo nuevo `ImpactoTarjeta` con presupuesto, reputación, velocidad y riesgo legal como enteros, todos 0 por defecto) y `microPregunta` opcional (`MicroPregunta`: `enunciado` como "¿por qué es ilegal?", 2 o 3 `opciones` y `indiceCorrecto`). `explicacion` ya existe.
- `MockTarjetas`: en `spr-1-3` completar los cuatro datos en las 10 tarjetas. La tarjeta de la GPL-3.0 usa los valores de Figma: acierto Reputación +5 y Riesgo −10 (con micro-pregunta "¿por qué es ilegal?", opciones "La GPL-3.0 obliga a liberar el código derivado" —correcta— y "Porque el código de GitHub siempre es privado"); fallo Velocidad +10 y Riesgo +25; parcial Presupuesto −5 y Velocidad −10. Textos de explicación de Figma (12b, 12c, 14, 14b). En las demás tarjetas, valores razonables parecidos y micro-pregunta solo en 4 de las 10. Las tarjetas de los otros sprints las completa T-06b.
- **Estado del sprint** (`EstadoJuego`, extender): `estadoStartup` actual, `vidas`, `xp`, `monedas`, `resultados` (por tarjeta: tipo y si hubo bonus), `falladas` y el panel pendiente. Es **local de la sesión del sprint**: los repositorios solo leen y no se guardan vidas ni XP todavía (lo hace el servidor en T-14). Dejarlo anotado como límite conocido. El índice de tarjeta avanza al **cerrar el panel**, no al lanzar la tarjeta.
- La barra de juego y los indicadores de la pantalla muestran los valores actualizados; las barras de la Startup animan el cambio (o saltan con reducir animaciones). Un corazón menos aparece cuando se abre el panel de error.

## Flujo en la pantalla
Confirmar dirección (arrastre, botón o teclado) → la tarjeta sale volando (como en T-05) → se califica y se actualiza el estado → sube el panel (modal sin descarte: no se cierra con atrás, Esc ni tocando fuera) → el jugador pulsa su botón → sale el panel y se resuelve la siguiente pantalla según la prioridad de arriba. En la variante Correcto con micro-pregunta, elegir una opción cambia el panel a **Bonus** (si acertó) o a **Correcto con Explicación** (si falló), y "Saltar bonus" lo cambia también a Correcto con Explicación; el XP del subtítulo sigue el resultado (+15 o +10). Sin comodines todavía (la barra sigue como en T-05).

## Componentes nuevos (`lib/componentes/`, con pruebas y en la galería)
`PanelVeredicto` (5 variantes), `OpcionJustificacion` (si no existe aún) y el uso de `ImpactoStartup`, `SarkoImagen` y `BotonApp` (agregar el tipo peligro o secundario si falta). Medidas, tokens y textos en `ai/conocimiento/07-componentes.md` ("Componentes del veredicto"). Solo tokens del tema, sin colores sueltos; textos en `Textos`. Agregar las 5 variantes a la galería. Íconos de Lucide: check, star, arrow-down, x, shield-check, coin, zap, alert (verificar que existan en el mapa de íconos).

## Pruebas
- **Lógica pura:** correcto, bonus, parcial (Escalar vs. otras), incorrecto, Amparo (sin vida y Riesgo −5), límites 0–100, quiebra por Riesgo 100 y por Presupuesto 0, prioridad de destino.
- **Componentes** (claro y oscuro): 5 variantes con medidas, textos, íconos, pose de Sarko, contraste de títulos y chips (≥ 4.5:1), semántica (diálogo modal, anuncio de título, subtítulo e impacto), orden de foco, ajuste a texto al 200 % sin desbordes en 390×844, 360×640 y a 320 de ancho.
- **Pantalla** con repositorios de prueba: cada variante aparece con el estado correcto; la vida baja solo en error sin Amparo; indicadores, XP y monedas se actualizan; micro-pregunta acertada, fallada y saltada; el panel no se descarta con atrás ni Esc; avanza la tarjeta al cerrar; quiebra, 0 vidas y última tarjeta navegan a su ruta; `disableAnimations` sin movimiento; vibraciones llamadas según el tipo.
- Actualizar las pruebas de T-05 afectadas (el índice avanza al cerrar el panel; el estado del juego; el mock de tarjetas).

## Archivos permitidos
`lib/funciones/juego/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**` (rutas), `lib/datos/**` (modelo `Tarjeta`, `ImpactoTarjeta`, `MicroPregunta`, `MockTarjetas`), `lib/funciones/bienvenida/galeria_componentes.dart`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] Las 5 variantes del panel coinciden con Figma (medidas, tokens, tipografías, íconos, Sarko), en claro y oscuro.
- [ ] La calificación sigue las reglas de arriba; vida, indicadores, XP y monedas se actualizan solo donde corresponde.
- [ ] Micro-pregunta con bonus, fallada y saltada; el panel no se descarta sin pulsar el botón.
- [ ] Destinos: siguiente tarjeta, última tarjeta, 0 vidas y quiebra, con la prioridad indicada.
- [ ] Lector de pantalla: diálogo modal, anuncio del veredicto, foco inicial en el título, orden de foco; reduce animaciones respetado; sin desbordes a 200 % de texto y 320 dp.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI en verde.
- [ ] Grafo actualizado (PANT-12, 12b, 12c, 14 y 14b con su ruta; nodos nuevos: LOGICA-VEREDICTO, COMP-PANEL-VEREDICTO, COMP-OPCION-JUSTIFICACION si se crea, TEST-VEREDICTO; cambios en MOD, MOCK-TARJ, EST-JUEGO, CODIGO-PANT-10, RUTAS, TEXTOS, PANT-GALERIA, COMP-BOTON si aplica) y `reporte.md` con ID **T-06**, rama `06-veredictos`, dudas numeradas (D1, D2…) y los límites conocidos (estado local, Amparo sin activar, parcial solo con Escalar).
- [ ] Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisar con `git log -1 --format=%B`). Pull Request hacia `develop`, sin menciones a Claude. No hacer merge.
