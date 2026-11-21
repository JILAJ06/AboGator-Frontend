# Reporte
- **Tarea:** T-11 · Examen Final (Nivel Jefe): crisis, decisión, contraargumento y golpe (pantallas 27, 28, 28b y 28c)
- **Rama:** `11-nivel-jefe`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge. 29 y 30 quedan con marcador para la T-11b.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas.
- **Comparé contra Figma** con el conector (solo lectura): 27 (`42:5885`), 28 (`42:6027`), 28b (`42:6140`) y 28c (`42:6284`).
  - **Sarko de 27:** pose **enojado** (mazo en alto, ceño), la que coincide con Figma.
  - **Anillo del temporizador** (SVG de `10:188`): trazo **6**, pista `#F1F5F9` (= `fondoSuperficieAlt`), arco desde arriba en sentido horario con punta redonda. El fondo de 80 lleva la sombra de tarjeta (0, 8, 24, 14 %).
  - **Íconos de las reglas de 27:** `#E0A060` (leído de los SVG); lo guardé como `EfectosApp.iconoReglaCrisis`.
- **Prueba en el navegador** (web a 390×844, cuenta de prueba del mock en localhost):
  - **27** coincide con Figma: alerta, título con Sarko, texto, barra del Jefe, línea de crisis, reglas y botones.
  - **28** coincide: barra "Crisis · Decisión 1 de 10", barra del Jefe, chip "Hora 0 de 72", temporizador, tarjeta, veredictos y la pastilla de comodines. Con tiempo extendido aparece la pausa.
  - **28b:** para verlo compilé **una versión temporal** con tiempos largos, porque las capturas del panel tardan más de 8 s (la revertí antes de subir; las pruebas usan los tiempos reales). La tarjeta queda girada con el sello, con velo, réplica, dos fundamentos y "Tienes N s para responder".
  - **28c:** con el fundamento correcto, HP 100 → 80 y ya se ve la decisión 2.
  - Probé también que el tiempo agotado resta vidas y que al quedarse sin vidas lleva a la ruta de 30.

## Qué se hizo
1. **Datos:**
   - Modelos en `examen.dart`: `FaseCrisis`, `EstadoExamen`, `DecisionCrisis`, `Replica`, `ResultadoDecision`, `ResultadoContraargumento`, `InfoExamen`, `IntentoExamen`, `ResumenExamen` y `DecisionFallada`.
   - `RepositorioExamen` con `consultar` (lo que muestra 27) además de lo pedido, y `ExcepcionExamen`.
   - `repositorioExamenProvider` en `proveedores_repositorios.dart`.
2. **`MockExamen`** (hace de servidor, con reloj inyectable y las vidas en `RepositorioVidas`):
   - HP 100 y 10 decisiones; 15 s por decisión (22 s con tiempo extendido) y 8 s por réplica (12 s).
   - Correcto → réplica; fundamento correcto −20 HP; incorrecto, tiempo agotado o veredicto incorrecto −1 vida (con `guardarVidas`).
   - **Aprobado** con HP 0, aunque queden decisiones. **Reprobado** con 0 vidas o al acabarse las decisiones con HP > 0.
   - `intentoCerrado` si se responde dos veces, fuera de turno, en pausa o tras cerrar.
   - Una respuesta que llega más de **2 s** después del límite cuenta como tiempo agotado.
   - La pausa corre el límite lo que duró. Abandonar cierra sin tocar vidas.
   - Sin red o sin vidas no inicia. Solo el módulo 1 tiene escenario; los demás lanzan `examenNoDisponible`.
3. **Estado (`examenProvider`, vivo hasta la T-11b):**
   - Fase (intro, decisión, réplica, chip, pausa, terminado), decisión, vidas, HP, réplica, resumen y **falladas** (con el veredicto elegido y la respuesta correcta).
   - Cada respuesta se envía una sola vez: se ignora si ya hay una en camino o si no es su turno.
