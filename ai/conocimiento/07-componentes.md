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

## Componentes del juego: tarjeta swipe (se construyen en T-05)
Medidas en dp sobre el marco 390×844. Figma: 10 = `37:1676`, 11 = `37:2043`, 11b = `37:3376`, 11c = `37:3605`, 13 = `37:2845`, orden de foco 26b = `79:9056`.
- **Barra de juego (`BarraJuego`)**: alto 56 (en y=48), relleno horizontal 20, separación 14. Botón Salir 48×48 (`fondoSuperficie`, borde 1 `bordeDefault`, radio 12, ícono x 20); columna con "Sprint N · Tarjeta k de n" (Leyenda `textoSecundario`) y `BarraProgreso` de 12; `ChipHud` de vidas.
- **Tarjeta de caso (`TarjetaCaso`)**: 342×440, `fondoSuperficie`, borde 1 `bordeDefault`, radio 28, sombra de Figma (nodo `10:5`), relleno 24/22/20/22, separación 18. De arriba abajo: etiqueta del caso (chip con el color del módulo al 14 %, texto Leyenda `textoAcento`, ej. "CASO 4 · LICENCIAS OSS"); fila del personaje (avatar 48 `fondoDestacado` con iniciales Fredoka SemiBold 17/22 `accionSecundaria`, nombre Cuerpo/Énfasis y rol Leyenda `textoSecundario`); globo del caso (`fondoSuperficieAlt`, relleno 18, esquinas 6/20/20/20, texto Fredoka SemiBold 17/25 `textoPrimario`); espacio; pista de gesto (← ILEGAL en `estadoIlegal`, ↑ CONDICIONAL en `estadoCondicional` sobre ↓ ESCALAR en `estadoEscalar`, LEGAL → en `estadoLegal`). Las pistas llevan texto, no solo color.
- **Pila de tarjetas (`PilaTarjetas`)**: detrás de la tarjeta, dos tarjetas vacías: Pila 1 en (36,174) de 318×440 con opacidad 0.8 y Pila 2 en (48,184) de 294×440 con opacidad 0.5 (mismo estilo de tarjeta). Se dibujan solo si quedan tarjetas.
- **Sello (`SelloVeredicto`)**: recuadro `fondoSuperficie` con borde de 4 en el color del veredicto, radio 12, relleno 18×6, texto Fredoka Bold con espaciado 3: LEGAL e ILEGAL en 34, CON CONDICIONES y A JURÍDICO en 26. Legal e Ilegal van inclinados (leer el ángulo en los nodos `37:2132` y `37:2134`).
- **Tinte (`TinteVeredicto`)**: capa de pantalla completa en el color del veredicto, opacidad 0 en reposo y 0.10 al llegar al umbral.
- **Acciones (`AccionesVeredicto`)**: fila de los 4 `BotonVeredicto` (68 + etiqueta) separados 14, en este orden: Ilegal, Escalar, Condicional, Legal.
- **Barra de comodines (`BarraComodines`)**: tres píldoras de 48 de alto (borde 1.5 `accionAcento`, fondo `fondoSuperficie`, ícono 18 y texto Etiqueta): "Lupa ×2", "Abogado ×1", "Amparo ×1", separadas 8. En T-05 solo se muestran; se activan en T-07.

