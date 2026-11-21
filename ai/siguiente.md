# T-12b · Tablet: Mapa de sprints + detalle (lista-detalle), Tienda, Perfil y Ajustes

**Rama:** `12b-tablet-mapa-y-cuenta` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-12b**).
**Figma** (archivo `SYNAyUal3xVk4k8SEBEb7f`, página "Tablet · Vistas"): T08 Mapa de sprints + detalle del sprint `96:582` (detallada aquí), T24 Tienda `101:4306`, T25 Perfil y progreso `101:4553`, T26 Ajustes de accesibilidad `101:4759`. T24, T25 y T26 **las mides tú con el conector** (como en la T-12) y dejas las medidas en el reporte. Reglas generales: `106:10163`.
**Parte de la T-12 ya mergeada:** `ClasePantalla` (`context.clasePantalla`, `Adaptativo`), `MedidasAdaptativas`, `RielNavegacion` dentro de `MarcoPrincipal`, `tamanoPantalla(tester, Tamano.…)`. Léelas y reutilízalas; no las dupliques.

## Objetivo
Llevar a tablet el Mapa de sprints con el detalle del sprint (lista-detalle), la Tienda, el Perfil y Ajustes, más tres arreglos pendientes de la T-12 (consejo de Sarko, espacio sobrante del Buzón y riel en Ajustes).

## 1. Mapa de sprints + detalle del sprint (T08, 08 + 09 juntos)
Solo con `ClasePantalla.ancho` (≥ 960) y dentro de `MarcoPrincipal` (riel). **Entre 600 y 959 y en móvil** el mapa y la intro funcionan **como hoy** (tocar un sprint abre la intro a pantalla completa; entre 600 y 959 solo se añade el riel). Medidas de Figma con `x` desde el borde izquierdo de la ventana y `y` **sin** la barra de estado de 32 (restada); anchos proporcionales si la ventana es menor de 1194 (las dos columnas se reparten 596:494).

- **Panel izquierdo** (x 104 a 700, ancho **596**):
  - **Encabezado del módulo** 596 × 134 en y 0 (el color del módulo, p. ej. `#2B5FA8`): botón atrás 48 × 48 radio 12, blanco al 18 %, ícono 20, en (16, 20); "MÓDULO 1 · PROTECCIÓN DE DATOS" (Leyenda, `#DCE7F7`) en (72, 24); nombre del módulo (Fredoka SemiBold 20/26, blanco) en (72, 40); **chip de vidas** en (516, 28); barra de avance de 504 × 8 radio 4 (pista blanca al 25 %, relleno `#E0A060`) en (20, 86) y "2/5" (Etiqueta, blanco) en (536, 81). Es `EncabezadoModulo` de 04b con ancho 596: parametriza el ancho, no lo dupliques.
  - **Mapa (se desplaza)** 596 × 668 desde y 134: es el **camino de sprints del móvil escalado × 1.12** (nodos de 80.64 en lugar de 72, Examen final de 103.04, etiquetas de 13.44 y 12.32, estrellas de 17.92) y **centrado** en los 596 (en Figma, x 79.6 con ancho 436.8). El zigzag, el camino y el globo "Estás aquí"/Sarko son los de 04b. No hay botón Buzón flotante.
  - **Anillo de foco** (`foco/anillo`, 3 de grosor, radio del control + 5, margen 5 por lado) sobre el nodo seleccionado cuando tiene foco de teclado.