4. **Reloj (`RelojCrisis`):** usa `Cronometro` monótono inyectable (`crearCronometroJefeProvider`; falso en pruebas). Se detiene en pausa, mientras se envía y durante el chip, y sigue donde iba. Llama a "agotado" una sola vez y avisa cada segundo para los anuncios.
5. **Pantallas** (`pantalla_jefe.dart`; 27 → 28 → 28b → 28c en la misma ruta):
   - **27:** siempre oscura (colores fijos de `EfectosApp`; usa el tema claro para el botón y los mensajes). Con tiempo extendido, "22 s" y la línea verde.
     - Sin conexión: el botón queda deshabilitado y aparece el aviso.
     - Sin vidas: lleva a "Sin vidas" del módulo.
     - Módulo sin examen: "Este examen aún no está disponible" con "Volver al mapa".
     - Esqueleto oscuro mientras carga y error con "Reintentar".
   - **28:**
     - tinte de urgencia al 6 %; `BarraJuego` con paso propio y vidas; barra del Jefe; chip de hora; temporizador (verde, rojo a ≤ 5 s);
     - `TarjetaCaso` + `MazoSwipe` (arrastre, botones y teclado; respeta "solo botones");
     - la pastilla de comodines y la pausa (solo con tiempo extendido);
     - `AvisoConexion` sin conexión;
     - Salir y atrás piden confirmación.
   - **28b:** la tarjeta queda en su pose de vuelo, girada 14° hacia el lado del veredicto, con el sello. Encima, el velo (`ModalBarrier` sin descarte) y el panel con la réplica, los dos fundamentos y la cuenta regresiva real.
   - **28c:**
     - el chip de daño sobre la barra del Jefe;
     - la vida baja en 300 ms (sin animación con "reducir animaciones");
     - ya se ve la siguiente decisión con el tiempo lleno y **detenido hasta que el chip desaparece** (1.5 s).
   - Con HP 0 va a la ruta de 29; con 0 vidas o sin decisiones, a la de 30.
6. **Componentes nuevos** (`piezas_jefe.dart`): `AvatarJefe`, `BarraDelJefe`, `LineaDeCrisis`, `ChipHoraCrisis`, `TemporizadorCrisis` con su pintor del anillo, `ChipGolpe` (daño y fallo), `PildoraComodinesBloqueados` y `PanelContraargumento`. Todos están en la galería.
7. **Rutas:**
   - `/jefe/:moduloId` → `PantallaJefe` (exige sesión, sin barra inferior).
   - Ayudantes `auditoriaSuperadaDe` e `inspectoraGanoDe`.
   - 29 y 30 son marcadores (`PantallaPendiente`) con texto propio y "Atrás" al mapa. Para eso `PantallaPendiente` suma `alVolver`.
   - Quité `Textos.pendienteJefe`.
   - Verifiqué que el nodo del Examen final del mapa y "Comenzar" de la intro llegan a 27.
8. **Ajustes de la T-10b:**
   - **tiempo extendido:** 22 s, 12 s y la pausa;
   - **solo botones;**
   - **vibración:** acierto y golpe = `acierto`; fallos = `error`;
   - **reducir animaciones:** barra del Jefe y vuelo de la tarjeta.

## Decisiones que no vienen de Figma
- **Chip de fallo:** fondo/superficie con borde `estadoIlegal`, corazón y "−1 vida · Fallaste" / "· Se acabó el tiempo" / "· Ese fundamento no sirve". Se anuncia con las vidas que quedan.
- **Pausa:** capa opaca `fondoApp` con "Examen en pausa", "El tiempo está detenido.", "Continuar" y "Salir del examen".
- **Tocar un fundamento responde** al instante, sin botón de confirmar, por la prisa.
- **Escenario:** las otras 8 decisiones y la réplica y fundamentos de la 9 son míos (lista abajo).
- **Módulos sin examen:** mensaje con "Volver al mapa".
- **Sin conexión a mitad del examen:** `AvisoConexion` sobre la tarjeta, sin pausar; el tiempo lo manda el servidor (asunto de la T-14).
- **Pastilla y pausa en la misma fila:** en Figma la pausa está debajo, a la derecha, y se encima con la pastilla. Las puse en una sola fila (pastilla centrada y pausa a la derecha), sin cambiar medidas.
- **`DecisionCrisis` no es una `Tarjeta`:** guarda solo etiqueta, personaje, rol, texto e iniciales. Así la app nunca recibe la respuesta correcta.
- **Avatar de la tarjeta:** la decisión 8 usa "CT" y la 9 "AE", como en Figma; las demás, las iniciales del personaje.
- **Lucide en contorno:** el corazón de las reglas va en contorno; en Figma está relleno.

## Contenido legal para verificar contra el curso
Escenario "¡Ransomware! Se filtró la base de usuarios" (módulo 1). ✓ = respuesta o fundamento correcto. Ninguno cita números de artículo.

1. **H0 · Analista de seguridad (Equipo de TI):** "Aparecieron archivos cifrados y una nota de rescate en el servidor de clientes. ¿Desconecto ese servidor de la red ahora mismo?"
   - ✓ **Legal.**
   - Réplica: "¿Desconectar sin pedirle permiso a nadie? Vas a tumbar el servicio."
   - ✓ "Aislar el equipo afectado es la primera medida de contención para que el ataque no se propague."
   - ✗ "Primero hay que averiguar quién fue el atacante y después decidir."
