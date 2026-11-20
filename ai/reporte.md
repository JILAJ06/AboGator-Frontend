# Reporte
- **Tarea:** T-09b · Juicio de apelación, apelación ganada y apelación perdida (pantallas 22 y 22b)
- **Rama:** `09b-juicio-apelacion`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas.
- **Comparé contra Figma** con el conector (solo lectura): 22 (`41:5785`) y 22b (`41:5862`).
- **Prueba en el navegador:** compilé la app para web y recorrí el flujo completo a 390×844 (modo oscuro), con la cuenta de prueba del mock en localhost:
  - Buzón → "Iniciar apelaciones de hoy" → "Apelación 1 de 2" con la tarjeta GPL, la etiqueta "APELACIÓN · LICENCIAS OSS" y el aviso "La fallaste hace 3 días" dentro de la tarjeta;
  - Ilegal → "¡Apelación ganada!" con Sarko alegre, corazones, insignia, texto, Día 3 hecho y Día 7/14 pendientes, y los dos botones;
  - "Siguiente apelación" → "Apelación 2 de 2" ("La fallaste hace 7 días") → Legal → "Apelación perdida" con Sarko triste, "No pierdes vidas", la respuesta correcta y solo "Volver al Buzón";
  - de vuelta en el Buzón: "Hoy no tienes juicios de apelación", la de la GPL como "Día 7 · en 4 días" y la del consentimiento como "Día 7 · mañana".

  La estructura, el orden y los colores coinciden con Figma.

## Qué se hizo
1. **Datos:**
   - Modelo nuevo `ResultadoApelacion` (`ganada`, `diaSiguiente`, `diasParaVolver`, `dominada`).
   - `RepositorioApelaciones.resolverApelacion(id, ganada:)`. `MockApelaciones` lo resuelve con su reloj:
     - ganar: 3 → 7 a hoy + 4 días y 7 → 14 a hoy + 7 días (medianoche UTC); el de 14 sale del Buzón;
     - perder: se queda en su día y se abre mañana;
     - lanza `StateError` si no existe o no se abre hoy.
   - `RepositorioVidas.recuperarVida()`: +1 sin pasar de 5. En `MockVidas`, al llegar a 5 quita la regeneración y si no, la conserva.
2. **Lógica (`logica_apelacion.dart`):** gana solo la respuesta correcta; etiqueta "APELACIÓN · TEMA"; frase de regreso (en N días, dominada o mañana); días de repaso hechos al ganar (≤ el día) y al perder (< el día); texto del resultado.
3. **Sesión (`sesion_apelaciones.dart`):** `sesionApelacionesProvider` (no se descarta entre rutas) con `ids`, `indice`, `fase` (juicio/resultado), el resultado y las vidas antes y después.
   - "Iniciar apelaciones de hoy" la empieza con todas las de hoy en el orden de la lista; una fila de hoy, con una.
   - El enlace profundo sin sesión, o con un id fuera de ella, empieza una de una.
   - Resolver: llama al servidor y, si ganó con menos de 5 vidas, a `recuperarVida()`. Luego pasa a la fase de resultado.
   - Al resolver y al salir invalida el Buzón, el Inicio, el mapa, "Sin vidas" y el juego, para que contadores y vidas se actualicen.
4. **Pantalla 22 (`pantalla_juicio.dart`):**
   - Barra: Salir, "Apelación k de n" con su progreso y la píldora "+1 vida" (o "Vidas al máximo").
   - `TarjetaCaso` dentro de `MazoSwipe`, con el nuevo parámetro `aviso` para "La fallaste hace N días". Se arrastra en 4 direcciones y con teclado (flechas, Enter, Esc), como en el juego.
   - Los 4 veredictos y la nota.
   - Sin barra inferior, indicadores ni comodines.
   - Salir o atrás vuelven al Buzón sin resolver.
   - Estados: sin conexión ("Necesitas conexión para apelar"), no disponible ("Esta apelación ya no está disponible"), ambos con "Volver al Buzón"; esqueleto mientras carga.
   - Si no se guarda, aparece un SnackBar en región en vivo y la tarjeta vuelve a entrar.
5. **22b y la perdida:**
   - Cruce de 200 ms (sin transición con "reducir animaciones").
   - Sarko de 184 sobre un círculo `fondoDestacado` de 230, corazones con las vidas después, insignia, título, texto, Día 3/7/14 y botones fijos ("Siguiente apelación" + fantasma "Volver al Buzón"; en la última, solo el primario "Volver al Buzón").
   - Vibración: ligera al ganar y media al perder (no en web).
6. **Componentes nuevos** (`piezas_apelacion.dart`): `InsigniaVida` (chica en la barra, grande en 22b), `AvisoFallo`, `PildoraRepaso` y `FilaRepaso`. `BloqueLectura` suma `nodoFoco` opcional. Todo está en la galería.
7. **Enrutador:** la ruta hija `/buzon/:apelacionId` muestra `PantallaJuicio` y sigue exigiendo sesión. Borré el marcador `Textos.pendienteJuicio`.

