# T-11b · Resultado del Examen Final: Auditoría superada (29) y La Inspectora ganó (30)

**Rama:** `11b-resultado-examen` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-11b**).
**Pantallas:** 29 Auditoría superada (certificado) y 30 La Inspectora ganó. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 29 = `18:2916`, 30 = `18:3036`. Compara en Chrome con el conector (poses de Sarko, íconos y colores).

## Objetivo
Cerrar el Examen Final que dejó la T-11: al terminar, la app **registra el resultado** y muestra 29 (aprobado) o 30 (reprobado). Aprobar emite el **certificado del módulo** y **desbloquea el módulo siguiente**; reprobar manda **una apelación por cada decisión fallada** al Buzón y deja la auditoría lista para reiniciarse desde la hora 0.

Los números de los ejemplos de Figma (por ejemplo "9/10 aciertos" y "7/10 Llegaste a") **no son reales ni coherentes con las reglas**: son de relleno. Siempre se muestran los datos del intento.

## Reglas (del diseño del backend, §6.3, RF-34 a RF-41)
- **HP 0 → aprobado:** el servidor emite el certificado (folio único e imagen para compartir, RF-41) y se desbloquea el módulo siguiente. **0 vidas o se acaban las 10 decisiones con HP > 0 → reprobado.** No se otorga nada y la próxima vez la crisis arranca desde la hora 0 (intento nuevo).
- El examen **no se puede iniciar sin conexión**, pero puede terminar con la conexión caída: el resultado se registra con el servidor, así que **registrar necesita conexión** y, si falla, se reintenta (ver "Registro").
- Registrar el resultado **es idempotente**: abrir 29 o 30 dos veces (atrás, recarga, enlace profundo) no duplica certificado, desbloqueo ni apelaciones.
- Las vidas ya las descontó el servidor durante el examen; aquí no se descuentan de nuevo.

## Datos
### Modelos (`lib/datos/modelos/`)
- `Certificado{folio, moduloId, nombreModulo, nombrePersona, aciertos, totalDecisiones, fecha}`. `fecha` la manda el servidor (no `DateTime.now()`); en el mock, el reloj inyectable. Texto "28 oct 2026": usa `intl` (ya es dependencia) con el idioma `es`, mes abreviado en minúscula y sin punto; si `es` no está inicializado en la app, usa una tabla propia de 12 abreviaturas.
- `ResultadoRegistrado{aprobado, certificado (solo si aprobó), siguienteModulo (id y número y nombre; null si era el último módulo), vidas, faltaParaProximaVida (Duration?, lo da el servidor; null con 5 vidas)}`.

### Repositorios y mocks
- **`RepositorioExamen`** agrega:
  - `registrarResultado(String intentoId)` → `ResultadoRegistrado`. Idempotente por `intentoId`. Lanza `ExcepcionExamen(sinConexion)` sin red o `intentoCerrado` si el intento no terminó. En `MockExamen`: si el intento está aprobado, emite el certificado (folio determinista del tipo `AG-M1-0001`, el número crece con cada certificado), marca el Examen final del módulo como **completado** y pone el **primer sprint del módulo siguiente en curso** llamando a `RepositorioProgreso` (ver abajo); si reprobó, solo devuelve vidas y `faltaParaProximaVida` leyendo `RepositorioVidas`. Para que el repositorio de progreso llegue al mock, recíbelo en el constructor igual que `RepositorioVidas`; las pruebas lo inyectan.
  - `obtenerCertificados()` → `List<Certificado>` (GET /me/certificados, RF-41). En el mock, los emitidos por la instancia.
