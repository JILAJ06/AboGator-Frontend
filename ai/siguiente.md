# T-11 · Examen Final (Nivel Jefe): crisis, decisión, contraargumento y golpe

**Rama:** `11-nivel-jefe` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-11**).
**Pantallas:** 27 Crisis, 28 Decisión de crisis, 28b Contraargumento del Jefe y 28c Golpe al Jefe. **29 Auditoría superada y 30 La Inspectora ganó son la T-11b**: aquí solo se les deja la ruta. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 27 = `42:5885`, 28 = `42:6027`, 28b = `42:6140`, 28c = `42:6284`. Compara en Chrome con el conector (poses de Sarko, íconos y colores de los SVG).

## Objetivo
El Examen Final de un módulo: una crisis de 72 horas con **10 decisiones cronometradas**; cada acierto se defiende frente a la Inspectora Vega, y defenderlo bien le quita 20 HP. Esta tarea construye el motor y el recorrido completo del examen; **cómo termina** (certificado, reinicio, registro del resultado) lo hace la T-11b.

## Reglas (del diseño del backend, §6.3, RF-34 a RF-38)
- El intento empieza con **HP del Jefe = 100** y las 10 decisiones del escenario. Los comodines están **desactivados** (RN03).
- **Necesita conexión** para empezar (sin red no se inicia un Examen Final). Con 0 vidas no se puede empezar: lleva a "Sin vidas" (20) del módulo.
- **Cada decisión:** 15 s (**22 s** con "Tiempo extendido", +50 %). El cronómetro de la pantalla es **monótono** (`Cronometro`, nunca el reloj del dispositivo) y arranca desde el límite que da el servidor. Si se agota: cuenta como fallo ("por tiempo"). El mock rechaza como `tiempoAgotado` toda respuesta que llegue 2 s después del límite (reloj inyectable).
- **Veredicto incorrecto o tiempo agotado:** −1 vida y no hay contraargumento. No existe "parcial": solo cuenta el veredicto exacto.
- **Veredicto correcto:** la Inspectora contraargumenta (28b) con **2 fundamentos**, uno correcto; hay **8 s** (**12 s** con tiempo extendido) para elegir. Correcto: **−20 HP** (28c). Incorrecto o sin tiempo: **−1 vida**, sin daño.
- **Fin:** HP 0 → **aprobado** (29). 0 vidas, o se acaban las 10 decisiones con HP > 0 → **reprobado** (30). Con HP 0 el examen termina al instante, aunque queden decisiones.
- **Pausa (RF-38):** solo existe con "Tiempo extendido" activo (`ajustesProvider`). El tiempo se detiene mientras está en pausa.
- **Salir:** pide confirmación y **cierra el intento sin premio ni pérdida de vidas**; la crisis se reinicia desde la hora 0 la próxima vez.
- Las apelaciones de las decisiones falladas y el resultado final los registra la T-11b: aquí el estado guarda todo lo necesario (resumen y falladas).

## Datos
### Modelos (`lib/datos/modelos/`)
- `DecisionCrisis{id, indice (1–10), tarjeta (Tarjeta sin respuesta correcta visible para la UI: usa solo texto, personaje, rol y etiqueta), hora (0–72), limite (Duration)}`.
- `Replica{texto, fundamentos (2 textos)}` y `ResultadoDecision{correcta, tiempoAgotado, vidas, hpJefe, replica (solo si correcta), limiteReplica (Duration), estado (enCurso/aprobado/reprobado), siguiente (DecisionCrisis?)}`.
- `ResultadoContraargumento{correcto, tiempoAgotado, vidas, hpJefe, danio (20 o 0), estado, siguiente}`.
- `IntentoExamen{id, moduloId, hpJefe, vidas, totalDecisiones (10), decision (la primera)}` y `ResumenExamen{decisiones jugadas, aciertos, porTiempo, golpes, vidasRestantes, aprobado}`.
- `FaseJefe`/estado de la UI: `intro`, `decision`, `replica`, `feedback` (golpe o fallo), `pausa`, `terminado`.
- `Fase` por hora (para la línea de crisis y el texto de la hora): H0 Detección (0–5), H6 Contención (6–23), H24 Aviso (24–71), H72 Autoridad (72).

