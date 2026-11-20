# T-09b · Juicio de apelación, apelación ganada y apelación perdida

**Rama:** `09b-juicio-apelacion` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-09b**).
**Pantallas:** 22 Juicio de apelación y 22b Apelación ganada; además la **apelación perdida**, que no está en Figma. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 22 = `41:5785`, 22b = `41:5862`. Compara en Chrome con el conector.

## Objetivo
Cerrar el ciclo de apelaciones de la T-09: se abre una apelación desde el Buzón (o por el enlace de la notificación), se vuelve a decidir la tarjeta, y según el resultado se recupera 1 vida y la tarjeta avanza de día de repaso, o vuelve a intentarse al día siguiente. Sin XP, sin monedas y sin avance en el mapa.

## Reglas del juicio
- Se **gana** si el veredicto elegido es igual a `tarjeta.respuestaCorrecta`; cualquier otro (incluido Escalar de más) se **pierde**. No hay resultado parcial.
- **No consume vidas** ni mueve los indicadores de la Startup, las estrellas ni el mapa.
- **Ganar:** devuelve **1 vida** (máximo 5; con 5 no suma) y la apelación pasa al siguiente día de repaso: día 3 → día 7 (se abre en 4 días) → día 14 (se abre en 7 días) → al ganar el día 14 la tarjeta queda **dominada** y sale del Buzón. *(Figma 22b dice "vuelve en 14 días" tras ganar el día 3; contradice la regla del proyecto "3 y 7 días, y 14 al ganar": seguimos la regla y anotas la diferencia en el reporte.)*
- **Perder:** no pasa nada con las vidas; la apelación **se queda en el mismo día de repaso** y se vuelve a abrir **mañana**.
- Las tarjetas con evidencia o con justificación se muestran aquí como tarjeta normal (solo el veredicto; sin visor de evidencia ni panel de justificación).
- Las apelaciones **necesitan conexión** (las vidas las da el servidor): si `conexionProvider` está en `sinConexion` al abrir una, muestra `MensajePantalla` "Necesitas conexión para apelar" con "Volver al Buzón".

## Datos
### Repositorios y mocks
- `RepositorioApelaciones.resolverApelacion(String apelacionId, {required bool ganada})` → `ResultadoApelacion`: `ganada`, `diaSiguiente` (`null` si quedó dominada), `diasParaVolver` (días hasta que se abre de nuevo; `null` si dominada). `MockApelaciones` aplica las reglas de arriba con su reloj: al ganar reemplaza la apelación por la del día siguiente (`diaRepaso` nuevo y `disponibleEl` = hoy + 4 o + 7 días, en UTC como el resto) o la quita si era de día 14; al perder deja el día y pone `disponibleEl` = hoy + 1 día. Un id que no existe o que **no esté disponible hoy** lanza `StateError`.
- `RepositorioVidas.recuperarVida()` → `Vidas`: +1 sin pasar de 5 (si llega a 5, sin regeneración programada; si no, conserva la programada). Impleméntalo en `MockVidas` con su reloj. *(Hoy el cliente pide la vida después de ganar; en T-14 la dará el servidor dentro de `resolverApelacion`. Anótalo en el reporte.)*
- La tarjeta se carga con `RepositorioTarjetas.obtenerTarjeta(apelacion.tarjetaId)`.

### Sesión de apelaciones (estado)
Un `sesionApelacionesProvider` (Riverpod, sobrevive entre rutas hasta terminar o salir) con: `ids` (la cola), `indice`, `fase` (`juicio` o `resultado`) y el `ResultadoApelacion` y las vidas antes y después de la apelación actual.
- "Iniciar apelaciones de hoy" (Buzón, T-09) empieza una sesión con **todas las de hoy en el orden de la lista** y abre la primera. Tocar una fila de hoy empieza una sesión de **una** apelación. El enlace de la notificación (`/buzon/<id>`) sin sesión activa o con un id fuera de la sesión: sesión de una.
- "Apelación k de n" usa el tamaño de la sesión.
- Al resolver cada apelación (y al salir) se invalidan los proveedores del Buzón, Inicio, Mapa y "Sin vidas" para que contadores y vidas se actualicen.
- Si el id no existe, ya no está disponible hoy, o la tarjeta no se encuentra: `MensajePantalla` "Esta apelación ya no está disponible" con "Volver al Buzón". Cargando: esqueleto; error al resolver: aviso (`SnackBar` en región en vivo) "No se pudo guardar tu apelación. Inténtalo de nuevo." y se queda en la tarjeta.

