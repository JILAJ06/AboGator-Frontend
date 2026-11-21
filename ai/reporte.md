# Reporte
- **Tarea:** T-11b · Resultado del Examen Final: Auditoría superada (29) y La Inspectora ganó (30)
- **Rama:** `11b-resultado-examen`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas; la fecha se formatea con una tabla propia de meses, sin `intl`.
- **Comparé contra Figma** con el conector (solo lectura): 29 (`18:2916`) y 30 (`18:3036`).
  - **Sarko de 29:** en Figma es la pose **alegre de cuerpo completo** en la caja de 176×220 (no recortada al torso como decía la tarea). Usé `SarkoImagen` alegre de 176 en (170, 90).
  - **Fondo de la ilustración de 30:** gris claro (`fondoSuperficieAlt`), el mismo de la pantalla 20.
  - **Confeti de 29:** las 8 piezas con sus posiciones, colores y giros de Figma (`18:2928` a `18:2935`).
- **Prueba en el navegador** (web a 390×844, cuenta de prueba del mock en localhost):
  - **30:** dejé que el tiempo agotara las vidas. Coincide con Figma: Sarko triste, título rojo, texto, resumen con los datos reales del intento (5/10, 1, 2), la próxima vida con cuenta regresiva y los dos botones.
  - **29:** para ganar a mano compilé **una versión temporal** con tiempos largos (las acciones del navegador son más lentas que los 8 s de la réplica). La revertí antes de subir.
  - En esa prueba encontré y corregí dos detalles: el **borde punteado quedaba tapado** por el fondo de la tarjeta (ahora es `foregroundPainter`) y **Sarko salía más chico** que en Figma.
  - Después: confeti, trofeo, Sarko, título, "Desbloqueaste el Módulo 2: Licencias y Propiedad Intelectual", certificado con borde punteado, "Ana López · 6/10 aciertos · 21 nov 2026", "Folio AG-M1-0001" y los botones.

## Qué se hizo
1. **Modelos** (`resultado_examen.dart`):
   - `Certificado`, con la fecha corta "28 oct 2026" y la larga "28 de octubre de 2026" (tabla propia de 12 meses);
   - `ModuloDesbloqueado`;
   - `ResultadoRegistrado`.
2. **`RepositorioExamen` / `MockExamen`:**
   - `registrarResultado(intentoId)`: idempotente por intento. Lanza `sinConexion` sin red o `intentoCerrado` si el intento no terminó.
     - **Aprobado:** emite el certificado. El folio es `AG-M{número del módulo}-{0001…}`, uno por módulo aunque se apruebe dos veces. La fecha sale del reloj inyectado y el nombre, de la autenticación. Luego llama a `registrarExamenAprobado` y devuelve el módulo siguiente.
     - **Reprobado:** solo vidas y `faltaParaProximaVida` de `RepositorioVidas`.
   - `obtenerCertificados()`.
   - El mock recibe `RepositorioProgreso` y `RepositorioAutenticacion` en el constructor, como las vidas.
3. **`RepositorioProgreso.registrarExamenAprobado`:** completa el Examen final (3 estrellas) y pone en curso el primer sprint del módulo siguiente. El último módulo no desbloquea nada y repetirlo no cambia nada más.
4. **`MockPerfil`:** `certificados` = los de `obtenerCertificados()`. El Perfil pasa a "1 / 5" tras aprobar.
5. **Apelaciones del examen:**
   - `LogicaResultado.apelaciones`: una por decisión fallada (veredicto, tiempo o fundamento), sin repetir decisión. Título "Hora 24 · CTO" (≤ 45, con "…"), tema "Brechas de seguridad", `tarjetaId` = `ran-NN`.
   - Se registran al reprobar **y** al aprobar con fallos.
   - `EscenarioRansomware.comoTarjeta(id)` arma la `Tarjeta` (el fundamento correcto como explicación) y `MockTarjetas.obtenerTarjeta` la usa, así que el juicio (22) abre estas apelaciones.