- **Panel derecho** "Detalle del sprint" (x 700 a 1194, ancho **494**, alto completo desde y 0 hasta abajo): `fondoSuperficie`, **borde izquierdo 1** `bordeDefault`. Columna de **430** en x 31 desde y 123, separación 14, que se desplaza si no cabe:
  1. **Ilustración** 207 × 208.8: círculo decorativo de 207 y Sarko (la misma de la intro 09, la pose que ya usa).
  2. "SPRINT 3 · MÓDULO 1": Etiqueta `textoAcento`.
  3. Título del sprint (Fredoka Bold 26/32 `textoPrimario`; el de la intro: "Aviso de privacidad en el MVP").
  4. "Objetivo: …": Cuerpo/Base `textoSecundario`.
  5. **Tarjeta de detalles** (`fondoSuperficie`, borde 1, radio 18, padding horizontal 16) con tres filas de padding vertical 12, ícono 22 y dos líneas: "10 tarjetas / 6 normales · 3 con evidencia · 1 dilema", "Hasta 60 monedas / Dilema clave acertado = monedas ×2" y "4 indicadores de tu Startup / Presupuesto, Reputación, Velocidad y Riesgo legal". Son las `FilaDetalleSprint` de 04b (sin cambios de lógica).
  6. **Botón primario** "Comenzar sprint" a ancho completo (430 × 52) → juego, igual que la intro del móvil.
  Todo ese contenido sale de los mismos datos y textos de la intro (09); **comparte el widget** del detalle entre la intro móvil y este panel.
- **Selección:** al abrir el mapa queda seleccionado el sprint **en curso** (si no hay, el último completado; si no hay ninguno, el primero). Tocar (o Enter sobre) un nodo **completado o en curso** lo selecciona y cambia el detalle, sin navegar; los **bloqueados** siguen sin acción (como en móvil). El **Examen final** habilitado sigue abriendo la crisis (27) directamente, no usa panel; bloqueado no hace nada. El nodo seleccionado se distingue sin color solo (el anillo de foco al navegar con teclado y, para el seleccionado sin foco, el globo/pulso que ya usa el actual; si el seleccionado no es el actual, un borde de 3 `accionPrimaria`; decide y reporta).
- **Enlaces profundos:** la ruta de la intro de un sprint (`Rutas.introSprintDe`) en **ancho** muestra esta vista combinada con ese sprint seleccionado (no una pantalla aparte); en móvil y 600–959 sigue siendo la intro a pantalla completa. El botón atrás del encabezado hace lo mismo que hoy en 08 (vuelve al Inicio, con o sin pila).
- **Carga, error y "módulo no encontrado":** como hoy, a ancho de contenido (sin dos paneles); el esqueleto puede mostrar los dos.
- **Accesibilidad:** orden de foco: riel → atrás → mapa (nodos de arriba abajo) → detalle (botón al final). El detalle se anuncia con `liveRegion` al cambiar la selección ("Sprint 2, Consentimiento. Completado, 3 estrellas."); los nodos conservan sus semánticas de 04b y suman "seleccionado".

## 2. Tienda (T24), Perfil (T25) y Ajustes (T26)
Mide `101:4306`, `101:4553` y `101:4759` con el conector y respeta sus posiciones, medidas, textos y colores. Lo esperable (**confírmalo y repórtalo**): las mismas piezas de T-10 (`TarjetaArticulo`, `PildoraSaldo`, `PildoraInventario`, tarjeta de perfil, `TarjetaEstadistica`, insignias, filas de menú) reubicadas en rejilla de varias columnas dentro del ancho junto al riel, con margen 32 y medianil 24.
- **Tienda y Perfil** en `ancho`: la composición de Figma. En 600–959: una columna centrada (ancho máximo 640 como el Inicio) **o** la rejilla reducida si Figma la sugiere; decide y reporta. En móvil, sin cambios.
- **Ajustes (T26)** hoy es una pantalla sin `MarcoPrincipal`; en tablet debe verse **con el riel** (como T26) y la composición de Figma. En móvil, sin cambios y sin navegación inferior como hoy.
- Los diálogos y hojas (confirmación de compra, selector de tamaño de texto, cerrar sesión) se ven bien en tablet: **centrados con ancho máximo de 440** (no estirados a 1194). La hoja del selector de tamaño pasa a diálogo centrado de ese ancho. Si Figma muestra otra cosa, sigue Figma.
- Se conservan **todas** las reglas y semánticas de T-10 y T-10b (compra con confirmación y sin conexión, máximo 9, cierre de sesión que invalida 11 proveedores, ajustes que se aplican al instante, "Solo botones", etc.).