### Repositorio y mock
- `RepositorioExamen`: `iniciar(moduloId)` → `IntentoExamen`; `responderDecision(intentoId, {Veredicto? veredicto})` (`null` = tiempo agotado); `responderContraargumento(intentoId, {int? fundamento})` (`null` = tiempo agotado); `pausar(intentoId)` y `reanudar(intentoId)`; `abandonar(intentoId)`. Errores: `ExcepcionExamen` (`sinConexion`, `sinVidas`, `intentoCerrado`, `examenNoDisponible`).
- `MockExamen` (hace de servidor; recibe `RepositorioVidas` y un reloj inyectable): aplica las reglas de arriba, resta las vidas con `guardarVidas` y valida que no se responda dos veces (`intentoCerrado`). Un solo escenario real: **módulo 1 (Protección de datos)**; los demás módulos lanzan `examenNoDisponible` y 27 muestra `MensajePantalla` "Este examen aún no está disponible" con "Volver al mapa".
- **Escenario "Ransomware" (10 decisiones, horas 0, 1, 3, 6, 9, 12, 18, 24, 48, 72).** Las decisiones **8** (hora 24, CTO "Fundador técnico", "Ya contuvimos el ataque. Propongo borrar los logs del incidente y no avisar a los usuarios para cuidar la reputación. ¿Lo hacemos?", correcto **Ilegal**; réplica "¿Seguro que no debes avisar? Si borras el log nadie se va a enterar."; fundamento correcto "Ocultar evidencia de una brecha agrava la infracción; hay que notificar a los titulares y a la autoridad.", incorrecto "Solo hay que avisar si los datos filtrados eran contraseñas.") y **9** (hora 48, "Abogada externa", "Despacho jurídico", "Ya pasaron 48 horas. ¿Notificamos ahora a la autoridad de protección de datos y a los usuarios afectados?", correcto **Legal**) vienen de Figma. Escribe tú las otras 8 y la réplica y fundamentos de la 9, en español de México, con el mismo tono, sobre el ciclo de una brecha (detección, contención, preservar evidencia, avisar a titulares y autoridad, documentar, proveedores) y **sin citar números de artículo**: nombra la ley solo de forma general (por ejemplo "la ley de protección de datos"). Reparte los veredictos (que no sean todos iguales) y alterna la posición del fundamento correcto (a veces primero, a veces segundo). **Todo el contenido legal queda en una lista en el reporte para que el usuario lo verifique contra su curso.**
- Proveedor en `proveedores_repositorios.dart` (único sitio donde se elige la implementación).

### Estado (`lib/funciones/jefe/`)
- `examenProvider` (Notifier, **se mantiene vivo** hasta que la T-11b guarde el resultado o se salga): intento, decisión actual, fase, vidas, HP, resumen, falladas (con su veredicto y la respuesta correcta que devuelve el servidor al reprobar o al cierre) y el cronómetro de la decisión.
- Los cronómetros usan `Cronometro` inyectable (en pruebas, falso). Al llegar a 0 se responde con `null`.
- Cada respuesta se envía **una sola vez** (sin doble toque ni respuesta tardía tras el tiempo).
- Sin conexión a mitad del examen: se muestra `AvisoConexion` sobre la tarjeta, sin pausar nada (el servidor manda el tiempo); anótalo en el reporte como asunto de la T-14.
- Cuando `estado` pasa a `aprobado`/`reprobado`: tras el feedback (golpe o fallo), `go` a `Rutas.auditoriaSuperadaDe(moduloId)` o `Rutas.inspectoraGanoDe(moduloId)` (nuevos ayudantes; las pantallas reales son de la T-11b, por ahora `PantallaPendiente` con su texto propio y botón "Atrás" que vuelve al mapa).