## Componentes del veredicto (se construyen en T-06)
Medidas en dp sobre el marco 390×844. Figma: Panel 12 = `37:2427` (pantalla `37:2287`), 12b = `37:2671` (`37:2531`), 12c = `37:4047` (`37:3907`), 14 = `37:3287` (`37:3147`), 14b = `38:5384` (`38:5240`). Es **un solo componente** (`PanelVeredicto`) con 5 variantes; cambian el color, el ícono, los textos, la pose de Sarko, el contenido central y el botón.
- **Contenedor:** pegado abajo, ancho completo; `fondoSuperficie`, esquinas superiores 28, sombra elevada (0,16,40, 22 %), relleno 12 arriba / 24 a los lados / 34 abajo (más la zona segura inferior), columna centrada. Separación 14 (en la variante Incorrecto 16). Agarre decorativo de 40×5, radio 3, `bordeDefault` (no se arrastra).
- **Encabezado** (fila, separación 12): a la izquierda una columna (separación 6) con la **insignia** (círculo de 30 con ícono blanco de 18 + título Fredoka SemiBold 20/26 en el mismo color) y debajo el **subtítulo** (Etiqueta 12/16, mismo color, ancho máx. 220); a la derecha `SarkoImagen` de 76.8×96. El título y el subtítulo pueden pasar a 2 líneas con texto grande.
- **Fila Impacto:** reusar `ImpactoStartup` ("Impacto:" + chips; solo los indicadores que cambian). Signo con "−" (U+2212).
- **Caja Explicación:** `fondoSuperficieAlt`, radio 16, relleno 16×14, separación 6: "¿Por qué?" (Cuerpo/Énfasis `textoPrimario`) y el texto (Cuerpo/Base `textoPrimario`).
- **Micro-pregunta (solo variante Correcto):** reemplaza la caja Explicación; `fondoDestacado`, radio 16, relleno 16×14, separación 10. Título: ícono star 18 + "Bonus +5 XP: {enunciado}" (Cuerpo/Énfasis `textoPrimario`); debajo 2 o 3 `OpcionJustificacion` (la misma de la tarjeta de justificación: `fondoSuperficie`, borde 1.5 `bordeDefault`, radio 16, relleno 16×14, radio de selección 24 con borde 2 `bordeControl`, texto Cuerpo/Base). Seleccionar una opción la confirma de inmediato (no hay botón "Responder").
- **Acierto sin micro-pregunta, o con la micro-pregunta saltada o fallada:** misma variante Correcto pero con la caja Explicación en lugar de la micro-pregunta y el botón "Continuar" (primario).
- **Botón:** ancho completo, alto 52. Correcto con micro-pregunta: "Saltar bonus" (fantasma). Bonus y Parcial: "Continuar" (primario). Incorrecto: "Entendido" (peligro, `estadoIlegal`). Amparo: "Entendido" (secundario con borde 2 `accionSecundaria`).
| Variante | Cuándo | Insignia (color · ícono) | Título | Subtítulo | Sarko | Contenido | Botón |
|---|---|---|---|---|---|---|---|
| Correcto (12) | acierto con micro-pregunta | `estadoLegal` · check | ¡Veredicto correcto! | +10 XP · +5 monedas | alegre | Impacto + Micro-pregunta | Saltar bonus |
| Bonus (12b) | acierto con la micro-pregunta bien respondida | `estadoLegal` · star | ¡Bonus ganado! | +15 XP en total · +5 monedas | alegre | Impacto + Explicación | Continuar |
| Parcial (12c) | Escalar cuando no hacía falta | `estadoEscalar` · arrow-down | Respuesta parcial | +3 XP · no pierdes vida | sorprendido | Impacto + Explicación | Continuar |
| Incorrecto (14) | error sin Amparo | `estadoIlegal` · x | Veredicto incorrecto | −1 vida · Se guarda en tu Buzón de Apelaciones | triste | Impacto + Explicación | Entendido |
| Amparo (14b) | error con Amparo activo | `accionSecundaria` · shield-check | ¡El Amparo te protegió! | Veredicto incorrecto · conservas tu vida | sorprendido | Impacto + Explicación | Entendido |
- **Chips de impacto** (fondo = color al 13 %, texto en su color): Presupuesto `textoAcento` (ícono coin), Reputación `estadoCondicional` (star), Velocidad `estadoLegal` (zap), Riesgo legal `estadoIlegal` (alert). Texto Etiqueta 12/16, relleno 6/8/3/3, radio 999.
- **Accesibilidad:** el panel es un diálogo modal sin descarte (no se cierra con atrás, Esc ni tocando fuera: el jugador debe pulsar el botón). Al abrirse, el foco pasa al título y se anuncia "{título}. {subtítulo}. Impacto: …". El orden de foco es título → impacto → explicación o micro-pregunta → botón. Sarko y el agarre no se leen. Nada depende solo del color (ícono, título y signo).
- **Animación:** el panel sube desde abajo en 280 ms (ease-out) y la caja de la Startup de la pantalla de atrás anima sus barras al nuevo valor. Con `MediaQuery.disableAnimationsOf` verdadero, aparece sin movimiento y las barras saltan.
- **Vibración:** correcto y bonus `lightImpact`, parcial `selectionClick`, incorrecto y Amparo `mediumImpact` (ignorar en web).