## Decisiones que no vienen de Figma
- **Apelación perdida:** Sarko triste, corazones sin cambio, insignia neutra "No pierdes vidas", título "Apelación perdida", "Esta vez no: " + `explicacionFallo` (o `explicacion`), "La respuesta correcta era X." y "La tarjeta vuelve mañana…". Los días anteriores al actual van como hechos y los botones siguen la misma regla de la última.
- **Con 5 vidas:**
  - la píldora de la barra dice "Vidas al máximo" en `fondoSuperficieAlt` con corazón y `textoSecundario`;
  - en 22b la insignia neutra dice "Vidas al máximo", sin corazón (la de la perdida tampoco lo lleva).
- **"14 días" de Figma 22b:** Figma dice que vuelve en 14 días tras ganar el día 3. Seguí la regla del proyecto: 4 días (al día 7). Lo dejo anotado.
- **La vida la pide el cliente:** después de `resolverApelacion` se llama a `recuperarVida()`. En T-14 debería darla el servidor dentro de la misma operación, para no poder pedirla sin ganar.
- **Foco al resultado:** el juicio tenía el foco y `autofocus` no lo quita, así que el título lo pide de forma explícita tras el primer cuadro (sin anillo, como en 19 y 19b).

## Accesibilidad
- La tarjeta se lee "Apelación k de n. Personaje, rol: texto. La fallaste hace N días."
- La píldora de la barra se lee "Si ganas, recuperas 1 vida" (o "Tienes las vidas al máximo").
- En el resultado, el título es encabezado, tiene el foco y se anuncia como "¡Apelación ganada! +1 vida recuperada. Vidas: 2 de 5.".
- Los corazones se leen como un bloque.
- Cada día se lee "Día 3, completado" o "Día 7, pendiente" y lleva ícono además de color.
- **Contraste verificado en claro y oscuro:**
  - `textoEnPrimario` sobre `estadoIlegal` y `estadoLegal`;
  - `textoSecundario` sobre `fondoSuperficieAlt`;
  - `textoAcento` sobre `fondoDestacado`.

  Todos ≥ 4.5:1.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y al 200 % (juicio y resultado).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (840 pruebas; antes de T-09b, 800):
```
+840: All tests passed!
```
- **Pruebas nuevas en `juicio_test.dart`:**
  - mock: 3 → 7 a +4, 7 → 14 a +7, 14 sale, perder abre mañana, y los errores;
  - `recuperarVida`;
  - lógica;
  - pantalla 22: claro/oscuro con solo colores del tema, recompensa con 3 y 5 vidas, aviso dentro de la tarjeta, arrastre = botón, Salir y atrás sin resolver, sin conexión, no disponible y error al guardar con reintento;
  - 22b y perdida: con 0, 3 y 5 vidas, insignias, días, botones, foco y anuncio, contrastes y sin desbordes;
  - flujos: Iniciar 2 → ganar → siguiente → perder → Buzón (contadores y servidor al día); desde 0 vidas; fila de una; enlace profundo sin sesión de la app.
- **Ajustes en pruebas existentes:**
  - los repositorios falsos implementan `resolverApelacion`;
  - el Buzón y el enlace profundo ya abren `PantallaJuicio`;
  - la galería cuenta las piezas nuevas.

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, PANT-PENDIENTE, TEXTOS, MOD, REPO-APEL, MOCK-APEL, REPO-VIDAS, MOCK-VIDAS, CODIGO-PANT-21, PANT-GALERIA, COMP-TARJETA-CASO, COMP-BLOQUE-LECTURA, TEST-GALERIA y TEST-BUZON.
- **Nuevos:** LOGICA-APEL, SESION-APEL, CODIGO-PANT-22, COMP-PIEZAS-APEL y TEST-JUICIO.
- PANT-22 y PANT-22b ya apuntan a `pantalla_juicio.dart`.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **"La fallaste hace N días":** uso N = `diaRepaso`, como pide la tarea. Si una apelación se pierde y vuelve al día siguiente, N sigue siendo el día de repaso y no los días reales desde el primer fallo. ¿El servidor mandará la fecha del fallo (T-14)?
2. **La vida del cliente:** hoy `recuperarVida()` se pide aparte después de ganar. ¿En T-14 `resolverApelacion` devolverá ya las vidas, para quitar esa llamada?
3. **Atrás en Android:** el botón atrás del sistema y Salir terminan la sesión y van al Buzón, aunque la apelación venga de la notificación. ¿Está bien, o desde la notificación debería volver al Inicio?
4. **Destino tras iniciar sesión** (pendiente de T-09): con el enlace profundo sin sesión de la app, después de entrar se va al Inicio y no al juicio.