## 27 · Crisis (marco 390×844; **siempre oscura**, no cambia con el tema)
Columna desplazable, relleno horizontal 24. Colores fuera de los tokens **solo** en `EfectosApp` (constantes iguales en claro y oscuro): fondo `#0F294A`, barra del Jefe `#162030`, avatar del Jefe `#6B4BA1`, vida `#F07070`, textos `#CBD5E1` y `#94A3B8`, punto inactivo y conectores `#2A3850`, verde `#68B678`, réplica `#B7A0E6`; el rojo de alerta es `#B52426` (como `estadoIlegal` claro). Barra de estado del sistema en claro (íconos blancos).
- **Alerta** (24,64): `#B52426`, radio 999, relleno 12×6, separación 6, ícono `alert-triangle`/`alert` de 16 y "NIVEL JEFE · CRISIS EN CURSO" Etiqueta 12 blanca.
- **Título** (24,104, ancho 240): "¡Ransomware! Se filtró la base de usuarios", Fredoka Bold 26/32 blanco. **Sarko** a la derecha (254,86; 112×140, recortado a medio cuerpo como en Figma; compara la pose con el conector y usa la de `IlustracionSarko`/`SarkoImagen` que más se parezca).
- **Texto** (24,210, ancho 342): "Tienes 72 horas para tomar las decisiones correctas antes de que la Inspectora Vega cierre la auditoría." Cuerpo/Base `#CBD5E1`.
- **Barra del Jefe** (24,286; componente `BarraDelJefe`): `#162030`, radio 18, relleno izq. 12 / der. 14 / vert. 10, separación 12; avatar 44 (radio 14, `#6B4BA1`, ícono `gavel` 24 blanco); columna (separación 6): fila "Inspectora Vega" (Inter SemiBold 14 blanco) y "HP 100%" (Etiqueta `#F07070`), pista de 10 (radio 5, blanco 15 %) con la vida (`#F07070`) **proporcional al HP**, y "Auditora de protección de datos" (Leyenda `#94A3B8`). Se lee "Inspectora Vega, auditora de protección de datos. HP 100 por ciento". (En Figma la vida mide siempre 250; aquí se calcula.)
- **Línea de crisis** (32,378; `LineaDeCrisis`): cuatro puntos "H0 Detección", "H6 Contención", "H24 Aviso", "H72 Autoridad": punto 34×24 radio 12 con la hora (Leyenda), la etiqueta debajo (Leyenda `#CBD5E1`), separación 6, conectores 28×2. Activo `#B52426` con texto blanco; inactivo `#2A3850` con texto `#94A3B8`. En 27 solo el primero está activo. Se lee "Línea de crisis: detección, contención, aviso y autoridad".
- **Reglas** (24,434, ancho 342): fondo blanco al 8 %, radio 20, relleno horizontal 16; 4 filas de relleno vertical 10, separación 12, ícono de 20 (`zap`, `megaphone`, `lock`, `heart`) y Cuerpo/Base blanco: "10 decisiones en secuencia rápida: 15 s cada una" (con tiempo extendido, "22 s cada una"), "La Inspectora te contraargumenta: defiende tu veredicto", "Comodines desactivados (RN03)", "Si pierdes todas tus vidas, la crisis se reinicia". Los colores de los íconos, léelos de los SVG de Figma.
- **Tiempo extendido** (centrado, y=664, solo si el ajuste está activo): ícono `accessibility` 16 y "Tiempo extendido activo: 22 s por decisión" Leyenda `#68B678`.
- **Botones** (fijos abajo): primario "Enfrentar la auditoría" (24,722; 342×52, `accionAcento`, sombra de botón) y texto "Ahora no" (centrado, alto 48, Inter SemiBold 14 `#CBD5E1`) que vuelve al mapa.
- Sin conexión: el primario queda deshabilitado y aparece "Necesitas conexión para iniciar el examen." (Leyenda `#CBD5E1`). Sin vidas: al tocar el primario va a `Rutas.sinVidasDe(moduloId)`. Cargando: esqueleto oscuro. Error: `MensajePantalla` con "Reintentar".
- Al empezar: foco en el título; "Enfrentar la auditoría" llama a `iniciar` y pasa a 28.

