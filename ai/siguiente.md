# T-04 · Inicio (pantallas 07 y 07b)

**Rama:** `04-inicio` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Implementar la pantalla **07 Inicio** (y su versión oscura **07b**, que sale del tema, no es otra pantalla) con datos del usuario y del progreso que ya existen (sesión y repositorios con mocks), 5 componentes nuevos y la navegación inferior funcionando. El **Mapa de sprints (08) y la Intro del sprint (09) NO van aquí**: son la tarea T-04b. Aquí, tocar un módulo o "Continuar sprint" navega a su ruta, que sigue siendo un marcador pendiente.

## Antes de empezar
- `git fetch`, `git checkout 04-inicio`, `git pull`. Leer `ai/conocimiento/` (00 a 07): `03-pantallas.md` (flujo 2), `05-reglas-y-seguridad.md` y `07-componentes.md` (sección "Componentes del Inicio").
- Comparar en Chrome contra Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`, página "Vistas", nodos 07 = `13:356`, 07b = `14:1132`). Las medidas de abajo salen de ese diseño.

## Estructura de la pantalla (marco 390×844, fondo `fondoApp`)
Contenido con desplazamiento vertical (`CustomScrollView` o `ListView`); encabezado, héroe, reto y módulos se mueven con el scroll; **la navegación inferior y el botón Buzón quedan fijos**. Márgenes laterales 24. Respetar la zona segura superior (el 58 de Figma es la barra de estado + relleno).

1. **Encabezado** (alto 44, y=58): `AvatarApp` (44) con iniciales; a su derecha, a 10 dp, "Hola, {primer nombre}" (Fredoka SemiBold 17/22, `textoPrimario`) y debajo "{Perfil} · Nivel {n}" (Leyenda, `textoSecundario`). A la derecha, los `ChipHud` ya existentes, separados 6: racha, monedas y vidas. En 360 dp de ancho el encabezado no puede desbordar: el nombre se recorta con puntos suspensivos y los chips se mantienen.
   - Nombre e iniciales: de `sesionProvider` (primera letra del nombre y del apellido; si hay una sola palabra, una letra). Perfil legible en español: Estudiante / Dev / Legal (Figma muestra "Dev").
   - Racha: `Usuario.racha`. Monedas: `RepositorioTienda.obtenerMonedas()`. Vidas: `RepositorioVidas`.
2. **Tarjeta héroe** (`TarjetaHeroeStartup`, y=124, margen 24, 342×168): ver sección de componentes. Textos: "TU STARTUP ESTÁ EN" / nombre del módulo actual ("Del Garage al MVP") / "Sprint {n} de {total} · {nombre del módulo}" / botón "Continuar sprint". El módulo y el sprint actual salen de `obtenerModulos()` (primer módulo con algún sprint `enCurso`; si no hay, el primero `disponible`). El botón navega a la ruta de intro del sprint (marcador pendiente hasta T-04b).
3. **Reto diario** (`TarjetaRetoDiario`, 16 dp debajo del héroe): "Reto diario: 3 tarjetas sin fallar" / "Mantén tu racha de {racha} días · +15 monedas" / "1/3". Por ahora es solo presentación (datos fijos en una constante o en el mock); no se puede tocar.
4. **Título** "Ruta de tu Startup" (Fredoka SemiBold 20/26), 18 dp debajo del reto.
5. **Lista de módulos** (16 dp debajo del título, separación 12): una `TarjetaModulo` por módulo de `obtenerModulos()`, en orden. Cada módulo tiene su color (`ColoresModulo.enOrden`) y su ícono: 1 `shield`, 2 `code`, 3 `gavel`, 4 `doc`, 5 `shieldCheck` (todos existen ya en `IconosApp`; si falta uno, agregarlo y decirlo en el reporte). Etiqueta: `MÓDULO {n} · {NOMBRE EN MAYÚSCULAS}` (en Figma: "PROTECCIÓN DE DATOS", "LICENCIAS OPEN SOURCE", "DELITOS INFORMÁTICOS", "CONTRATOS DIGITALES"; para el 5 usar "AUDITORÍA Y CUMPLIMIENTO"). **Nota:** los nombres del mock son más largos ("Licencias y Propiedad Intelectual"); la etiqueta de Figma usa nombres cortos. Agregar al modelo/mocks un `nombreCorto` solo si hace falta, o mapearlo en una constante de textos; decidirlo y reportarlo.
   - Estado de cada módulo: bloqueado si todos sus sprints están `bloqueado`; completado si todos están `completado`; en curso si alguno está `enCurso` o hay algunos completados; si no, disponible. El título de la tarjeta es el nombre del tramo de la Startup ("Del Garage al MVP", "Ronda Semilla", "Escalando el equipo", "Serie A"; el módulo 5 como "Salida a bolsa"). Ponerlos en `Textos`.
   - Progreso: `sprints completados / total`. **Diferencia en Figma:** la tarjeta del 07 dice "3/5 sprints" y el mapa 08 dice 2/5. Decisión de esta tarea: contar solo los **completados** (2/5 si el mock tiene dos completados y uno en curso). Anotar en el reporte lo que muestra el mock.
   - Tocar una tarjeta no bloqueada navega a `Rutas.mapaSprints` con su `moduloId` (marcador pendiente). La bloqueada no responde y lo anuncia el lector de pantalla.
6. **Botón Buzón** (`BotonBuzon`): flotante a la derecha, 24 dp sobre la barra inferior (en Figma, (306,672)); contador con el número de apelaciones pendientes de `RepositorioApelaciones` (Figma muestra 6; si el mock no devuelve 6 pendientes, ajustarlo para que coincida). Navega a `Rutas.buzon` (marcador pendiente). Reservar espacio al final de la lista para que el botón no tape la última tarjeta.
7. **Navegación inferior**: `NavegacionInferiorApp` con `actual: PestanaApp.mapa`. Al tocar Buzón, Tienda o Perfil se navega a `Rutas.buzon`, `Rutas.tienda`, `Rutas.perfil` (marcadores pendientes con el nombre de la tarea que los implementa: Buzón T-09, Tienda y Perfil T-10); tocar Mapa estando en Inicio no hace nada. Usar `context.go` para que cada pestaña sea una raíz sin pila acumulada.

## Estados de la pantalla
- **Cargando**: mientras llegan los datos, mostrar el esqueleto simple (bloques `fondoSuperficieAlt` con las mismas medidas) sin saltos de diseño.
- **Error de carga**: mensaje breve con botón "Reintentar" (`BotonApp` secundario). Texto en `Textos`.
- **Sin sesión** (no debería ocurrir): redirigir a `Rutas.inicioSesion`.

## Arreglo pendiente del mock (viene de T-03, duda D3)
`MockAutenticacion.iniciarSesion` debe rechazar la contraseña exacta `incorrecta` lanzando `ExcepcionAutenticacion(Textos.errorCredenciales)` (acepta cualquier otra no vacía). Agregar la prueba. Sirve para probar el error de inicio de sesión sin servidor.

## Componentes nuevos (`lib/componentes/`, con pruebas y en la galería)
`AvatarApp`, `TarjetaHeroeStartup`, `TarjetaRetoDiario`, `TarjetaModulo` (4 estados) y `BotonBuzon`. Especificaciones en `ai/conocimiento/07-componentes.md` ("Componentes del Inicio"). Reglas: solo tokens y estilos del tema (nada de colores sueltos salvo el color del módulo y la sombra de Figma ya usada en otras tarjetas), zonas táctiles ≥ 48, anillo de foco visible con teclado (reusar `AccionEnfocable`/`AnilloFoco`), semántica completa, texto al 200 % sin desbordes. Agregar a la galería los 4 estados de `TarjetaModulo` y el botón Buzón con y sin contador.

## Orden de foco y semántica
Orden: avatar/saludo (un solo encabezado de lectura) → chips (racha, monedas, vidas, con sus etiquetas) → "Continuar sprint" → reto diario → módulos en orden → botón Buzón → pestañas. Los títulos ("Ruta de tu Startup") se marcan como encabezado. Sarko es decorativo (sin etiqueta).

## Modo oscuro (07b)
Sin código especial: todo por tokens. Verificar que el héroe siga en verde de marca (`accionPrimaria` del tema oscuro) y que el contraste del texto sobre él cumpla 4.5:1 en ambos modos (usar `UTIL-CONTRASTE` en las pruebas).

## Pruebas
- Pantalla: se ve el saludo con el nombre de la sesión, las 4 secciones, las 5 tarjetas de módulo con estados correctos (usando un repositorio de prueba), contador del Buzón, navegación de cada pestaña y de cada tarjeta, bloqueado no navega, estados cargando y error con reintento.
- Componentes: claro y oscuro, estados, semántica, foco con teclado, solo colores del tema.
- Texto al 200 % sin desbordes en 390×844 y 360×640; sin desbordes tampoco en 320 de ancho.
- Mock de autenticación: contraseña `incorrecta` falla, otra acierta.
- Actualizar `TEST-GALERIA` y la galería.

## Archivos permitidos
`lib/funciones/inicio/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**` (modelo/mocks solo para lo indicado), `lib/funciones/bienvenida/galeria_componentes.dart`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
- [ ] El Inicio coincide con Figma 07 y 07b (medidas, colores por tokens, tipografías, Sarko 120×150 en la tarjeta).
- [ ] Datos reales desde sesión y repositorios (nada fijo salvo el reto diario).
- [ ] Navegación: tarjetas, "Continuar sprint", Buzón y pestañas llegan a sus rutas; bloqueado no responde.
- [ ] Cargando, error con reintento y sin desbordes a 200 % de texto y 320 dp de ancho.
- [ ] Mock de autenticación rechaza `incorrecta`.
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI en verde.
- [ ] Grafo actualizado (nodos de código: PANT-07 con su ruta, CODIGO-PANT-07, EST-INICIO, COMP-AVATAR, COMP-HEROE, COMP-RETO, COMP-MODULO, COMP-BUZON, TEST-INICIO; cambios en ENRUTADOR, RUTAS, PANT-PENDIENTE, TEXTOS, MOCK-AUTH, PANT-GALERIA y SESION) y `reporte.md` con ID **T-04**, rama `04-inicio`, dudas numeradas (D1, D2…).
- [ ] Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisar con `git log -1 --format=%B`). Pull Request hacia `develop`, sin menciones a Claude. No hacer merge.