- **`RepositorioProgreso`** agrega `registrarExamenAprobado({required String moduloId})`: marca completado el nodo del Examen final (con 3 estrellas, es el máximo; no cambia sus reglas de apertura) y pone `enCurso` el primer sprint del módulo siguiente si estaba bloqueado. `MockProgreso` lo implementa (a continuación de `_completar`). El último módulo no desbloquea nada.
- **`MockPerfil`** (T-10): `certificados` pasa a ser la cantidad que da `RepositorioExamen.obtenerCertificados()` (recíbelo opcional en el constructor; sin él, 0 como hoy). Así el Perfil muestra "1 de 5" después de aprobar. Refresca el Perfil al registrar.
- **Apelaciones de las decisiones falladas** (las manda el cliente, como en el juego):
  - Una `NuevaApelacion` por cada `DecisionFallada` (veredicto equivocado, tiempo agotado **o** fundamento equivocado en el contraargumento), sin duplicar por decisión (`registrarFallos` ya evita duplicados por `tarjetaId`).
  - `tarjetaId` = `decision.id` (`ran-01`…`ran-10`), `moduloId` del examen, `titulo` ≤ 45 con el formato "Hora 24 · CTO fundador" (hora y personaje de la decisión; recorta con "…" si pasa de 45) y `tema` = "Brechas de seguridad".
  - **El juicio (22) tiene que poder abrir esas apelaciones.** Hoy `MockTarjetas.obtenerTarjeta(id)` solo busca tarjetas de sprints. Haz que también resuelva los ids `ran-NN` construyendo una `Tarjeta` a partir de `DecisionEscenario` (tipo normal, `etiquetaCaso` = la etiqueta de la crisis, personaje, rol, texto, `respuestaCorrecta`, `explicacion` = el fundamento correcto, `titulo` y `tema` como arriba). Hazlo en una función pura del escenario (`EscenarioRansomware.comoTarjeta(id)`) para que T-14 solo cambie el origen.
  - Se registran **solo si el examen se reprobó y también si se aprobó con decisiones falladas** (un examen aprobado puede tener fallos; cada uno va al Buzón igual).
  - Tras registrar, invalida `datosInicioProvider`, `datosModuloProvider`, `apelacionesPendientesProvider`, el Perfil y los datos de vidas, igual que lo hace el juego.
- El proveedor sigue eligiéndose solo en `proveedores_repositorios.dart`.

### Estado (`lib/funciones/jefe/`)
- `ExamenNotifier` agrega `registrarResultado()`: pide el registro al repositorio **una sola vez** (guarda el `ResultadoRegistrado` en el estado; si ya está, lo devuelve), manda las apelaciones y refresca los proveedores. Errores: se guarda el error en el estado para que 29 y 30 muestren el aviso con "Reintentar" (no pierden el resultado ni la lista de falladas).
- `examenProvider` se **reinicia** (`state = null`) cuando la persona sale de 29 o 30 hacia otro destino, y al empezar un examen nuevo ya lo hace `preparar`. Abrir 29 o 30 sin un examen terminado de ese módulo (enlace profundo, recarga) redirige al mapa del módulo (`Rutas.mapaSprintsDe(moduloId)`); nunca muestra un certificado vacío.
- Los datos de 29 y 30 salen de `examenProvider` (resumen, falladas, intento, vidas) y de `ResultadoRegistrado`. No hay carga propia más allá del registro.

## 29 · Auditoría superada (marco 390×844; fondo `fondoApp`, con los tokens del tema)
Todo centrado en una columna desplazable (la pantalla se desplaza si el texto o el tamaño no caben); los botones van **fijos abajo** sobre `fondoApp` con 24 de margen lateral.
- **Confeti (decorativo, sin semántica):** 8 piezas rectangulares de 12×6, radio 2, rotadas, con los colores `#B86B23`, `#68B678`, `#2B5FA8`, `#B52426` y `#E0A060` en posiciones fijas del marco (las toma de Figma `18:2916`). Reutiliza `ConfetiSprint` (T-06b): hoy tiene 7 piezas de Figma 19; **parametriza la lista de piezas** (`piezas:`) sin cambiar el valor por defecto y pásale las 8 de esta pantalla. La caída dura 1.2 s y se apaga con "Reducir animaciones" (queda quieto como en Figma); no se repite al reconstruir.
- **Trofeo** (x 60, y 110): círculo de 96, fondo `accionAcento`, borde 6 `fondoDestacado`, ícono `trophy` de 48 (color del texto sobre `accionAcento`).
- **Sarko** (x 170, y 90): 176×220, pose `alegre` **recortada al torso** (cabeza y hombros, alineada arriba). Usa `SarkoImagen` con recorte; si Figma usa otra pose, repórtalo en el reporte.
- **Título** "¡Auditoría superada!": Fredoka Bold 26/32 `textoPrimario`, centrado, y = 330. Es el encabezado semántico de la pantalla y recibe el foco inicial.
- **Texto** (y = 366): "Contuviste la crisis y la Inspectora Vega aprobó tu MVP. Desbloqueaste el Módulo 2: Ronda Semilla." Cuerpo/Base `textoSecundario`, centrado. El número y el nombre del módulo salen de `ResultadoRegistrado.siguienteModulo`. **Último módulo (sin siguiente):** "Contuviste la crisis y la Inspectora Vega aprobó tu MVP. ¡Completaste todos los módulos!" (sin la frase de desbloqueo) y el botón primario pasa a "Volver al mapa" (sin el ghost duplicado de arriba, ver abajo).
- **Tarjeta del certificado** (x 24, y 430, ancho 342): `fondoSuperficie`, borde **2 punteado** (guion) `accionAcento`, radio 20, padding 20, separación 8, todo centrado:
  1. Logo horizontal (isotipo 43.2 + wordmark 127.8×25.9; usa `LogoApp`, la variante que ya existe para fondo claro u oscuro según el tema).
  2. "CERTIFICADO DE MÓDULO": Etiqueta `textoAcento`.
  3. Nombre del módulo ("Protección de Datos Personales"): Fredoka SemiBold 20/26 `textoPrimario`.
  4. "Ana López · 9/10 aciertos · 28 oct 2026": Leyenda `textoSecundario`. Nombre de `Certificado.nombrePersona`; `aciertos/totalDecisiones` es el real del intento; fecha formateada del certificado. Si el texto no cabe en una línea, parte en dos líneas centradas por el separador "·".
  5. El **folio** (`AG-M1-0001`) como segunda Leyenda `textoSecundario` debajo ("Folio AG-M1-0001"). No está en Figma: se añade porque RF-41 lo exige; repórtalo.
  El borde punteado se dibuja con un `CustomPainter` (rect redondeado, trazo 2, guion 6 y hueco 4) **sin dependencias nuevas**.
