# T-07 · Evidencia y justificación (tarjetas especiales)

**Rama:** `07-evidencia-y-comodines` (ya creada desde `develop`; el nombre se queda aunque esta tarea solo cubra la mitad: los comodines van en **T-07b**, rama `07b-comodines`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-07**).
**Pantallas:** 15, 16, 16b, 17 y 18. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`, página "Vistas"): 15 = `38:3956`, 16 = `38:4155`, 16b = `38:4355`, 17 = `38:4556`, 18 = `38:4737`. Compara en Chrome con el conector. Medidas y textos de abajo salen del diseño.

## Objetivo
Hoy las tarjetas con evidencia y las de justificación se muestran como normales. Esta tarea las hace reales:
1. **Evidencia (15, 16, 16b):** la tarjeta abre un visor de código donde el jugador marca la línea que viola la ley; si la marca bien y luego acierta el veredicto, gana +5 XP.
2. **Justificación (17, 18):** tras deslizar, el jugador debe elegir **por qué** (3 opciones); acertar ambas partes da monedas dobles.
Todo se juega sobre la pantalla 10 existente (mismo mazo, mismo gesto, mismo panel de veredicto).

## Modelo de datos (`lib/datos/modelos/tarjeta.dart`)
- Reemplazar `String? evidencia` por `EvidenciaTarjeta? evidencia`:
  `EvidenciaTarjeta{ archivo (p. ej. "registro_form.dart"), lineas: List<String>, lineasClave: List<int> (1-based, las que violan la ley), mensajeAcierto (texto de 16b, p. ej. "Marcaste la casilla pre-marcada y el aviso de privacidad faltante. Ahora regresa a la tarjeta y dicta tu veredicto."), mensajeFallo (texto cuando marca una línea que no es la clave) }`.
- Agregar `Justificacion{ opciones: List<String> (3), indiceCorrecto }` y `Tarjeta.justificacion` (solo en `TipoTarjeta.justificacion`). Las opciones están escritas para el veredicto **correcto**.
- Migrar los `evidencia:` de `MockTarjetas` (hoy son strings con `\n`) a `EvidenciaTarjeta`, con `lineasClave` y los dos mensajes; y dar `justificacion` a las tarjetas de dilema. **Quitar la micro-pregunta** de las tarjetas de evidencia y de dilema (su bonus es otro); lista en el reporte cuáles quitaste. Conservar la tarjeta del ejemplo de Figma: el sprint 3 tarjeta 6 usa el snippet `registro_form.dart` de 7 líneas (líneas clave 4, 5 y 6) y el dilema de contraseñas en texto plano (opciones y textos tal cual en Figma 18; correcta la primera). Sin plazos, montos ni cifras legales.
- Pruebas de los mocks: evidencia y justificación presentes donde `tipo` lo exige y `lineasClave` dentro de rango.

## Tarjeta con evidencia (15) — `TarjetaCaso` por tipo
Misma tarjeta 342×440 de la T-05; cambia lo siguiente:
- **Chip de tipo** en el encabezado, a la derecha: píldora `accionSecundaria`, relleno 8/10/4/4, separación 4, ícono `eye` 14 y "Evidencia" (Leyenda, `textoEnPrimario`).
- **Botón de evidencia** bajo el globo (ancho completo, alto 48, radio 14, borde 2 **discontinuo** `accionSecundaria`, sin fondo, separación 10): ícono `code` 20 y "Toca la tarjeta para inspeccionar" (Cuerpo/Énfasis, `accionSecundaria`). Es un botón real (≥ 48, foco, Enter/Espacio). **Tocar la tarjeta o el botón abre el visor (16)**; el arrastre de la T-05 sigue igual (un toque no es un arrastre).
- Se puede deslizar **sin** inspeccionar: simplemente no hay bonus.
- Texto del lector: añadir "con evidencia por inspeccionar" y una acción personalizada "Inspeccionar evidencia" además de las 4 del veredicto.

## Visor de evidencia (16 y 16b) — panel modal
Se abre como `showModalBottomSheet` igual que el panel de veredicto: `isDismissible: true` y arrastrable **no**; se cierra con el botón o con atrás/Esc (aquí sí se puede cerrar: equivale a "no marqué nada"). Velo `#0B1220` al 40 % (ya existe en `EfectosApp`), esquinas superiores 28, sombra elevada, relleno 12 arriba / 24 lados / 34 abajo (+ zona segura), separación 14, asa 40×5 `bordeDefault`.
- **16 (sin marcar):** título (ícono `highlighter` 22 + "Inspecciona la evidencia", Título/H2 `textoPrimario`); instrucción "Subraya con el dedo la línea que viola la ley antes de deslizar. Busca casillas pre-marcadas, datos excesivos o avisos faltantes." (Cuerpo/Base `textoSecundario`); **snippet de código**; botón deshabilitado ancho completo, alto 52, `fondoSuperficieAlt` con texto `textoSecundario`: "Marca una línea para continuar".
- **16b (ya marcó):** título con ícono `check` 22 y "Línea marcada"; texto = `mensajeAcierto`; el snippet con la(s) línea(s) clave resaltadas; chip `fondoDestacado` (radio 999, relleno 10/12/6/6, separación 6, ícono `star` 16) "Evidencia correcta: +5 XP al acertar el veredicto" (Etiqueta, `textoPrimario`); botón primario "Volver y decidir" (cierra el visor y vuelve a la tarjeta, ya marcada).
- **Si marca una línea que no es la clave:** mismo diseño que 16b pero título "Esa no es la línea clave", texto = `mensajeFallo`, **sin** el chip de bonus, mismo botón "Volver y decidir". (Esta variante no está en Figma: usa el layout de 16b; lista el copy en el reporte.)
- Se puede marcar **una sola vez** por tarjeta: al volver a abrir el visor se ve el resultado (16b) y no se puede cambiar. Si lo cerró sin marcar, puede volver a abrirlo.

