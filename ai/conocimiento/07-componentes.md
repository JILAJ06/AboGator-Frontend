# 07 · Especificación de componentes (Figma → Flutter)

Medidas en dp (px de Figma). Fuente: página "Componentes" de Figma. Todos usan tokens de tema (claro/oscuro); nada de hex en los componentes. Los nombres de clases son sugerencias en español. Cada componente debe: respetar texto dinámico, tener etiqueta semántica en español, zona táctil ≥ 48 dp y mostrar el anillo de foco al navegar con teclado.

## Tokens que faltaban (se agregan en T-01)
| Token | Claro | Oscuro | Uso |
|---|---|---|---|
| borde/control | #64748B | #64748B | Bordes de campos, interruptores inactivos, puntos del paginador, corazón vacío (≥3:1) |
| estado/condicional | #2B5FA8 | #6FA0E8 (propuesto) | "Legal con condiciones", barra de Reputación |
| foco/anillo | #2B5FA8 | #7CB0F0 (propuesto) | Anillo de foco |
Los valores **oscuros son propuestos** (en Figma solo vi los claros). Una prueba debe comprobar contraste: texto/estado ≥ 4.5:1 y bordes/anillos ≥ 3:1 sobre `fondo/app` y `fondo/superficie`, en ambos modos; si un valor no pasa, ajustarlo y anotarlo en el reporte.

## Texto con tracking
Los estilos Botón, Etiqueta y Leyenda llevan `letterSpacing` de 0.2 en los componentes (los demás, 0). Agregarlo a los tres estilos.

## Íconos
- Trazo de 2, esquinas redondeadas, caja de 24×24 (tamaños de uso: 12, 14, 16, 20, 22, 24, 26, 48). Color por defecto: el del texto que lo acompaña, salvo indicación.
- Nombres (45): heart, coin, flame, star, bulb, home, inbox, store, user, lock, check, x, code, clock, back, chevron, settings, doc, trophy, shield, eye, moon, vibrate, bell, logout, pause, refresh, mail, map, gavel, info, accessibility, type, arrow-up, arrow-down, search, zap, alert, paperclip, highlighter, briefcase, trending-down, building, megaphone, shield-check.
- Son del estilo de **Lucide**. Usar el paquete `lucide_icons_flutter` (verificar que exista y su versión). Para los que no tengan equivalente exacto (por ejemplo coin, vibrate, back, chevron, gavel, highlighter), usar el más cercano y listarlos en el reporte. Una sola clase `IconosApp` con una entrada por nombre de Figma y un widget `IconoApp(icono, tamano, color, etiquetaSemantica?)`: decorativo (excluido de semántica) si no recibe etiqueta.

## Botón (`BotonApp`)
Alto 52, radio 16, relleno horizontal 24, ancho: el del contenedor (342 en móvil) o intrínseco, texto centrado estilo **Botón** (Fredoka SemiBold 16/20, tracking 0.2). Opcional: ícono a la izquierda o derecha (16).
| Tipo | Fondo | Texto | Borde / sombra |
|---|---|---|---|
| Primario | accion/primaria | texto/en-primario | sombra sólida inferior |
| Secundario | fondo/superficie | accion/secundaria | borde 2 accion/secundaria, sin sombra |
| Acento | accion/acento | texto/en-primario | sombra sólida inferior |
| Peligro | estado/ilegal | texto/en-primario | sombra sólida inferior |
| Fantasma | sin fondo | texto/acento | sin borde ni sombra (zona táctil ≥ 48) |
| Deshabilitado | fondo/superficie-alt | texto/secundario | sin sombra; semántica "deshabilitado" |
- Sombra sólida: desplazamiento (0, 4), desenfoque 0, color #0F294A al 18 % de opacidad (0x2E).
- Estado presionado (no está en Figma): bajar el botón 2 dp y reducir la sombra a 2; anótalo en el reporte como decisión. Con "reducir animaciones" activo, sin transición.
- Nombre accesible = texto visible.

