# T-04b · Mapa de sprints e Intro del sprint (pantallas 08 y 09)

**Rama:** `04b-mapa-e-intro` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Implementar **08 Mapa de sprints** (de un módulo) y **09 Intro del sprint**, conectadas al Inicio que ya existe: tocar un módulo abre el mapa y "Continuar sprint" o "Comenzar" abre la intro. Incluye ajustes pequeños que quedaron de T-04 (datos del mock, Sarko en pantallas angostas) y datos nuevos en el modelo `Sprint` para poder mostrar la intro.

## Antes de empezar
- `git fetch`, `git checkout 04b-mapa-e-intro`, `git pull`. Leer `ai/conocimiento/` (00 a 07), sobre todo `03-pantallas.md` (flujo 2) y `07-componentes.md` ("Componentes del Mapa y la Intro del sprint").
- Comparar con Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 08 = `13:562`, 09 = `13:776`. Con el conector, mirar además los nodos de detalle: Camino `14:1131`, Nodo de nivel `10:119` (Completado), `10:135` (Actual), `10:143` (Bloqueado) y `10:150` (Jefe), Globo `13:685`, Encabezado `13:574` y Elipse de la intro `13:796`. De ellos sacar trazo y colores exactos del camino, de las estrellas y de la elipse.

## 1 · Ajustes de datos y de T-04 (primero, porque la Intro depende de ellos)
1. **Sprints del mock.** Figma muestra por módulo **5 sprints más el Examen final** (6 nodos) y progreso "2/5". Hoy el mock tiene 4 sprints más el final. Cambiar `MockProgreso` a 5 sprints + final en los 5 módulos. Los títulos del módulo 1 salen de Figma: "Datos personales", "Consentimiento", "Aviso de privacidad" (el 3.º, en curso), "Derechos ARCO", "Brechas de seguridad", y el final "Auditoría de inversores". Para los módulos 2 a 5 agregar un quinto título razonable.
2. **El Examen final no cuenta como sprint** en los números: el progreso de la tarjeta del Inicio, el "n/5" del mapa y el "Sprint n de total" del héroe usan solo los sprints normales (total 5). Ajustar `LogicaInicio` y sus pruebas (ya no contar el final en `completados` ni en el total).
3. **Datos nuevos en `Sprint`** (modelo y mock): `objetivo` (texto), `tarjetasNormales`, `tarjetasConEvidencia`, `dilemas`, `monedasMaximas`, `minutosEstimados` y `estrellas` (0 a 3, solo si está completado). `numeroTarjetas` pasa a ser la suma. El sprint 3 del módulo 1 como en Figma: 10 tarjetas (6 normales, 3 con evidencia, 1 dilema), hasta 60 monedas, ≈ 4 min y objetivo "El MVP sale a producción el viernes. Revisa que el registro de usuarios cumpla con la LFPDPPP antes del lanzamiento." (el prefijo "Objetivo: " lo pone la pantalla). Los demás sprints: valores razonables. Sprints 1 y 2 completados con 3 estrellas.
4. **D1 de T-04:** `usuarioDemo` pasa a "Ana López", perfil Dev, nivel 4, racha 7; monedas 240 y vidas 5. Ajustar las pruebas que dependan de esos datos.
5. **D4 de T-04:** la tarjeta héroe oculta a Sarko cuando mide menos de 320 de ancho.

## 2 · Pantalla 08 · Mapa de sprints (`lib/funciones/mapa/`)
Ruta: `Rutas.mapaSprints` (`/inicio/modulo/:moduloId`), con la navegación inferior y el Buzón como en el Inicio (**extraer la navegación de pestañas a una función compartida**; no duplicarla). Pestaña activa: Mapa.

- **Encabezado fijo** (`EncabezadoModulo`, 150 + zona segura): ver 07-componentes. Fondo = color del módulo; textos blancos; etiqueta "MÓDULO N · NOMBRE CORTO" (reusar `LogicaInicio.nombreCorto`); título = tramo (reusar `LogicaInicio.tramo`); `ChipHud` de vidas; progreso "n/5" con la barra (completados / sprints normales). El botón atrás regresa al Inicio (`context.pop()` si hay pila; si no, `context.go(Rutas.inicio)`). Contraste del texto blanco sobre el color de cada módulo ≥ 4.5:1 (verificar los 5 colores).
- **Mapa que se desplaza** debajo del encabezado. Alto total de unas 1180 dp (en Figma, 6 nodos). Posiciones del marco 390 (superior izquierda de cada nodo): Sprint 1 (147,200), Sprint 2 (62,320), Sprint 3 actual (143,440), Sprint 4 (232,700), Sprint 5 (147,830), Examen final (137,960). Los centros en x siguen el patrón zigzag 50 %, 28 %, 50 %, 72 %, 50 %, 50 % del ancho disponible (para que se adapte a otros anchos); las separaciones verticales son fijas en dp y la separación extra tras el sprint actual deja espacio al globo. Al abrir, el mapa se desplaza para dejar a la vista el sprint actual.
- **Nodos** (`NodoSprint`, 4 estados), **camino** (`CaminoSprints`, curva decorativa pintada con `CustomPainter`; tomar trazo y colores del nodo `14:1131`), **etiquetas** a un lado: a la derecha del nodo, salvo el nodo del lado derecho (Sprint 4), donde va a la izquierda con alineación a la derecha. Las etiquetas se ajustan en varias líneas si no caben (texto al 200 %).
- **Globo del sprint actual** (`GloboSprintActual`) bajo el nodo actual, centrado; **Sarko alegre** de 88×110 a la derecha del nodo actual (decorativo). "Comenzar" abre la Intro de ese sprint.
- **Interacción:** nodo actual o completado → Intro del sprint (`Rutas.introSprintDe`); nodo bloqueado → no hace nada y el lector lo anuncia como bloqueado; **Examen final** → ruta del Examen final de `Rutas` (marcador pendiente, T-11) solo si todos los sprints están completados; si no, bloqueado.
- **Estados:** cargando (esqueleto con las mismas medidas), error con "Reintentar", y módulo no encontrado (mensaje y botón "Volver al inicio"). Sin sesión: redirige (ya lo hace el enrutador).
- **Semántica y foco:** orden de arriba abajo: atrás → nodos 1 a 5 y Examen final → "Comenzar" → Buzón → pestañas. Cada nodo lee "Sprint N, título, estado" y, si está completado, sus estrellas ("3 de 3 estrellas"); el camino y las estrellas sueltas no se leen.

