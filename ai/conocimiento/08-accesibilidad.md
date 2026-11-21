# 08 · Accesibilidad (WCAG 2.1 AA)

Resultado de la auditoría de la T-13 en móvil y tablet: cómo cumple la app cada criterio, qué prueba lo verifica y qué queda para revisión manual. Las pruebas automáticas viven en `test/auditoria/`.

## Cómo se audita (automático)
- **Matriz** (`test/auditoria/matriz.dart` + `catalogo.dart`, cinco archivos `auditoria_*_test.dart`): 50 escenas × 4 tamaños × 2 temas × 3 escalas de texto = **1200 pruebas**.
  - Escenas: las 30 vistas de Figma en sus estados principales, más Ajustes, el selector de tamaño y los diálogos de compra, cerrar sesión, salir y pausa.
  - Tamaños: 360×640, 390×844, 834×1194 y 1194×834.
  - Temas: claro y oscuro. Texto al 100, 160 y 200 %.
  - En cada combinación se verifica:
    - que no haya desbordes ni excepciones de dibujo;
    - zona táctil ≥ 48 × 48 (Android) y ≥ 44 × 44 (iOS), con `ZonaTactilMinima` (ver la nota de abajo);
    - nombre accesible en todo lo que se toca (`labeledTapTargetGuideline`);
    - contraste del texto pintado (`textContrastGuideline`).
- **Contrastes de tokens** (`contrastes_test.dart`): la tabla de abajo, en claro y oscuro.
- **Criterios** (`criterios_test.dart`):
  - orientación y rotación;
  - foco visible en cada parada de Tab;
  - teclado (Tab, Shift+Tab, Enter, Espacio, Esc y P) y diálogos que encierran y devuelven el foco;
  - "Solo botones" con "Reducir animaciones";
  - información que no depende solo del color;
  - la propia guía de zona táctil.
- **Pulido** (`pulido_test.dart`): orden de foco 26b en juego, juicio y Examen (móvil y tablet), foco tras los diálogos, anuncio único del Buzón y tarjeta retenida en tablet.
- **Nota sobre `ZonaTactilMinima`.** Es la guía de Flutter con un arreglo.
  - La original quiere omitir los controles cortados por el borde de su desplazable, pero compara rectángulos en sistemas de coordenadas distintos. Por eso no reconoce el recorte cuando el desplazable no empieza en el origen de su padre, como el mapa bajo su encabezado fijo.
  - Todo control que se ve completo se mide igual que en la original. Una prueba confirma que la guía detecta un control de 40 × 40.

