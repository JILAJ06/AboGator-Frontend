# Reporte

- **Tarea:** T-00 · Base del proyecto
- **Rama:** `00-base-del-proyecto`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable, revisión ab2912035e) · Dart 3.14.0 · Windows 11.
- **No hay Android toolchain** (`flutter doctor`: falta `cmdline-tools`) y en Windows no se compila para iOS. Por eso **no pude compilar el APK ni abrir la app en un emulador**. Verifiqué la pantalla con pruebas de widget (montan la app completa en claro y oscuro). Ver D4.

## Qué se hizo
1. **Proyecto Flutter** creado en la raíz con `flutter create --org mx.abogator --project-name abogator --platforms android,ios`. El paquete es `abogator` y el applicationId/bundle es `mx.abogator.abogator`. Se conservaron `README.md` y `ai/`, y se agregó el `.gitignore` estándar de Flutter. El nombre visible de la app es "AboGator" en Android e iOS. La orientación queda solo en vertical (`SystemChrome` en `main.dart`).
2. **Localización:** la app usa siempre `es_MX` (`locale`, `supportedLocales` y los delegados de `GlobalMaterialLocalizations`).
3. **Estructura de `lib/`** tal como pide la tarea:
   - `app/`: `app.dart` (MaterialApp.router), `enrutador.dart` (GoRouter vía Riverpod) y `rutas.dart`.
   - `core/tema/`: `tokens_color.dart`, `colores_marca.dart`, `tipografia.dart`, `tema_app.dart` y `modo_tema.dart`.
   - `core/textos/textos.dart` y `core/utilidades/extensiones_contexto.dart` (`context.tokens`, `context.estilos`, `context.esModoOscuro`).
   - `datos/modelos/`, `datos/repositorios/` y `datos/mocks/`.
   - `funciones/` (bienvenida, acceso, inicio, juego, apelaciones, tienda, perfil y jefe) y `componentes/`. Las carpetas vacías llevan `.gitkeep`.
4. **Tema:**
   - `TokensColor` es una `ThemeExtension` con los 14 tokens y dos instancias, `TokensColor.claro` y `TokensColor.oscuro`, con los valores exactos de la tabla. Incluye `copyWith` y `lerp`.
   - `ColoresMarca` tiene los 15 primitivos y `ColoresModulo` los 5 colores de módulo, más `enOrden`.
   - `TipografiaBase` tiene los 11 estilos (familia, peso, tamaño e interlineado exactos; `height = interlineado / tamaño`). `EstilosTexto` es una `ThemeExtension` que guarda esos estilos ya con fuente y color, y también se mapean al `TextTheme` de Material.
   - `crearTema` arma el `ColorScheme` a partir de los tokens. No fija la escala de texto, así que se respeta el texto dinámico.
   - `modoTemaProvider` (Notifier de Riverpod) empieza en `ThemeMode.system` y queda listo para forzarse desde Ajustes en T-10.
5. **Capa de datos:**
   - Modelos inmutables: `Usuario` (con `PerfilUsuario`), `Modulo`, `Sprint` (con `EstadoSprint`), `Tarjeta` (con `TipoTarjeta` y `Veredicto`: legal, ilegal, condicional y escalar), `EstadoStartup` y `Vidas` (con `maximo = 5` y `proximaEn` del servidor). Además agregué `Apelacion` y `ArticuloTienda` (con `Comodin`), que necesitan los repositorios de apelaciones y tienda (ver D7).
   - Interfaces: `RepositorioAutenticacion`, `RepositorioProgreso`, `RepositorioTarjetas`, `RepositorioVidas`, `RepositorioApelaciones` y `RepositorioTienda`.
   - Mocks con datos en español: los 5 módulos, la tarjeta "Librería GPL en app cerrada" con su evidencia, casos ARCO, MIT, los 3 comodines y 2 apelaciones. Todos devuelven `Future` y esperan 300 ms; la espera se puede cambiar por constructor y las pruebas usan `Duration.zero`.
   - `proveedores_repositorios.dart` es el único lugar donde se elige la implementación. Los proveedores están tipados con la interfaz, así que en T-14 solo se cambia ahí.
   - El registro recibe `aceptaAvisoPrivacidad` y `aceptaTerminos` por separado, y el mock rechaza el registro si falta cualquiera de los dos.
   - No hay código de red. Ningún mock guarda ni registra (log) contraseñas.
6. **Enrutador:** tiene una sola ruta, `/`, que abre la pantalla "Tema de prueba". En `Rutas` están declaradas las constantes de todas las pantallas del inventario de `03-pantallas.md`, sin implementar.
7. **Pantalla de prueba** (`funciones/bienvenida/pantalla_prueba.dart`): un interruptor "Modo oscuro", los 14 tokens con su muestra, nombre y valor hex, y los 11 estilos con su tamaño/interlineado y un texto de ejemplo. Se elimina en T-02.
8. **Calidad:**
   - `analysis_options.yaml` con `flutter_lints`, `strict-casts`, `strict-inference` y `strict-raw-types`, y reglas como comillas simples, `prefer_const_*`, `prefer_final_locals`, `directives_ordering` y `unawaited_futures`. Ancho de formato: 100 columnas.
   - CI en `.github/workflows/ci.yml`: en push y PR a `develop` corre `flutter pub get`, revisa el formato y ejecuta `flutter analyze` y `flutter test`, con Flutter fijo en 3.50.0.