2. **H1 · Director de operaciones (Operaciones):** "Los atacantes piden un pago en criptomonedas a cambio de no publicar la base. ¿Les pago ya para cerrar el asunto?"
   - ✓ **Escalar.**
   - Réplica: "Pagar es lo más rápido. ¿Para qué complicarlo?"
   - ✗ "Pagar garantiza que borren los datos y que nadie se entere."
   - ✓ "Pagar no garantiza nada ni libera de responder por la brecha; lo decide la dirección con asesoría jurídica."
3. **H3 · Administradora de sistemas (Infraestructura):** "Para volver a operar rápido, ¿formateo los servidores comprometidos antes de sacar una copia de la evidencia?"
   - ✓ **Condicional.**
   - Réplica: "Formatear de una vez es lo más limpio, ¿o no?"
   - ✓ "Se puede restaurar, pero solo después de preservar la evidencia y documentar el incidente."
   - ✗ "La evidencia no importa si ya sabemos que fue ransomware."
4. **H6 · Líder de soporte (Atención a clientes):** "Varios usuarios preguntan en redes sociales si se filtraron sus datos. ¿Les respondo que todo está bien mientras investigamos?"
   - ✓ **Ilegal.**
   - Réplica: "Decir que todo está bien calma a la gente. ¿Qué tiene de malo?"
   - ✗ "Mientras no esté confirmado se puede negar."
   - ✓ "Dar información falsa a los titulares sobre una vulneración les impide proteger sus datos."
5. **H9 · Responsable de datos (Privacidad):** "Confirmamos que se filtraron nombres, correos y teléfonos. ¿Abro una bitácora con lo que pasó, los datos afectados y las medidas que tomamos?"
   - ✓ **Legal.**
   - Réplica: "¿Documentarlo todo? Eso solo deja pruebas en tu contra."
   - ✓ "Documentar la vulneración y las medidas es parte del deber de seguridad y sirve ante la autoridad."
   - ✗ "La bitácora solo hace falta si la autoridad la pide."
6. **H12 · Gerente de producto (Producto):** "El proveedor de la nube que guarda los respaldos también pudo verse afectado. ¿Le pido un reporte de lo que ocurrió de su lado?"
   - ✓ **Legal.**
   - Réplica: "Es su infraestructura, no tu problema. ¿Para qué preguntar?"
   - ✗ "El proveedor responde por su cuenta; no hace falta coordinarse."
   - ✓ "Quien trata datos por encargo también debe protegerlos; el responsable debe coordinarse con él y saber qué pasó."
7. **H18 · Directora de marketing (Marketing):** "Propongo regalar un mes gratis a los afectados a cambio de que firmen que no van a reclamar nada. ¿Lo lanzo?"
   - ✓ **Ilegal.**
   - Réplica: "Es un regalo. Si firman, es porque quieren."
   - ✓ "Condicionar un beneficio a que renuncien a sus derechos sobre sus datos no es válido: los conservan."
   - ✗ "Es válido si el regalo vale más que el daño."
8. **H24 · CTO (Fundador técnico), de Figma:** "Ya contuvimos el ataque. Propongo borrar los logs del incidente y no avisar a los usuarios para cuidar la reputación. ¿Lo hacemos?"
   - ✓ **Ilegal.**
   - Réplica: "¿Seguro que no debes avisar? Si borras el log nadie se va a enterar."
   - ✓ "Ocultar evidencia de una brecha agrava la infracción; hay que notificar a los titulares y a la autoridad."
   - ✗ "Solo hay que avisar si los datos filtrados eran contraseñas."
9. **H48 · Abogada externa (Despacho jurídico), de Figma:** "Ya pasaron 48 horas. ¿Notificamos ahora a la autoridad de protección de datos y a los usuarios afectados?"
   - ✓ **Legal.**
   - Réplica (mía): "¿Ahora? Mejor espera a tenerlo todo resuelto para no quedar mal."
   - ✗ "Si ya pasó tiempo, conviene esperar a cerrar la investigación para avisar."
   - ✓ "Hay que avisar sin demora a los titulares y a la autoridad para que puedan protegerse; esperar agrava la falta."
10. **H72 · Directora general (Dirección):** "La autoridad nos pide un informe del incidente. Yo puedo redactarlo hoy mismo sin consultar a nadie. ¿Lo envío?"
    - ✓ **Escalar.**
    - Réplica: "Tú conoces el incidente mejor que nadie. ¿Para qué meter a jurídico?"
    - ✓ "La respuesta a la autoridad tiene consecuencias legales: jurídico debe revisarla para que sea completa y veraz."
    - ✗ "Basta con que lo firme quien atendió el incidente."