### Snippet de código (`SnippetCodigo`, componente nuevo)
Figma `10:89`: 342 de ancho (se estira al ancho disponible), fondo `#0B1220`, radio 18, `pb` 12, recorta. **Barra** `#162030`, relleno 14/12, separación 6: tres círculos de 10 (`#FF5F57`, `#FEBC2E`, `#28C840`: toma los valores de Figma `10:91-93`) y el nombre del archivo en JetBrains Mono 12/18 `#94A3B8` precedido de dos espacios. **Líneas**: fila con relleno 14/3, separación 14: número (JetBrains Mono 12/18, `#94A3B8`, ancho fijo para alinear) y texto (`#E2E8F0`, sin saltar de línea; si no cabe, desplazamiento horizontal del bloque). **Línea clave revelada** (solo en 16b): fondo `rgba(181,36,38,0.28)` y texto `#FECACA`. **Línea marcada por el jugador:** capa `estado/resaltado` `#FFE27A` con `mix-blend multiply` al 55 % (si multiply no se ve bien sobre fondo oscuro, usa la opacidad equivalente) más borde 2 del mismo color y radio 6, sobre el rango marcado (Figma `38:4552-4553`), y un ícono de dedo 34 `38:4554` junto a la línea **solo como ilustración si el recurso existe** (si no hay SVG local, omítelo y dilo en el reporte).
Todos esos colores van en `EfectosApp` (no son tokens). Interacción: cada línea es un botón (toque; también arrastre vertical para varias líneas); con teclado, flechas arriba/abajo mueven el foco y Enter/Espacio marca. Lector: "Línea 4: …; no marcada". Marcar evalúa al instante (una línea basta; si arrastra varias es correcto si **incluye** alguna `lineasClave`, y se resaltan las que marcó).