## Matriz WCAG 2.1 AA
| Criterio | Cómo se cumple | Verificación |
|---|---|---|
| 1.1.1 Contenido no textual | Íconos decorativos fuera de la semántica (`IconoApp` sin etiqueta); Sarko con descripción solo cuando aporta; confeti y caminos excluidos. | Matriz (`labeledTapTargetGuideline`), `imagenes_e_iconos_test`. **Manual:** escuchar con TalkBack y VoiceOver. |
| 1.2.x Multimedia | No hay audio ni video. | No aplica. |
| 1.3.1 Información y relaciones | Encabezados con `header`, grupos con `container`, listas con su total ("Lista de N apelaciones"), radios en grupo exclusivo. | Pruebas de semántica de cada pantalla. |
| 1.3.2 Secuencia significativa | Orden de lectura = orden visual; donde no, `OrdinalSortKey` o `ElementoOrdenado` (resultados, mapa). | Pruebas de orden de foco y de lectura. |
| 1.3.3 Características sensoriales | Las instrucciones nombran el botón o el texto, no solo la posición o el color. | Revisión de `textos.dart`. |
| 1.3.4 Orientación | Teléfono solo en vertical (diseño móvil); **tablet en todas las orientaciones** (`orientacionesPermitidas`, T-13). Rotar conserva el estado. | `criterios_test`: orientación y rotación en juego, Buzón y Examen. **Manual** en dispositivo. |
| 1.3.5 Propósito de la entrada | `autofillHints` (correo, contraseña, nombre) y teclado del tipo correcto. | Pruebas de acceso. |
| 1.4.1 Uso del color | Veredictos con texto e ícono, impactos con signo ("+5", "−10"), plazos con ícono y texto, nodos del mapa con ícono. | `criterios_test`: "No depender solo del color". |
| 1.4.2 Control del audio | No hay audio. | No aplica. |
| 1.4.3 Contraste (mínimo) | Solo tokens de tema (tabla de abajo). | `contrastes_test` y `textContrastGuideline` en la matriz. |
| 1.4.4 Cambio de tamaño del texto | Escala del sistema × ajuste (100 a 160 %) con tope en 200 %, sin desbordes. | Matriz al 100, 160 y 200 %. **Manual:** texto grande del sistema. |
| 1.4.5 Imágenes de texto | Ningún texto se dibuja como imagen (el logo es marca). | Revisión. |
| 1.4.10 Reajuste | Desde 360 de ancho sin desplazamiento horizontal; en tablet las dos zonas pasan a una columna cuando no caben. | Matriz (360×640 y 834×1194 al 200 %). |
| 1.4.11 Contraste sin texto | Bordes de controles, anillo de foco y barras ≥ 3:1. | `contrastes_test` (pares "componente"). |
| 1.4.12 Espaciado del texto | Ningún texto tiene alto fijo; crecen con la escala. | Matriz al 200 %. |
| 1.4.13 Contenido al pasar o enfocar | No hay tooltips ni contenido que aparezca al enfocar. | Revisión. |
| 2.1.1 Teclado | Todo funciona con Tab, Enter o Espacio, flechas en el juego y en el Buzón, Esc en paneles descartables y P (pausa del Examen). | `criterios_test` (teclado), `pulido_test` (26b). **Manual:** teclado físico en tablet. |
| 2.1.2 Sin trampas de teclado | Los diálogos encierran el foco y lo devuelven al cerrar. El panel de veredicto no se descarta, pero su botón siempre se alcanza. | `criterios_test`: diálogo con Tab y Esc. |
| 2.1.4 Atajos de una tecla | Flechas y P solo actúan con el foco dentro de la pantalla del juego o del Examen. | Revisión. |
| 2.2.1 Tiempo ajustable | El Examen es una prueba con tiempo (excepción "esencial"); aun así hay "Tiempo extendido" (+50 %) y pausa (botón y tecla P). La cuenta de vidas solo informa. Ningún otro límite de tiempo. | `jefe_test`; `criterios_test` (pausa y P). |
| 2.2.2 Pausar, detener, ocultar | El confeti dura ≈ 1.2 s y no se repite; con "Reducir animaciones" no hay movimiento. | Pruebas de confeti y de reducir animaciones. |
| 2.3.1 Tres destellos | No hay destellos. | Revisión. |
| 2.4.2 Titulado | Cada pantalla abre con su título como encabezado y con el foco inicial. | Pruebas de cada pantalla. |
| 2.4.3 Orden del foco | Ver "Orden de foco". | `pulido_test` (26b) y pruebas de orden de cada pantalla. |
| 2.4.4 Propósito de los enlaces | Enlaces con texto propio ("Regístrate", "Aviso de Privacidad"). | Pruebas de acceso. |
| 2.4.6 Encabezados y etiquetas | Etiqueta visible en los campos (no solo el texto de ayuda) y encabezados descriptivos. | Pruebas de componentes. |
| 2.4.7 Foco visible | `AnilloFoco` (3 dp, `foco/anillo`) en todo control enfocable y en la tarjeta del juego. El control enfocado siempre se desplaza a la vista (`FocoSiempreVisible`, T-13). | `criterios_test`: anillo en cada parada de Tab de 8 pantallas y del acceso, en móvil y tablet. |
| 2.5.1 Gestos del puntero | El deslizamiento tiene botones equivalentes. Con "Solo botones" no hay arrastre (juego, juicio, Examen y onboarding). | `criterios_test` (sprint solo con botones), `pulido_test` (onboarding). |
| 2.5.2 Cancelación del puntero | Los botones actúan al soltar; soltar la tarjeta antes del umbral la regresa. | Pruebas del juego. |
| 2.5.3 Etiqueta en el nombre | El nombre accesible empieza por el texto visible ("Comprar Lupa…", "Veredicto: Legal"). | Pruebas de semántica. |
| 2.5.4 Activación por movimiento | No se usa el movimiento del dispositivo. | No aplica. |
| 3.1.1 Idioma | `locale` es-MX en toda la app. | `app.dart`. |
| 3.2.1 y 3.2.2 Al enfocar o introducir datos | Enfocar no cambia de pantalla; los ajustes se aplican al instante y se anuncian, sin navegar. | Pruebas de Ajustes. |
| 3.2.3 y 3.2.4 Navegación y nombres coherentes | La misma barra o el mismo riel y los mismos nombres en todas las pantallas. | Pruebas del riel y de la navegación. |
| 3.3.1 Identificación de errores | Error bajo cada campo, en región en vivo, y foco en el primero (el grupo de perfiles se muestra completo). | Pruebas de acceso y matriz (06 con errores). |
| 3.3.2 Etiquetas o instrucciones | Etiqueta visible en cada campo; dos casillas de consentimiento separadas. | Pruebas de registro. |
| 3.3.3 Sugerencia ante errores | Los mensajes dicen cómo corregir ("Ingresa un correo válido"). | `validadores_test`. |
| 3.3.4 Prevención de errores | Compra, cierre de sesión y salida del Examen piden confirmación. | Pruebas de Tienda, Perfil y Examen. |
| 4.1.2 Nombre, función y valor | Botones, casillas, interruptores y radios con su función y estado en `Semantics`. | Matriz y pruebas de componentes. |
| 4.1.3 Mensajes de estado | Avisos con `liveRegion` o `SemanticsService.sendAnnouncement` (compra, guardado, selección del Buzón una sola vez). | `pulido_test` (anuncio único), pruebas de Tienda y Ajustes. |