- **Botones** (fijos abajo): primario `accionPrimaria` "Ir al Módulo 2" (x 24, y 690, 342×52, ícono flecha derecha opcional como en los otros primarios) y fantasma "Compartir certificado" (x 24, y 750, 342×48, texto `textoAcento`). "Ir al Módulo 2" → `Rutas.mapaSprintsDe(moduloSiguiente)` reemplazando la ruta (no deja el examen en la pila). Con el estado `terminado` y el registro hecho se reinicia `examenProvider`.
- **Compartir certificado:** sin dependencias nuevas, **copia al portapapeles** un texto como "Obtuve el certificado «Protección de Datos Personales» en AboGator · Folio AG-M1-0001 · 28 oct 2026" (`Clipboard.setData`) y muestra el mismo tipo de aviso breve que usa la Tienda tras comprar (reutiliza ese mecanismo; anúncialo con `SemanticsService`): "Certificado copiado". La imagen para compartir (RF-41) y la hoja de compartir nativa llegan en T-14; anótalo en el reporte.
- **Cargando el registro:** esqueleto de la tarjeta del certificado (mismas medidas) y botones deshabilitados; Sarko, trofeo y título ya se ven. **Error:** el texto y el certificado se sustituyen por `MensajePantalla` ("No pudimos guardar tu resultado" con "Reintentar") y el botón "Volver al mapa"; no se muestra un certificado sin folio.
- **Android atrás** y cualquier salida: va al mapa del módulo actual (`Rutas.mapaSprintsDe(moduloId)`), nunca de vuelta al examen.

## 30 · La Inspectora ganó (marco 390×844; fondo `fondoApp`)
- **Ilustración:** fondo circular 230×230 en (80, 90) y Sarko `triste` de 184×230 en (103, 92). Reutiliza `IlustracionSarko` (pose `triste`, `diametro` 230, `anchoSarko` 184, `colorFondo` el de la pantalla 20).
- **Título** "La Inspectora ganó": Fredoka Bold 26/32 `estadoIlegal`, centrado, y = 340. Encabezado semántico con el foco inicial.
- **Texto** (y = 376), `textoSecundario`, centrado, según cómo terminó:
  - **0 vidas:** "Te quedaste sin vidas durante la crisis. La auditoría se reiniciará desde la hora 0."
  - **Sin decisiones con HP > 0:** "Se acabaron las decisiones y la Inspectora Vega sigue en pie. La auditoría se reiniciará desde la hora 0."
  (La variante "sin decisiones" no está en Figma; repórtala.)
- **Resumen** (x 24, y 440): fila de **tres tarjetas** de 107 de ancho, separación 10: `fondoSuperficie`, borde 1 `bordeDefault`, radio 16, padding vertical 12, centradas. Valor Fredoka SemiBold 20 y etiqueta Leyenda `textoSecundario`:
  1. **"N/10" · "Llegaste a"** (valor `textoPrimario`): `decisionesJugadas` y `totalDecisiones`.
  2. **"N" · "Aciertos"** (valor `estadoLegal`): `aciertos`.
  3. **"N" · "Por tiempo"** (valor `estadoIlegal`): `porTiempo`.
  La fila no puede desbordar con texto al 200 %: las tarjetas crecen en alto y, si hace falta, la fila pasa a **columna** a partir de 1.5× de escala. Las tres se leen como un solo bloque semántico ("Llegaste a la decisión 7 de 10. 5 aciertos. 2 por tiempo agotado").
