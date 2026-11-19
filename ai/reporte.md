# Reporte

- **Tarea:** T-04 · Inicio (pantallas 07 y 07b)
- **Rama:** `04-inicio`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector de Figma (solo lectura): capturas y metadatos de los nodos 07 (`13:356`) y 07b (`14:1132`).
- En Chrome (web en modo debug) revisé:
  - El inicio de sesión con `incorrecta`, que muestra el error.
  - El Inicio en claro y oscuro a 390×844, desplazado hasta el final.
  - El Inicio a 320×640.
- Aviso: en GitHub existe la rama `revert-5-03-acceso`, creada por el botón "Revert" del PR #5. No está mergeada en `develop` y no la toqué.

## Qué se hizo
1. **Componentes nuevos** en `lib/componentes/`, con pruebas y en la galería:
   - `AvatarApp`: círculo de 44 en `fondo/destacado` con iniciales en H3 y color `accion/secundaria`. Es decorativo.
   - `TarjetaHeroeStartup`:
     - Medidas: 342×168 (crece con el texto), `accion/primaria`, radio 24, sombra (0, 8, 24) y recorte.
     - Contenido: elipse de 220 en (190, −30), etiqueta, título de ancho 200, subtítulo, botón "Continuar sprint" y Sarko de 120×150 en (226, 22).
     - El botón mide 148×48 (`accion/acento`, radio 12, Etiqueta + chevron 16), tiene anillo de foco y se anuncia.
   - `TarjetaRetoDiario`: 342×60 en `fondo/destacado`, radio 18, relleno 14×12, flame de 24, dos líneas y "1/3" en `texto/acento`. Se lee como un solo bloque.
   - `TarjetaModulo` y el enum `EstadoModulo`, con 4 estados:
     - En curso y disponible: insignia del color del módulo y etiqueta en `texto/acento`.
     - Completado: check y "5/5 sprints · Completado".
     - Bloqueado: `fondo/superficie-alt`, candado y "Completa el módulo anterior". Sin acción, y se anuncia como deshabilitado.
     - Todas tienen barra de 96×8 y semántica "Módulo N, nombre, tramo, estado, progreso".
   - `BotonBuzon`: 60×60 en `accion/secundaria`, radio 20, sombra (0, 16, 40) y contador de 24×22 en (46, −8). Se anuncia como "Buzón de apelaciones, N pendientes". Sin pendientes no dibuja el contador.
2. **Lógica del Inicio** (`funciones/inicio/logica_inicio.dart`, pura y probada):
   - Iniciales (primera letra del nombre y del apellido) y perfil corto (Estudiante / Dev / Legal).
   - Estado del módulo con la regla de la tarea; un módulo sin sprints cuenta como bloqueado.
   - Progreso = solo los sprints **completados**.
   - Módulo y sprint actuales: el primero en curso o, si no hay, el primero disponible.
   - Nombre corto, tramo e ícono por número de módulo (shield, code, gavel, doc, shieldCheck; ya existían en `IconosApp`).
   - El reto diario es una constante (`RetoDiario`: 1/3, +15 monedas).
3. **Datos** (`estado_inicio.dart`): `datosInicioProvider` pide en paralelo los módulos, las monedas (`RepositorioTienda`), las vidas y las apelaciones pendientes. "Reintentar" hace `invalidate`. El nombre, nivel, perfil y racha salen de `sesionProvider`.
4. **Pantalla 07 / 07b** (`pantalla_inicio.dart`):
   - Un `CustomScrollView` con el encabezado (avatar, saludo y chips de racha, monedas y vidas), el héroe, el reto, "Ruta de tu Startup" (marcado como encabezado) y los 5 módulos.
   - El Buzón queda **fijo** a 28 dp sobre la barra inferior, y la lista reserva espacio al final para que no tape la última tarjeta.
   - Navegación inferior con "Mapa" activo. Buzón, Tienda y Perfil usan `context.go` hacia sus marcadores; tocar Mapa no hace nada.
   - "Continuar sprint" va a `introSprintDe(módulo, sprint)` y las tarjetas abiertas a `mapaSprintsDe(módulo)`, los dos todavía marcadores (T-04b).
   - Estados de la pantalla:
     - Cargando: esqueleto con las mismas medidas.
     - Error de carga: mensaje y "Reintentar".
     - Sin sesión: el enrutador redirige al inicio de sesión.
   - El modo oscuro (07b) sale solo de los tokens, sin código especial.
5. **Rutas:** ayudantes `Rutas.mapaSprintsDe` e `introSprintDe`. Marcadores para mapa e intro (T-04b), Buzón (T-09), Tienda y Perfil (T-10).
6. **Mocks:**
   - `MockAutenticacion` rechaza la contraseña exacta `incorrecta` con `Textos.errorCredenciales`. Lo comprobé en Chrome.
   - `MockApelaciones` devuelve **6** pendientes, como el contador de Figma.
   - `MockProgreso` tiene 5 sprints por módulo, el último es el Examen final. El módulo 1 lleva 2 completados, el 3.º en curso y 2 bloqueados; los módulos 2 a 5 están bloqueados. Lo cambié porque antes los módulos 3 a 5 no tenían sprints y el héroe no podía decir "Sprint 3 de 5".

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (235 pruebas):
```
+235: All tests passed!
```
- `test/funciones/inicio/logica_inicio_test.dart`: iniciales, perfil corto, estados (incluido el módulo sin sprints), conteo de completados, módulo y sprint actuales, nombres, tramos e íconos, y el mock real (2/5, sprint 3 de 5, resto bloqueado).
- `test/componentes/inicio_componentes_test.dart`:
  - Cada componente en claro y oscuro, con solo colores del tema (más los colores de módulo).
  - Medidas, semántica, foco con teclado y Enter, y el módulo bloqueado sin acción.
  - El Buzón con y sin contador.
  - **Contraste** de `texto/en-primario` sobre `accion/primaria` y sobre `accion/acento` ≥ 4.5:1 en ambos modos (claro 9.55 y 5.45; oscuro 7.62 y 8.35).