**Solo manuales:**
- cómo suena de verdad con TalkBack y VoiceOver (pronunciación, pausas, que no se repitan anuncios);
- el teclado físico en una tablet real;
- el texto grande del sistema (además del ajuste de la app);
- la rotación en dispositivo;
- el modo oscuro del sistema.

Ver la lista de verificación al final.

## Contrastes de tokens
Razones calculadas con la fórmula de WCAG 2.1 (`Contraste.razon`): texto normal ≥ 4.5:1, componentes y gráficos ≥ 3:1. La prueba `contrastes_test.dart` usa esta misma tabla.

| Frente | Fondo | Tipo (mínimo) | Claro | Oscuro | Uso |
|---|---|---|---|---|---|
| `texto/primario` | `fondo/app` | texto (≥ 4.5:1) | 13.84 | 17.89 | títulos y cuerpo |
| `texto/primario` | `fondo/superficie` | texto (≥ 4.5:1) | 14.48 | 15.64 | tarjetas |
| `texto/primario` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 13.21 | 13.83 | globo |
| `texto/primario` | `fondo/destacado` | texto (≥ 4.5:1) | 10.22 | 11.83 | avisos |
| `texto/secundario` | `fondo/app` | texto (≥ 4.5:1) | 7.24 | 7.30 | subtítulos |
| `texto/secundario` | `fondo/superficie` | texto (≥ 4.5:1) | 7.58 | 6.38 | leyendas |
| `texto/secundario` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 6.92 | 5.64 | chip de plazo, botón deshabilitado |
| `texto/secundario` | `fondo/destacado` | texto (≥ 4.5:1) | 5.35 | 4.83 | recompensa del Buzón |
| `texto/acento` | `fondo/app` | texto (≥ 4.5:1) | 6.25 | 8.35 | enlaces |
| `texto/acento` | `fondo/superficie` | texto (≥ 4.5:1) | 6.54 | 7.30 | etiquetas |
| `texto/acento` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 5.97 | 6.45 | etiquetas |
| `texto/acento` | `fondo/destacado` | texto (≥ 4.5:1) | 4.61 | 5.52 | "La fallaste hace N días", reto diario |
| `accion/primaria` | `fondo/destacado` | texto (≥ 4.5:1) | 6.74 | 5.04 | pestaña activa |
| `accion/primaria` | `fondo/superficie` | texto (≥ 4.5:1) | 9.55 | 6.66 | textos |
| `texto/en-primario` | `accion/primaria` | texto (≥ 4.5:1) | 9.55 | 7.62 | botón primario |
| `texto/en-primario` | `accion/acento` | texto (≥ 4.5:1) | 5.45 | 8.35 | botón acento |
| `texto/en-primario` | `estado/ilegal` | texto (≥ 4.5:1) | 6.47 | 6.47 | botón peligro, chip de hoy, insignia |
| `texto/en-primario` | `accion/secundaria` | texto (≥ 4.5:1) | 14.62 | 15.19 | insignia del Amparo, Buzón |
| `texto/en-primario` | `estado/legal` | texto (≥ 4.5:1) | 6.53 | 8.99 | insignia acierto |
| `accion/primaria` | `fondo/superficie-alt` | componente (≥ 3:1) | 8.72 | 5.89 | barra de progreso |
| `accion/secundaria` | `fondo/superficie-alt` | componente (≥ 3:1) | 13.35 | 11.73 | barra del Examen |
| `accion/acento` | `fondo/superficie-alt` | componente (≥ 3:1) | 4.97 | 6.45 | barra de Presupuesto |
| `estado/legal` | `fondo/app` | texto (≥ 4.5:1) | 6.24 | 8.99 | sellos, pistas y veredictos |
| `estado/legal` | `fondo/superficie` | texto (≥ 4.5:1) | 6.53 | 7.86 | sellos, pistas y veredictos |
| `estado/legal` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 5.96 | 6.95 | sellos, pistas y veredictos |
| `estado/ilegal` | `fondo/app` | texto (≥ 4.5:1) | 6.19 | 6.47 | sellos, pistas y veredictos |
| `estado/ilegal` | `fondo/superficie` | texto (≥ 4.5:1) | 6.47 | 5.65 | sellos, pistas y veredictos |
| `estado/ilegal` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 5.91 | 5.00 | sellos, pistas y veredictos |
| `estado/condicional` | `fondo/app` | texto (≥ 4.5:1) | 6.07 | 7.02 | sellos, pistas y veredictos |
| `estado/condicional` | `fondo/superficie` | texto (≥ 4.5:1) | 6.35 | 6.13 | sellos, pistas y veredictos |
| `estado/condicional` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 5.80 | 5.42 | sellos, pistas y veredictos |
| `estado/escalar` | `fondo/app` | texto (≥ 4.5:1) | 6.38 | 8.25 | sellos, pistas y veredictos |
| `estado/escalar` | `fondo/superficie` | texto (≥ 4.5:1) | 6.67 | 7.21 | sellos, pistas y veredictos |
| `estado/escalar` | `fondo/superficie-alt` | texto (≥ 4.5:1) | 6.09 | 6.38 | sellos, pistas y veredictos |
| `accion/secundaria` | `fondo/app` | texto (≥ 4.5:1) | 13.97 | 15.19 | botón secundario |
| `accion/secundaria` | `fondo/superficie` | texto (≥ 4.5:1) | 14.62 | 13.27 | botón secundario |
| `borde/control` | `fondo/app` | componente (≥ 3:1) | 4.55 | 3.93 | campos, casillas, interruptor, puntos |
| `borde/control` | `fondo/superficie` | componente (≥ 3:1) | 4.76 | 3.44 | campos, casillas, interruptor, puntos |
| `borde/control` | `fondo/superficie-alt` | componente (≥ 3:1) | 4.34 | 3.04 | campos, casillas, interruptor, puntos |
| `foco/anillo` | `fondo/app` | componente (≥ 3:1) | 6.07 | 8.31 | anillo de foco |
| `foco/anillo` | `fondo/superficie` | componente (≥ 3:1) | 6.35 | 7.27 | anillo de foco |
| `foco/anillo` | `fondo/superficie-alt` | componente (≥ 3:1) | 5.80 | 6.42 | anillo de foco |
| `foco/anillo` | `fondo/destacado` | componente (≥ 3:1) | 4.48 | 5.50 | anillo de foco |

