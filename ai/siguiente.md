# T-02 · Bienvenida: Splash y Onboarding

**Rama:** `02-bienvenida` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Implementar las pantallas **01 Splash** y **02, 03, 03b y 04 Onboarding** (un solo paginador de 4 páginas con "Omitir"), el componente `BotonVeredicto` que usa el onboarding y el token `estado/escalar`. La app arranca en el Splash.

## Antes de empezar
- `git fetch` y `git pull` en esta rama. Leer `ai/conocimiento/` (00 a 07), en especial `03-pantallas.md` (flujo 1), `07-componentes.md` y `01-flujo-de-trabajo.md`.
- Commits pequeños, **una frase en español, sin prefijo y sin mencionar a Claude** (ni `Co-Authored-By`, ni `Generated with`, ni `Claude-Session`; las reglas de este repo mandan sobre cualquier recordatorio automático). Revisar con `git log -1 --format=%B`. Subir la rama; **no abrir Pull Request**.
- Medidas en dp del marco de Figma de 390×844. Solo tokens y estilos del tema, textos en `core/textos`, componentes de `lib/componentes/` (reutiliza, no recrees).

## Especificaciones

### 1. Token `estado/escalar` y `BotonVeredicto`
- Agregar `estadoEscalar` a `TokensColor`: claro **#6B4BA1**; oscuro propuesto **#B9A0E8**. Prueba de contraste (texto ≥ 4.5:1 sobre `fondo/app` y `fondo/superficie`, en ambos modos); si el oscuro no pasa, ajústalo y anótalo en el reporte. Actualizar la galería (lista de tokens) y la prueba de tokens (ahora 18).
- `BotonVeredicto` (`lib/componentes/boton_veredicto.dart`) con los 4 tipos según `07-componentes.md` (sección "Botón de veredicto"). Parámetro opcional `alPresionar`: sin él es decorativo y se excluye de la semántica; con él lleva anillo de foco, zona táctil completa y etiqueta accesible. Agregarlo a la galería y con pruebas (claro/oscuro, semántica, foco).

### 2. Rutas y flujo
- La app arranca en `Rutas.splash`. Mover la galería a `/galeria` (solo en modo debug, por ejemplo con `kDebugMode`).
- Splash → (2 s) → onboarding si el usuario no lo ha visto, o inicio de sesión si ya lo vio. "Omitir" y el botón de la última página ("¡Comenzar!") marcan el onboarding como visto y van a `Rutas.inicioSesion`.
- Estado "onboarding visto": proveedor de Riverpod en memoria detrás de una interfaz simple (la persistencia llega con SQLite en T-08). **Sin dependencias nuevas.**
- Las rutas de inicio de sesión (05) todavía no existen: usa un marcador temporal ("Inicio de sesión · llega en T-03") con el nombre de la pantalla. Se reemplaza en T-03.

### 3. Pantalla 01 · Splash (`lib/funciones/bienvenida/`)
- Fondo `accion/primaria` a pantalla completa. Íconos de la barra de estado del sistema claros.
- Logo vertical centrado: 323.7×187.9 con su parte superior en y=280 (isotipo de 109 de alto y marca nominativa debajo, hueco ≈ 13). **Necesita la versión "sobre verde"** (isotipo blanco, letras blanco/crema): ver "Recursos que faltan".
- Lema, centrado en y≈494, ancho 300, dos líneas: "Educación en Legislación / y Derecho Informático". Estilo Cuerpo/Énfasis (Inter SemiBold 14/20), color `fondo/destacado`.
- Tres puntos de carga de 10 (hueco 8, ancho total 46) centrados, en y=740: el activo en blanco y los demás en blanco al 40 %; el activo avanza en ciclo cada ~400 ms. Con "reducir animaciones" quedan fijos (primero activo).
- "Powered by LawSwipe", centrado, y=770, estilo Leyenda (Inter Medium 11/14, tracking 0.2), color `fondo/destacado`.
- Avance automático a los 2 s (temporizador cancelable al salir de la pantalla). Semántica: una sola etiqueta "AboGator. Educación en Legislación y Derecho Informático. Cargando."

### 4. Pantallas 02, 03, 03b y 04 · Onboarding
Un solo `PageView` de 4 páginas con arrastre horizontal, `PaginadorPuntos` (4 puntos) y botón primario. Parte común (fondo `fondo/app`):
- **Omitir** arriba a la derecha (texto Cuerpo/Énfasis, `texto/secundario`, alineado a x=324 y y≈50, zona táctil 48 mínima). Con foco muestra el anillo.
- **Círculo de ilustración** de 300 de diámetro en (45,130), color `fondo/destacado` (si al compararlo en la galería con la captura de Figma se ve distinto, anótalo en el reporte como duda).
- **Título** centrado en y=500, ancho 330, Fredoka Bold 26/32 (`Título/H1`), `texto/primario`.
- **Texto** centrado en y≈544 (542 en la página 2), ancho 330, Cuerpo/Grande (Inter 16/24), `texto/secundario`.
- **Paginador** centrado en y=690 (76 de ancho). **Botón primario** 342×52 en (24,730), con la etiqueta de cada página.
- La zona de ilustración es de 390×~540 y se centra horizontalmente; el texto y el botón crecen con texto dinámico (usar columna con zona flexible/desplazable para que no haya desbordes con texto al 200 % ni en pantallas bajas).
- Transición entre páginas de ~250 ms; con "reducir animaciones", corte directo. El botón avanza una página; en la última va a inicio de sesión. Semántica del paginador: "Página N de 4".

