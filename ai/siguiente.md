# FIX-02 · Imágenes de logos y Sarko según Figma

**Rama:** `fix/02-imagenes-figma` (desde `develop`; ya existe en GitHub)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Reemplazar los logos y las poses de Sarko provisionales por las exportaciones reales de Figma: renombrarlas, ordenarlas en `assets/imagenes/` y hacer que `LogoApp`, `SarkoImagen`, el Splash y la galería las usen. El usuario las dejó **en su computadora** (no están en GitHub):

`C:\Users\alexa\Proyectos\Etica y Legislacion en TI\AboGator-Frontend\Imegenes\Logo-Isotipo\`

(las carpetas `Imegenes\Mascota` y `Imegenes\Logo-Base_Isotipo` están vacías; ignóralas).

## Antes de empezar
- `git fetch`, `git checkout fix/02-imagenes-figma` y `git pull`. Leer `ai/conocimiento/07-componentes.md` (secciones Sarko y LogoApp) y `01-flujo-de-trabajo.md`.
- Commits pequeños, **una frase en español, sin prefijo y sin mencionar a Claude** (ni `Co-Authored-By`, ni `Generated with`, ni `Claude-Session`). Revisar con `git log -1 --format=%B`. Subir la rama; **no abrir Pull Request**.

## Hallazgos sobre los archivos (ya revisados por Chat)
La carpeta mezcla **dos familias de logos**:
1. **`Versión=<tono> <forma>.png`** → logos limpios con fondo transparente. **Son los que se usan.** (Los claros se ven "vacíos" sobre blanco porque son blancos/crema: es correcto.)
2. **`<tono> <forma>.png`** (sin "Versión=") y `Ícono App v2` → **láminas de presentación de Figma** (tarjeta con fondo, esquinas redondeadas y la leyenda "Sobre Verde Bosque" etc.). **No se usan en la app**: no las copies a `assets/`.

Formas: `(sin sufijo)` = isotipo solo (200×200) · `Vertical` (355×206) · `Horizontal` (495×120) · `Extendido` (495×120, con el lema "EDUCACIÓN EN LEGISLACIÓN Y DERECHO INFORMÁTICO"). Tonos: color, negro, negativo, sobreAzul, sobreVerde.
Notas: `Versión=color 2.png` es el **Horizontal en color** (falta "Versión=color Horizontal.png"; confírmalo viéndolo). `Versión=sobreAzul.png` y `Versión=sobreVerde.png` son idénticos byte a byte, y también sus `Vertical`: cópialos con ambos nombres de todos modos.
**Resolución:** las exportaciones están a ~1x (p. ej. el vertical mide 355×206 para un uso de 323.7×187.9 dp). Úsalas tal cual y anótalo en el reporte (se pedirá 3x después).

## Estructura y renombrado
Crear en `assets/imagenes/` y **copiar desde `Imegenes\Logo-Isotipo\`** (los originales se quedan donde están). Nombres sin espacios, acentos ni símbolos, en minúsculas y `snake_case`:

```
assets/imagenes/
  logos/
    base/
      logo_base_isotipo.png            ← Base · Isotipo.png (1068×973)
      logo_base_marca_nominativa.png   ← Base · Marca nominativa.png (1312×266)
    isotipo/      logo_isotipo_{color,negro,negativo,sobre_azul,sobre_verde}.png      ← Versión=<tono>.png
    vertical/     logo_vertical_{color,negro,negativo,sobre_azul,sobre_verde}.png     ← Versión=<tono> Vertical.png
    horizontal/   logo_horizontal_{color,negro,negativo,sobre_azul,sobre_verde}.png   ← Versión=<tono> Horizontal.png (color ← "Versión=color 2.png")
    extendido/    logo_extendido_{color,negro,negativo,sobre_azul,sobre_verde}.png    ← Versión=<tono> Extendido.png
  sarko/
    sarko_alegre.png        ← Sarko · Alegre (original).png (432×432)
    sarko_enojado.png       ← Sarko · Enojado.png (269×312)
    sarko_sorprendido.png   ← Sarko · Sorprendido.png (256×283)
    sarko_triste.png        ← Sarko · Triste.png (216×283)
  icono_app/
    icono_app_180.png ← Ícono App.png · icono_app_120.png ← Ícono App v3.png · icono_app_64.png ← Ícono App v4.png · icono_app_40.png ← Ícono App v5.png