## 28 · Decisión de crisis (marco 390×844; con los tokens del tema)
Fondo `fondoApp` y encima un **tinte de urgencia** de pantalla completa (`estadoIlegal` al 6 %, decorativo, siempre presente en 28, 28b y 28c). Sin navegación inferior.
- **Barra de juego** (y=48, alto 56): reusa `BarraJuego` con `paso` "Crisis · Decisión 8 de 10", progreso k/10 y el chip de vidas ("2"). Salir (48) abre la confirmación.
- **Barra del Jefe** (24,108) con el HP actual ("HP 60%").
- **Hora de crisis** (40,186): `#B52426` (`estadoIlegal`), radio 999, relleno izq. 10 / der. 12 / vert. 5, separación 6, ícono `clock` 14 y "Hora 24 de 72" (Etiqueta blanca).
- **Tarjeta** (24,200; 342×410): reusa `TarjetaCaso` y `MazoSwipe` (4 direcciones, sellos, botones equivalentes, solo botones si el ajuste lo pide). Etiqueta "CRISIS · BRECHA DE DATOS" (chip `#B86B23` al 14 %, texto `textoAcento`; el color sale de `EfectosApp`), avatar con iniciales ("CT"), "CTO / Fundador técnico", globo con el texto y la pista de gestos.
- **Temporizador** (`TemporizadorCrisis`): fondo circular de 80 (superficie con sombra) en (298,176) y anillo de 64 en (306,184) con el número en Fredoka Bold 24; el anillo se vacía con el tiempo restante. **Normal:** número y anillo `accionPrimaria`. **Urgente** (≤ 5 s): `estadoIlegal`. Lee el SVG del anillo en Figma (`10:184` y `10:188`) para el grosor. No es el reloj del dispositivo.
- **Acciones** (28.5,626): `AccionesVeredicto` (los 4 botones de 68, separación 14).
- **Comodines** (56.5,740): píldora de 48 `fondoSuperficieAlt`, radio 999, relleno izq. 10 / der. 12, ícono `lock` 16 y "Comodines desactivados en el examen" (Etiqueta `textoSecundario`). Usa `BarraComodines(habilitados: false)` solo si ya da este resultado; si no, un componente propio.
- **Pausa** (322,782; 48×48, `fondoSuperficie`, borde 1, radio 12, ícono `pause` 18): **solo con tiempo extendido**. Abre una capa opaca `fondoApp` con "Examen en pausa", "El tiempo está detenido." y los botones "Continuar" y "Salir del examen"; mientras dura, la tarjeta no se ve.
- **Al responder:** vibración (`acierto` / `error` del `ServicioHaptico`); tarjeta vuela (animación del juego). Incorrecto o sin tiempo: chip de fallo (ver abajo) y luego la siguiente decisión; correcto: 28b.
- **Chip de fallo** (mismo lugar y forma que el de daño de 28c): superficie `fondoSuperficie`, borde `estadoIlegal`, ícono `heart` y "−1 vida · Fallaste" / "−1 vida · Se acabó el tiempo" / "−1 vida · Ese fundamento no sirve" (Etiqueta `textoPrimario`); visible ~1.5 s; región en vivo.