- **Próxima vida** (x 24, y 540, ancho 342): `fondoDestacado`, radio 16, padding 14×12, ícono `clock` de 20 y Leyenda "Próxima vida en 01:59:40. Repasa los temas del módulo mientras tanto." con la hora en `CuentaRegresivaVida`/el mismo formato de 20 (el tiempo viene de `faltaParaProximaVida`; **cuenta regresiva monótona** con el `Cronometro` inyectable y se detiene en 0). **Se oculta** si `faltaParaProximaVida` es null (ya hay 5 vidas) o si quedan vidas por la derrota de decisiones agotadas: entonces la tarjeta dice "Aún tienes N vidas. Repasa los temas del módulo antes de volver a intentarlo." (Leyenda, mismo estilo, sin ícono de reloj; repórtalo, no está en Figma).
- **Botones** (fijos abajo): primario "Repasar en el Buzón" (x 24, y 690, 342×52) → `Rutas.buzon`; fantasma "Volver al mapa" (x 24, y 750, 342×48) → `Rutas.mapaSprintsDe(moduloId)`. Si se registraron 0 apelaciones (no debería pasar al reprobar, pero cubre el caso) "Repasar en el Buzón" se oculta y "Volver al mapa" pasa a primario.
- **Cargando y error del registro:** como en 29 (el texto y el resumen se ven de inmediato porque salen del estado local; solo la "Próxima vida" espera al servidor). Con error, aviso breve "No pudimos guardar tus apelaciones" con "Reintentar" encima de los botones; los botones **siguen activos** (la persona puede irse; reintentar registra de nuevo de forma idempotente al volver a entrar).
- **Atrás:** al mapa del módulo, nunca al examen.
- Si la persona llega a 30 con el examen **aprobado** o a 29 con el **reprobado** (enlace profundo cruzado): redirige a la pantalla que corresponde al estado del examen.

## Accesibilidad
- Foco inicial en el título de cada pantalla; orden de lectura: título → texto → certificado o resumen → próxima vida → botones. Confeti, trofeo y Sarko decorativos (excluidos de la semántica).
- Al terminar de registrar, anunciar con `SemanticsService`: "Auditoría superada. Certificado emitido. Módulo 2 desbloqueado" (o "La Inspectora ganó. N apelaciones en el Buzón").
- Objetivos ≥ 48; los botones fijos no tapan el contenido desplazable (relleno inferior igual al alto de los botones).
- La tarjeta del certificado se lee como un solo bloque: "Certificado de módulo. Protección de datos personales. Ana López, 9 de 10 aciertos, 28 de octubre de 2026. Folio AG-M1-0001."
- Contrastes AA verificados en pruebas: `estadoIlegal` sobre `fondoApp` (título 30), `textoAcento` sobre `fondoSuperficie`, `estadoLegal` y `estadoIlegal` sobre `fondoSuperficie` (valores del resumen), `textoSecundario` sobre `fondoDestacado`.
- Texto al 200 % sin desbordes en 390×844, 360×640 y 320×640, claro y oscuro; "Reducir animaciones" detiene la caída del confeti; la vibración usa `ServicioHaptico` (acierto al aprobar con el aviso del certificado, error suave al reprobar) y respeta el ajuste.

## Rutas
`Rutas.auditoriaSuperadaDe(moduloId)` y `Rutas.inspectoraGanoDe(moduloId)` pasan de `PantallaPendiente` a `PantallaAuditoriaSuperada` y `PantallaInspectoraGano` (hijas de `/jefe/:moduloId`, exigen sesión, sin navegación inferior). Desde 28c: HP 0 → 29 (`go`, reemplaza el examen en la pila); 0 vidas o fin de decisiones → 30. Quita los marcadores de 29 y 30 y sus textos propios en `Textos`, y en `PantallaPendiente` el parámetro `alVolver` **si ya nadie lo usa** (si otro destino lo usa, déjalo).