## Componentes del fin de sprint (se construyen en T-06b)
Medidas en dp sobre el marco 390×844 (posiciones absolutas de Figma; en código usar una columna desplazable con las mismas separaciones). Figma: 19 = `38:5557`, 19b = `37:4136`. Sin navegación inferior.
- **Confeti (`ConfetiSprint`)**: 7 piezas de 12×6 (radio 2) con inclinación, decorativas: `(60,120)` `#B86B23`; `(320,144)` `#68B678` −30°; `(90,240)` `#2B5FA8` −60°; `(300,87)` `#B52426` −15°; `(200,62)` `#E0A060` −45°; `(40,296)` `#68B678` −20°; `(340,269)` `#B86B23` −70°. Los colores van en `EfectosApp` (no son tokens). Caen una vez al abrir la pantalla (≈ 1.2 s); con reducir animaciones aparecen quietas. No se leen.
- **Ilustración de Sarko**: fondo circular de 200 en (95,70) (en 19b de 220 en (85,128)) con `SarkoImagen` alegre de 160×200 en (115,74) (en 19b triste de 176×220 en (107,132)). Reusar el recurso del fondo si ya existe en `assets`; si no, es un círculo `fondoDestacado` con transparencia leída del SVG de Figma (nodos `38:5576` y `37:4186`).
- **Estrellas (`EstrellasSprint`)**: fila centrada en y=284, tres íconos star de 36 · 46 · 36 alineados abajo, separación 6. Llenas en `accionAcento` las ganadas; las no ganadas en contorno `bordeControl`. Se anuncian como un texto: "N de 3 estrellas".
- **Título** Fredoka Bold 26/32 `textoPrimario` centrado (y=338); **subtítulo** Cuerpo/Base `textoSecundario` centrado, ancho 342 (y=374).
- **Estadísticas (`EstadisticasSprint`)**: fila en (24,424), tres tarjetas de 107 de ancho, separación 10, `fondoSuperficie`, borde 1 `bordeDefault`, radio 18, relleno vertical 12, columna centrada con separación 4: ícono de 20 (check, star, coin), valor Fredoka SemiBold 20/26 `textoPrimario`, etiqueta Leyenda `textoSecundario`. Contenido: "8/10 · Aciertos", "+95 · XP (con bonus)", "+45 · Monedas". Se leen como un bloque: "8 de 10 aciertos, 95 XP con bonus, 45 monedas".
- **Estado final**: texto Etiqueta `textoSecundario` "Estado final de tu Startup" (24,536) y debajo `IndicadoresStartup` (24,556, 342) mostrando el **cambio respecto al inicio del sprint** junto a cada barra que cambió (en Figma 19: Reputación +15 y Riesgo legal +5).
- **Aviso de buzón / de reinicio (`AvisoInformativo`)**: `fondoDestacado`, radio 16, relleno 14×10 (12 vertical en 19b), separación 10, ícono de 20 (inbox en 19, info en 19b) y texto Leyenda `textoPrimario`; ancho 342.
- **Etiqueta de quiebra (`EtiquetaQuiebra`, solo 19b)**: píldora `estadoIlegal` (relleno 12×6, separación 6) con ícono trending-down 16 y "RIESGO LEGAL 100%" (Etiqueta, `textoEnPrimario`), centrada en y=364. Si la causa es el Presupuesto: "PRESUPUESTO 0%".
- **Botones**: primario 342×52 y fantasma 342×48 debajo (separación 8). 19: "Continuar al mapa" y "Repasar mis fallos". 19b: "Reiniciar sprint" y "Ir al Buzón de Apelaciones".
- **Indicadores en 19b** (24,64): los valores del momento de la quiebra con su cambio (Presupuesto −60, Riesgo legal +40 en Figma).

