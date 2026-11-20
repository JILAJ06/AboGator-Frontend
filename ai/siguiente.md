# T-10b · Ajustes de accesibilidad y modo oscuro

**Rama:** `10b-ajustes-accesibilidad` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-10b**).
**Pantalla:** 26 Ajustes de accesibilidad. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 26 = `18:2634`. Compara en Chrome con el conector. (26b, el orden de foco del juego, ya se hizo en la T-05 y se verifica en la T-13.)

## Objetivo
Una pantalla de ajustes con seis opciones que **se guardan en el dispositivo y de verdad cambian la app**: modo oscuro, tamaño de texto, solo botones (sin deslizar), vibración, tiempo extendido y reducir animaciones.

## Datos
### Ajustes
- Modelo `Ajustes{modoTema (ThemeMode), escalaTexto (int, %), soloBotones, haptica, tiempoExtendido, reducirAnimaciones}` con `copyWith`. **Valores por defecto:** `ThemeMode.system`, 100, `false`, **`true`**, `false`, `false`.
- `RepositorioAjustes`: `cargar()` → `Ajustes` y `guardar(Ajustes)`. Implementación SQLite sobre la tabla `ajustes` de `BaseLocal` (clave/valor, mismo estilo que `OnboardingSqlite`; claves `modo_tema` = `system|light|dark`, `escala_texto`, `solo_botones`, `haptica`, `tiempo_extendido`, `reducir_animaciones`; un valor inválido o ausente = el por defecto) y una **en memoria** para web y pruebas; la elección vive en `proveedores_repositorios.dart` con `usarBaseLocal`, como el onboarding. Son ajustes **del dispositivo**: cerrar sesión no los borra.
- `ajustesProvider` (`Notifier<Ajustes>`): estado inicial ya cargado, para que el tema correcto salga **desde el primer cuadro** (sin parpadeo). En `main()` se hace `await` de `cargar()` antes de `runApp` y se pasa por un override de Riverpod; si cargar falla, se usan los por defecto. Cada cambio actualiza el estado al instante y guarda; si guardar falla, **se revierte** y un `SnackBar` en región en vivo dice "No se pudo guardar el ajuste. Inténtalo de nuevo."
- `modoTemaProvider` sigue existiendo con la misma API (la galería lo usa) pero su estado sale de los ajustes y `establecer` guarda. Actualiza `modo_tema.dart` (su comentario también).
- **Cómo se lee el modo oscuro:** guardado es `system`, `light` o `dark`. El interruptor está **encendido** cuando el modo efectivo es oscuro (incluye `system` con el sistema en oscuro) y al tocarlo se guarda `dark` o `light` explícito. Mientras haya un modo explícito aparece bajo la tarjeta Visual un botón de texto (alto 48) "Usar el modo del sistema" que vuelve a `system`.

### Efectos reales (todos con prueba)
1. **Modo oscuro:** `MaterialApp.themeMode` ya lo usa; verifica que cambia al instante y que se conserva al reabrir.
2. **Tamaño de texto:** opciones **100, 120, 140 y 160 %**. La escala efectiva es `escala del sistema × porcentaje`, con **tope de 2.0** (200 %, WCAG 1.4.4; ya hay pruebas de layout hasta 200 %). Se aplica en `MaterialApp.builder` con `MediaQuery.copyWith(textScaler: TextScaler.linear(…))`, así llega a diálogos y paneles. Calcula la parte del sistema con `MediaQuery.textScalerOf(context).scale(1)`.
3. **Reducir animaciones:** en el mismo `builder`, `MediaQuery.copyWith(disableAnimations: sistema || ajuste)`. Los componentes ya respetan `MediaQuery.disableAnimationsOf`; comprueba con una prueba en el juego y el Splash. Con el sistema ya en "reducir" el interruptor sigue mostrando lo que guardó la persona, pero el efecto es el del sistema (anótalo en el reporte).
4. **Vibración háptica:** nuevo `ServicioHaptico` (interfaz + proveedor, sustituible en pruebas) con `acierto()` (`lightImpact`), `parcial()` (`selectionClick`), `error()` (**dos** `mediumImpact` con 90 ms entre ellos, como dice "doble = error") y `suave()` (`lightImpact`, para la compra y el juicio ganado). No hace nada en web ni con el ajuste apagado. Sustituye **todas** las llamadas directas a `HapticFeedback` (juego, juicio de apelación, tienda). Al encender el interruptor da un `suave()` de muestra.
5. **Solo botones (sin deslizar):** con el ajuste encendido, `MazoSwipe` **no arrastra** (nuevo parámetro `arrastreActivo`, sin reconocedor de arrastre); los 4 botones de veredicto y las acciones del lector funcionan igual, y un toque sobre la tarjeta con evidencia sigue abriendo el visor. La pista de gesto de la tarjeta dice "Elige con los botones" en lugar de la de deslizar (texto nuevo). Aplica también en el juicio de apelación. Los sellos y el tinte solo aparecen al previsualizar con botón/teclado como hoy.
6. **Tiempo extendido:** solo se guarda (`ajustesProvider` lo expone); lo usará el Examen Final de la T-11 (+50 % de tiempo por tarjeta y pausa). Dilo en el reporte; no inventes temporizadores aquí.