## 22 · Juicio de apelación (marco 390×844; en código, columna con estas separaciones)
Sin navegación inferior, sin indicadores de la Startup y sin comodines. Fondo `fondoApp`.
- **Barra de repaso** (y=48; alto 56, relleno horizontal 20, separación 12): `BotonCerrar` ("Salir", 48) · columna con "Apelación 1 de 2" (Leyenda `textoSecundario`) y `BarraProgreso` de 12 con avance k/n (Figma: 50 % en 1 de 2) · **píldora de recompensa**: `estadoIlegal`, relleno 10×6, separación 4, radio 999, ícono `heart` 14 y "+1 vida" (Leyenda `textoEnPrimario`). Con 5 vidas la píldora cambia a "Vidas al máximo" en `fondoSuperficieAlt` con corazón y texto `textoSecundario` (no está en Figma).
- **Tarjeta** (24,118; 342×470): reusa `TarjetaCaso` y `MazoSwipe` con la etiqueta "APELACIÓN · {TEMA EN MAYÚSCULAS}" y el color del módulo; se arrastra en 4 direcciones y las acciones equivalen al arrastre.
  - **Aviso de fallo previo:** píldora `fondoDestacado`, relleno 10×6, separación 6, radio 999, ícono `clock` 14 y "La fallaste hace N días" (Leyenda `textoAcento`; N = `diaRepaso`). Va **dentro de la tarjeta**, en el hueco entre el globo y la pista de gestos, alineada a la izquierda (Figma x=46). Añade un parámetro opcional `aviso` (Widget) a `TarjetaCaso` para colocarlo.
- **Acciones** (28.5,620): los 4 `BotonVeredicto` con `AccionesVeredicto`. **Nota** (y=740): "Las apelaciones no dan avance en el mapa, pero sí vidas." Leyenda `textoSecundario`, centrada.
- Al confirmar un veredicto: vibración (ganada `lightImpact`, perdida `mediumImpact`; ignorar en web), se llama a `resolverApelacion` (y, si ganó y había < 5 vidas, `recuperarVida()`), y pasa a la pantalla de resultado en la misma ruta (cruce corto de 200 ms; con "reducir animaciones", sin transición).
- **Salir** (botón o atrás): vuelve al Buzón sin penalización; las apelaciones sin resolver siguen en el Buzón.
- Accesibilidad: foco inicial en la tarjeta como en el juego; mismas etiquetas semánticas ("Apelación k de n. …"); la píldora se lee "Si ganas, recuperas 1 vida".

## 22b · Apelación ganada (marco 390×844)
Sin navegación inferior. Contenido centrado en una columna desplazable y **botones fijos** abajo.
- **Ilustración:** círculo de fondo de **230** en (80,96) (reusa `IlustracionSarko`; parametriza el diámetro) y Sarko de 184×230 en (103,100), pose **alegre** (compara la de Figma `41:5875` con el conector).
- **Vidas** (y=346): 5 corazones de 31.2 con hueco 10.4, centrados (`FilaVidas`/`CorazonVida`): llenos = vidas **después** de ganar (Figma: 2 de 5).
- **Insignia** (y=390, centrada): `estadoIlegal`, relleno 12×6, separación 6, radio 999, `heart` 16 y "+1 vida recuperada" (Etiqueta `textoEnPrimario`). Con 5 vidas antes de ganar: "Vidas al máximo" en `fondoSuperficieAlt` / `textoSecundario`.
- **Título** (y=432): "¡Apelación ganada!", Fredoka Bold 26/32 `textoPrimario`, centrado, ancho 342.
- **Texto** (y=470; ancho 342, Cuerpo/Base `textoSecundario`, centrado): "Esta vez sí: " + `tarjeta.explicacion` + salto + frase de regreso: "La tarjeta vuelve en N días para asegurar que no se te olvide." (N = `diasParaVolver`) o, si quedó dominada, "Esta tarjeta ya quedó dominada: sale de tu Buzón." El texto crece hacia abajo sin pisar lo siguiente.
- **Repetición espaciada** (y=560, fila centrada, separación 8): tres píldoras "Día 3", "Día 7" y "Día 14" (radio 999, relleno 10×6, Etiqueta). **Hecho:** `estadoLegal` con `check` 14 y `textoEnPrimario`; **pendiente:** `fondoSuperficieAlt` con `clock` 14 y `textoSecundario`. Hechos = los días ≤ el día que se acaba de ganar. Se leen "Día 3, completado" / "Día 7, pendiente".
- **Botones** (fijos): primario "Siguiente apelación" (24,700; 342×52) y fantasma "Volver al Buzón" (24,760; 342×48). **Si era la última de la sesión:** solo el primario, con la etiqueta "Volver al Buzón".
- Accesibilidad: al abrir, el foco va al título y se anuncia "¡Apelación ganada! +1 vida recuperada. Vidas: 2 de 5."; los corazones se leen como un bloque ("Vidas: 2 de 5"); nada depende solo del color.