## 3. Arreglos pendientes
- **Consejo de Sarko (Inicio):** el texto de Figma es incorrecto (terminar el Sprint N desbloquea el sprint N+1, no el módulo). Nuevo texto: "Termina el Sprint N hoy y desbloquea <título del sprint siguiente>." (por ejemplo "Derechos ARCO"); si el sprint en curso es el **último de los normales**: "Termina el Sprint 5 hoy y desbloquea el Examen final."; si no hay sprint en curso, el texto general que ya existe. Actualiza `LogicaInicio.consejo`, `Textos` y las pruebas del Inicio de tablet.
- **Reserva del botón del Buzón:** Mapa, Buzón, Tienda y Perfil siguen reservando `MarcoPrincipal.reservaBuzon` al final. Cuando `MarcoPrincipal.conRiel(context)` es verdadero, **no la reserves** (en móvil sigue igual).
- **Insignia del riel tras acciones:** al ganar o perder un juicio, comprar en la Tienda o registrar fallos, la insignia del Buzón debe actualizarse (`ref.invalidate(totalBuzonRielProvider)` donde corresponda); verifica con una prueba que cambia al resolver una apelación.

## Archivos permitidos
`lib/funciones/mapa/` (08 y 09), `lib/funciones/tienda/`, `lib/funciones/perfil/` (incluye Ajustes), `lib/funciones/inicio/` (solo el consejo), `lib/app/enrutador.dart` y `marco_principal.dart` (la selección en la ruta de intro y la reserva del Buzón), `lib/componentes/` (`EncabezadoModulo`, `CaminoSprints` y nodos para recibir escala y ancho; el detalle del sprint compartido; piezas de Tienda y Perfil), `lib/core/adaptativo/` solo para ayudantes nuevos si hacen falta, `lib/core/tema/efectos.dart`, `iconos_app.dart`, `lib/core/textos/textos.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **No toques** el juego, el Buzón (más allá de la reserva), el Examen ni la lógica de datos. **Sin dependencias nuevas.**

## Pruebas
- **Mapa en ancho (1194×834):** estructura y medidas de T08 (encabezado, mapa × 1.12 centrado, detalle de 494 con sus 6 piezas); selección inicial (en curso, luego último completado, luego primero); tocar un completado o el actual cambia el detalle sin navegar; bloqueado y Examen bloqueado no hacen nada; Examen habilitado abre 27; "Comenzar sprint" abre el juego del sprint seleccionado; atrás con y sin pila; ruta de la intro muestra la vista combinada con ese sprint; anuncio de la selección; foco (orden y anillo); carga, error y no encontrado; claro y oscuro; 200 % sin desbordes.
- **Mapa en 834×1194 y 600×960 y en móvil:** como hoy (tocar abre la intro) con riel en tablet; las pruebas existentes de 04b siguen verdes **sin cambiar su tamaño**.
- **Tienda, Perfil y Ajustes en tablet** (1194×834, 834×1194, 600×960): posiciones y medidas de Figma, compra de punta a punta (confirmación, saldo, inventario, sin conexión), cierre de sesión, ajustes que se aplican, Ajustes con riel, diálogos centrados de 440; sin desbordes al 100 % y 200 %, claro y oscuro.
- **Consejo, reserva e insignia:** los tres casos del consejo; sin reserva con riel y con ella en móvil; la insignia baja de N a N−1 al ganar un juicio.
- La galería suma las piezas nuevas; `TEST-GALERIA` actualiza su cuenta.
- Las 1116 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] En 1194×834 el mapa y la intro se ven juntos como T08 (lista a la izquierda, detalle a la derecha) y la selección funciona con toque, teclado y lector de pantalla; en móvil y 600–959 nada cambia salvo el riel.
- [ ] Tienda, Perfil y Ajustes coinciden con T24, T25 y T26 y conservan todas sus reglas; Ajustes ya lleva el riel en tablet.
- [ ] Consejo de Sarko corregido, sin espacio sobrante del Buzón con riel e insignia que se actualiza.
- [ ] Lo que no viene de Figma (600–959, cómo se marca el seleccionado, diálogos de 440) queda en el reporte, igual que las medidas que tomaste de T24 a T26.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Dudas numeradas (D1, D2…), decisiones propias, las medidas tomadas de T24 a T26 y una nota para T-12c y T-12d con lo que ya ofrecen el detalle compartido y los ayudantes.