## 26 · Ajustes de accesibilidad (marco 390×844, sin navegación inferior)
Columna desplazable sobre `fondoApp`.
- **Encabezado** (y=54): botón de regreso de 48 en (20,54) (`BotonCerrar` con etiqueta "Atrás", como en `PantallaPendiente`) y el título "Accesibilidad" Fredoka Bold 26/32 `textoPrimario` en (76,62). Debajo (24,112) "WCAG 2.1 AA · Ajusta la app a tu forma de aprender." Cuerpo/Base `textoSecundario`. Al abrir, el foco va al título.
- **Secciones** (etiqueta Etiqueta 12 `textoSecundario` en x=28, encabezado semántico; tarjeta debajo en x=24, ancho 342): `fondoSuperficie`, borde 1 `bordeDefault`, radio 18, filas de relleno 16×12, separación 12, divisores de 1 `bordeDefault` entre filas. Cada fila: ícono de 22, columna de texto (Cuerpo/Énfasis + Leyenda `textoSecundario`) y el control a la derecha. Alto de fila ≥ 56 y el toque abarca **toda la fila**.
  - **VISUAL** (etiqueta y=174, tarjeta y=196): "Modo oscuro" / "Contraste alto en fondos oscuros" (`moon`, interruptor) · "Tamaño de texto" / "Texto dinámico sin deformar" (`type`, chip "Aa 120 %") · "Etiquetas para lector" / "TalkBack / VoiceOver" (`eye`, chip "Activo").
  - **MOTOR Y AUDITIVA** (etiqueta y=401, tarjeta y=423): "Botones en lugar de deslizar" / "Toca uno de los 4 veredictos (48 dp)" (`check`, interruptor) · "Vibración háptica" / "Corta = acierto · doble = error" (`vibrate`, interruptor).
  - **COGNITIVA (WCAG 2.2.1)** (etiqueta y=567, tarjeta y=589): "Tiempo extendido en exámenes" / "+50 % por tarjeta y opción de pausa" (`clock`, interruptor) · "Reducir animaciones" / "Menos movimiento en tarjetas" (`pause`, interruptor).
- **Interruptor:** 48×28, radio 14, pulgar de 22. **Lee los colores de las imágenes de Figma con el conector** (activo e inactivo) y ponlos con tokens (`accionPrimaria` / `bordeControl` si coinciden; si no, dímelo en el reporte). Hay que cumplir contraste ≥ 3:1 del control contra su fondo (WCAG 1.4.11). Si el `Switch` del tema alcanza esas medidas, úsalo; si no, un componente `InterruptorApp` propio. Valores de Figma: todos encendidos salvo "Reducir animaciones"; **los valores por defecto reales son los de arriba**, no los de Figma.
- **Chip de valor** (`fondoSuperficieAlt`, radio 10, relleno 10×6, Etiqueta): tamaño "Aa 100 %" (el valor real); **"Etiquetas para lector"** es solo informativo (no tocable, sin foco): "Activo" si `MediaQuery.accessibleNavigationOf(context)` es verdadero y **"Disponible"** si no (las etiquetas siempre existen; Figma solo muestra "Activo"). Se lee "Etiquetas para lector: activo/disponible".
- **Selector de tamaño** (tocar la fila): `showModalBottomSheet` con título "Tamaño de texto", cuatro opciones de radio (alto ≥ 48; "100 %", "120 %", "140 %", "160 %", cada una con el texto "Aa" a ese tamaño) y se cierra al elegir; se aplica al instante. Foco inicial en la opción actual.
- **Semántica de las filas con interruptor:** una sola etiqueta "Modo oscuro, contraste alto en fondos oscuros", `toggled` con el estado, acción de tocar; sin que el lector lea dos veces el interruptor interno (exclúyelo). La fila de tamaño es botón con valor "120 por ciento".