## 28b · Contraargumento del Jefe
Es 28 con la tarjeta ya enviada y un **velo** `#0B1220` al 40 % (decorativo, no cierra nada) más el **panel de contraargumento** anclado abajo.
- **Tarjeta enviada:** queda a la vista en la pose de vuelo del veredicto elegido (en Figma, "Ilegal": girada −14° y movida a la izquierda, con el sello visible) y el temporizador **detenido** en su valor.
- **Panel** (`PanelContraargumento`, y=423, ancho 390, hasta abajo): `fondoSuperficie`, radio superior 28, sombra elevada, relleno arriba 12 / abajo 34 / horizontal 24, separación 14; sin descarte (ni deslizar, ni tocar el velo; atrás abre "Salir del examen").
  - Agarre 40×5 (radio 3, `bordeDefault`).
  - **Réplica:** avatar 44 del Jefe (radio 14, `#6B4BA1`, `gavel`) y globo `#162030` (radios 4/16/16/16, relleno 14×12): "INSPECTORA VEGA" (Leyenda `#B7A0E6`) y la cita entre comillas curvas en Fredoka SemiBold 17/22 blanco.
  - "Defiende tu veredicto · elige el fundamento" (Etiqueta `textoSecundario`).
  - **2 `OpcionJustificacion`** (el componente de la T-07, radio, ancho completo). **Tocar una opción responde de inmediato** (no hay botón de confirmar: hay prisa; anótalo como decisión en el reporte).
  - Fila de tiempo: ícono `alert` 14 y "Tienes 8 s para responder" (Leyenda `estadoIlegal`), con la cuenta regresiva real ("Tienes 5 s…"); con tiempo extendido, 12 s.
- Accesibilidad: al abrir, foco en la réplica y anuncio "La Inspectora contraargumenta: … Tienes 8 segundos"; se anuncia de nuevo a los 3 s. Orden: réplica → fundamento 1 → fundamento 2.

## 28c · Golpe al Jefe
Vuelve a 28 con la **siguiente decisión** ya cargada ("Crisis · Decisión 9 de 10", "Hora 48 de 72", otra tarjeta) y el HP ya reducido ("HP 40%"; la barra baja en 300 ms, sin animación con "reducir animaciones").
- **Chip de daño** (152,92, centrado sobre la barra del Jefe): `#B52426`, radio 999, relleno 12×6, separación 6, sombra (0,16,40, 22 %), ícono `zap` 16 y "−20 HP · ¡Argumento sólido!" (Etiqueta blanca). Visible ~1.5 s, región en vivo ("Daño a la Inspectora: menos 20 HP. Le quedan 40."), vibración `acierto`.
- **El tiempo de la nueva decisión empieza a correr cuando el chip desaparece**, no antes (el temporizador se ve lleno y detenido mientras tanto).
- Si el golpe lleva el HP a 0, el examen termina: tras el chip, `go` a la ruta de 29.

## Accesibilidad (todo el flujo)
- Cada decisión: etiqueta de la tarjeta "Decisión k de 10. personaje, rol: texto", con la hora ("Hora 24 de 72") y el HP leídos en su propio bloque. El temporizador **no** se lee continuamente: se anuncia el límite al empezar, a los 10 s, a los 5 s y "Tiempo agotado".
- Objetivos ≥ 48 (los botones de veredicto de 68); foco inicial en la tarjeta; orden de foco: barra de juego → Jefe → hora → tarjeta → botones → pausa.
- Nada depende solo del color (urgencia: número y anillo más el texto "Quedan N segundos" en la semántica). Tinte de urgencia al 6 %, sin parpadeos.
- Contrastes AA verificados en pruebas: blanco sobre `#B52426`, `#94A3B8` y `#CBD5E1` sobre `#0F294A` y `#162030`, `#F07070` sobre `#162030`, `#68B678` sobre `#0F294A`, `#B7A0E6` sobre `#162030`, `estadoIlegal` sobre `fondoSuperficie`, `textoSecundario` sobre `fondoSuperficieAlt`.
- Texto al 200 % sin desbordes en 390×844, 360×640 y 320×640 (27 se desplaza; en 28 la tarjeta se estira o la pantalla se desplaza como en el juego).
- Los ajustes "Reducir animaciones", "Solo botones", "Vibración" y "Tiempo extendido" se respetan aquí (los dos últimos con efecto real).