## Campo de texto (`CampoTextoApp`)
Columna con hueco 6, ancho del contenedor (342): etiqueta superior, caja y mensaje de error opcional.
- Etiqueta: estilo Etiqueta (Inter SemiBold 12/16), color texto/primario. Siempre visible (no solo placeholder).
- Caja: alto 52, radio 14, fondo fondo/superficie, relleno horizontal 16, hueco 10, ícono inicial de 20.
- Valor: Cuerpo/Grande (Inter 16/24). En reposo con texto de ayuda: color texto/secundario; con valor: texto/primario.
| Estado | Borde |
|---|---|
| Reposo | 1.5 borde/control |
| Foco | 2 accion/primaria |
| Error | 2 estado/ilegal + mensaje debajo (Leyenda, estado/ilegal) |
- Opcional a la derecha: botón de mostrar/ocultar contraseña (zona ≥ 48). Teclado y autocompletado según el tipo (correo, contraseña, nombre).
- Semántica: la etiqueta se asocia al campo; el error se anuncia ("Ingresa un correo válido").

## Chip HUD (`ChipHud`)
Píldora (radio 999), fondo fondo/superficie, borde 1 borde/default, relleno izquierdo 10, derecho 12, vertical 6, hueco 6. Ícono de 20 y valor en Cuerpo/Énfasis (Inter SemiBold 14/20, texto/primario).
Tipos: **Vidas** (heart), **Monedas** (coin), **Racha** (flame), **Comodines** (bulb) y **Amparo** (shield-check; borde de 1.5 en accion/secundaria). Colores de los íconos: provisionales (Vidas estado/ilegal; Monedas y Racha accion/acento; Comodines texto/acento; Amparo accion/secundaria); si el diseño real difiere, ajustarlo después en revisión.
Semántica del contenedor: "Vidas: 4 de 5", "240 monedas", "Racha de 7 días".

## Corazón (`CorazonVida`)
24×24. **Llena**: heart relleno estado/ilegal. **Vacía**: contorno borde/control. Fila de 5 con hueco ≈ 10 (en el onboarding y "Sin vidas" se muestran a 33.6 con hueco 11.2; el tamaño es parámetro).

## Indicadores de la Startup (`IndicadoresStartup`)
Contenedor 342 de ancho (alto 46), fondo fondo/superficie, borde 1 borde/default, radio 16, relleno 10, cuatro columnas con espacio uniforme entre ellas. Cada columna (hueco 4): fila (ícono 14 + etiqueta Leyenda texto/secundario, hueco 3) y barra: pista de **68 de ancho** × 6 de alto, radio 3, fondo fondo/superficie-alt; relleno del mismo alto y radio con ancho = valor (0–100) × 68 / 100.
| Indicador | Ícono | Color del relleno |
|---|---|---|
| Presupuesto | coin | accion/acento |
| Reputación | star | estado/condicional |
| Velocidad | zap | estado/legal |
| Riesgo legal | alert | estado/ilegal |
Valores de ejemplo de Figma: 70, 60, 50 y 25. Semántica por barra: "Presupuesto 70 %" (progressbar). Quiebra si Presupuesto o Reputación = 0, o Riesgo legal = 100.
**Impacto** (`ImpactoStartup`, aparece tras un veredicto): fila con "Impacto:" (Etiqueta, texto/secundario) y hasta 4 chips (relleno de la píldora = color del indicador al 13 % de opacidad; relleno izq. 6, der. 8, vertical 3; ícono de 12; valor con signo "+5"/"−5" en Etiqueta con el color del indicador; hueco 3; hueco entre chips 6). Se muestran solo los que cambian. El cambio se comunica con signo y color (nunca solo color).

