# Reporte

- **Tarea:** T-02 · Bienvenida: Splash y Onboarding
- **Rama:** `02-bienvenida`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- Revisé el Splash y las 4 páginas en Chrome, compilando la web en modo debug, en 390×844 (claro) y 360×640 (oscuro).
- Sigue sin haber herramientas de Android (no hay APK). Para compilar la web uso `--no-tree-shake-icons` (ver T-01, D6).

## Qué se hizo
1. **Token `estado/escalar`:** claro #6B4BA1 y el oscuro propuesto #B9A0E8 (`TokensColor`, ahora con 18 tokens).
   - Contraste medido contra `fondo/app` / `fondo/superficie`: claro 6.38 / 6.67 y oscuro 8.25 / 7.21. Pasa, así que **no lo ajusté**.
   - La galería lo muestra en su lista de tokens, y las pruebas de tokens y de contraste lo incluyen.
2. **`BotonVeredicto`** (`lib/componentes/boton_veredicto.dart`):
   - Usa el enum `Veredicto` que ya existía en los modelos, en lugar de crear uno nuevo.
   - Círculo de 68 con borde de 3 y fondo `fondo/superficie`, sombra (0, 8, desenfoque 24, #0F294A al 14 %), ícono de 32 y etiqueta en mayúsculas en estilo Etiqueta, con hueco de 6. Condicional ocupa una columna de al menos 87.
   - Sin `alPresionar` es decorativo y queda fuera de la semántica. Con él tiene zona táctil completa, anillo de foco alrededor del círculo, se activa con Enter o Espacio y se anuncia como "Veredicto: Legal con condiciones", etc.
   - Está en la galería en sus dos versiones, decorativa e interactiva.
3. **Rutas y flujo:**
   - La app arranca en `/splash` y `/` redirige ahí.
   - La galería pasó a `/galeria` y solo existe en modo debug (`kDebugMode`).
   - `FlujoBienvenida` (`funciones/bienvenida/flujo_bienvenida.dart`) decide a dónde va el Splash y qué pasa al terminar el onboarding. Las pantallas solo piden el destino y navegan.
   - El estado "onboarding visto" vive detrás de la interfaz `RepositorioOnboarding`. Su implementación en memoria, `OnboardingEnMemoria`, está en `datos/mocks/` y se elige en `proveedores_repositorios.dart`. No agregué dependencias.
   - Inicio de sesión todavía no existe: hay un marcador temporal, `PantallaPendiente` ("Inicio de sesión · llega en T-03", en `lib/app/pantalla_pendiente.dart`).
4. **01 Splash** (`pantalla_splash.dart`):
   - Fondo `accion/primaria` e íconos de la barra de estado claros (`SystemUiOverlayStyle.light`).
   - Logo vertical (ver "Recurso que faltó"), lema en Cuerpo/Énfasis con color `fondo/destacado` y ancho 300, y "Powered by LawSwipe" en Leyenda.
   - Tres puntos de 10 con hueco 8. El activo avanza cada 400 ms; con "reducir animaciones" el primero queda fijo.
   - A los 2 s avanza con un `Timer` que se cancela si se sale de la pantalla.
   - Tiene una sola etiqueta semántica: "AboGator. Educación en Legislación y Derecho Informático. Cargando."
5. **02–04 Onboarding** (`pantalla_onboarding.dart` e `ilustraciones_onboarding.dart`):
   - Un `PageView` de 4 páginas con "Omitir", `PaginadorPuntos` y `BotonApp`.
   - El botón avanza una página (250 ms; corte directo con "reducir animaciones"). En la última dice "¡Comenzar!": marca el onboarding como visto y va al inicio de sesión. "Omitir" hace lo mismo desde cualquier página.
   - Cada ilustración se dibuja en un lienzo de 390×400 que corresponde a y = 90…490 del marco de Figma, con las coordenadas exactas de la tarea. El círculo es de 300 en (45, 130) con color `fondo/destacado`.
   - Elementos por página:
     - Pantalla 02: Sarko de 264×330.
     - Pantalla 03: la miniatura de la tarjeta de caso rotada 8° y los 4 `BotonVeredicto` decorativos.
     - Pantalla 03b: `IndicadoresStartup` (70, 60, 50, 25) y Sarko de 160×200.
     - Pantalla 04: `FilaVidas` (4 de 5, corazones de 33.6 con hueco 11.2), Sarko de 208×260 y los chips "+5" y "7 días".
   - Título en H1 con `texto/primario`, y texto en Cuerpo/Grande con `texto/secundario`, ambos de 330 de ancho máximo. El hueco entre título y texto es 12 (10 en la página 2, por el y=542).
   - Foco: Omitir → botón. El paginador no es enfocable y se anuncia como "Página N de 4".
6. **`LogoApp` vertical** ahora sigue las proporciones de Figma (323.7×187.9): isotipo de 109, hueco ≈ 13 y la marca a todo el ancho. Antes la marca era más chica.

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (128 pruebas):
```
+128: All tests passed!
```
- `test/funciones/bienvenida/bienvenida_test.dart`:
  - El Splash es la primera pantalla y muestra sus textos, con fondo `accion/primaria` y una sola etiqueta semántica.
  - Sigue en el Splash a los 1.9 s; a los 2 s va al onboarding, o al inicio de sesión si ya se vio.
  - Los puntos de carga avanzan, y con "reducir animaciones" quedan fijos con el primero activo.
  - Las 4 páginas muestran su título, texto y botón. El paginador dice "Página 2 de 4" tras deslizar.
  - "¡Comenzar!" y "Omitir" marcan el onboarding como visto. Un segundo arranque salta al inicio de sesión.
  - Omitir tiene zona táctil ≥ 48 y está alineado a 24 del borde derecho. El foco va Omitir → botón.
  - Sarko no se anuncia (es decorativo).
  - Con texto al 200 % no hay desbordes en 390×844 ni en 360×640, en claro ni en oscuro.
- `test/componentes/boton_veredicto_test.dart`: los 4 tipos en claro y oscuro, solo colores del tema, ancho de Condicional, decorativo frente a interactivo, semántica, anillo de foco y Enter.
- Tokens: 18 valores, más el contraste de `estado/escalar`.
- No hay hex fuera de `lib/core/tema/` (lo revisé con `git grep`).

## Recurso que faltó
**Logo vertical "sobre verde"** para el Splash: no existe `assets/imagenes/logo_vertical_sobre_verde.png`. Como marcador uso el logo actual dentro de una tarjeta de radio 24, centrada en la misma posición. Cuando lo exporten de Figma, basta con agregarlo a `ImagenesApp` y a `LogoApp` y quitar `_LogoSobreVerde`.

## Decisiones
- **Colores del Splash en modo oscuro:** sigo los tokens del modo. Los puntos usan `texto/en-primario` en vez de "blanco" fijo: en claro es #FFFFFF (lo mismo que pide Figma) y en oscuro #0B1220. El blanco sobre el verde oscuro #68B678 daría solo 2.46:1; con #0B1220 da 7.62:1. El lema en `fondo/destacado` da 6.74:1 en claro y 5.04:1 en oscuro. Ver D2.
- **Tarjeta del logo marcador:** usa siempre `TokensColor.claro.fondoSuperficie`. Con la superficie oscura el logo (azul marino y verde) casi no se veía; lo comprobé en Chrome.
- **Posiciones del Splash:** el logo va en una zona central con 54 de relleno superior, para que su parte superior caiga cerca de y=280. Debajo van los puntos, un hueco de 20, "Powered by LawSwipe" y 60 de relleno inferior, que corresponden a y=740 y y=770.
- **Ilustraciones decorativas:**
  - El lienzo entero está fuera de la semántica y **no escala con el texto del sistema**: es un dibujo de tamaño fijo, y escalar sus textos de 6.8 desbordaría la tarjeta.
  - En pantallas bajas el lienzo se encoge (`altoLienzo = alto disponible − 180`, entre 160 y 400) y el título y el texto se pueden desplazar. Así no hay desbordes con texto al 200 % ni en 360×640.
  - Sarko también es decorativo en estas páginas, porque el título ya lo nombra.
- **Pistas de la miniatura de tarjeta:** las tres pistas ("←  ILEGAL", "↑ CONDICIONAL / ↓ ESCALAR" y "LEGAL  →") van en tres columnas que se encogen si no caben. En una sola fila se desbordaban 23 dp dentro de los 186.8 de ancho útil de la tarjeta.
- **"Omitir"** es un botón propio de la pantalla, no un `BotonApp`, porque su estilo (Cuerpo/Énfasis en `texto/secundario`) no coincide con ningún tipo de botón. Tiene zona de 48, anillo de foco y se activa con Enter.
- **Indicadores en la página 3b:** con 342 de ancho caben en una fila. No tuve que usar el `Wrap` en dos filas.
- **Posiciones verticales del fondo de la pantalla:** sin la zona segura del sistema (como en Chrome), el botón queda unos 34 dp más abajo que en Figma. En un iPhone con indicador de inicio, `SafeArea` lo deja en y=730.

## Grafo actualizado
Solo toqué la sección 4 (Código), las filas de pantallas (sección 5) para anotar la ruta del código, la línea "Última actualización" y el registro de cambios. Comprobé con `ls` que todas las rutas de la sección 4 existen.
- **Cambiados (`en curso`):** ENRUTADOR (arranca en el Splash), RUTAS, TEMA-TOKENS (18), TEMA-EFECTOS, TEXTOS, PROV-REPO, PANT-GALERIA (en `/galeria`), COMP-LOGO, TEST-TEMA, TEST-GALERIA y TEST-COMP.
- **Solo relaciones:** APP y COMP-PAGINADOR (su código no cambió).
- **Nuevos:** COMP-VEREDICTO, PANT-PENDIENTE, REPO-ONBOARDING, MEM-ONBOARDING, FLUJO-BIENVENIDA, CODIGO-PANT-01, CODIGO-PANT-02..04, ILUS-ONBOARDING y TEST-BIENVENIDA.
- **Sección 5:** la ruta del código quedó anotada en PANT-01, PANT-02, PANT-03, PANT-03b y PANT-04, sin cambiar las columnas.
- **Obsoletos:** ninguno.

## Dudas
- **D1 · Logo "sobre verde".** Falta exportarlo de Figma (componente "Logo / Vertical", variante `sobreVerde`). Mientras tanto se ve la tarjeta blanca marcador.
- **D2 · Splash en modo oscuro.** `accion/primaria` oscuro es el verde claro #68B678, así que el Splash oscuro se ve muy distinto al de marca (#1F4E35). ¿El Splash debe mantener siempre el verde bosque, como pantalla de marca, o seguir el tema?
- **D3 · Círculo de ilustración.** No tengo acceso a Figma para comparar contra la captura. En claro el círculo es `fondo/destacado` (#E8D8A8) y se ve como en la tarea. En oscuro es #3A3424, marrón oscuro, y Sarko (traje azul marino) queda con poco contraste sobre él. ¿Es lo esperado?
- **D4 · Página 3 (gestos).** Con las coordenadas de la tarea, Escalar en (161, 394) queda encima del borde inferior de la tarjeta, y su etiqueta "ESCALAR" cae sobre la pista central. Condicional también tapa la etiqueta "CASO 4". ¿Así es en Figma?
- **D5 · Pruebas y fuentes.** En `flutter_test` los textos se miden con la fuente de prueba (cada letra ocupa un cuadrado), así que las pruebas de posición solo comprueban bordes que no dependen del ancho del texto. Las medidas reales las revisé en Chrome.