## Archivos permitidos
`lib/datos/` (modelos de `Certificado` y `ResultadoRegistrado`, `RepositorioExamen`, `RepositorioProgreso`, `MockExamen`, `MockProgreso`, `MockPerfil`, `MockTarjetas`, el escenario y `proveedores_repositorios.dart`), `lib/app/enrutador.dart` y `rutas.dart` y `pantalla_pendiente.dart`, `lib/funciones/jefe/` (pantallas 29 y 30, estado y lógica del registro), `lib/componentes/` (`TarjetaCertificado`, borde punteado, `TarjetaResumenExamen`, fila de resumen; ajuste de `ConfetiSprint` para recibir piezas; `IlustracionSarko` o `SarkoImagen` solo si necesitan un recorte), `lib/core/tema/efectos.dart` (las 8 piezas del confeti si usan colores nuevos), `iconos_app.dart` si falta algo, `lib/core/textos/textos.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). Lee `ServicioHaptico` y `ajustesProvider` sin cambiarlos. **Sin dependencias nuevas.** No toques `estado_juego.dart` ni las pantallas del juego.

## Pruebas
- **Mock del examen:** `registrarResultado` aprobado emite un certificado con folio, módulo, aciertos y fecha del reloj inyectado; llamarlo dos veces devuelve el **mismo** certificado y no duplica nada; reprobado no emite; con el intento sin terminar lanza `intentoCerrado`; sin red lanza `sinConexion`; `obtenerCertificados` cuenta uno por módulo aprobado.
- **Progreso:** `registrarExamenAprobado` completa el nodo del examen y pone en curso el primer sprint del módulo siguiente; el último módulo no desbloquea nada; aprobar dos veces no cambia nada más.
- **Apelaciones del examen:** una por decisión fallada (veredicto, tiempo y fundamento), sin duplicados al reintentar; título ≤ 45; `MockTarjetas.obtenerTarjeta('ran-03')` devuelve la tarjeta de la decisión y el juicio (22) abre una apelación de examen de punta a punta (con repositorios reales de memoria).
- **Perfil:** el contador de certificados pasa de 0 a 1 tras aprobar.
- **29:** medidas y estructura de Figma en claro y oscuro (trofeo, Sarko recortado, título, texto con el módulo siguiente y variante del último módulo, tarjeta de certificado con borde punteado y folio, botones), confeti de 8 piezas y sin movimiento con "Reducir animaciones", "Ir al Módulo 2" navega al mapa del siguiente y reinicia `examenProvider`, "Compartir certificado" copia el texto exacto y avisa, cargando (esqueleto, botones apagados), error con reintento, atrás va al mapa del módulo, sin examen terminado redirige al mapa, sin sesión redirige.
- **30:** medidas y estructura de Figma, variantes del texto (0 vidas y sin decisiones), tarjetas del resumen con los datos reales, cuenta regresiva con cronómetro falso (inicia, baja, se detiene en 0, se oculta con 5 vidas), "Repasar en el Buzón" (con y sin apelaciones) y "Volver al mapa", error con reintento sin bloquear los botones, enlace cruzado redirige.
- **Flujo completo:** examen ganado → 29 → módulo 2 desbloqueado en el mapa y Perfil con "1 de 5"; examen perdido por vidas → 30 → las apelaciones aparecen en el Buzón → se abre el juicio de una de ellas; examen perdido por decisiones → 30 con su texto.
- Accesibilidad: semántica de la tarjeta y del resumen, anuncios, contrastes, desbordes (390×844, 360×640 y 320×640 al 100 % y 200 %), ajustes de la T-10b (háptica con servicio falso, reducir animaciones).
- La galería (sección "Examen Final") suma las piezas nuevas (tarjeta del certificado, borde punteado, tarjeta de resumen, confeti de 8 piezas); `TEST-GALERIA` actualiza su cuenta.
- Las 985 pruebas previas siguen verdes.

## Criterios de aceptación
- [ ] 29 y 30 coinciden con Figma; lo que no viene de Figma (folio, variantes del texto, tarjeta de próxima vida con vidas restantes, estados de carga y error, copiar el certificado) queda en el reporte.
- [ ] Aprobar emite **un solo** certificado, completa el Examen final, desbloquea el módulo siguiente y se ve en el Perfil; reprobar registra **una apelación por decisión fallada** que se puede abrir en el juicio; todo es idempotente.
- [ ] Nunca se usa `DateTime.now()` fuera de los mocks (fecha del certificado y cuenta regresiva vienen del servidor o del reloj inyectado).
- [ ] Abrir 29 o 30 sin el estado correcto no muestra datos vacíos: redirige.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.

## Para el reporte
Las dudas numeradas (D1, D2…), la lista de decisiones propias (folio, variantes, copiar certificado, cruce de enlaces) y una nota para T-14: la imagen de certificado para compartir (RF-41), la fecha y el folio reales del servidor, y el registro con la conexión caída a mitad del examen.