Fuera de la tabla: `borde/control` sobre `fondo/destacado` da 2.6:1 en oscuro y **no se usa** en ninguna pantalla. Las opciones de la micro-pregunta, que viven en la caja destacada, ponen su radio sobre su propio `fondo/superficie`; una prueba deja constancia del valor.

## Orden de foco
| Pantalla | Orden con Tab |
|---|---|
| Juego, móvil (26b) | Salir → indicadores de la Startup → tarjeta → Ilegal → Escalar → Condicional → Legal → Lupa → Abogado → Amparo |
| Juego, tablet ≥ 960 | Salir → Pausa → tarjeta → Ilegal → Escalar → Condicional → Legal → comodines (el panel lateral es solo lectura: el lector lo lee, Tab no se detiene) |
| Juicio de apelación (móvil y tablet) | Salir → tarjeta → los 4 veredictos (sin comodines) |
| Examen (móvil y tablet) | Salir → (Pausa, solo con tiempo extendido) → tarjeta → los 4 veredictos (comodines desactivados, sin parada) |
| Panel de veredicto | Título → impacto → explicación o micro-pregunta → botón |
| Contraargumento (28b) | Réplica → las dos opciones |
| Buzón en lista-detalle | Riel → título → recompensa → lista (una parada por fila; ↑ ↓ mueven la selección) → "Iniciar apelaciones de hoy" → detalle → "Iniciar juicio" |
| Resultados (19, 19b, 20, 22b, 29, 30) | Título (foco inicial) → estrellas o ilustración informativa → estadísticas (una frase) → indicadores → aviso → botones |
| Registro | Atrás → los 3 chips de perfil → nombre → correo → contraseña → Mostrar contraseña → Aviso de Privacidad → Términos → Crear cuenta → Inicia sesión |
| Diálogos | Foco inicial en el título (o en "Seguir en el examen" al salir del Examen); Tab no sale del diálogo; Esc cancela y el foco vuelve al control que lo abrió. |