6. **Estado (`ExamenNotifier`):**
   - `registrarResultado()` registra una sola vez, manda las apelaciones y refresca Buzón, Inicio, mapa, vidas y Perfil. Si algo falla, guarda el error sin perder el resultado ni las falladas.
   - `reiniciar()` limpia el examen al salir de 29 o 30.
7. **Pantallas** (`pantalla_resultado.dart`):
   - **29:** confeti (las 8 piezas; `ConfetiSprint` ahora recibe `piezas`), trofeo, Sarko, título con foco, texto con el módulo siguiente (o la variante del último módulo) y la tarjeta del certificado con borde punteado (`CustomPainter`: trazo 2, guion 6, hueco 4) y folio.
     - "Ir al Módulo N" va al mapa del siguiente con `go` y reinicia el examen.
     - "Compartir certificado" copia el texto al portapapeles, muestra "Certificado copiado" y lo anuncia.
     - Mientras registra: esqueleto y botones apagados. Con error: el aviso con "Reintentar" y "Volver al mapa".
   - **30:**
     - Sarko triste y título rojo; el motivo (0 vidas o decisiones agotadas).
     - Resumen de tres tarjetas en un solo bloque semántico; en columna desde 1.5× de texto.
     - Próxima vida con cuenta regresiva monótona (`RelojCrisis` y el `Cronometro` inyectable), o las vidas que quedan.
     - "Repasar en el Buzón" (se oculta sin apelaciones) y "Volver al mapa".
     - Con error, un aviso con "Reintentar" encima de los botones, que siguen activos.
   - En las dos, atrás va al mapa del módulo; al terminar el registro se anuncia y vibra (acierto o error, por `ServicioHaptico`).
8. **Rutas:**
   - `superada` y `derrota` muestran las pantallas reales.
   - Sin un examen terminado de ese módulo redirigen al mapa; con el resultado cruzado, a la que corresponde.
   - Quité los marcadores, sus textos y `alVolver` de `PantallaPendiente` (ya nadie lo usaba).
9. **Galería:** tarjeta del certificado, esqueleto, trofeo, resumen y confeti de 8 piezas.

## Decisiones propias (no vienen de Figma)
- **Folio** bajo el detalle del certificado (RF-41 lo exige).
- **Variantes de texto:**
  - 29 del último módulo: "¡Completaste todos los módulos!" y "Volver al mapa";
  - 30 por decisiones agotadas;
  - tarjeta "Aún tienes N vidas…" cuando la derrota no fue por vidas.
- **Compartir copia al portapapeles**; la imagen y la hoja nativa quedan para la T-14.
- **Enlaces:** el cruce de 29 y 30 lleva a la que corresponde, y sin examen terminado se va al mapa.
- **Estados de carga y error:** con error, 29 usa un bloque propio con el mismo texto y "Reintentar", en lugar de `MensajePantalla`, porque `MensajePantalla` trae su propio desplazamiento y no cabe dentro de la columna.
- **El certificado y el texto de 29 usan los datos reales:** "Protección de Datos" y "Módulo 2: Licencias y Propiedad Intelectual" (Figma muestra "Protección de Datos Personales" y "Ronda Semilla" de ejemplo).
- **Título de la apelación:** "Hora 24 · CTO" (hora y personaje, como dice la regla); el ejemplo de la tarea decía "CTO fundador".
- **Aciertos del certificado:** cuenta los veredictos correctos del intento, aunque después fallara el fundamento.
- **Confeti:** con 8 piezas el escalonado se reduce para que la caída termine a tiempo; el de 19 sigue igual.

## Accesibilidad
- **Foco inicial** en el título (encabezado). Confeti, trofeo y Sarko son decorativos.
- **Bloques:**
  - la tarjeta del certificado se lee "Certificado de módulo. Protección de Datos. Ana López, 6 de 10 aciertos, 21 de noviembre de 2026. Folio AG-M1-0001.";
  - el resumen se lee "Llegaste a la decisión 5 de 10. 1 acierto. 2 por tiempo agotado".
