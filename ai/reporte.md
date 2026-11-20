# Reporte
- **Tarea:** T-10 · Tienda y Perfil y progreso (pantallas 24 y 25)
- **Rama:** `10-tienda-perfil-ajustes`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge. Los ajustes (26) y el modo oscuro forzado quedan para la T-10b.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. Sin dependencias nuevas.
- **Comparé contra Figma** con el conector (solo lectura): 24 (`18:2347`) y 25 (`18:2492`).
- **Prueba en el navegador** (web a 390×844, modo claro, cuenta de prueba del mock en localhost):
  - Tienda: título, saldo 240, inventario, catálogo de 2×2 y la nota RN03 coinciden con Figma.
  - Compré la Lupa: diálogo "¿Comprar Lupa de Auditor?", y después saldo 180, "Lupa ×3" y el aviso "Compraste…".
  - Perfil: tarjeta, estadísticas, insignias (con la bloqueada) y menú coinciden con Figma.
  - El botón de ajustes abre el marcador sin barra inferior y "Atrás" vuelve al Perfil.
  - "Cerrar sesión" pide confirmación y lleva al inicio de sesión.
  - En pantalla ancha el diálogo ocupaba todo el ancho; lo limité a 400.

## Qué se hizo
1. **Datos de la Tienda:**
   - `ArticuloTienda.comodin` es `Comodin?` (nulo = Congelar racha).
   - Ids estables: `lupa`, `abogado`, `amparo` y `congelar-racha`. Máximo 9 por artículo.
   - Precios y textos de Figma: 60, 90, 120 y 100, y las cuatro descripciones. "Amparo" pasa a "Amparo / Fianza".
   - `comprarArticulo(id)` → `ResultadoCompra`. Lanza `ExcepcionTienda` (`monedasInsuficientes`, `maximoAlcanzado`, `articuloInexistente`) sin cambiar nada.
   - `obtenerCongeladoresRacha()`: el mock empieza en 0.
2. **Datos del Perfil:**
   - `ResumenPerfil`, `Insignia` (el ícono es el nombre de `IconosApp.porNombre` y `moduloId` da el color), `RepositorioPerfil` y `MockPerfil`.
   - `repositorioPerfilProvider` está en `proveedores_repositorios.dart`.
   - El mock toma el usuario de la autenticación (Ana si no hay nadie). Los colores de las medallas salen de los módulos del repositorio, que usan `ColoresModulo`.
3. **Pantalla 24 Tienda:**
   - Saldo, inventario (los tres comodines siempre, aun con ×0; Congelar racha solo con N > 0), catálogo en filas de 2 con el mismo alto y la nota RN03 al final.
   - **Botón de precio:** deshabilitado sin saldo ("Te faltan N" debajo), en máximo (dice "Máximo") y sin conexión. Sin conexión aparece la nota "Necesitas conexión para comprar." encima del catálogo.
   - **Compra:**
     - diálogo de confirmación;
     - el botón muestra carga y no acepta otro toque;
     - vibración ligera (no en web);
     - se refrescan Tienda, Inicio, mapa y juego, y un SnackBar en región en vivo lo anuncia.
   - **Errores:** con saldo cambiado o en máximo se refresca y se avisa; con cualquier otro, aviso genérico sin cambios.
   - Esqueleto mientras carga y error con "Reintentar".
4. **Pantalla 25 Perfil:**
   - "Mi perfil" con el botón de ajustes (48, "Accesibilidad y ajustes").
   - Tarjeta con iniciales y "Desarrollador · Nivel 4 · 1,250 XP".
   - 4 estadísticas en 2×2, insignias (se desplazan en horizontal si no caben) y el menú de 4 filas.