Reparto de veredictos: Legal 4, Ilegal 3, Escalar 2, Condicional 1. El fundamento correcto va primero en 6 decisiones y segundo en 4.

## Accesibilidad
- **27:** el título es encabezado y tiene el foco al abrir. La barra del Jefe se lee "Inspectora Vega, auditora de protección de datos. HP 100 por ciento". La línea de crisis se lee como un bloque.
- **28:**
  - la tarjeta se lee "Decisión k de 10. personaje, rol: texto";
  - la hora y el HP en sus bloques;
  - el temporizador se lee "Quedan N segundos" pero no se anuncia continuamente: se anuncia el límite al empezar, a los 10 s, a los 5 s y "Tiempo agotado";
  - la urgencia lleva número, anillo y texto, no solo color.
- **28b:** al abrir, el foco va a la réplica y se anuncia "La Inspectora contraargumenta: … Tienes 8 segundos"; se anuncia de nuevo con 3 s. Orden: réplica → fundamento 1 → fundamento 2.
- **Chips:** son región en vivo ("Daño a la Inspectora: menos 20 HP. Le quedan 40.").
- **Contraste verificado con pruebas** (todos ≥ 4.5:1):
  - blanco sobre `#B52426`;
  - `#94A3B8` y `#CBD5E1` sobre `#0F294A` y `#162030`;
  - `#F07070` sobre `#162030`;
  - `#68B678` sobre `#0F294A`;
  - `#B7A0E6` sobre `#162030`;
  - `estadoIlegal` sobre `fondoSuperficie` y `textoSecundario` sobre `fondoSuperficieAlt`, en claro y oscuro.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y 200 %, recorriendo 27 → 28 → 28b → 28c con tiempo extendido.
- El número del temporizador no escala con el texto (`TextScaler.noScaling`) para caber en el anillo de 64; el valor se lee completo en la semántica.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (985 pruebas; antes de T-11, 938):
```
+985: All tests passed!
```
- **Pruebas nuevas en `jefe_test.dart` (47):**
  - mock: escenario, inicio con 15/22 s, sin vidas, red o escenario, golpe, fundamento incorrecto, fallo y tiempo, réplica sin tiempo y 12 s, aprobado con 5 golpes, reprobado por vidas, reprobado al acabarse las decisiones (con un repositorio de 9 vidas), intento cerrado, tolerancia de 2 s, pausa y abandono;
  - lógica;
  - 27: claro/oscuro, tiempo extendido, sin conexión, sin vidas, no disponible, ahora no, sin sesión;
  - 28: piezas en claro/oscuro, urgencia, tiempo agotado una sola vez, veredicto incorrecto, arrastre = botón, solo botones, pausa, salir;
  - 28b: panel, velo que no cierra, cuenta regresiva, tiempo agotado, fundamento incorrecto, 12 s, foco;
  - 28c: HP y reloj detenido hasta el chip, con vibraciones de servicio falso;
  - flujos: 5 golpes → 29; perder las vidas → 30;
  - contrastes y desbordes.

  Todo con reloj y cronómetro falsos compartidos.
- **Ajustes en pruebas existentes:** el mapa abre `PantallaJefe`; galería; ayudantes.

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, MOD, PROV-REPO, COMP-BARRA-JUEGO, PANT-GALERIA, TEST-AYUDA, TEST-GALERIA y TEST-MAPA.
- **Nuevos:** REPO-EXAMEN, MOCK-EXAMEN, ESCENARIO-RANSOMWARE, EST-EXAMEN, LOGICA-JEFE, RELOJ-CRISIS, CODIGO-PANT-27, COMP-PIEZAS-JEFE y TEST-JEFE.
- PANT-27 a PANT-28c apuntan a su código.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **El tiempo corre con el diálogo de "Salir" abierto:** el servidor manda el tiempo, así que confirmar tarde puede costar una vida. ¿Pausamos el reloj mientras el diálogo está abierto (como pausa implícita) o lo dejamos así?
2. **`DateTime.now()` fuera de los mocks:** sigue uno de la T-08 en `estado_juego.dart` (sello de hora de las respuestas en la cola). No es de esta tarea; ¿lo cambiamos en la T-14 por la hora del servidor?
3. **Contenido legal:** las 8 decisiones nuevas y la réplica y fundamentos de la 9 son míos; están arriba para revisarlos contra el curso.
4. **Apelaciones del examen:** guardo las falladas con la respuesta correcta. ¿La T-11b registra una apelación también cuando falló solo el fundamento (el veredicto era correcto)?
5. **Barra de progreso:** en Figma el relleno del examen es azul marino (`accionSecundaria`); `BarraProgreso` usa su color de siempre. ¿Se cambia solo para el examen?