- **Anuncios:** "Auditoría superada. Certificado emitido. Módulo 2 desbloqueado" o "La Inspectora ganó. N apelaciones en el Buzón".
- **Contrastes AA verificados en pruebas, en claro y oscuro:**
  - `estadoIlegal` sobre `fondoApp`;
  - `textoAcento` sobre `fondoSuperficie`;
  - `estadoLegal` y `estadoIlegal` sobre `fondoSuperficie`;
  - `textoPrimario` y `textoSecundario` sobre `fondoDestacado`.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y 200 % (29 y 30). Con "Reducir animaciones" el confeti queda quieto.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (1025 pruebas; antes de T-11b, 985):
```
+1025: All tests passed!
```
- **Pruebas nuevas en `resultado_test.dart` (40):**
  - mock: certificado, idempotencia (también entre intentos), reprobado, `intentoCerrado`, `sinConexion`;
  - progreso: completar y desbloquear, último módulo;
  - apelaciones: una por fallo sin duplicar, título ≤ 45, `ran-03` como tarjeta;
  - Perfil 0 → 1;
  - 29: claro/oscuro, "Ir al Módulo 2" (mapa del módulo 2, examen reiniciado, progreso, Perfil 1 de 5), compartir con el texto exacto, error y reintento, atrás, redirecciones sin examen y sin sesión, fallos aprobados en el Buzón;
  - 30: claro/oscuro, cuenta regresiva (baja y para en 00:00:00), sin decisiones (texto y vidas), **perder → Buzón → juicio de la apelación** de punta a punta, error que no bloquea y reintento sin duplicar, enlace cruzado y "Volver al mapa";
  - desbordes y reducir animaciones.
- **Ajustes en pruebas existentes:**
  - los flujos de la T-11 llegan a las pantallas reales;
  - `ConfetiSprint.piezasSprint`;
  - galería;
  - `abrirJuego` acepta `progreso` y cualquier `RepositorioVidas`;
  - las tarjetas falsas resuelven `ran-NN`.

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, PANT-PENDIENTE, TEXTOS, MOD, REPO-PROG, MOCK-PROG, MOCK-TARJ, MOCK-PERFIL, PROV-REPO, REPO-EXAMEN, MOCK-EXAMEN, ESCENARIO-RANSOMWARE, EST-EXAMEN, COMP-CONFETI, PANT-GALERIA y las pruebas TEST-GALERIA, TEST-JEFE, TEST-COMP y TEST-AYUDA.
- **Nuevos:** LOGICA-RESULTADO, CODIGO-PANT-29, COMP-PIEZAS-RESULTADO y TEST-RESULTADO.
- PANT-29 y PANT-30 apuntan a su código.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Para la T-14
- La **imagen del certificado** para compartir (RF-41) y la hoja nativa de compartir.
- La **fecha y el folio reales** del servidor.
- El **registro con la conexión caída a mitad del examen**: hoy se reintenta desde 29 o 30. Si la persona sale sin reintentar, el resultado no se registra hasta un nuevo intento.
- Queda un `DateTime.now()` de la T-08 en `estado_juego.dart` (la hora de las respuestas en la cola). Esta tarea no permitía tocarlo.

## Dudas
- **D1.** Si la persona sale de 30 con el error de registro sin reintentar, sus apelaciones no llegan al Buzón (el examen se reinicia al salir). ¿Guardamos el registro pendiente en la cola local, como las respuestas del juego, o se resuelve en la T-14?
- **D2.** Aprobar otra vez un módulo ya aprobado devuelve el mismo certificado (uno por módulo). ¿Debería actualizarse con el nuevo intento (aciertos y fecha) o quedarse el primero?
- **D3.** En 29, ¿"Compartir" debe quedar visible también en el último módulo? Lo dejé visible con "Volver al mapa" como primario.
- **D4.** Figma muestra el certificado de "Protección de Datos Personales" y el módulo 2 como "Ronda Semilla". Los datos del proyecto son "Protección de Datos" y "Licencias y Propiedad Intelectual". ¿Se ajustan los nombres de los módulos o Figma?