## Rutas
`Rutas.crisisJefe` pasa a `PantallaJefe` (27 → 28 → 28b → 28c dentro de la misma ruta, con la fase en `examenProvider`), exige sesión como las demás, y sin navegación inferior. Añade `Rutas.auditoriaSuperadaDe(moduloId)` y `Rutas.inspectoraGanoDe(moduloId)` y deja sus constantes con marcadores (`PantallaPendiente`, texto propio y "Atrás"). Quita `Textos.pendienteJefe`. "Comenzar" en la intro del Examen (09) ya llega a 27: verifícalo.

## Archivos permitidos
`lib/datos/` (modelos y repositorio del examen, `MockExamen`, el escenario y `proveedores_repositorios.dart`), `lib/app/enrutador.dart` y `rutas.dart`, `lib/funciones/jefe/` (pantallas, estado, lógica, piezas), `lib/componentes/` (`BarraDelJefe`, `LineaDeCrisis`, `TemporizadorCrisis`, `PanelContraargumento`, chips de hora, daño y fallo, y ajustes menores a `BarraJuego`, `TarjetaCaso` y `ChipHud` si hace falta), `lib/core/tema/efectos.dart` e `iconos_app.dart` si falta algo, `lib/core/textos/textos.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). Lee `ServicioHaptico` y `ajustesProvider` sin cambiarlos. **Sin dependencias nuevas.**

## Pruebas
- **Mock:** 10 decisiones con 4 veredictos; correcto → réplica con 2 fundamentos; fundamento correcto −20 HP, incorrecto o sin tiempo −1 vida; incorrecto y tiempo agotado −1 vida sin réplica; 5 golpes → aprobado (también antes de la decisión 10); 0 vidas → reprobado; se acaban las decisiones con HP > 0 → reprobado; respuesta repetida o fuera de turno → `intentoCerrado`; respuesta 2 s tarde → `tiempoAgotado` (reloj inyectado); tiempo extendido (22 s y 12 s); sin vidas o sin red no inician; módulo sin escenario → `examenNoDisponible`; salir no cambia vidas.
- **Lógica:** fases por hora; HP proporcional; urgencia a ≤ 5 s; textos de cada resultado.
- **27:** estructura y medidas de Figma, línea de crisis, reglas (15 s y 22 s), línea de tiempo extendido solo con el ajuste, sin conexión (botón deshabilitado y aviso), sin vidas (va a 20), módulo sin examen, error y reintento, "Ahora no", sin sesión redirige.
- **28:** medidas y piezas de Figma en claro y oscuro (tinte, hora, temporizador normal y urgente, pastilla de comodines, pausa solo con tiempo extendido); arrastre y botones dan el mismo resultado; tiempo agotado responde `null` una sola vez (cronómetro falso); fallo con chip y vidas; pausa detiene el cronómetro y no deja ver la tarjeta; Salir (confirmación, cancelar, confirmar → mapa sin perder vidas).
- **28b:** panel y velo, cuenta regresiva (8 s y 12 s), tocar una opción responde, tiempo agotado = fallo, no se descarta, foco y anuncios.
- **28c:** chip de daño, HP 60 → 40, el cronómetro de la siguiente decisión espera al chip, HP 0 navega a 29, 0 vidas o fin de decisiones navega a 30.
- **Flujo completo:** examen ganado (5 golpes) y perdido (por vidas y por decisiones) en pruebas de widget con cronómetro falso.
- Accesibilidad: semántica, anuncios del temporizador, contrastes, desbordes (390×844, 360×640, 320×640 al 100 % y 200 %), ajustes de la T-10b (solo botones, háptica con servicio falso, reducir animaciones).
- Las 938 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] 27, 28, 28b y 28c coinciden con Figma; lo que no viene de Figma (chip de fallo, pausa, tocar responde, escenario de las otras 8 decisiones, módulos sin examen, avisos sin conexión) queda en el reporte, y la lista de contenido legal para que el usuario la verifique.
- [ ] Las reglas del examen se cumplen en el mock y en la pantalla con el cronómetro monótono; nunca se usa `DateTime.now()` fuera de los mocks.
- [ ] El flujo completo funciona de principio a fin hasta las rutas de 29 y 30 (marcadores).
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.