## Resultados
`flutter analyze`:
```
Analyzing AboGator-Frontend...
No issues found!
```
`flutter test` (31 pruebas):
```
00:06 +31: All tests passed!
```
- `test/core/tema/tokens_color_test.dart`: los 14 tokens, claro y oscuro, contra los hex de la tabla; también `lerp`.
- `test/core/tema/tipografia_test.dart`: los 11 estilos (familia, peso, tamaño e interlineado).
- `test/funciones/bienvenida/pantalla_prueba_test.dart`: monta la app y muestra los 14 tokens y los 11 estilos; el interruptor pasa a oscuro y regresa a claro; sigue al sistema en oscuro; respeta la escala de texto 2×.
- `test/datos/mocks_test.dart`: los mocks y la sustitución de proveedores.

`dart format --set-exit-if-changed lib test`: sin cambios.

Ningún color en hex en `lib/` fuera de `core/tema/`. Lo comprobé con grep.

## Criterios de aceptación
1. Analyze sin avisos, pruebas en verde y CI definido: ✅
2. La app abre en la pantalla de prueba con los 14 tokens y los 11 estilos, y alterna claro/oscuro con los valores exactos: ✅ en pruebas de widget; ⚠️ no la abrí en un dispositivo (D4).
3. Estructura de carpetas tal como se pide: ✅
4. Repositorios como interfaces con mocks, sin red: ✅
5. Sin hex fuera de `core/tema/`: ✅ (las pruebas sí tienen los hex de la tabla para verificarlos; ver D10).
6. Commits sin prefijo y sin mención a Claude, rama subida y reporte reescrito: ✅

## Decisiones y dudas
- **D1 · Fuentes.** Usé `google_fonts` (9.0.0) para el desarrollo: descarga Fredoka, Inter y JetBrains Mono la primera vez y las guarda en caché. Sin internet en el primer arranque, la app usa la fuente del sistema. Todo pasa por `resolutorFuenteProvider`, y las pruebas lo cambian por `fuenteSinDescarga` para no depender de la red. Recomiendo pasar a archivos `.ttf` en `assets/fuentes/` (licencia OFL) en una tarea posterior: solo se cambia el proveedor y el `pubspec`. **¿Quién entrega los archivos y en qué tarea?**
- **D2 · Dependencia `material_ui` (no estaba en la lista).** En Flutter 3.50, `package:flutter/material.dart` está marcado como obsoleto y `flutter create` ya agrega `material_ui: ^1.1.0`. Todo el código importa `package:material_ui/material_ui.dart`. Las demás dependencias son las permitidas: `flutter_riverpod` 3.5.0, `go_router` 18.1.4, `google_fonts` 9.0.0, `intl` 0.20.x, `flutter_localizations` y `flutter_lints` 6.0.0.
- **D3 · Carpeta `Imegenes/` (sin rastrear).** En la raíz hay logos y poses de Sarko. **No la subí**, porque no estaba entre los archivos permitidos. Propongo moverla a `assets/imagenes/` con nombres sin espacios, acentos ni "·" (por ejemplo `sarko_alegre.png`) en T-01. También el ícono de la app.
- **D4 · Sin Android toolchain.** Para compilar el APK o abrir la app en un emulador hace falta instalar Android Studio o los `cmdline-tools` y aceptar las licencias (`flutter doctor --android-licenses`). iOS requiere macOS.
- **D5 · Convención de nombres.** Las clases, variables y archivos propios están en español (`TokensColor`, `RepositorioTarjetas`, `pantalla_prueba.dart`). Las APIs de Flutter quedan como son. ¿Se confirma como convención del proyecto?
- **D6 · Rutas.** Elegí una ruta para todo el onboarding (02–04, un paginador) y una para el juego (10–18, el sprint completo), además de rutas anidadas como `/inicio/modulo/:moduloId`. Las pestañas Inicio, Buzón, Tienda y Perfil se harán con `StatefulShellRoute` en T-04. ¿Algún cambio?
- **D7 · Modelos extra.** Agregué `Apelacion` y `ArticuloTienda`. `Modulo.color` es un `Color` (de `dart:ui`) tomado de `ColoresModulo`. Si el backend no manda el color, se puede resolver desde `Modulo.numero` con `ColoresModulo.enOrden`.
- **D8 · Mapeo a Material.** `onPrimary`, `onSecondary`, `onError` y `onTertiary` usan `texto/en-primario`; `outline` usa `borde/default`; `surfaceContainerHighest` usa `fondo/superficie-alt`. Por ahora no hay espaciados ni radios como tokens (Figma no los define en la tabla); la pantalla de prueba usa 24/16/8.
- **D9 · CI.** Agregué la revisión de formato (`dart format --set-exit-if-changed`). El CI solo corre en push y PR a `develop`, así que se ejecuta cuando se abra el PR de esta rama.
- **D10 · Hex en pruebas.** `tokens_color_test.dart` repite la tabla de Figma en hex a propósito, para verificar los tokens. No está en `lib/`.
- **D11 · Saltos de línea.** Git avisa LF→CRLF (`core.autocrlf` en Windows). No agregué `.gitattributes` porque no estaba en la lista de archivos permitidos. ¿Lo agrego en otra tarea con `* text=auto eol=lf`?