## Navegación inferior (`NavegacionInferiorApp`)
Ancho completo, alto 84 (58 de contenido + zona segura inferior; en Figma el relleno inferior es 26 por el indicador de inicio: usa `SafeArea` y documenta cómo lo resolviste), fondo fondo/superficie, borde superior 1 borde/default, relleno horizontal 20, cuatro elementos con espacio uniforme.
Elemento: columna centrada, hueco 4, relleno 14 horizontal / 6 vertical, radio 14, ícono de 24 y etiqueta Leyenda. Etiquetas: **Mapa** (map), **Buzón** (inbox), **Tienda** (store), **Perfil** (user). Activo: fondo fondo/destacado, texto e ícono accion/primaria; inactivo: texto/secundario. Zona táctil ≥ 48 dp. Semántica: "Pestaña Mapa, seleccionada, 1 de 4".
Nota: en Figma la primera pestaña se llama **Mapa** (la pantalla 07).

## Barra de progreso (`BarraProgreso`)
Alto 12, radio 6, pista fondo/superficie-alt, relleno accion/primaria (radio 6) con **brillo**: franja de 3 de alto, radio 2, blanco al 35 %, a 6 del borde izquierdo y 2.5 de arriba, ancho = relleno − 12. Ancho flexible (240 en el catálogo). Variantes de ejemplo: 10 %, 50 %, 80 %, 100 %. Semántica de progreso ("Tarjeta 5 de 10"). Animación suave del cambio (sin animación con "reducir animaciones").

## Paginador (`PaginadorPuntos`)
Alto 8, hueco 8. Punto inactivo 8×8 en borde/control; punto activo píldora de 28×8 en accion/primaria. Ejemplos: 4 puntos (ancho total 76). Semántica: "Página 2 de 4".

## Indicador de foco (`AnilloFoco`)
Envuelve un control: anillo de 3 en foco/anillo con separación de 2 (margen de 5 por lado) y radio = radio del control + 5. Se muestra solo al enfocar con teclado o switch control (`Focus`/`FocusableActionDetector`), no con el toque. Lo usan botón, campo, elementos de navegación y, más adelante, botones de veredicto y opciones.

## Sarko (`SarkoImagen`)
Imagen de la mascota por **pose/expresión**. Las imágenes están en la carpeta local `Imegenes/` de Claude Code (logos y poses). En T-01: moverlas a `assets/imagenes/` con nombres sin espacios, acentos ni símbolos (por ejemplo `sarko_alegre.png`), declararlas en `pubspec.yaml`, y exponer un `enum PoseSarko` con las que existan. Cada pose lleva texto alternativo descriptivo en español ("Sarko, cocodrilo juez, celebra con el mazo en alto"). Si el archivo no existe, mostrar un marcador. Los logos (vertical y horizontal) igual: `LogoApp` con variantes vertical/horizontal. Tamaños que usa el diseño: 264×330, 208×260, 184×230, 176×220, 160×200, 120×150, 104×130, 96×120, 88×110 (relación ancho:alto 4:5). No redibujar ni modificar las imágenes.

## Galería de componentes (temporal)
Pantalla de desarrollo que muestra todos los componentes de arriba en todos sus tipos y estados, con interruptor claro/oscuro, para revisarlos de un vistazo. Reemplaza a "Tema de prueba"; se elimina cuando existan las pantallas reales.

