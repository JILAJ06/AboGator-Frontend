# Reporte

- **Tarea:** T-04b · Mapa de sprints e Intro del sprint (pantallas 08 y 09)
- **Rama:** `04b-mapa-e-intro`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector de Figma (solo lectura):
  - Contexto de diseño y capturas de 08 (`13:562`) y 09 (`13:776`).
  - Los SVG del camino, de las bases de los nodos, del pulso, de las estrellas y de la elipse, para sacar trazos y colores exactos.
- Revisé la app compilada para web en el navegador a 390×844 (claro y oscuro): Inicio → mapa → "Comenzar" → intro.

## Qué se hizo
1. **Datos y ajustes de T-04** (primero, porque la intro depende de ellos):
   - `Sprint` tiene ahora `objetivo`, `tarjetasNormales`, `tarjetasConEvidencia`, `dilemas`, `monedasMaximas`, `minutosEstimados` y `estrellas` (0 a 3). `numeroTarjetas` es la suma.
   - `MockProgreso` tiene 5 sprints más el Examen final en los 5 módulos.
     - Módulo 1 con los títulos de Figma. Los sprints 1 y 2 están completados con 3 estrellas.
     - El sprint 3 lleva los datos de Figma: 6 + 3 + 1 tarjetas, 60 monedas, ≈ 4 min y el objetivo de la LFPDPPP.
     - Los módulos 2 a 5 tienen un quinto título y objetivos razonables.
   - **El Examen final no cuenta como sprint.** `LogicaInicio` tiene `sprintsNormales` y `totalSprints`. `completados` y el número del sprint actual ya no lo cuentan. El Inicio sigue mostrando 2/5 y "Sprint 3 de 5".
   - **D1:** `usuarioDemo` es Ana López (Dev, nivel 4, racha 7). El mock da 240 monedas y 5 vidas; `MockVidas` acepta otra cantidad para las pruebas.
   - **D4:** la tarjeta héroe oculta a Sarko con menos de 320 de ancho.
2. **Marco compartido** (`lib/app/marco_principal.dart`):
   - `MarcoPrincipal` arma la barra inferior, el Buzón fijo a 28 dp y, si se pide, el foco ordenado.
   - `irAPestana`: la pestaña Mapa vuelve al Inicio, salvo que ya se esté en él.
   - Lo usan el Inicio y el mapa; ya no hay código de pestañas duplicado.
   - `MensajePantalla` reúne el mensaje de error o de "no encontrado" con su botón. El Inicio también lo usa.
3. **Componentes nuevos** en `lib/componentes/`, con pruebas y en la galería:
   - `EncabezadoModulo`:
     - Color del módulo; atrás 48 blanco al 18 %; etiqueta (color del módulo mezclado con blanco al 85 %); tramo en H2 blanco.
     - `ChipHud` de vidas y barra de avance de 8 (pista blanca al 25 %, relleno `#E0A060`) con "n/5".
   - `NodoSprint` en 4 estados (completado, actual, bloqueado, jefe), con las medidas de Figma:
     - Cara sobre una base 8 más abajo. El actual lleva un aro de pulso de 100 en `accion/acento` al 40 %.
     - El completado lleva 3 estrellas rellenas (dibujadas con la silueta de Lucide, porque Lucide solo tiene contorno). Las no ganadas van en `borde/default`.
     - Sin acción no responde ni recibe foco, y se anuncia deshabilitado.
   - `CaminoSprints`: línea recta entre los centros con trazo de 8 en `borde/default`, guiones de 2 con punta redonda y huecos de 15. Es lo que dibuja el SVG de Figma.
   - `GloboSprintActual`: `fondo/superficie`, radio 16, sombra elevada y botón acento "Comenzar" de 170×48. Agregué `altoMinimo` a `BotonApp` (por defecto 52).
   - `FilaDetalleSprint` y `TarjetaDetallesSprint`: ícono de 22 en `accion/primaria`; tarjeta de 342 con radio 18. Cada fila se lee como un bloque.
4. **Pantalla 08** (`lib/funciones/mapa/pantalla_mapa_sprints.dart`):
   - El encabezado queda fijo y el mapa se desplaza debajo.
   - Nodos en zigzag 50/28/50/72/50 % y el final al centro. Las separaciones son las de Figma: 120 entre los nodos anteriores al actual, el globo bajo el actual y 130 después.
   - Etiquetas a la derecha del nodo; la del lado derecho (Sprint 4) va a la izquierda, alineada a la derecha. Se ajustan en varias líneas.
   - El sprint actual no lleva etiqueta: su título está en el globo, como en Figma. Sarko alegre de 88×110 queda a su derecha (o a la izquierda si no cabe).
   - **El camino se mide después de cada diseño** (centros reales de las caras), así que pasa por los nodos con cualquier ancho o texto grande.
   - Al abrir, el mapa se desplaza hasta el sprint actual.
   - Navegación:
     - Los nodos actual y completados abren la intro. Los bloqueados no hacen nada.
     - El Examen final abre su ruta (marcador de T-11) solo con los 5 sprints completados.
     - "Comenzar" abre la intro del sprint actual.
     - Atrás hace `pop` si hay pila; si no, `go(inicio)`.
   - Estados: esqueleto, error con "Reintentar" y "módulo no encontrado" con "Volver al inicio".
   - Foco y lector: atrás → nodos 1 a 6 → "Comenzar" → Buzón → pestañas, con `FocusTraversalOrder` y `OrdinalSortKey`.
     - Cada nodo lee "Sprint N, título, estado" y, si está completado, "3 de 3 estrellas".
     - Las etiquetas visibles, el camino, las estrellas y Sarko no se leen.
