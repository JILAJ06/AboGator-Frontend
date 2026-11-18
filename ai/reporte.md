# Reporte

- **Tarea:** T-01 · Componentes base
- **Rama:** `01-componentes-base`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- Sigue sin haber herramientas de Android (falta `cmdline-tools`), así que no hay APK ni emulador. La galería sí la revisé en Chrome con la plataforma web, en 390×844, en claro y oscuro.
- `flutter build web` falla en esta máquina porque Windows (Smart App Control) bloquea `font-subset.exe` del SDK. Compilé con `--no-tree-shake-icons`, que no usa esa herramienta. No toqué la configuración de seguridad. Ver D6.

## Qué se hizo
1. **Tokens y tipografía**
   - `TokensColor` tiene ahora 17 tokens: agregué `bordeControl`, `estadoCondicional` y `focoAnillo`, con los valores de `07-componentes.md`. También agregué `porNombre`, el mapa de nombre de Figma → color que usan la galería y las pruebas.
   - Botón, Etiqueta y Leyenda llevan `letterSpacing` de 0.2.
   - `crearTema` usa `borde/control` para `outline` y `foco/anillo` para `focusColor`, e Inter como fuente por defecto.
   - Nuevo `core/utilidades/contraste.dart` con el cálculo WCAG 2.1.
2. **Fuentes locales.** Con tu permiso descargué los `.ttf` estáticos del CDN oficial de Google Fonts (`fonts.gstatic.com`) y verifiqué que su SHA-256 y su tamaño coincidan con los que publica el paquete `google_fonts`:
   - Fredoka 600 y 700.
   - Inter 400, 500, 600 y 700.
   - JetBrains Mono 400 (hace falta para el estilo Código, aunque la tarea solo menciona Fredoka e Inter).
   - Las licencias OFL van en `assets/fuentes/OFL-*.txt`.
   - Quité `google_fonts`, junto con su resolutor y su proveedor, y declaré las fuentes en `pubspec.yaml`.
3. **Imágenes.** Moví `Imegenes/` a `assets/imagenes/` sin modificar los archivos:
   - `logo_isotipo.png` (1068×973), `logo_marca_nominativa.png` (1312×266) e `icono_app.png` (180×180).
   - `sarko_alegre.png`, `sarko_enojado.png`, `sarko_sorprendido.png` y `sarko_triste.png`.
   - Todas tienen fondo transparente. Las rutas están en `core/recursos/imagenes_app.dart`.
   - En la raíz quedaron las carpetas vacías de `Imegenes/`. Una regla de seguridad me impidió borrarlas; git no las ve, pero puedes borrarlas a mano.
4. **`.gitattributes`** con `* text=auto eol=lf`, y las imágenes, fuentes y `.jar` marcados como binarios. Lo apliqué con `git add --renormalize .` y no hubo cambios en archivos existentes.
5. **Íconos:**
   - Agregué `lucide_icons_flutter` 4.0.3, la versión más reciente compatible. Es la única dependencia nueva.
   - `IconosApp` (en `core/tema/iconos_app.dart`) tiene una entrada por cada nombre de Figma, más `eyeOff` para ocultar la contraseña. `porNombre` lista los 45.
   - `IconoApp(icono, tamano, color, etiquetaSemantica)` queda decorativo, fuera de la semántica, cuando no recibe etiqueta.