## Alternativas al gesto
| Gesto | Alternativa de un toque o tecla |
|---|---|
| Deslizar la tarjeta (4 direcciones) | Los 4 botones de veredicto; flechas + Enter; acciones del lector ("Legal", "Ilegal"…). Con "Solo botones" no hay arrastre. |
| Tocar la tarjeta con evidencia | Botón "Toca la tarjeta para inspeccionar" y la acción del lector "Inspeccionar evidencia". |
| Marcar una línea de código (16b) | Cada línea es un botón enfocable. |
| Deslizar el onboarding | "Siguiente" y "Omitir"; con "Solo botones" no se desliza. |
| Desplazar el mapa | Tab recorre los nodos y el foco los muestra. |

## Atajos de teclado
| Dónde | Tecla | Acción |
|---|---|---|
| Juego, juicio y Examen | ← → ↑ ↓ | Previsualiza Ilegal, Legal, Condicional o Escalar (sello y tinte) |
| Juego, juicio y Examen | Enter | Confirma la previsualización |
| Juego, juicio y Examen | Esc | Quita la previsualización; cierra los paneles descartables (evidencia, Abogado) |
| Examen con tiempo extendido | P | Pausa (T-13) |
| Buzón en tablet | ↑ ↓ | Cambia la apelación seleccionada |
| Todo control | Tab / Shift+Tab | Siguiente / anterior |
| Todo control | Enter o Espacio | Activa |

## Lista de verificación manual
Hacer cada flujo con cada herramienta y anotar lo que falle (pantalla, paso, qué se oyó o vio).

**Herramientas**
- **TalkBack (Android):** Ajustes → Accesibilidad → TalkBack. Deslizar a la derecha o izquierda para avanzar o retroceder; doble toque para activar.
- **VoiceOver (iOS/iPadOS):** Ajustes → Accesibilidad → VoiceOver. Los mismos gestos; el rotor para encabezados.
- **Teclado físico en tablet:** Tab, Shift+Tab, Enter, Espacio, flechas, Esc y P.
- **Texto grande del sistema:** al máximo, además de Ajustes de la app al 160 %.
- **Rotación:** girar la tablet a mitad de cada flujo.
- **Modo oscuro:** el del sistema y el forzado desde Ajustes.

**Flujo 1 · Acceso**
1. Splash → onboarding: cada página anuncia su título; "Omitir" y "Siguiente" se leen como botones.
2. Registro: enviar vacío.
   - El primer error se anuncia y recibe el foco.
   - Los chips de perfil dicen "seleccionado, k de 3".
   - Las dos casillas se leen por separado.
3. Inicio de sesión: "Mostrar contraseña" se anuncia y cambia a "Ocultar contraseña".

**Flujo 2 · Un sprint**
1. Inicio → módulo → nodo actual → Comenzar.
2. Con el lector:
   - la tarjeta se lee completa;
   - las acciones del lector califican;
   - el panel de veredicto toma el foco y no se cierra con atrás.
3. Con teclado:
   - el orden 26b;
   - flecha + Enter;
   - en tablet, la tarjeta queda con su sello mientras está la hoja.
4. Con "Solo botones" y "Reducir animaciones": terminar el sprint sin arrastrar y sin movimiento.
5. Fin de sprint: se anuncia el título y las estadísticas se leen como una frase.

**Flujo 3 · Buzón**
1. En tablet, con teclado: Tab a la lista; ↑ ↓ cambian la selección y se anuncia **una sola vez**; "Iniciar juicio".
2. Juicio con el lector: aviso "La fallaste hace N días", resultado y "+1 vida".
3. Rotar a mitad del Buzón: la selección se conserva.

**Flujo 4 · Examen**
1. Crisis → "Enfrentar la auditoría".
2. Escuchar el anuncio de los segundos (no cada segundo, solo los hitos).
3. Con tiempo extendido: botón de pausa y tecla P.
4. Salir del examen: el diálogo dice que el tiempo sigue y el foco está en "Seguir en el examen".
5. Contraargumento: toma el foco y se puede responder con teclado.
6. Resultado (29 o 30): título anunciado y botones alcanzables.

**Flujo 5 · Cuenta**
1. Tienda: comprar y cancelar; el foco vuelve a la tarjeta y la compra se anuncia.
2. Ajustes: cambiar el tamaño de texto; el foco vuelve a la fila y el cambio se aplica al instante.
