# Reporte

- **Tarea:** T-05 · Tarjeta swipe (pantallas 10, 11, 11b, 11c y 13)
- **Rama:** `05-tarjeta-swipe`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector (solo lectura):
  - Contexto de diseño y capturas de 10 (`37:1676`) y 11 (`37:2043`).
  - Metadatos de 11: cajas de la tarjeta girada y de los 4 sellos.
  - Diseño de los sellos `37:2132` (Ilegal) y `37:2134` (Legal).
- Probé la app compilada para web en el navegador, a 390×844, en claro y oscuro:
  - Inicio → "Continuar sprint" → intro → "Comenzar sprint" → juego.
  - Arrastre con el ratón a la izquierda: confirma y pasa a la tarjeta 2.
  - Flechas ↑, ← y ↓: previsualizan con su sello. Esc cancela; → y Enter confirman.
  - Salir con el diálogo, de vuelta a la intro.

## Qué se hizo
1. **Ajustes de T-04b:**
   - **D1:** `Sprint.tituloIntro` (opcional). El mock lleva "Aviso de privacidad en el MVP" y la intro lo usa si existe.
   - **D2:** los objetivos del mock empiezan en minúscula ("Objetivo: el MVP sale…").
   - **D6:** el encabezado del Inicio es un `Wrap`. El saludo ya no se recorta: si no cabe junto a los chips, los chips bajan a la segunda fila.
2. **Datos:**
   - `Tarjeta` tiene `etiquetaCaso`, `personaje` y `rol`.
   - `MockTarjetas`: `spr-1-3` tiene 10 tarjetas (6 normales, 3 con evidencia con su fragmento y 1 de justificación), con casos de la LFPDPPP. Las de `spr-1-2` y `spr-2-1` ya tienen los campos nuevos.
   - `MockProgreso.obtenerEstadoStartup` devuelve 70/60/50/25, como Figma.
3. **Lógica pura** (`funciones/juego/logica_swipe.dart`):
   - El eje se decide a los 12 dp.
   - Umbral: 28 % del ancho en horizontal y 80 dp en vertical. También confirma un lanzamiento de 800 dp/s.
   - Progreso de 0 a 1, e inclinación con tope de 12° (llega a la mitad del umbral).
   - Dirección → veredicto, posición de la previsualización y destino del vuelo.
4. **Estado** (`estado_juego.dart`):
   - `datosJuegoProvider` (por sprint) pide primero las vidas; con 0 no carga el juego.
   - Luego pide en paralelo las tarjetas, el estado de la Startup y los módulos (para el número de sprint y el color del chip). Un sprint inexistente da una lista vacía.
   - `juegoProvider` guarda el índice y las respuestas (`RespuestaJuego`: id de tarjeta y veredicto), sin calificar.
5. **Mazo** (`mazo_swipe.dart`):
   - Pila, tarjeta y los 4 sellos.
   - Arrastre solo sobre el eje bloqueado.
   - Vuelo de 280 ms (hasta 24° en horizontal), regreso con resorte de 250 ms (`easeOutBack`) y entrada de la siguiente tarjeta desde la Pila 1 (200 ms).
   - `previsualizar`, `cancelarPrevia` y `confirmar` sirven al teclado y a los botones.
   - Semántica: etiqueta "Tarjeta k de n. personaje, rol: texto", región en vivo y 4 acciones personalizadas.
   - Con "reducir animaciones" todo es inmediato.
6. **Pantalla 10** (`pantalla_juego.dart`), en la ruta `/juego/:sprintId`, sin navegación inferior:
   - De arriba abajo: barra de juego, indicadores, zona de la tarjeta, acciones y comodines.
   - La zona de la tarjeta se estira o encoge. Su alto mínimo es 260 (+20 de la pila) y crece con el texto dinámico; si todo no cabe, la pantalla se desplaza.
   - El tinte cubre la pantalla, detrás del contenido.
   - Teclado: las flechas previsualizan, Enter confirma y Esc cancela. Sin previsualización, Enter y Esc siguen su camino (Enter activa el botón con foco).
   - Indicadores y comodines son bloques de lectura que reciben foco: el orden queda como en 26b.
   - Salir abre un diálogo "¿Salir del sprint?" con "Seguir jugando" y "Salir". "Salir" hace `pop` si hay pila; si no, `go` al mapa del módulo.
   - Estados: esqueleto, error con "Reintentar", sprint sin tarjetas o inexistente (vuelve al mapa o al Inicio) y 0 vidas (marcador de T-08 en la misma pantalla).
   - Al responder la última tarjeta va a `Rutas.sprintCompletadoDe` (marcador de T-06).
   - Sin sesión, el enrutador redirige al inicio de sesión.