- `test/funciones/inicio/inicio_test.dart`:
  - Saludo, iniciales y "Dev · Nivel 4" desde la sesión; chips con los datos de los repositorios.
  - Héroe con "Sprint 3 de 5 · Protección de datos", reto y título como encabezado.
  - Estados y progreso de los 5 módulos (en curso, disponible, completado, bloqueado y bloqueado), y contador "6".
  - "Continuar sprint" va a la ruta exacta. Las tarjetas abiertas navegan y la bloqueada no.
  - El Buzón queda fijo al desplazar, no tapa la última tarjeta y navega.
  - Las 3 pestañas llevan a sus marcadores y Mapa no hace nada.
  - Esqueleto mientras carga, error y reintento, y redirección sin sesión.
  - Orden de foco: Continuar → módulos 1, 2 y 3 → Buzón → pestañas; los bloqueados no reciben foco.
  - **Sin desbordes** en 390×844 y 360×640 con texto al 200 %, y en 320×640 al 100 % y 200 %, en claro y oscuro, recorriendo toda la lista.
- `test/datos/mocks_test.dart`: `incorrecta` falla y otra contraseña entra; 5×5 sprints y 6 apelaciones.
- Revisé con `git grep` que no haya hex fuera de `lib/core/tema/`.

## Decisiones
- **Nombres cortos y tramos** (DEC-INICIO-NOMBRES): están en `Textos`, ordenados por número de módulo. No agregué un campo al modelo.
  - Etiqueta: "MÓDULO N · NOMBRE" con los nombres cortos de Figma, y "AUDITORÍA Y CUMPLIMIENTO" para el módulo 5.
  - Títulos: Del Garage al MVP, Ronda Semilla, Escalando el equipo, Serie A y Salida a bolsa.
  - El subtítulo del héroe también usa el nombre corto ("Protección de datos", como en Figma).
- **Progreso:** cuenta solo los completados. **El mock muestra 2/5** en el módulo 1; Figma 07 dice 3/5.
- **Encabezado** (DEC-INICIO-ENCABEZADO):
  - Normalmente va en una fila: el nombre se recorta con puntos suspensivos y los chips se mantienen.
  - Con texto ≥ 130 % o menos de 300 dp útiles (320 de ancho), los chips bajan a una segunda fila, para evitar desbordes.
- **Buzón a 28 dp** de la barra, como en Figma (760 − 732). La tarea decía 24.
- **Colores fuera de los tokens, en `EfectosApp`:**
  - Ícono blanco fijo sobre el color del módulo (de marca), con contraste de 4.07 a 9.55.
  - Elipse del héroe en blanco al 8 %: se ve más clara que el verde en 07 y en 07b. El valor lo estimé de la captura (ver D3).
  - Sombras de Figma: héroe y módulo al 14 %, Buzón al 22 %.
- **Módulo bloqueado:** "Completa el módulo anterior" va debajo del título, donde estaría la barra. En Figma aparece en una columna a la derecha. El chevron se ve en `borde/control` y no es tocable.
- **El usuario del mock no cambió** (Valeria Ríos, Dev, nivel 3, racha 4; 340 monedas y 3 vidas). La tarea solo pedía ajustar las apelaciones, así que el Inicio no muestra los mismos números que Figma ("Hola, Ana", 7, 240 y 5).

## Grafo actualizado
Toqué la sección 4 (Código), las filas PANT-07 y PANT-07b (sección 5) con la ruta del código, la línea "Última actualización" y el registro de cambios. Comprobé con `ls` que todas las rutas de la sección 4 existen.
- **Cambiados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, MOCK-AUTH, MOCK-PROG, MOCK-APEL, PANT-GALERIA, SESION, TEST-GALERIA, TEST-COMP y TEST-DATOS.
- **Nuevos:**
  - Lógica y pantalla: LOGICA-INICIO, EST-INICIO y CODIGO-PANT-07.
  - Componentes: COMP-AVATAR, COMP-HEROE, COMP-RETO, COMP-MODULO y COMP-BUZON.
  - Pruebas: TEST-INICIO.
  - Decisiones: DEC-INICIO-NOMBRES y DEC-INICIO-ENCABEZADO.
- **Obsoletos:** ninguno.

## Dudas
- **D1 · Datos del usuario del mock.** ¿Cambio `usuarioDemo` a "Ana López", Dev, nivel 4, racha 7, y las monedas y vidas a 240 y 5, para que el Inicio se vea idéntico a Figma? Ahora el saludo se recorta a "Hola, V…" en 390 porque "Valeria" es más largo.
- **D2 · Corte del título del héroe.** Con Fredoka en Flutter, "Del Garage al" cabe en 200 dp y el título queda "Del Garage al / MVP". En Figma es "Del Garage / al MVP". ¿Se fuerza el salto después de "Garage"?
- **D3 · Elipse del héroe.** No tengo el color exacto (lo estimé de la captura en blanco al 8 %). Si Figma usa otro valor u opacidad, lo cambio.
- **D4 · Sarko en 320 dp.** El héroe mide 272 de ancho y Sarko (en x=226) queda casi fuera de la tarjeta. ¿Se oculta o se reduce en pantallas angostas?
- **D5 · Ícono de monedas.** Figma usa una moneda rellena; el chip usa `coins` de Lucide, una decisión de T-01. ¿Se mantiene?
