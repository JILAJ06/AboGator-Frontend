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