## 3 · Pantalla 09 · Intro del sprint (`lib/funciones/mapa/`)
Ruta: `Rutas.introSprint`. Sin navegación inferior.
- **Cerrar** (X, 48×48, `fondoSuperficie`, borde 1 `bordeDefault`, radio 12, en (20,54)) regresa al mapa; `ChipHud` de vidas en (306,64).
- **Sarko alegre** de 184×230 en (103,112) sobre la elipse de 230 en (80,110); color y opacidad de la elipse: leerlos del nodo `13:796`.
- "SPRINT N · MÓDULO M" (Etiqueta, `textoAcento`, centrado) a y=362; título del sprint (Fredoka Bold 26/32, centrado, máx. 2 líneas visuales en 390 pero crece si hace falta) a y=384; objetivo (Cuerpo/Base, `textoSecundario`, centrado, ancho 342) a y=456 con el prefijo "Objetivo: ".
- **Tarjeta de detalles** (`FilaDetalleSprint` ×3) a y=530: "{n} tarjetas" / "{a} normales · {b} con evidencia · {c} dilema(s)" (singular o plural); "Hasta {m} monedas" / "Dilema clave acertado = monedas ×2"; "4 indicadores de tu Startup" / "Presupuesto, Reputación, Velocidad y Riesgo legal". Íconos: doc, coin y zap (ya existen).
- **Botón "Comenzar sprint"** (`BotonApp` primario, 342×52) **fijo abajo** (a y=740 en el marco; respetar la zona segura). El contenido de arriba se desplaza si no cabe (texto al 200 %, pantallas de 360×640).
- El botón abre la ruta del juego (`Rutas.juego` con el sprint; marcador pendiente hasta T-05). Si el sprint está bloqueado (entrada directa por ruta) se muestra un mensaje y el botón queda deshabilitado.
- Estados: cargando, error con reintento y sprint no encontrado, como en el mapa.
- Semántica: título como encabezado; la elipse y Sarko se ignoran; el botón X dice "Cerrar".

## Textos, íconos y colores
Todo texto nuevo va en `Textos`. Íconos de `IconosApp` (si falta alguno, agregarlo y decirlo en el reporte). Solo tokens del tema; los únicos colores fuera de tokens son el del módulo, el relleno claro `#E0A060` de la barra del encabezado y los que salgan de Figma para camino y elipse, guardados en `EfectosApp`.

## Pruebas
- Lógica pura (progreso sin Examen final, estado de cada nodo, módulo actual, etiquetas de la intro con singular/plural).
- Componentes (claro y oscuro, estados, semántica, foco, solo colores del tema, contraste del encabezado sobre los 5 colores) y galería con los 4 estados de nodo, el globo y las filas.
- Pantallas con repositorio de prueba: encabezado y progreso 2/5, 6 nodos con su estado, globo, navegación (actual/completado abren la intro; bloqueado no; Examen final bloqueado), atrás, cerrar, "Comenzar" y "Comenzar sprint", estados cargando/error/no encontrado, desplazamiento inicial al sprint actual.
- Sin desbordes con texto al 200 % en 390×844 y 360×640, y a 320 de ancho, en claro y oscuro, recorriendo todo el mapa.
- Actualizar las pruebas de T-04 afectadas por el mock (5 sprints, Ana López) y de la tarjeta héroe (Sarko oculto < 320).

## Archivos permitidos
`lib/funciones/mapa/**`, `lib/funciones/inicio/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**`, `lib/funciones/bienvenida/galeria_componentes.dart`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] 08 y 09 coinciden con Figma (medidas, tokens, tipografías, íconos, Sarko) y funcionan en claro y oscuro.
- [ ] Mock con 5 sprints + Examen final y datos nuevos del sprint; progreso sin contar el final; usuario demo "Ana López" (D1) y Sarko oculto en la tarjeta héroe < 320 (D4).
- [ ] Navegación completa: Inicio → mapa → intro → juego (marcador); atrás y cerrar; pestañas compartidas con el Inicio sin código duplicado.
- [ ] Bloqueados no responden y se anuncian; Examen final solo con todos los sprints completados.
- [ ] Cargando, error con reintento y no encontrado; sin desbordes a 200 % de texto y 320 dp.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI en verde.
- [ ] Grafo actualizado (nodos nuevos de código: PANT-08 y PANT-09 con su ruta, CODIGO-PANT-08, CODIGO-PANT-09, EST-MAPA, COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, COMP-CAMINO, COMP-GLOBO-SPRINT, COMP-FILA-DETALLE, TEST-MAPA; cambios en MOD, MOCK-PROG, MOCK-AUTH, LOGICA-INICIO, COMP-HEROE, ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, PANT-GALERIA) y `reporte.md` con ID **T-04b**, rama `04b-mapa-e-intro`, dudas numeradas (D1, D2…).
- [ ] Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisar con `git log -1 --format=%B`). Pull Request hacia `develop`, sin menciones a Claude. No hacer merge.