5. **Pantalla 09** (`lib/funciones/mapa/pantalla_intro_sprint.dart`):
   - Cerrar (48, borde, radio 12) y chip de vidas arriba.
   - Elipse de 230 en `fondo/destacado` (Figma usa `#E8D8A8`, el mismo token) con Sarko de 184×230.
   - "SPRINT 3 · MÓDULO 1", título H1 centrado y objetivo con el prefijo "Objetivo: ".
   - Las 3 filas, con singular y plural.
   - "Comenzar sprint" queda fijo abajo y abre `Rutas.juegoDe` (marcador de T-05); el contenido de arriba se desplaza.
   - Si el sprint está bloqueado (entrada directa por ruta): aviso y botón deshabilitado.
   - Estados: esqueleto, error con reintento y "sprint no encontrado" (vuelve al mapa o al Inicio).
6. **Rutas:** el mapa (`modulo/:moduloId`) y la intro (`sprint/:sprintId`) cuelgan del Inicio. Así atrás y Cerrar usan `pop`, y la redirección sin sesión aplica a las tres. Agregué los ayudantes `juegoDe` y `crisisJefeDe`, y sus marcadores.
7. **Mocks:** `esperar(Duration.zero)` ya no crea un temporizador. Las pruebas dejaban temporizadores pendientes cuando el Inicio, que queda debajo del mapa en la pila, volvía a pedir datos.

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (327 pruebas; antes 235):
```
+327: All tests passed!
```
- `test/funciones/mapa/logica_mapa_test.dart`:
  - Zigzag, tipo de nodo, sprint actual (en curso o disponible) y número sin el Examen final.
  - El Examen final se abre solo con todo completado.
  - Semántica con estrellas, búsqueda por id y textos con singular y plural.
- `test/funciones/mapa/mapa_test.dart`:
  - Contenido: encabezado y 2/5, 6 nodos con su estado y estrellas, etiquetas, globo y Sarko.
  - Medidas: centros en x (195, 109, 195, 281, 195, 195), separaciones de Figma, etiqueta del Sprint 4 a la izquierda y globo centrado bajo el actual.
  - Camino por los 6 centros y desplazamiento inicial al sprint actual (360×640).
  - Navegación:
    - Actual y completado abren la intro; bloqueados y Examen bloqueado no.
    - Con todo completado, el Examen final abre su ruta.
    - Atrás y Cerrar funcionan con y sin pila, y "Continuar sprint" del Inicio lleva a la intro y luego al mapa.
    - Pestañas y Buzón.
  - Estados: cargando, error con reintento, módulo o sprint inexistente, sin sesión y sprint bloqueado con el botón deshabilitado.
  - Semántica y orden de foco: atrás → nodos 1, 2, 3 → Comenzar → Buzón → pestañas.
  - **Sin desbordes** en 390×844 al 100 % y 200 %, 360×640 al 200 % y 320×640 al 100 % y 200 %, en claro y oscuro. Recorre todo el mapa y toda la intro, y el último nodo no queda bajo el Buzón.
- `test/componentes/mapa_componentes_test.dart`:
  - Cada componente en claro y oscuro, con medidas, semántica, foco y Enter.
  - Solo colores del tema (más las bases de los nodos).
  - **Contraste del encabezado ≥ 4.5:1 sobre los 5 colores de módulo**, y solo se oscurecen los módulos 2 y 5.
  - Bases de los nodos iguales a Figma en claro.
- También: héroe con y sin Sarko (342, 320, 319 y 272), galería con los componentes nuevos, y mocks con los datos de Figma, Ana, 5 vidas y 240 monedas.
- Con `git grep` comprobé que no haya `Color(0x…)` fuera de `lib/core/tema/`.

## Decisiones
- **Contraste del encabezado** (DEC-ENCABEZADO-CONTRASTE):
  - El blanco sobre el ámbar del módulo 2 da 4.07:1. La etiqueta al 85 % da 3.4:1 en el módulo 2 y 3.9:1 en el 5.
  - `EfectosApp.fondoEncabezado` oscurece el fondo lo mínimo (pasos de 2 % hacia negro) hasta que los dos textos pasen 4.5:1.
  - Los módulos 1, 3 y 4 quedan con su color exacto.