## Componentes de evidencia y justificación (se construyen en T-07)
Figma: 15 = `38:3956`, 16 = `38:4155`, 16b = `38:4355`, 17 = `38:4556`, 18 = `38:4737`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-07.
- **Tarjeta con evidencia:** chip "Evidencia" (`accionSecundaria`, ícono eye) y botón discontinuo "Toca la tarjeta para inspeccionar" (48, borde 2 `accionSecundaria`, radio 14, ícono code 20).
- **Visor (panel modal):** sin marcar (16): ícono highlighter, instrucción, snippet y botón deshabilitado "Marca una línea para continuar"; marcado (16b): "Línea marcada", snippet con líneas clave reveladas, chip `fondoDestacado` "Evidencia correcta: +5 XP al acertar el veredicto" y "Volver y decidir".
- **`SnippetCodigo`:** fondo `#0B1220`, barra `#162030` con 3 círculos y nombre de archivo, números `#94A3B8`, texto `#E2E8F0`; línea clave `rgba(181,36,38,0.28)` con texto `#FECACA`; línea marcada con `#FFE27A` (borde 2, multiply 55 %). Colores en `EfectosApp`.
- **Tarjeta de justificación:** chip "Dilema ×2" (`accionAcento`, ícono star) y aviso `fondoDestacado` "Después de deslizar tendrás que justificar tu veredicto. Acertar ambas partes = monedas dobles."
- **Panel de justificación (18):** chip "Dictaste: …" del color del veredicto, título "¿Por qué es …?" (Fredoka Bold 26), 3 `OpcionJustificacion` (seleccionar no confirma) y "Confirmar justificación". Resultado: 12b con "+15 XP en total · +10 monedas" si acierta veredicto y justificación.

## Componentes de comodines (T-07b)
Figma: 10b = `38:4914`, 10c = `38:5065`; barra `33:393`. Medidas completas en el historial de la T-07b.
- **`BarraComodines`:** tres píldoras interactivas (alto ≥ 48, borde 1.5 `accionAcento`). Estados: disponible, activa (`accionAcento` con texto `textoEnPrimario`), deshabilitada (`fondoSuperficieAlt`). Parámetro `habilitados` para apagarla en el Examen final (RN03).
- **`TextoConTrampas` y `EtiquetaLupa`:** resaltado de las palabras trampa (subrayado `#FFD84D` al 65 %, en `EfectosApp`) y etiqueta "Lupa de Auditor: palabras trampa resaltadas".
- **`PanelAbogado`:** panel modal descartable con la traducción legal y las normas; gasta 1 la primera vez por tarjeta.
- **Amparo:** se arma sin costo y se gasta al absorber un error (panel 14b).

## Componentes de vidas y conexión (se construyen en T-08)
Figma: 20 = `17:2072`, 23 = `41:5976`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-08.
- **`CuentaRegresivaVida`:** `HH:MM:SS` en Fredoka Bold 52 `estadoIlegal`; cuenta con reloj monótono a partir de lo que manda el servidor; semántica por minuto.
- **Sugerencia del Buzón:** `fondoDestacado`, radio 22, relleno 18; cuadrado 44 `accionSecundaria` con ícono `inbox`, texto con N apelaciones y botón primario "Ir al Buzón de Apelaciones".
- **`AvisoConexion`:** superpuesto a la tarjeta, borde 1.5 `accionAcento` (5 a la izquierda), ícono `info`, "Conexión inestable. Se guardará tu progreso localmente."; `liveRegion`, no recibe toques.
- **`IndicadorPendientes`:** ícono `refresh` 14 + "N respuestas guardadas en el dispositivo (SQLite)" (Leyenda `textoAcento`); reemplaza la barra de comodines sin conexión.