## Rutas y limpieza
- `Rutas.ajustes` deja de ser marcador: `PantallaAjustes`, hija del Perfil (el redirect sin sesión del Perfil la cubre) y **sin** barra inferior. Quita `Textos.pendienteAjustes`. "Atrás" vuelve al Perfil.
- Que desde 25 el botón de ajustes y la fila "Accesibilidad" sigan llegando aquí.

## Archivos permitidos
`lib/datos/` (`ajustes.dart` modelo, `repositorio_ajustes.dart`, su implementación SQLite en `lib/datos/local/` y la de memoria en `mocks/`, `proveedores_repositorios.dart`), `lib/main.dart`, `lib/app/app.dart`, `enrutador.dart` y `rutas.dart`, `lib/core/tema/modo_tema.dart`, `lib/core/servicios/` o donde cuadre para `ServicioHaptico`, `lib/funciones/ajustes/` (pantalla, estado, lógica), `lib/funciones/juego/` (`pantalla_juego.dart`, `mazo_swipe.dart`: haptics y solo botones), `lib/funciones/apelaciones/pantalla_juicio.dart` y `lib/funciones/tienda/pantalla_tienda.dart` (solo háptica y solo botones), `lib/componentes/` (`tarjeta_caso.dart` o su pista de gesto para el texto alterno; nuevos: fila de ajuste, interruptor, chip de valor, selector de tamaño), `lib/core/textos/textos.dart`, `iconos_app.dart` si faltan `moon`, `type`, `eye`, `vibrate`, `pause`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **Sin dependencias nuevas.**

## Pruebas
- **Repositorio:** valores por defecto; guardar y cargar cada ajuste (SQLite con `sqflite_common_ffi` y memoria); valor inválido → por defecto; los ajustes sobreviven a `cerrarSesion`.
- **Estado:** cambio al instante; si guardar falla, se revierte y avisa; `modoTemaProvider` guarda.
- **Efectos:** modo oscuro y claro cambian el tema y el interruptor refleja el modo efectivo con el sistema en oscuro; "Usar el modo del sistema" solo con modo explícito; tamaño 120/140/160 cambia el texto y el tope de 2.0 se respeta con el sistema en 150 %; reducir animaciones pone `disableAnimations` en verdadero (y con el sistema en verdadero se mantiene); háptica con ajuste apagado no llama a nada, encendida usa los patrones (error = dos pulsos) con un servicio falso, y la compra y el juicio usan el servicio; solo botones: arrastrar la tarjeta no la mueve, los 4 botones y el teclado sí califican, la pista cambia, un toque abre el visor de evidencia; también en el juicio.
- **Pantalla 26:** estructura y medidas de Figma en claro y oscuro (secciones, filas ≥ 56, encabezado, etiquetas); estados de los interruptores con los valores por defecto; selector (abre, elige, cierra, aplica); chip "Activo" / "Disponible"; arranque con ajustes guardados (modo y escala ya aplicados en el primer cuadro); sin parpadeo; atrás vuelve al Perfil; sin barra inferior.
- **Accesibilidad:** foco inicial en el título, semántica (`toggled`, valor, sin doble lectura), objetivos ≥ 48, contraste de los interruptores y chips en claro/oscuro, sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %.
- Las 893 pruebas previas siguen verdes (ajusta las que llamaban a `HapticFeedback` directo o a `pendienteAjustes`).

## Criterios de aceptación
- [ ] 26 coincide con Figma; lo que no viene de Figma (valores por defecto reales, "Disponible", selector, "Usar el modo del sistema", doble vibración de error) queda en el reporte.
- [ ] Cada ajuste se guarda en el dispositivo, sobrevive al reinicio y cambia de verdad la app (tema, tamaño, animaciones, háptica, solo botones); el tiempo extendido queda guardado para la T-11.
- [ ] El tema y el tamaño correctos salen desde el primer cuadro, sin parpadeo.
- [ ] Ya no hay llamadas directas a `HapticFeedback` fuera del servicio ni el marcador `pendienteAjustes`.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.