- **Alto del encabezado** (DEC-ENCABEZADO-ALTO):
  - En Figma, los 150 incluyen la barra de estado de 48. Uso como relleno superior el mayor entre la zona segura y 48, y el contenido mide 102.
  - En un teléfono con barra de ≈ 48 mide 150, como Figma. "150 + zona segura" lo habría dejado en ≈ 198.
- **Bases de los nodos** (DEC-BASES-NODO): en claro uso los 4 colores de Figma (`#123222`, `#7A4615`, `#CBD5E1` y `#07172B`). En oscuro no hay valores, así que uso la cara oscurecida un 35 %.
- **Rutas anidadas** (DEC-RUTAS-ANIDADAS): ver el punto 6.
- **Sprint actual sin etiqueta lateral:** como en Figma; su título está en el globo.
- **Separaciones verticales:** 120 antes del actual y 130 después (lo que mide Figma). El espacio del globo crece con el texto, en lugar de los 260 fijos.
- **"Comenzar sprint" y el Examen final usan `push`** a sus marcadores, para que "atrás" regrese a la intro o al mapa.
- **Colores fuera de los tokens** (en `EfectosApp`): blanco del encabezado, blanco al 18 % y al 25 %, `#E0A060`, la mezcla de la etiqueta y las bases de los nodos. El camino, las estrellas, el pulso y la elipse sí son tokens.
- **Monedas en la intro:** sigo usando `coins` de Lucide (D5 de T-04); Figma dibuja un círculo relleno.

## Grafo actualizado
Toqué la sección 4 (Código), las filas PANT-08 y PANT-09 (sección 5), la línea "Última actualización" y el registro de cambios. Comprobé que todas las rutas de `lib/` y `test/` del grafo existen.
- **Cambiados (`en curso`):**
  - App y rutas: ENRUTADOR, RUTAS y PANT-PENDIENTE.
  - Tema y textos: TEXTOS y TEMA-EFECTOS.
  - Datos: MOD, MOCK-*, MOCK-AUTH, MOCK-PROG, MOCK-VIDAS y MOCK-TIENDA.
  - Pantallas y lógica: FUNC, LOGICA-INICIO, CODIGO-PANT-07 y PANT-GALERIA.
  - Componentes: COMP-BOTON y COMP-HEROE.
  - Pruebas: TEST-INICIO, TEST-COMP, TEST-AYUDA (ahora también `datos.dart`), TEST-DATOS y TEST-GALERIA.
- **Solo relaciones:** COMP-MODULO (navega a PANT-08) y COMP-BUZON (lo usa MARCO-PRINCIPAL).
- **Nuevos:**
  - App: MARCO-PRINCIPAL.
  - Lógica y pantallas: LOGICA-MAPA, EST-MAPA, CODIGO-PANT-08 y CODIGO-PANT-09.
  - Componentes: COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, COMP-CAMINO, COMP-GLOBO-SPRINT, COMP-FILA-DETALLE y COMP-MENSAJE.
  - Pruebas: TEST-MAPA.
  - Decisiones: DEC-RUTAS-ANIDADAS, DEC-ENCABEZADO-CONTRASTE, DEC-ENCABEZADO-ALTO y DEC-BASES-NODO.
- **Obsoletos:** ninguno. Los textos `pendienteMapaSprints` y `pendienteIntroSprint` se eliminaron; no tenían nodo propio.

## Dudas
- **D1 · Título del sprint 3.** En el mapa de Figma el sprint 3 se llama "Aviso de privacidad", y en la intro (09) el título es "Aviso de privacidad en el MVP". Usé el mismo `titulo` en las dos pantallas ("Aviso de privacidad"). ¿Se agrega un campo de título largo para la intro?
- **D2 · Mayúscula del objetivo.** La tarea da el objetivo con "El MVP…", y Figma muestra "Objetivo: el MVP…" con minúscula. Seguí la tarea. ¿Lo paso a minúscula?
- **D3 · Vidas.** Figma muestra 4 vidas en 08 y 09, y el mock da 5, como pidió la tarea (D1 de T-04). ¿Se queda en 5?
- **D4 · Última fila de detalles.** "Presupuesto, Reputación, Velocidad y Riesgo legal" ocupa dos líneas en el navegador (276 dp útiles); en Figma cabe en una. ¿Se acepta, o se reduce el relleno de la tarjeta?
- **D5 · Examen final bloqueado.** El nodo jefe se ve igual (azul marino con trofeo) bloqueado o disponible, como en Figma. Solo cambia la semántica y que no responde. ¿Se le agrega alguna señal visual de bloqueo?
- **D6 · "Hola, Ana".** En el navegador a 390 el saludo del Inicio todavía se corta en "Hola, A…" porque los chips (7, 240, 5) ocupan su ancho. No lo cambié porque está fuera del alcance (DEC-INICIO-ENCABEZADO). ¿Se ajusta en otra tarea?