## Componentes del Buzón de Apelaciones (se construyen en T-09; el juicio, en T-09b)
Figma: 21 = `41:5631`, 21b = `41:5499`, 22 = `41:5785`, 22b = `41:5862`. Medidas y reglas completas en `ai/siguiente.md` de la T-09.
- **Recompensa:** `fondoDestacado`, radio 18, cuadrado 40 `estadoIlegal` con `heart`; "N juicios de apelación hoy" y "Gana cada apelación y recupera 1 vida".
- **Fila de apelación:** franja 6×40 con el color del módulo, título, tema y píldora de plazo (de hoy: `estadoIlegal` con `gavel` y "Día N · hoy · +1 vida"; futura: `fondoSuperficieAlt` con `clock` y "Día N · mañana / en N días"), `chevron` 18. Plazos con la fecha del servidor.
- **Notificación (21b):** `NotificacionApelacion`, 358 de ancho, ícono de app 38 y texto "⚖️ Tienes un juicio de apelación pendiente"; solo maqueta y enlace profundo.
- **Juicio (22), T-09b:** barra "Apelación k de n" con chip "+1 vida", tarjeta "APELACIÓN · TEMA", aviso "La fallaste hace N días" y las 4 acciones, sin indicadores ni comodines.
- **Apelación ganada (22b), T-09b** (y la perdida, sin Figma: Sarko triste, "No pierdes vidas", "Apelación perdida"): Sarko, 5 corazones, "+1 vida recuperada", título, explicación y fila "Día 3 · Día 7 · Día 14" (hecho = `estadoLegal` con `check`).


## Componentes de la Tienda y el Perfil (se construyen en T-10)
Figma: 24 = `18:2347`, 25 = `18:2492`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-10.
- **Tienda:** píldora de saldo (`fondoDestacado`, moneda 22), píldoras de inventario (borde 1, ícono 16, "Lupa ×2"), tarjeta de artículo (ancho 165, radio 22, ícono en cuadro 52 `fondoDestacado`) y botón de precio (alto 48, `accionPrimaria`; deshabilitado en `fondoSuperficieAlt` con "Te faltan N" o "Máximo"). La compra pide confirmación en un diálogo y se anuncia en una región en vivo.
- **Perfil:** tarjeta de perfil (`accionPrimaria`, avatar 60 con iniciales), tarjeta de estadística (166, radio 16), medalla de insignia (60, borde 3 `accionAcento`, color del módulo; bloqueada en `fondoSuperficieAlt` con `lock`) y menú agrupado con filas ≥ 48 y chevron.
- **Diálogo de confirmación:** `fondoSuperficie`, radio 22, título Fredoka SemiBold 20, botón primario y fantasma de alto 48; lo usan la compra y "Cerrar sesión".

## Componentes de Ajustes (se construyen en T-10b)
Figma: 26 = `18:2634`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-10b.
- **Tarjeta de sección:** `fondoSuperficie`, borde 1, radio 18, filas de relleno 16×12 con ícono 22, texto (Cuerpo/Énfasis + Leyenda) y control; el toque abarca toda la fila (≥ 56).
- **Interruptor** 48×28 (radio 14, pulgar 22) con contraste ≥ 3:1; **chip de valor** (`fondoSuperficieAlt`, radio 10); **selector de tamaño** (hoja modal con 100/120/140/160 %).
- **Servicio háptico:** acierto ligero, parcial de selección, error doble, suave; apagable desde Ajustes.

## Componentes del Examen Final (se construyen en T-11)
Figma: 27 = `42:5885`, 28 = `42:6027`, 28b = `42:6140`, 28c = `42:6284`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-11.
- **`BarraDelJefe`:** `#162030`, radio 18, avatar 44 `#6B4BA1` con `gavel`, nombre, "HP N%" y vida `#F07070` proporcional al HP.
- **`LineaDeCrisis`:** cuatro puntos (H0, H6, H24, H72) con conectores; el activo en `#B52426`.
- **`TemporizadorCrisis`:** anillo de 64 sobre un círculo de 80; normal `accionPrimaria`, urgente (≤ 5 s) `estadoIlegal`.
- **Chips de hora, daño y fallo:** pastillas de radio 999; hora y daño en `#B52426`, fallo con borde `estadoIlegal`.
- **`PanelContraargumento`:** panel inferior sin descarte con la réplica, dos `OpcionJustificacion` y la cuenta regresiva.
- La pantalla 27 es siempre oscura: sus colores viven en `EfectosApp`.