```
- Eliminar con `git rm` los archivos provisionales anteriores de `assets/imagenes/` (`logo_isotipo.png`, `logo_marca_nominativa.png`, `icono_app.png`, `sarko_*.png`) una vez reemplazados.
- Declarar **cada subcarpeta** en `pubspec.yaml` (Flutter no entra en subcarpetas con una sola entrada).
- Agregar `Imegenes/` a `.gitignore` (originales y láminas de Figma no van al repo).
- Verifica con `file`/miniatura que cada copia coincide en medidas con las indicadas; si algo no coincide, anótalo y no lo adivines.

## Código
1. **`ImagenesApp`** (`lib/core/recursos/imagenes_app.dart`): rutas con las nuevas ubicaciones y una forma ordenada de obtener el logo por forma y tono (por ejemplo `ImagenesApp.logo(forma, tono)`), y las poses de Sarko.
2. **`LogoApp`**: usa los PNG ya armados (se elimina el armado por código de isotipo + marca). Parámetros: `forma` (`vertical`, `horizontal`, `extendido`, `isotipo`), `tono` (`color`, `negro`, `negativo`, `sobreAzul`, `sobreVerde`; por defecto automático: **color en claro, negativo en oscuro**) y `ancho`; la proporción sale del archivo. Conserva la semántica "AboGator" (decorativo si se indica).
3. **Splash**: usar `logo_vertical_sobre_verde.png` a 323.7×187.9, con su parte superior cerca de y=280, **sin la tarjeta marcador**. Además (decisión de Chat sobre D2 de T-02): el Splash es pantalla de marca y **siempre** usa verde bosque `TokensColor.claro.accionPrimaria` como fondo y blanco / `fondo/destacado` claros fijos para puntos y textos, también en modo oscuro (barra de estado clara). Documenta la excepción en el código y en el reporte; actualiza las pruebas.
4. **`SarkoImagen`**: las nuevas poses ya no tienen texto incrustado, pero **no son 4:5** (alegre es 1:1; las otras ≈0.76–0.86). Mantén la caja de 4:5 y `BoxFit.contain`, alineando la imagen **abajo al centro** (los pies de Sarko deben quedar sobre la misma línea en todas las poses). Revisa en Chrome que en el onboarding (264×330, 160×200, 208×260) y en la galería se vean bien y con tamaño parecido entre poses; si alguna se ve claramente más chica, **no la escales por tu cuenta**: anótalo en el reporte con la medida.
5. **Galería** (`/galeria`): mostrar todos los logos (4 formas × 5 tonos, cada tono sobre un fondo adecuado: color y negro sobre `fondo/app`, negativo sobre superficie oscura, sobreAzul sobre `accion/secundaria`, sobreVerde sobre verde bosque) y las 4 poses de Sarko.
6. **Pruebas:** que toda ruta de `ImagenesApp` exista en disco y esté dentro de una carpeta declarada en `pubspec.yaml`; `LogoApp` automático (claro/oscuro), proporciones, semántica; `SarkoImagen` con las 4 poses y alineación abajo; Splash con fondo fijo en ambos modos; galería sin desbordes. `dart format`, `flutter analyze` y `flutter test` en verde.

## Archivos permitidos
`assets/imagenes/**`, `pubspec.yaml`/`pubspec.lock`, `.gitignore`, `lib/core/recursos/**`, `lib/componentes/logo_app.dart`, `lib/componentes/sarko_imagen.dart`, `lib/core/textos/**` (solo textos alternativos), `lib/funciones/bienvenida/**`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
1. Estructura y nombres exactamente como arriba; ninguna lámina de Figma dentro de `assets/`; los provisionales eliminados.
2. El Splash usa el logo vertical sobre verde real, sin tarjeta, con verde de marca en claro y oscuro.
3. `LogoApp` y `SarkoImagen` usan los archivos nuevos; sarko con pies alineados; galería con todas las variantes.
4. Sin textos de pose incrustados visibles en ninguna pantalla.
5. CI en verde; commits sin prefijo y sin menciones a Claude.
6. `ai/grafo.md` actualizado (ASSETS-IMG, RECURSOS, COMP-LOGO, COMP-SARKO, PANT-01 y pruebas) y `reporte.md` con ID **FIX-02**, rama, tabla de **archivo original → nombre nuevo** (confirmando medidas), decisiones, la nota de resolución 1x, sección **"Grafo actualizado"** y dudas numeradas.