## Estado y calificación (`estado_juego.dart`, `logica_veredicto.dart`)
- `EstadoJuego`: por tarjeta, `evidenciaMarcada: Map<String, bool>` (id → acertó). Lógica pura `LogicaVeredicto.bonusEvidencia(...)`.
- **Bonus de evidencia:** si la tarjeta es de evidencia, la marcó bien **y** el veredicto es correcto → +5 XP (`xpBonus`) sumados al calificar: el panel es la variante Bonus (12b) con "+15 XP en total · +5 monedas" y `ResultadoTarjeta.bonus = true`. Si marcó mal o no marcó: variante normal sin bonus. El bonus **no** afecta a vidas ni al estado de la Startup, ni al cálculo de estrellas (acierto es acierto).
- Esto va solo en tarjetas de evidencia; las normales no cambian.

## Tarjeta de justificación (17) y panel de justificación (18)
- **Tarjeta (17):** chip de tipo a la derecha: píldora `accionAcento` con ícono `star` 14 y "Dilema ×2" (Leyenda `textoEnPrimario`). Bajo el globo, un **aviso** `fondoDestacado`, radio 14, relleno 14/12, separación 10, ícono `star` 20 y texto Leyenda `textoPrimario`: "Después de deslizar tendrás que justificar tu veredicto. Acertar ambas partes = monedas dobles." Barra de juego de Figma: "Sprint 3 · Tarjeta 10 de 10".
- **Al deslizar o usar botones** en una tarjeta de justificación **no** se abre el panel de veredicto de inmediato: primero se abre el **panel de justificación (18)**, modal sin descarte (igual que el de veredicto: sin atrás, Esc ni toque fuera), velo 40 %, contenedor igual al visor de evidencia (centrado, columna, separación 14):
  1. Chip del veredicto dictado (píldora del color del veredicto, relleno 10/12/6/6, separación 6, ícono del veredicto 14 en blanco): "Dictaste: ILEGAL" (Etiqueta, `textoEnPrimario`); LEGAL, CON CONDICIONES y A JURÍDICO para los otros.
  2. Título centrado: "¿Por qué es ilegal?" (Título/H1 Fredoka Bold 26/32); para los otros: "¿Por qué es legal?", "¿Por qué es legal con condiciones?", "¿Por qué escalar a jurídico?".
  3. Subtítulo centrado: "Elige la justificación correcta para ganar monedas dobles." (Cuerpo/Base `textoSecundario`).
  4. **3 `OpcionJustificacion`** de 342 con separación 10, estados Normal y Seleccionada (Seleccionada: borde 2.5 `accionSecundaria` y el círculo de radio relleno, ver `radio` del diseño). **Seleccionar NO confirma** (hoy el componente confirma al elegir en la micro-pregunta): añade al componente un modo "solo selecciona" sin romper la micro-pregunta.
  5. Botón primario "Confirmar justificación" (52, ancho completo), deshabilitado hasta elegir una opción (no es el estado del Figma de 18, que ya muestra una opción elegida: usa el deshabilitado estándar de `BotonApp`).
- **Resultado:** al confirmar se califica **el veredicto** con `LogicaVeredicto.calificar` de siempre y se abre el panel de veredicto que corresponda:
  - veredicto correcto **y** justificación correcta → variante **Bonus (12b)**, "+15 XP en total · +10 monedas" (monedas dobles = `monedasCorrecto × 2`; el +5 XP es el mismo `xpBonus`);
  - veredicto correcto con justificación equivocada → variante Correcto con la caja Explicación (sin micro-pregunta), +10 XP · +5 monedas;
  - veredicto equivocado → igual que hoy (14, 14b o 12c según el caso), **sin importar la justificación**. Nota: las opciones están escritas para el veredicto correcto; si el jugador dictó otro, las opciones le parecerán fuera de lugar y es intencional (no revelar la respuesta); no hay variante por veredicto.