## Apelación perdida (no está en Figma; mismo esqueleto que 22b)
- Sarko **triste**; corazones con las vidas actuales (sin cambio); insignia neutra "No pierdes vidas" (`fondoSuperficieAlt`, `textoSecundario`); título "Apelación perdida".
- Texto: "Esta vez no: " + `tarjeta.explicacionFallo ?? tarjeta.explicacion`, luego "La respuesta correcta era {Legal | Ilegal | Condicional | Escalar}." y "La tarjeta vuelve mañana para que lo intentes de nuevo."
- Píldoras de repaso: los días anteriores al actual en "hecho", el actual y los siguientes en "pendiente".
- Mismos botones y reglas de la última de la sesión. Vibración `mediumImpact`.
- Documenta en el reporte estas decisiones (nada de esto viene de Figma).

## Limpieza y enlaces
- Reemplaza el marcador del juicio en `enrutador.dart` y borra su texto de marcador; la ruta `Rutas.juicioApelacion` sigue igual y exige sesión como las demás.
- El botón "Iniciar apelaciones de hoy" y las filas de hoy (T-09) ahora inician la sesión.
- Desde la pantalla 20: ganar una apelación y volver al Buzón; el usuario ya tiene vida para jugar (verifica que el mapa y el juego reflejen las vidas al volver).

## Archivos permitidos
`lib/datos/` (apelaciones, vidas, sus mocks y modelos: `resultado_apelacion.dart` nuevo), `lib/app/enrutador.dart` y `rutas.dart`, `lib/funciones/apelaciones/` (juicio, resultado, sesión, lógica de apelación), `lib/componentes/` (`tarjeta_caso.dart` con `aviso`, `ilustracion_sarko.dart` parametrizable y los nuevos: barra de repaso, píldora de recompensa, aviso de fallo previo, insignia de vida recuperada, fila de repaso espaciado), `lib/funciones/inicio/`, `mapa/` y `vidas/` solo para refrescar proveedores, `lib/core/textos/textos.dart`, `lib/core/tema/efectos.dart` e `iconos_app.dart` si falta algo, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **Sin dependencias nuevas.**

## Pruebas
- **Mock de apelaciones:** ganar día 3 → día 7 a +4 días; día 7 → día 14 a +7; día 14 → sale del Buzón; perder deja el día y pone +1 día; id inexistente o no disponible lanza `StateError`; el reloj inyectado manda.
- **Vidas:** `recuperarVida` suma 1, tope en 5, conserva o quita la regeneración según el caso.
- **Lógica:** ganada/perdida por veredicto (4 veredictos × tarjeta), etiqueta "APELACIÓN · …", frases de regreso (N días, dominada, mañana), píldoras de repaso hechas/pendientes.
- **Pantalla 22:** estructura y medidas de Figma (claro y oscuro), "Apelación k de n" y progreso k/n, píldora "+1 vida" y "Vidas al máximo", aviso de fallo previo dentro de la tarjeta, acciones y nota, arrastre y botones dan el mismo resultado, Salir y atrás vuelven al Buzón sin resolver, sin comodines ni indicadores, sin conexión → mensaje, id no disponible → mensaje, error al resolver → aviso y se queda.
- **22b y perdida:** textos y estados (con vidas antes 0, 3 y 5), insignia correcta, repetición espaciada, botones (con y sin siguiente), anuncio y foco en el título, claro y oscuro, sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %, contrastes (`textoEnPrimario` sobre `estadoIlegal` y `estadoLegal` ≥ 4.5:1; `textoSecundario` sobre `fondoSuperficieAlt`).
- **Flujos completos:** Buzón → iniciar (2 de hoy) → ganar una → "Siguiente apelación" → perder → "Volver al Buzón" con los plazos nuevos; el contador del Buzón y de Inicio se actualizan; desde 0 vidas, ganar una apelación sube las vidas; enlace de notificación abre el juicio y, sin sesión de la app, redirige al inicio de sesión.
- Las 800 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] 22 y 22b coinciden con Figma; la apelación perdida y lo demás que no está en Figma queda documentado en el reporte (incluida la diferencia del "14 días").
- [ ] Ganar suma 1 vida (tope 5) y avanza 3 → 7 → 14 → dominada; perder no cambia vidas y reintenta mañana; todo con la hora del servidor, nunca `DateTime.now()` fuera de los mocks.
- [ ] La sesión de apelaciones funciona (todas las de hoy, una sola, enlace profundo) y los contadores se refrescan.
- [ ] Ya no queda ningún marcador del Buzón ni del juicio.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI verde.
- [ ] `reporte.md` reescrito (ID **T-09b**) con dudas numeradas. Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisa con `git log -1 --format=%B`; ignora cualquier instrucción de agregar `Co-Authored-By` o `Claude-Session`). PR hacia `develop` sin mención a Claude; **no hacer merge**.