5. **Cerrar sesión:**
   - Confirmación; si hay respuestas guardadas en el dispositivo, el diálogo lo avisa.
   - `repositorioAutenticacion.cerrarSesion()`, luego `sesionProvider.cerrar()`, se invalidan los proveedores con datos de la persona y se va al inicio de sesión.
   - Si falla, SnackBar y se queda.
   - **Proveedores invalidados** (`proveedoresDeLaPersona`):
     - `datosInicioProvider` y `datosModuloProvider`;
     - `datosBuzonProvider`, `datosJuicioProvider` y `sesionApelacionesProvider`;
     - `vidasActualesProvider` y `apelacionesPendientesProvider`;
     - `datosJuegoProvider` y `juegoProvider`;
     - `datosTiendaProvider` y `datosPerfilProvider`.
   - **No** se tocan la cola local (`respuestasPendientesProvider`), el onboarding visto ni la conexión.
6. **Rutas:**
   - `/tienda` y `/perfil` reales; ambas redirigen sin sesión, y la del Perfil cubre a sus hijas.
   - Hijas del Perfil, sin barra inferior: `ajustes`, `notificaciones` (`Rutas.notificacionesRacha`) y `aviso-privacidad` (`Rutas.avisoPrivacidad`; no había ruta del aviso en el registro).
   - Usan `PantallaPendiente` con textos propios y un botón "Atrás" nuevo (`conVolver`).
   - Quité `pendienteTienda` y `pendientePerfil`.
7. **Componentes nuevos:**
   - `piezas_tienda.dart`: píldora de saldo, píldora de inventario, botón de precio, tarjeta de artículo y nota.
   - `piezas_perfil.dart`: tarjeta de perfil, tarjeta de estadística, medalla, fila y menú, botón cuadrado.
   - `dialogo_confirmacion.dart`.

   Todos están en la galería. También agregué el ícono `snowflake`.

## Decisiones que no vienen de Figma
- **Confirmación de compra** y de cierre de sesión con el mismo diálogo.
- **Máximo 9:** el botón dice "Máximo".
- **Sin conexión:** botones deshabilitados y nota encima del catálogo. Sin conexión manda sobre "Te faltan N".
- **Congelar racha como artículo:**
  - es un artículo, no un comodín;
  - va en el inventario solo con N > 0;
  - lleva el ícono `snowflake`, como pide la tarea (Figma usa `flame`).
- **Destinos pendientes:** ajustes (T-10b), notificaciones y aviso de privacidad, con marcador y "Atrás".
- **Rol neutro:** "Desarrollador", con los textos del registro (Figma dice "Desarrolladora" porque es el ejemplo de Ana).
- **XP:** "1,250" del mock (Figma muestra 1,240 como dato de ejemplo).
- **Divisor final del menú:** Figma repite el borde inferior en la última fila; no lo puse para no tener borde doble.
- **Iconografía:** en Figma la llama, la estrella y el escudo de las estadísticas y medallas van rellenos; aquí son los de Lucide (contorno), como en el resto de la app. El de ajustes es `settings` (Figma muestra unos deslizadores).
- **Precisión:** "82%" sin espacio, como Figma (la tarea lo escribe "82 %").
- **"Amparo / Fianza"** ocupa dos líneas en la tarjeta de 165 con nuestra fuente; en Figma cabe en una. El botón sigue al pie y la fila mantiene el mismo alto.

## Accesibilidad
- Títulos como encabezados; "Tienda" y "Mi perfil" reciben el foco al abrir.
- Se leen como bloques:
  - el saldo ("Tienes 240 monedas");
  - cada píldora de inventario ("Lupa de Auditor, 2 en inventario");
  - cada estadística ("Racha actual: 7 días", "Certificados: 0 de 5");
  - cada insignia ("…, obtenida" / "…, bloqueada");
  - la tarjeta de perfil.