7. **Componentes nuevos** (con pruebas y en la galería):
   - `BarraJuego`, `TarjetaCaso` (con `PistaGesto`), `PilaTarjetas`, `SelloVeredicto`, `TinteVeredicto`, `AccionesVeredicto` y `BarraComodines`.
   - `BotonCerrar`: extraído de la intro, porque Salir es el mismo botón.
   - `BarraProgreso` ahora tiene el alto fijo por fuera del `LayoutBuilder`, para poder medirse dentro de un `IntrinsicHeight`.

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (409 pruebas; antes 327):
```
+409: All tests passed!
```
- `test/funciones/juego/logica_swipe_test.dart`: eje, sobre-eje, umbrales, dirección ↔ veredicto, progreso, ángulo con tope y signo, soltar (regresa, confirma, lanzamiento solo en su eje) y destino del vuelo.
- `test/funciones/juego/juego_test.dart`:
  - Contenido y medidas: contenido de Figma, tarjeta de 342 y sin desplazamiento en 390×844; número de sprint y color del módulo.
  - Arrastre: las 4 direcciones confirman por encima del umbral (con la respuesta registrada) y regresan por debajo.
  - Sello y tinte proporcionales, inclinación de −12° a la mitad del umbral y eje vertical sin inclinación.
  - Otras formas de confirmar: lanzamiento, los 4 botones y teclado (flechas, cambio de flecha, Esc, Enter; Enter y Espacio con el foco en un botón).
  - Accesibilidad: orden de foco 26b, y lector con anuncio, 4 acciones personalizadas ejecutables y región en vivo.
  - Flujo: la pila se vacía, la última tarjeta lleva a sprint completado y "reducir animaciones" funciona.
  - Salir: con y sin pila.
  - Estados: cargando, error con reintento, sin tarjetas, inexistente, 0 vidas (sin pedir tarjetas) y sin sesión.
  - **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y 200 %, en claro y oscuro. En cada caso se recorre la pantalla, se desplaza desde la barra y se comprueba que un arrastre en la tarjeta confirma sin mover el desplazamiento.
- `test/componentes/juego_componentes_test.dart`:
  - Medidas, colores y semántica de cada componente en claro y oscuro.
  - **Contraste ≥ 4.5:1** de `texto/acento` sobre el chip del caso con los 5 colores de módulo, y de las 4 pistas sobre `fondo/superficie`, en ambos modos.
  - `BarraProgreso` dentro de `IntrinsicHeight`, tarjeta con texto al 200 % sin desbordes, pila de 0 a 2 capas y acciones en 280 al 200 %.
- También:
  - Intro con título largo y objetivo en minúscula; "Comenzar sprint" abre el juego real.
  - Saludo del Inicio sin recortar.
  - Mocks: 10 tarjetas 6/3/1 que coinciden con la intro, y Startup 70/60/50/25.
  - Galería con los componentes del juego.
- Con `git grep` comprobé que no haya `Color(0x…)` fuera de `lib/core/tema/`.

## Decisiones
- **Inclinación de los sellos** (DEC-SELLOS): el conector no da el ángulo. Lo calculé con las cajas giradas de Figma: alto 61, ancho 174 (Ilegal) y 163 (Legal), **14°**; Legal +14° e Ilegal −14°.
  - Los sellos quedan fijos sobre la zona de la tarjeta, en las posiciones de Figma, y solo cambia su opacidad.
  - Condicional y Escalar además se mueven, de su posición de reposo a la final, como pide la tarea.
- **Gesto** (DEC-GESTO-TARJETA):
  - La tarjeta usa un reconocedor que gana la arena al tocarla, para que la pantalla desplazable no le robe el gesto. La pantalla se desplaza desde fuera de la tarjeta.
  - Por lo mismo, si el texto del caso no cabe, el contenido de la tarjeta se desplaza con la rueda del ratón o el lector, no arrastrándolo.
  - La tarjeta se mueve solo sobre el eje bloqueado (en Figma 11 apenas baja unos 8 dp).