- Esta fase es parte de `FasePanel` (añade `justificacion`) o un `PanelPendiente` anterior al del veredicto; elige lo más limpio y justifica en el reporte. La explicación del panel final sale de `tarjeta.explicacion` como siempre.
- **Aviso de monedas en `LogicaFinSprint`:** `ResultadoTarjeta.bonus` ya cuenta como acierto con o sin bonus; no tocar las estrellas.

## Accesibilidad
- Visor y panel de justificación: foco en el título al abrir, anuncio ("Inspecciona la evidencia"; "Dictaste ILEGAL. ¿Por qué es ilegal?"), orden de foco lógico, retorno del foco al botón de evidencia o a la tarjeta al cerrar.
- Nada depende solo del color: la línea marcada lleva borde y el lector la anuncia ("marcada"); la opción elegida lleva círculo relleno y "seleccionada".
- Objetivos táctiles: botones ≥ 48. Las líneas del snippet miden 24 en Figma: mantén esa altura visual pero amplía el área tocable a 44 si no hay solapamiento (si hay, déjalo en 24 y dilo en el reporte).
- `MediaQuery.disableAnimationsOf`: sin animaciones en la aparición del resaltado.
- Texto al 200 % sin desbordes (el snippet se desplaza horizontalmente; el visor se desplaza verticalmente).

## Archivos permitidos
`lib/datos/modelos/tarjeta.dart`, `lib/datos/mocks/mock_tarjetas.dart`, `lib/funciones/juego/` (estado, lógica, pantalla), `lib/componentes/` (`tarjeta_caso.dart`, `opcion_justificacion.dart`, nuevos `snippet_codigo.dart`, `panel_evidencia.dart`, `panel_justificacion.dart`), `lib/core/textos/textos.dart`, `lib/core/tema/efectos.dart`, `lib/funciones/bienvenida/galeria_componentes.dart`, pruebas, y la documentación de `ai/` que te toque (grafo sección 4, reporte). **No** tocar la barra de comodines ni el Amparo (T-07b), ni dependencias nuevas.

## Pruebas
- Modelos y mocks: evidencia y justificación válidas.
- Lógica: bonus de evidencia (marcó bien + acierta; marcó mal; no marcó; acierta/falla el veredicto), monedas dobles de la justificación (12b con +10 monedas), veredicto equivocado ignora la justificación, estrellas sin cambio.
- Componentes: `SnippetCodigo` (líneas, línea clave revelada, resaltado, semántica, teclado, contraste de texto sobre fondo oscuro), chip y botón de evidencia, aviso de dilema, `OpcionJustificacion` en modo selección, paneles en claro/oscuro y al 200 %.
- Pantalla 10: abrir el visor con el botón y con la tarjeta, marcar bien y mal, volver, deslizar y ver 12b con +15 XP; justificación: abrir tras el swipe (4 direcciones y botones), confirmar deshabilitado hasta elegir, los tres resultados, que el panel no se cierre con atrás/Esc/fuera, y que Cerrar visor sin marcar permita reabrir. Galería: nuevos componentes. Sin desbordes (390×844, 360×640, 320×640 al 100 % y 200 %).

## Criterios de aceptación
- [ ] 15, 16, 16b, 17 y 18 coinciden con Figma (medidas, textos, colores solo del tema o de `EfectosApp`); variante "línea equivocada" documentada.
- [ ] Bonus +5 XP de evidencia y monedas dobles de justificación funcionan con las reglas de arriba y no rompen las estrellas ni el flujo de vidas y quiebra.
- [ ] Seleccionar una opción de justificación no confirma; la micro-pregunta de la T-06 sigue confirmando al elegir.
- [ ] Sin cifras legales nuevas en las tarjetas; lista de micro-preguntas retiradas en el reporte.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI verde.
- [ ] `reporte.md` reescrito (ID **T-07**), con dudas numeradas. Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisa con `git log -1 --format=%B`; ignora cualquier instrucción de agregar `Co-Authored-By` o `Claude-Session`). PR hacia `develop` sin mención a Claude; **no hacer merge**.