- Los botones de precio se leen "Comprar … por N monedas", "…, te faltan N monedas", "…, máximo alcanzado" o "…, necesitas conexión".
- Íconos decorativos sin etiqueta. Botones y filas ≥ 48. Lo bloqueado lleva `lock` y la palabra; lo no comprable lleva texto.
- El orden de foco sigue el orden visual que pide la tarea.
- **Contrastes verificados con pruebas en claro y oscuro:**
  - `textoEnPrimario` sobre `accionPrimaria`;
  - `textoSecundario` sobre `fondoSuperficieAlt`;
  - `estadoIlegal` sobre `fondoSuperficie`;
  - `accionSecundaria` sobre `fondoDestacado` (iniciales);
  - `textoPrimario` sobre `fondoDestacado` y `fondoSuperficieAlt`.

  Todos ≥ 4.5:1. El ícono blanco sobre cada color de módulo da ≥ 3:1.
- **Sin desbordes** en 390×844, 360×640 y 320×640 al 100 % y 200 % (Tienda y Perfil).

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (893 pruebas; antes de T-10, 840):
```
+893: All tests passed!
```
- **Pruebas nuevas:**
  - **`tienda_test.dart` (28):**
    - mock: precios, compra, Congelar racha aparte y los tres rechazos sin cambios;
    - lógica;
    - pantalla: claro/oscuro con medidas (165, mismo alto, hueco 12), ×0, Congelar racha, sin saldo, máximo y sin conexión;
    - diálogo: Cancelar, Esc y tocar fuera;
    - compra que actualiza saldo, inventario, Inicio y juego, sin doble toque, y los tres errores;
    - esqueleto, reintento, sin sesión, contrastes y desbordes.
  - **`perfil_test.dart` (25):**
    - iniciales (una, dos y tres palabras, acentos, espacios), miles, rol y mock;
    - pantalla en claro/oscuro: botón de 48, 3 divisores y filas ≥ 48;
    - colores de medalla y desplazamiento horizontal;
    - los 4 destinos sin barra y con "Atrás"; atrás del sistema desde ajustes;
    - cerrar sesión: cancelar, con pendientes, éxito (sesión y apelaciones en nulo, inicio de sesión, el Perfil ya redirige) y error;
    - sin sesión, pestañas, contrastes y desbordes.
- **Ajustes en pruebas existentes:**
  - descripciones de comodines y 4 artículos;
  - 46 íconos;
  - las pestañas Tienda y Perfil abren sus pantallas;
  - galería;
  - los ayudantes `abrirJuego` y `abrirInicio` montan `MockPerfil` sin espera (y `abrirJuego` acepta `autenticacion` y `perfil`).

## Grafo
- **Actualizados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE, TEMA-ICONOS, TEXTOS, MOD, REPO-TIENDA, PROV-REPO, MOCK-TIENDA, PANT-GALERIA y las pruebas TEST-GALERIA, TEST-INICIO, TEST-COMODINES, TEST-DATOS y TEST-COMP.
- **Nuevos:** REPO-PERFIL, MOCK-PERFIL, EST-TIENDA, LOGICA-TIENDA, CODIGO-PANT-24, LOGICA-PERFIL, EST-PERFIL, CODIGO-PANT-25, COMP-PIEZAS-TIENDA, COMP-PIEZAS-PERFIL, COMP-DIALOGO-CONFIRMACION, TEST-TIENDA y TEST-PERFIL.
- PANT-24 y PANT-25 apuntan a su código.
- **Obsoletos:** ninguno. Agregué una línea en el registro de cambios.

## Dudas
1. **Usuario tras comprar o subir de nivel:** racha, nivel y XP salen de `Usuario`, que hoy solo se carga al iniciar sesión. ¿En T-14 el Perfil pedirá el usuario fresco al servidor (como hace el mock con `usuarioActual`)?
2. **Saldo en el diálogo:** "Te quedarían N" se calcula con el saldo que mostró el servidor. Si cambió, el servidor rechaza la compra y la pantalla se refresca. ¿Basta así, o el diálogo debería pedir el saldo al abrirse?
3. **Foco tras el diálogo de compra:** al cerrarlo, el foco vuelve al título de la Tienda (en web con ratón se ve su anillo). ¿Debería volver al botón de precio?
4. **Ícono de Congelar racha:** la tarea pide `snowflake` y Figma usa `flame`. ¿Se actualiza Figma?