6. **Componentes**, en `lib/componentes/`, uno por archivo:
   - `BotonApp`: tipos primario, secundario, acento, peligro y fantasma; con `alPresionar: null` se ve como Deshabilitado. Tiene sombra sólida, estado presionado y anillo de foco, y se activa con Enter o Espacio.
   - `CampoTextoApp`: estados reposo, foco y error; tipos texto, nombre, correo y contraseña, cada uno con su teclado y autocompletado. El botón de mostrar contraseña mide 48×48.
   - `ChipHud`: vidas, monedas, racha, comodines y amparo, cada uno con un constructor propio, por ejemplo `ChipHud.vidas(4)`.
   - `CorazonVida` y `FilaVidas`.
   - `IndicadoresStartup`, el enum `IndicadorStartup` e `ImpactoStartup`.
   - `NavegacionInferiorApp`, con el enum `PestanaApp`.
   - `BarraProgreso`, `PaginadorPuntos` y `AnilloFoco`.
   - `SarkoImagen`, con el enum `PoseSarko` y un texto alternativo por pose.
   - `LogoApp`: vertical, horizontal e isotipo.
   - Todos los componentes:
     - Toman sus colores de `context.tokens` y sus textos de `Textos`.
     - Tienen zonas táctiles de 48 o más.
     - Llevan semántica en español.
     - Crecen con el texto dinámico.
     - Respetan "reducir animaciones" con `EfectosApp.duracion`.
   - Los colores que no son tokens (la sombra #0F294A al 18 % y el brillo blanco al 35 %) están en `core/tema/efectos.dart`.
7. **Galería** (`funciones/bienvenida/galeria_componentes.dart`). Reemplaza a `pantalla_prueba.dart`, que eliminé junto con su prueba. Muestra todos los componentes en todos sus tipos y estados, los 45 íconos, los 17 tokens y los 11 estilos, con el interruptor claro/oscuro. La navegación inferior va como barra real abajo. Actualicé el enrutador.
8. **Plataforma web** de desarrollo, creada con `flutter create --platforms=web .`. Le puse el nombre "AboGator" y el idioma `es-MX`. El comando también generó un `test/widget_test.dart` de ejemplo (el contador), que estaba roto, y lo borré. Para ver la galería:
   ```bash
   flutter run -d chrome --no-tree-shake-icons
   ```

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (101 pruebas):
```
00:04 +101: All tests passed!
```
- `test/core/tema/`:
  - Los hex de los 17 tokens.
  - El contraste de los 3 tokens nuevos sobre `fondo/app` y `fondo/superficie`, en ambos modos.
  - Los 11 estilos con su tracking.
- `test/componentes/`: cada componente en claro y oscuro, con:
  - Medidas y colores esperados.
  - Estados: presionado, foco, error, contraseña y deshabilitado.
  - Semántica.
  - Foco con teclado: aparece el anillo y Enter activa.
  - Texto al 200 %.
  - Uso de colores: un ayudante (`test/ayudantes/montar.dart`) junta los colores de textos, íconos, fondos, bordes, sombras y del corazón, y comprueba que todos salgan del tema.
- `test/funciones/bienvenida/galeria_componentes_test.dart`: aparecen todos los componentes, el interruptor cambia el modo, la navegación cambia de pestaña y no hay desbordes con texto al 200 % en claro ni en oscuro.
- Contrastes medidos (razón contra `fondo/app` / `fondo/superficie`):

  | Token | Mínimo | Claro | Oscuro |
  |---|---|---|---|
  | borde/control | 3 | 4.55 / 4.76 | 3.93 / 3.44 |
  | estado/condicional | 4.5 | 6.07 / 6.35 | 7.02 / 6.13 |
  | foco/anillo | 3 | 6.07 / 6.35 | 8.31 / 7.27 |

  Todos pasan, así que **no ajusté ningún valor oscuro propuesto**.
- No hay hex fuera de `lib/core/tema/` (lo revisé con `git grep`) ni queda ninguna referencia a `google_fonts`.
- El CI no necesitó cambios: los assets y las fuentes se cargan en `flutter test`.

## Criterios de aceptación
1. La galería muestra todos los componentes en claro y oscuro: ✅ Lo revisé en Chrome a 390×844 y con pruebas. Las medidas siguen `07-componentes.md`, con los matices de D2 y D3.
2. Sin `google_fonts`; fuentes e imágenes desde `assets/`: ✅
3. Contraste verificado por pruebas y sin hex fuera de `core/tema`: ✅
4. Cada componente tiene pruebas, semántica en español y foco visible con teclado: ✅ (el foco aplica a botón, campo y navegación, que son los componentes interactivos).
5. CI en verde localmente, commits sin prefijo y sin menciones a Claude: ✅
6. Grafo y reporte actualizados: ✅

## Decisiones
- **Estado presionado del botón:** baja 2 dp y la sombra pasa de (0, 4) a (0, 2), con una transición de 80 ms; con "reducir animaciones" es inmediato. Deshabilitado, fantasma y secundario no tienen sombra.
- **Deshabilitado como estado:** `BotonApp` tiene 5 tipos en el enum. El sexto aspecto, Deshabilitado, sale de `alPresionar: null` en cualquier tipo, para que el estado no dependa de elegir un tipo.
- **Colores de íconos de los chips** (provisionales, según la especificación):
  - Vidas: corazón relleno en `estado/ilegal`.
  - Monedas y Racha: `accion/acento`.
  - Comodines: `texto/acento`.
  - Amparo: `accion/secundaria`, con borde de 1.5.
- **Corazón relleno:** Lucide solo tiene el corazón de contorno, así que dibujé su misma silueta (`PintorCorazon`) para poder rellenarlo. El chip de Vidas usa ese corazón relleno.
- **Zona segura de la navegación:** el contenido mide como mínimo 58 y debajo va `SafeArea(top: false)`. El sistema pone su propio relleno inferior: unos 34 en iPhone con indicador de inicio y 0 en teléfonos sin indicador. No fijé los 26 de Figma. Una prueba verifica que con un relleno de 26 la barra mide 58 + 26 = 84.
- **Valores oscuros de los tokens:** dejé los propuestos (#64748B, #6FA0E8 y #7CB0F0), porque pasan las pruebas de contraste.
- **Borde del campo en primer plano:** el borde se pinta encima de la caja para que su grosor (1.5 o 2) no cambie el alto. La caja mide 52 en los tres estados, y hay una prueba que lo verifica.
- **Indicadores de la Startup:** las columnas tienen el ancho de su contenido, dentro de un `Wrap` con espacio uniforme. Al principio usé cuatro columnas iguales, pero en Chrome "Presupuesto" se cortaba a media palabra (ver D3).

## Íconos sin equivalente exacto en Lucide
| Figma | Lucide usado |
|---|---|
| coin | `coins` (no existe una sola moneda) |
| back | `arrow-left` |
| chevron | `chevron-right` |
| refresh | `refresh-cw` |
| alert | `triangle-alert` |

Con otro nombre pero el mismo dibujo: bulb → `lightbulb`, home → `house`, doc → `file-text`, logout → `log-out`. Gavel, highlighter y vibrate sí existen tal cual.

## Ícono de la app
`assets/imagenes/icono_app.png` sirve como ícono: fondo verde, isotipo en crema y esquinas redondeadas. Pero mide **180×180**, y las tiendas piden 1024×1024. Para generar los íconos hace falta exportarlo de Figma a 1024. No generé ninguno.

## Grafo actualizado
Solo toqué la sección 4 (Código), la línea "Última actualización" y el registro de cambios. Comprobé con `ls` que las 62 rutas de la sección 4 existen.
- **Cambiados (`en curso`):** APP, ENRUTADOR (ahora lleva a PANT-GALERIA), TEMA, TEMA-TOKENS (17 tokens), TEMA-TIPO, TEMA-APP, TEXTOS, TEST-TEMA, CONF (incluye `.gitattributes`) y DEC-FUENTES (ya sin google_fonts). MODO-TEMA cambió de relación: ahora lo usa PANT-GALERIA en lugar de PANT-PRUEBA.
- **Con ruta real:** COMP-* (`lib/componentes/`) y COMP-SARKO (`lib/componentes/sarko_imagen.dart`).
- **Nuevos:**
  - Tema y recursos: TEMA-EFECTOS, TEMA-ICONOS, UTIL-CONTRASTE y RECURSOS.
  - Componentes: COMP-BOTON, COMP-CAMPO, COMP-CHIP, COMP-CORAZON, COMP-INDICADORES, COMP-IMPACTO, COMP-NAV, COMP-PROGRESO, COMP-PAGINADOR, COMP-FOCO, COMP-ICONO y COMP-LOGO.
  - Assets: ASSETS-IMG y ASSETS-FUENTES.
  - Galería y pruebas: PANT-GALERIA, TEST-GALERIA, TEST-COMP y TEST-AYUDA.
  - Plataforma y dependencias: PLAT-WEB y DEP-LUCIDE.
  - Decisiones: DEC-PRESIONADO, DEC-ZONA-SEGURA y DEC-INDICADORES.
- **Obsoletos:** PANT-PRUEBA y TEST-PRUEBA, porque se eliminaron sus archivos.

## Dudas
- **D1 · EXT-ASSETS en el grafo.** La fila todavía dice que las imágenes están en la carpeta local "aún sin subir". Ahora están en `assets/imagenes/`. No la cambié porque le corresponde a Claude Chat.
- **D2 · Indicadores de la Startup.** Con Inter real, las cuatro etiquetas más sus íconos miden unos 317 dp, y el espacio útil es 322 (342 menos el relleno de 10 por lado). Caben en una fila en 390 de ancho, pero muy justo, y en un teléfono de 360 pasan a dos filas. En Figma las columnas parecen de unos 80. ¿Figma usa etiquetas más cortas o un tamaño menor? Si es así, lo ajusto.
- **D3 · Medidas que no salían exactas.** El botón y la caja del campo miden mínimo 52 y crecen con el texto dinámico; con texto normal miden exactamente 52. El panel de indicadores mide mínimo 46.
- **D4 · Poses de Sarko.** Enojado, Sorprendido y Triste traen el nombre de la pose escrito dentro de la imagen ("ENOJADO", etc.). Además miden alrededor de 1:2, no 4:5 como Alegre, así que en la caja 4:5 se ven más pequeños. ¿Hay versiones sin texto y recortadas a 4:5?
- **D5 · Logos y Sarko en modo oscuro.** La marca nominativa y el isotipo usan azul marino y verde bosque, y casi no se ven sobre `fondo/app` oscuro (#0B1220). Lo mismo pasa con el traje de Sarko. ¿Existe una versión del logo para modo oscuro en Figma, o ponemos el logo sobre una superficie clara?
- **D6 · Compilar web en esta máquina.** Smart App Control de Windows bloquea `font-subset.exe` del SDK de Flutter. Con `--no-tree-shake-icons` compila bien; solo cambia que la fuente de íconos va completa. Para que funcione sin esa opción habría que agregar una excepción para la carpeta del SDK en la configuración de seguridad de Windows. Eso lo decides tú.
- **D7 · Número de íconos.** `07-componentes.md` dice que son 47, pero la lista tiene 45 nombres. Implementé esos 45. ¿Faltan dos?
- **D8 · Logo vertical y horizontal.** En el repo no hay archivos de logo "vertical" ni "horizontal", solo el isotipo y la marca nominativa. Armé las dos variantes combinándolos: la marca al 36 % del alto del isotipo en la vertical y al 50 % en la horizontal. Si en Figma existen como piezas propias, conviene exportarlas.
- **D9 · Carpetas vacías de `Imegenes/`.** Quedaron en la raíz porque una regla de seguridad me impidió borrarlas. No afectan a git; puedes borrarlas a mano.