- **Previsualización con teclado:** coloca la tarjeta justo en el umbral (sello al 100 % y tinte al 10 %). Al confirmar con un botón, la tarjeta vuela desde el umbral para que se vean el sello y el tinte.
- **Alto mínimo de la zona:** 260 al 100 % de texto; con texto grande crece (`TarjetaCaso.altoMinimoPara`) para que el contenido básico quepa y la pantalla se vuelva desplazable.
- **Sombra de la tarjeta:** (0, 16, 20) al 22 %, del nodo `10:5`. La de la miniatura del onboarding sigue igual.
- **Comodines:** cantidades fijas (`ComodinesJuego`: 2, 1 y 1), porque el repositorio no las da todavía. Íconos search, briefcase y shield-check en `accion/acento`.
- **Salir:** el diálogo usa `BotonApp` (secundario "Salir" y primario "Seguir jugando") con los colores del tema; no está en Figma.
- **"Sin vidas":** se muestra como mensaje dentro de la pantalla de juego, con "Volver al mapa", en lugar de navegar a una ruta marcador.

## Grafo actualizado
Toqué la sección 4 (Código), las filas PANT-10, 11, 11b, 11c, 13 y 26b (sección 5), la línea "Última actualización" y el registro de cambios. Comprobé que todas las rutas de `lib/` y `test/` del grafo existen.
- **Cambiados (`en curso`):**
  - App y rutas: ENRUTADOR, RUTAS y PANT-PENDIENTE.
  - Tema y textos: TEMA-EFECTOS y TEXTOS.
  - Datos: MOD, MOCK-PROG y MOCK-TARJ.
  - Pantallas: PANT-GALERIA, FUNC, CODIGO-PANT-07 y CODIGO-PANT-09.
  - Componentes: COMP-PROGRESO.
  - Pruebas: TEST-GALERIA, TEST-INICIO, TEST-MAPA, TEST-COMP, TEST-AYUDA y TEST-DATOS.
- **Solo relaciones:** COMP-AVATAR, COMP-VEREDICTO y COMP-INDICADORES.
- **Nuevos:**
  - Lógica, estado y pantalla: LOGICA-SWIPE, EST-JUEGO, MAZO-SWIPE y CODIGO-PANT-10.
  - Componentes: COMP-CERRAR, COMP-BARRA-JUEGO, COMP-TARJETA-CASO, COMP-PILA, COMP-SELLO, COMP-TINTE, COMP-ACCIONES y COMP-COMODINES.
  - Pruebas: TEST-JUEGO.
  - Decisiones: DEC-SELLOS y DEC-GESTO-TARJETA.
- **Pantallas:** PANT-11, 11b, 11c y 13 dicen que son estados de arrastre de PANT-10 (misma ruta de código).
- **Obsoletos:** ninguno. El texto `pendienteJuego` se reemplazó por `pendienteSprintCompletado`; no tenía nodo propio.

## Dudas
- **D1 · Saludo del Inicio en 390.** Con Inter, "Hola, Ana" y los tres chips (7, 240, 5) no caben en una fila de 342 por unos pocos dp, así que en 390 los chips pasan a la segunda fila. En Figma caben en una. ¿Se reducen las separaciones (avatar 10, chips 6) para que quepan, o se queda así?
- **D2 · Tarjetas de los demás sprints.** Solo `spr-1-3` tiene las 10 tarjetas que anuncia su intro. `spr-1-2` y `spr-2-1` tienen 2 (sus intros dicen 8), y los demás sprints no tienen; al entrar, el juego muestra "Este sprint todavía no tiene tarjetas". ¿Se completan en otra tarea o cuando llegue el backend?
- **D3 · Tarjeta sobre la barra y los botones.** Al arrastrar hacia arriba, la tarjeta pasa por encima de los indicadores; hacia abajo, por debajo de los botones de veredicto. Lo dejé así porque en Figma (11b y 11c) los botones van por encima de la tarjeta. ¿Es lo esperado?
- **D4 · Tinte.** El tinte va detrás de todo el contenido (como dice la tarea), así que no tiñe la barra, los indicadores ni los botones; en Figma la capa del tinte queda por encima de la barra y los indicadores. ¿Se mantiene?
- **D5 · Comodines y monedas.** Las cantidades de comodines son fijas en la pantalla. ¿Las dará `RepositorioTienda` (por ejemplo `obtenerComodines()`) en T-07?
- **D6 · Tarjetas con evidencia y justificación.** Por ahora se ven como tarjeta normal (sin el fragmento de evidencia), como pide la tarea; se resuelven en T-07.