## Componentes del resultado del Examen (se construyen en T-11b)
Figma: 29 = `18:2916`, 30 = `18:3036`. Medidas, textos y reglas completos en `ai/siguiente.md` de la T-11b.
- **`TarjetaCertificado`:** 342 de ancho, `fondoSuperficie`, borde 2 punteado `accionAcento`, radio 20, padding 20; logo horizontal, "CERTIFICADO DE MÓDULO" (Etiqueta `textoAcento`), módulo (Fredoka SemiBold 20/26), persona · aciertos · fecha y folio (Leyenda `textoSecundario`).
- **Confeti de 29:** `ConfetiSprint` con 8 piezas de 12×6 (parametrizable; el valor por defecto sigue siendo el de 19).
- **Trofeo:** círculo de 96 `accionAcento`, borde 6 `fondoDestacado`, ícono `trophy` de 48.
- **Resumen del examen (30):** tres tarjetas de 107 (`fondoSuperficie`, borde 1, radio 16): "Llegaste a", "Aciertos" (`estadoLegal`) y "Por tiempo" (`estadoIlegal`); en columna con texto grande.
- **Próxima vida (30):** `fondoDestacado`, radio 16, ícono `clock` 20 y cuenta regresiva del servidor.

## Componentes de tablet (se construyen en T-12; el resto, en T-12b, c y d)
Figma: páginas "Tablet · Vistas" (`94:23`), "Tablet · Navegación" (`103:23`); reglas de adaptación `106:10163`. Medidas completas en `ai/siguiente.md` de la T-12.
- **Clases de pantalla:** móvil (< 600), tablet (≥ 600) y ancho (≥ 960); se decide por el ancho disponible.
- **`RielNavegacion`:** 104 de ancho, `fondoSuperficie`, borde derecho 1; destinos de 80×72 con indicador 56×32 (activo `fondoDestacado`), insignia del Buzón de 20 `estadoIlegal`, Ajustes (48) y Avatar (48) abajo. Sustituye a la navegación inferior y al botón flotante del Buzón.
- **Inicio en tablet:** dos columnas (620 y 382) con "Tu semana", tarjeta del Buzón y "Consejo de Sarko".

## Mapa + detalle en tablet (se construye en T-12b)
Figma: T08 = `96:582`; Tienda T24 = `101:4306`, Perfil T25 = `101:4553`, Ajustes T26 = `101:4759`. Medidas en `ai/siguiente.md` de la T-12b.
- **Lista-detalle del mapa (ancho ≥ 960):** panel izquierdo de 596 (encabezado del módulo de 134 y camino de sprints × 1.12 centrado) y panel derecho de 494 (`fondoSuperficie`, borde izquierdo 1) con la ilustración, etiqueta, título, objetivo, tarjeta de detalles y "Comenzar sprint". El detalle es el mismo widget de la intro móvil.

## Juego en tablet (se construye en T-12c)
Figma: T10 = `97:772`; resto de vistas del juego en "Tablet · Vistas" (sección T3 y T3b). Medidas en `ai/siguiente.md` de la T-12c.
- **Zona de juego + panel lateral (ancho ≥ 960):** barra de juego de 64 (salir, progreso de 12, HUD y pausa), tarjeta de 380 × 470 con pila de dos, botones de veredicto de 68 y comodines a la izquierda; a la derecha una columna de 376 con "Tu Startup", contexto del sprint y atajos de teclado.
- **`HojaLateral`:** contenedor de 376 a la derecha (borde 1, radio 28, agarre de 40 × 5) que aloja los paneles de veredicto, evidencia, justificación, Abogado y bonus con el velo al 40 %.

## Resultados, Buzón y Examen en tablet (se construye en T-12d)
Figma: T19 = `98:5016`, T21 = `100:4028`; el resto en "Tablet · Vistas". Medidas en `ai/siguiente.md` de la T-12d.
- **Pantallas de resultado (ancho ≥ 960):** Sarko en un panel `fondoSuperficie` de 597 a la izquierda y el contenido en una columna centrada de 470 (título, estadísticas en tres tarjetas iguales, indicadores de la Startup, aviso del buzón y botones).
- **Buzón en lista-detalle:** lista de 500 (recompensa, tarjetas falladas con chip de plazo, botón de hoy) y panel de detalle de 526 con la vista previa del juicio de la tarjeta seleccionada.