## Botón de veredicto (`BotonVeredicto`) — se construye en T-02
Columna centrada, hueco 6. Círculo de **68** con borde 3 en el color del estado, fondo fondo/superficie, sombra (0, 8, desenfoque 24, #0F294A al 14 %) e ícono de 32 en el mismo color. Debajo, etiqueta en mayúsculas con estilo Etiqueta (Inter SemiBold 12/16, tracking 0.2) en el color del estado.
| Tipo | Ícono | Etiqueta | Color |
|---|---|---|---|
| Ilegal | x | ILEGAL | estado/ilegal |
| Legal | check | LEGAL | estado/legal |
| Condicional | arrow-up | CONDICIONAL | estado/condicional (columna de 87 de ancho) |
| Escalar | arrow-down | ESCALAR | estado/escalar |
Sin `alPresionar` es decorativo (excluido de semántica); con él, zona táctil completa, anillo de foco y nombre accesible "Veredicto: Legal con condiciones", etc. Agregar el token **estado/escalar** (#6B4BA1 claro; oscuro propuesto #B9A0E8, a verificar por contraste).

## Fuera de T-01/T-02 (se especifican en su tarea)
Tarjeta de caso, sellos, snippet de evidencia, nodos del mapa, opciones de justificación, temporizador, panel de retroalimentación, barra de juego, tarjeta de módulo, artículo de tienda, aviso de conexión, barra de comodines, barra del Jefe, notificación y contraargumento.

## Componentes de acceso (se construyen en T-03)
- **Casilla (`CasillaApp`)**: cuadro de 22 (radio 6) y texto Leyenda (Inter Medium 11/14, `texto/primario`) a 10 de distancia; ancho del texto hasta 300. Marcada: relleno `accion/primaria` con ícono check de 14 en `texto/en-primario`. Sin marcar (no está en Figma): relleno `fondo/superficie` y borde 1.5 `borde/control`. Toda la fila es táctil (≥ 48 de alto) con anillo de foco; semántica de casilla marcada/sin marcar y mensaje de error opcional (Leyenda, `estado/ilegal`).
- **Chip de perfil (`ChipSeleccion`)**: píldora (radio 999), relleno horizontal 12 y vertical 10, texto Etiqueta (Inter SemiBold 12/16, tracking 0.2). Seleccionado: fondo y borde 1.5 `accion/primaria`, texto `texto/en-primario`. No seleccionado: fondo `fondo/superficie`, borde 1.5 `borde/default`, texto `texto/primario`. Hueco entre chips 8. Zona táctil ≥ 48 (sin cambiar el aspecto). Semántica de botón de opción seleccionado ("Perfil Desarrollador, seleccionado, 2 de 3").
- **Enlace de texto (`EnlaceTexto`)**: Cuerpo/Énfasis (Inter SemiBold 14/20) en `texto/acento`, zona táctil ≥ 48 de alto, anillo de foco, semántica de enlace/botón.
- **Botón de regreso (`BotonAtras`)**: cuadro de 48 con radio 12, fondo `fondo/superficie`, borde 1 `borde/default`, ícono `back` de 20; etiqueta "Atrás".

## Componentes del Inicio (se construyen en T-04)
Medidas en dp sobre el marco 390×844. Colores siempre por tokens.
- **Avatar con iniciales (`AvatarApp`)**: círculo de 44, `fondoDestacado`; iniciales en Fredoka SemiBold 17/22 `accionSecundaria`. Semántica: excluida (decorativa; el saludo ya dice el nombre).
- **Tarjeta héroe (`TarjetaHeroeStartup`)**: 342×168, `accionPrimaria`, radio 24, sombra (0,8,24, #0F294A 14 %), recorta lo que sobresale. Elipse decorativa de 220 en (190,-30). Etiqueta "TU STARTUP ESTÁ EN" (Leyenda, `textoEnPrimario`), título Fredoka Bold 26/32 a dos líneas (ancho 200), subtítulo Leyenda, botón "Continuar sprint" 148×48 (`accionAcento`, radio 12, texto Etiqueta + chevron 16) y Sarko 120×150 en (226,22).
- **Reto diario (`TarjetaRetoDiario`)**: 342×60, `fondoDestacado`, radio 18, relleno 14×12, separación 12; ícono flame 24, dos líneas de texto (Cuerpo/Énfasis y Leyenda secundario) y progreso "1/3" (Etiqueta, `textoAcento`).
- **Tarjeta de módulo (`TarjetaModulo`)**: 342 de ancho, radio 22, relleno 16, separación 14, borde 1 `bordeDefault`, sombra (0,8,12, #0F294A 14 %). Insignia 56×56 radio 16 con ícono 28; etiqueta "MÓDULO N · NOMBRE" (Leyenda), título Fredoka SemiBold 17/22, fila de progreso (barra 96×8 + "n/5 sprints") y chevron 20.
  - **En curso** (Figma): insignia del color del módulo, etiqueta en `textoAcento`.
  - **Bloqueado** (Figma): fondo `fondoSuperficieAlt`, insignia `fondoSuperficieAlt` con ícono lock, etiqueta `textoSecundario`, texto "Completa el módulo anterior", sin chevron activo, no se puede abrir.
  - **Disponible** y **Completado** (no están en Figma; derivados): Disponible = como En curso con 0/5; Completado = insignia del color del módulo con ícono check y texto "5/5 sprints · Completado".
  - Semántica: un solo botón con el texto "Módulo N, nombre, estado, progreso"; bloqueado queda deshabilitado y lo dice.
- **Botón Buzón con contador (`BotonBuzon`)**: 60×60, `accionSecundaria`, radio 20, sombra (0,16,40, #0F294A 22 %), ícono inbox 26; contador 24×22 `estadoIlegal` con borde 2 `fondoApp` y número Leyenda `textoEnPrimario`, en (46,-8) respecto al botón. Semántica: "Buzón de apelaciones, N pendientes". Si N = 0 no se dibuja el contador.

## Componentes del Mapa y la Intro del sprint (se construyen en T-04b)
Medidas en dp sobre el marco 390×844. Figma: 08 = `13:562`, 09 = `13:776`.
- **Encabezado del módulo (`EncabezadoModulo`)**: 390×150 (más la zona segura superior), fondo = color del módulo. Botón atrás 48 (blanco al 18 %, radio 12, ícono back 20 blanco) en (16,52); etiqueta "MÓDULO N · NOMBRE" (Leyenda, el color del módulo mezclado con blanco al 85 %) en (72,56); título del tramo (Fredoka SemiBold 20/26, blanco) en (72,72); `ChipHud` de vidas en (310,60); barra de avance de 298×8 en (20,118) (pista blanca al 25 %, relleno claro `#E0A060`, radio 4) y "n/5" (Etiqueta, blanco) en (330,113). Fijo arriba; el mapa se desplaza debajo.
- **Nodo de sprint (`NodoSprint`)**: cara circular sobre una base (sombra sólida inferior), con 4 estados. Completado: cara 72 `accionPrimaria`, ícono check 30 y 3 estrellas de 16 (separación 2) debajo; Actual: cara 80 `accionAcento`, ícono gavel 34 y un aro de pulso de 100; Bloqueado: cara 72 `fondoSuperficieAlt`, ícono lock 30; Jefe (Examen final): cara 92 `accionSecundaria`, ícono trophy 39. Etiqueta junto al nodo: "Sprint N" (Etiqueta, `textoPrimario`; `textoSecundario` si está bloqueado) y el título (Leyenda, `textoSecundario`).
- **Camino (`CaminoSprints`)**: línea curva decorativa que une los nodos (se dibuja con código, no con imagen).
- **Globo del sprint actual (`GloboSprintActual`)**: `fondoSuperficie`, radio 16, relleno 14×12, sombra elevada (0,16,40, 22 %). Título "Sprint N · título" (Cuerpo/Énfasis), "n tarjetas · ≈ m min" (Leyenda `textoSecundario`) y botón acento "Comenzar" de 170×48.
- **Fila de detalle (`FilaDetalleSprint`)**: ícono 22, título (Cuerpo/Énfasis) y texto (Leyenda `textoSecundario`), relleno vertical 12, separación 12. Tres filas dentro de una tarjeta `fondoSuperficie` de 342, borde 1 `bordeDefault`, radio 18, relleno horizontal 16.