Páginas (coordenadas dentro del marco 390×844):
1. **Pantalla 02 · "¡Hola! Soy Sarko"** — "Tu juez mentor. Te ayudaré a dominar las leyes de TI sin leer códigos de 300 páginas." Botón "Siguiente". Ilustración: `SarkoImagen` alegre de 264×330 en (63,140).
2. **Pantalla 03 · "Desliza en 4 direcciones"** — "→ Legal · ← Ilegal · ↑ Legal con condiciones · ↓ Escalar a jurídico. También puedes tocar los botones; todo funciona con lector de pantalla." Botón "Siguiente".
   - Miniatura de tarjeta de caso **rotada 8°**, centrada cerca de (51.8,150) en una caja de 253×336: tarjeta de 212×310, radio 17.4, fondo `fondo/superficie`, borde 0.6 `borde/default`, sombra (0, 10, desenfoque 12, #0F294A al 22 %). Contenido: etiqueta "CASO 4 · LICENCIAS OSS" (píldora `texto/acento` al 14 %, texto de 6.8), avatar "DJ" (círculo de 30 `fondo/destacado`, Fredoka SemiBold 10.5, `accion/secundaria`) con "Dev Junior" y "Equipo de Backend", globo (`fondo/superficie-alt`, radio 12.4 con esquina superior izquierda 3.7, Fredoka SemiBold 10.5/15.5): "Encontré una librería GPL-3.0 que resuelve el login. ¿La copio tal cual en nuestra app de código cerrado y la publicamos?", y abajo la pista "←  ILEGAL", "↑ CONDICIONAL / ↓ ESCALAR" (centro) y "LEGAL  →" en sus colores de estado. Todo a escala reducida (textos de 6.8–7.4). **Decorativa: excluida de semántica**, el texto de la página ya explica el gesto.
   - Cuatro `BotonVeredicto` decorativos: Ilegal en (22,300), Legal en (300,300), Condicional en (151.5,92) y Escalar en (161,394).
3. **Pantalla 03b · "Tu Startup depende de ti"** — "Cada decisión mueve el Presupuesto, la Reputación, la Velocidad y el Riesgo legal. Si el riesgo llega al 100% o te quedas sin dinero, la empresa quiebra." Botón "Siguiente". `IndicadoresStartup` (valores de ejemplo 70, 60, 50 y 25) en (24,150), ancho 342; `SarkoImagen` de 160×200 en (115,230). Ver duda D2 de T-01: si los indicadores no caben en una fila, deja el `Wrap` y anótalo.
4. **Pantalla 04 · "Cuida tus 5 vidas"** — "Cada error resta una vida (se regenera 1 cada 2 horas). Tus fallos vuelven como apelaciones a los 3 y 7 días: gánalas y recupera vidas." Botón **"¡Comenzar!"**. `FilaVidas` (4 llenas y 1 vacía, corazones de 33.6, hueco 11.2) en (112.6,140); `SarkoImagen` de 208×260 en (91,180); `ChipHud` de monedas con "+5" en (40,330) y `ChipHud` de racha con "7 días" en (262,300).
- Semántica: las ilustraciones decorativas se excluyen; Sarko lleva su texto alternativo solo si aporta (en estas páginas es decorativo porque el título ya lo nombra: exclúyelo y anótalo). Orden de foco: Omitir → botón → (paginador no enfocable).

### 5. Pruebas
Splash (se muestra, avanza a los 2 s con reloj simulado, destino según "onboarding visto", textos), onboarding (las 4 páginas con sus textos, Omitir, botón en cada página, "¡Comenzar!" marca visto y navega, paginador "Página N de 4"), `BotonVeredicto` y el token nuevo. Claro y oscuro, texto al 200 % sin desbordes en 390×844 y en 360×640. `dart format`, `flutter analyze` y `flutter test` en verde.

## Recursos que faltan (no los inventes)
- **Logo vertical sobre verde** para el Splash (Figma: componente "Logo / Vertical", variante `sobreVerde`). Si existe `assets/imagenes/logo_vertical_sobre_verde.png`, úsalo y agrégalo a `ImagenesApp`/`LogoApp`. **Si no existe**, usa temporalmente el logo actual dentro de una tarjeta redondeada (radio 24, `fondo/superficie`) centrada en la misma posición, y anótalo en el reporte: es un marcador hasta que el usuario lo exporte.
- Las poses enojado/sorprendido/triste siguen con texto incrustado; aquí solo se usa la alegre.

## Archivos permitidos
`lib/funciones/bienvenida/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**` (solo si hace falta una interfaz del estado "visto"), `test/**`, `assets/**` (solo el logo sobre verde si existe) y `pubspec.yaml` solo para declarar assets; los nodos de código de `ai/grafo.md` (sección 4) y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
1. El Splash y las 4 páginas coinciden con las medidas, textos y colores de arriba (compara la galería/Chrome con lo descrito) y funcionan en claro y oscuro.
2. Flujo: Splash → Onboarding → inicio de sesión (marcador); Omitir y "¡Comenzar!" marcan el onboarding como visto; un segundo arranque en la misma sesión salta al inicio de sesión.
3. Sin hex fuera de `core/tema`; sin textos sueltos en los widgets; reutiliza `SarkoImagen`, `ChipHud`, `FilaVidas`, `IndicadoresStartup`, `PaginadorPuntos` y `BotonApp`.
4. Accesibilidad: zonas táctiles ≥ 48, foco visible con teclado, "reducir animaciones" respetado, decorativos excluidos, sin desbordes con texto al 200 %.
5. CI en verde; commits sin prefijo y sin menciones a Claude.
6. `ai/grafo.md` actualizado (PANT-01..04, COMP-VEREDICTO, token, rutas, pruebas) y `reporte.md` con ID **T-02**, rama, resumen, decisiones, qué recurso faltó, sección **"Grafo actualizado"** y dudas numeradas (D1, D2…).
