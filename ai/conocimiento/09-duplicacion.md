# 09 · Duplicación: catálogo y plan de la T-15

Resultado de la auditoría de la T-15a (solo análisis; no cambió `lib/` ni `test/`). Lo creó Claude Code; Claude Chat lo revisa y escribe la T-15b con base en los lotes del final.

## Punto de partida (2026-11-21, `develop` en `76c97da`)
| Carpeta | Archivos | Líneas |
|---|---|---|
| `lib/componentes/` | 77 | 10 861 |
| `lib/core/` | 16 | 2 646 |
| `lib/datos/` | 52 | 4 955 |
| `lib/app/` | 6 | 656 |
| `lib/funciones/juego/` | 11 | 3 093 |
| `lib/funciones/jefe/` | 6 | 2 419 |
| `lib/funciones/bienvenida/` | 5 | 2 233 |
| `lib/funciones/acceso/` | 11 | 2 026 |
| `lib/funciones/apelaciones/` | 4 | 1 579 |
| `lib/funciones/mapa/` | 5 | 1 331 |
| `lib/funciones/notificaciones/` | 3 | 912 |
| `lib/funciones/inicio/` | 3 | 711 |
| `lib/funciones/ajustes/` | 3 | 630 |
| `lib/funciones/perfil/` | 3 | 567 |
| `lib/funciones/tienda/` | 3 | 480 |
| `lib/funciones/vidas/` | 1 | 282 |
| `lib/funciones/legal/` | 1 | 142 |
| `lib/main.dart` | 1 | 29 |
| **`lib/` total** | **211** | **35 552** |
| **`test/` total** | **82** | **19 673** |

- **Pruebas:** 3025 al correr (`+3025: All tests passed!`). En el código hay 879 llamadas a `test` o `testWidgets`; las demás salen de los bucles (matriz de la auditoría, tamaños y escalas).
- **20 archivos más largos de `lib/`:**

| Archivo | Líneas |
|---|---|
| `datos/mocks/mock_tarjetas.dart` | 1 429 |
| `funciones/bienvenida/galeria_componentes.dart` | 1 234 |
| `funciones/jefe/pantalla_jefe.dart` | 1 182 |
| `core/textos/textos.dart` | 1 124 |
| `funciones/juego/pantalla_juego.dart` | 873 |
| `funciones/mapa/pantalla_mapa_sprints.dart` | 776 |
| `funciones/apelaciones/pantalla_juicio.dart` | 732 |
| `funciones/apelaciones/pantalla_buzon.dart` | 667 |
| `componentes/piezas_jefe.dart` | 626 |
| `funciones/juego/estado_juego.dart` | 593 |
| `funciones/jefe/pantalla_resultado.dart` | 591 |
| `funciones/juego/mazo_swipe.dart` | 586 |
| `componentes/tarjeta_caso.dart` | 565 |
| `funciones/inicio/pantalla_inicio.dart` | 549 |
| `funciones/ajustes/pantalla_ajustes.dart` | 546 |
| `funciones/bienvenida/pantalla_onboarding.dart` | 506 |
| `funciones/perfil/pantalla_perfil.dart` | 458 |
| `funciones/notificaciones/selector_hora.dart` | 454 |
| `funciones/jefe/estado_examen.dart` | 441 |
| `funciones/notificaciones/pantalla_notificaciones.dart` | 427 |

### Cómo se midió
- **Detector de clones:** ventanas de 6 líneas normalizadas, sin espacios, comentarios, imports ni cierres sueltos, y con los números cambiados por `N`. Las ventanas consecutivas se juntan en tramos. En `lib/funciones` + `lib/componentes` + `lib/app` hay **1 780 líneas** en tramos repetidos; en `test/` hay **828**.
- **Conteos con expresiones regulares** de decoraciones, estilos, `Semantics`, `SnackBar`, hojas, esqueletos y títulos enfocados.
- **Código muerto:** búsqueda de miembros de `Textos`, `Rutas`, clases y funciones sin referencias fuera de su declaración. `flutter analyze` ya está limpio, así que no hay imports sobrantes.
- Las cifras de ahorro son **estimadas**: líneas repetidas menos lo que cuesta el componente nuevo y sus llamadas.

## Hallazgo general
La app ya reutiliza mucho:
- `BotonApp` (67 usos), `CampoTextoApp`, `MensajePantalla` (18), `BloqueLectura`, `AccionEnfocable`, `ColumnaFinSprint` y las composiciones de tablet.
- **No hay botones, campos ni casillas construidos a mano** en las pantallas.
- **No hay colores ni `TextStyle` sueltos:** solo hay `Color(0x…)` en el tema y unos cuantos `0x00000000` transparentes.

La duplicación está en tres sitios:
1. **Piezas visuales pequeñas copiadas:** decoraciones de tarjeta, agarres, píldoras, avisos y esqueletos.
2. **Contenido armado dos veces:** para móvil y para tablet, o para las dos columnas de `ColumnaFinSprint`.
3. **Lógica de pantalla repetida:** el teclado del mazo, las hojas adaptativas y el `switch` de carga, error y datos.

## Catálogo (ordenado por ahorro ÷ riesgo)
El riesgo pesa 1 si es bajo, 2 si es medio y 3 si es alto. Las ubicaciones son `lib/…:línea`.

| # | Patrón | Dónde (mín. 3) | Líneas repetidas | Componente propuesto y API | Riesgo | Pruebas que lo cubren |
|---|---|---|---|---|---|---|
| P-01 | **Esqueletos de carga**: 10 clases con el mismo armazón (función local `bloque(alto, ancho, radio)` con `fondoSuperficieAlt`, `Semantics(label, liveRegion, excludeSemantics)` y un `SingleChildScrollView` sin desplazamiento) | `funciones/inicio/pantalla_inicio.dart:500`, `apelaciones/pantalla_buzon.dart:633`, `apelaciones/pantalla_juicio.dart:698`, `juego/pantalla_juego.dart:836`, `mapa/pantalla_intro_sprint.dart:140`, `mapa/pantalla_mapa_sprints.dart:726`, `perfil/pantalla_perfil.dart:422`, `tienda/pantalla_tienda.dart:360`, `jefe/pantalla_jefe.dart:437`, `componentes/piezas_resultado.dart:134` | 401 en total; **ahorro ≈ 150** | `EsqueletoPantalla({required String etiqueta, required Key clave, EdgeInsets relleno, bool conSafeArea = false, CrossAxisAlignment alineacion, required List<Widget> hijos})` + `BloqueEsqueleto(alto, {ancho, radio = 16})`. Cada pantalla solo pasa su lista de bloques y espacios | bajo: sin estado y con medidas literales que se copian tal cual | claves `esqueleto-*` en las pruebas de cada pantalla; auditoría (escenas de carga) |
| P-02 | **Avisos `SnackBar`**: `ScaffoldMessenger…hideCurrentSnackBar()..showSnackBar(SnackBar(key, content: Semantics(liveRegion: true, child: Text(…))))` | `funciones/apelaciones/pantalla_buzon.dart:121`, `apelaciones/pantalla_juicio.dart:246`, `jefe/pantalla_jefe.dart:152` y `:542`, `jefe/pantalla_resultado.dart:229`, `tienda/pantalla_tienda.dart:132`, `perfil/pantalla_perfil.dart:83`, `ajustes/pantalla_ajustes.dart:62`, `notificaciones/pantalla_notificaciones.dart:89` | 9 × ~9 = 81; **ahorro ≈ 60** | `mostrarAviso(BuildContext context, String texto, {required Key clave})` en `lib/componentes/aviso_breve.dart`. Usa el estilo actual, el del tema; no el de `mostrarAvisoBreve` (ver D2) | bajo | pruebas que buscan `aviso-*` o `error-*` (tienda, perfil, ajustes, examen, buzón, juicio, notificaciones) |
| P-03 | **Color de texto redundante**: `estilos.X.copyWith(color: tokens.textoPrimario)`. Los estilos ya traen `textoPrimario` (`core/tema/tema_app.dart:10`) | 68 usos en 40 archivos (h1 12, h2 13, h3 12, cuerpoEnfasis 15, cuerpoBase 9, leyenda 6 y etiqueta 5); p. ej. `funciones/apelaciones/pantalla_juicio.dart:577`, `componentes/tarjeta_caso.dart`, `componentes/piezas_jefe.dart` | 68 expresiones; **ahorro ≈ 40 líneas** (al reformatear) y menos ruido | Quitar el `copyWith`: `style: estilos.h1`. Sin componente nuevo | bajo: mismo color en claro y oscuro (la prueba de contrastes lo protege) | `contrastes_test`, `tipografia_test`, auditoría |
| P-04 | **Caja de superficie**: `Container(decoration: BoxDecoration(color: fondoSuperficie / fondoSuperficieAlt / fondoDestacado, borderRadius: N, border?: bordeDefault))` | Con borde (18): `componentes/indicadores_startup.dart:72`, `piezas_perfil.dart:105, 260, 304, 348`, `piezas_jefe.dart:603`, `piezas_resultado.dart:217`, `piezas_tienda.dart:79`, `boton_atras.dart:36`, `boton_cerrar.dart:38`, `fila_detalle_sprint.dart:67`, `panel_lateral_juego.dart:134`, `tarjeta_semana.dart:66`, `funciones/apelaciones/pantalla_buzon.dart:176, 355`, `juego/pantalla_sprint_completado.dart:158`, `notificaciones/pantalla_notificaciones.dart:161`. Sin borde (21): `componentes/barra_progreso.dart:50`, `panel_abogado.dart:89`, `panel_veredicto.dart:245, 278`, `piezas_ajustes.dart:120, 355`, `piezas_tienda.dart:253`, `fila_apelacion.dart:156`, `tarjeta_caso.dart:479`, `tarjeta_reto_diario.dart:38`, `funciones/jefe/pantalla_resultado.dart:571`… | 39 × ~6 = 234; **ahorro ≈ 120** | `CajaSuperficie({FondoCaja fondo = FondoCaja.superficie, double radio = 16, bool conBorde = false, EdgeInsets? relleno, double? ancho, double? alto, Clip recorte = Clip.none, Key? clave, required Widget child})` con `enum FondoCaja {superficie, superficieAlt, destacado}` | bajo: solo la decoración; las medidas van por parámetro | auditoría (contraste y desbordes); pruebas que miden tamaños por clave (perfil, buzón, notificaciones y resultados) |
| P-05 | **Tarjeta de lista con divisores**: caja de superficie con borde, `clipBehavior: antiAlias` y `Column` con `if (i > 0) Divider(height: 1, thickness: 1, color: bordeDefault)` | `componentes/piezas_perfil.dart:259`, `funciones/apelaciones/pantalla_buzon.dart:173` y `:352`, `funciones/notificaciones/pantalla_notificaciones.dart:160` | 4 × ~16 = 64; **ahorro ≈ 40** | `TarjetaLista({required List<Widget> filas, double radio = 16, Key? clave})`. Pone los divisores entre filas y usa `CajaSuperficie` | bajo | perfil, buzón (móvil y tablet), notificaciones (filas en x16/x20) |
| P-06 | **Agarre de hoja**: `Center(ExcludeSemantics(Container(key: 'agarre', width: 40, height: 5, BoxDecoration(bordeDefault, radio 3))))` | `componentes/panel_evidencia.dart:51`, `panel_veredicto.dart:148`, `piezas_jefe.dart:477`, `funciones/notificaciones/selector_hora.dart:175` | 4 × ~11 = 44; **ahorro ≈ 30** | `AgarreHoja()` (conserva la clave `agarre`) | bajo | pruebas de paneles y del selector de hora; auditoría |
| P-07 | **Botón cuadrado con ícono**: `AccionEnfocable` + `Semantics(button, label, onTap, excludeSemantics)` + caja de 48 con radio 12, superficie y borde | `componentes/boton_atras.dart:19`, `boton_cerrar.dart:21`, `encabezado_modulo.dart:181`, `funciones/notificaciones/selector_hora.dart:434` | 4 × ~25 = 100; **ahorro ≈ 40** | `BotonIconoCaja({required IconData icono, required String etiqueta, VoidCallback? alPresionar, double lado = 48, double radio = 12, Key? claveCaja})`. `BotonAtras` y `BotonCerrar` quedan como envolturas de una línea para no tocar sus usos | bajo | `riel_navegacion_test`, pruebas de atrás y cerrar en cada pantalla; foco visible (`criterios_test`) |
| P-08 | **Semántica de botón dentro de `AccionEnfocable`**: `semantica: (hijo) => Semantics(button: true, label: …, onTap: alPresionar, excludeSemantics: true, child: hijo)` | 18 con `button: true` (21 archivos usan `semantica:`): `componentes/barra_comodines.dart`, `barra_juego.dart`, `boton_buzon.dart`, `casilla_app.dart`, `chip_seleccion.dart`, `enlace_texto.dart`, `fila_acordeon.dart`, `fila_apelacion.dart`, `opcion_justificacion.dart`, `piezas_ajustes.dart`, `piezas_tienda.dart`, `riel_navegacion.dart`, `tarjeta_caso.dart`, `tarjeta_heroe_startup.dart`, `tarjeta_modulo.dart`… | 18 × ~7 = 126; **ahorro ≈ 90** | Constructor `AccionEnfocable.boton({required String etiqueta, String? valor, bool? seleccionado, …})` que arma esa `Semantics`. Los casos con banderas extra (toggled, checked, expanded) pasan sus banderas por parámetro o se quedan con `semantica:` | medio: cualquier bandera mal copiada cambia lo que lee el lector | auditoría de etiquetas (1 512 combinaciones), `criterios_test`, pruebas `isSemantics` de componentes |
| P-09 | **Esqueleto de carga, error y datos**: `switch (valor) { AsyncData(:final value) => …, AsyncError() => MensajePantalla(texto, Textos.reintentar, ref.invalidate(…)), _ => const _Esqueleto() }` | `funciones/inicio/pantalla_inicio.dart:50`, `apelaciones/pantalla_buzon.dart:70`, `juego/pantalla_juego.dart:76`, `mapa/pantalla_intro_sprint.dart:46`, `mapa/pantalla_mapa_sprints.dart:98`, `perfil/pantalla_perfil.dart:38`, `tienda/pantalla_tienda.dart:61`, `jefe/pantalla_jefe.dart:175` | 8 × ~9 = 72; **ahorro ≈ 30** | `VistaAsincrona<T>({required AsyncValue<T> valor, required Widget Function(T) datos, required Widget esqueleto, required String textoError, required VoidCallback alReintentar})`. Los casos especiales (sin tarjetas, sin conexión, no encontrado) se resuelven dentro de `datos` | bajo | pruebas de error con «Reintentar» de cada pantalla; escenas de error de la auditoría |
| P-10 | **Título de pantalla enfocado**: `BloqueLectura(encabezado: true, autofocus: true, radio: 8, child: Text(…, style: estilos.h1/h2))` | 18 `encabezado: true` (10 con `autofocus`): `funciones/acceso/recuperacion/marco_recuperacion.dart:98` (`TituloRecuperacion`), `juego/piezas_fin_sprint.dart:20` (`TituloFinSprint`), `ajustes/pantalla_ajustes.dart:256`, `apelaciones/pantalla_buzon.dart:93`, `apelaciones/pantalla_juicio.dart:567`, `jefe/pantalla_jefe.dart:263, 335, 972`, `jefe/pantalla_resultado.dart:147`, `juego/pantalla_juego.dart:710`, `notificaciones/pantalla_notificaciones.dart` | ~12 × ~7 = 84; **ahorro ≈ 45** | `TituloEnfocado(String texto, {EstiloTitulo estilo = EstiloTitulo.h1, TextAlign alineacion, bool autofocus = true, Key? clave})`. Une `TituloRecuperacion` y `TituloFinSprint` | bajo-medio: el foco inicial depende de esto | `criterios_test` (foco visible, primer foco), pruebas de «el foco empieza en el título» |
| P-11 | **Contenido doble en `ColumnaFinSprint`**: las mismas piezas (`IlustracionSarko`, `ElementoOrdenado`, estrellas, vidas, títulos) se arman dos veces, en `contenido` y en `contenidoTablet` o `ilustracionTablet` | `funciones/juego/pantalla_sprint_completado.dart:112-207` (47 + 16 líneas repetidas), `juego/pantalla_startup_quiebra.dart:97`, `apelaciones/pantalla_juicio.dart:581-651` (48 + 21) | ~150; **ahorro ≈ 100** | Sin componente nuevo: cada pantalla arma sus piezas una vez, en variables locales, y las pasa a las dos listas. Opcional: `ColumnaFinSprint` recibe `ilustracion` + `cuerpo` y reparte las piezas | medio: el orden de foco (`ElementoOrdenado`) y las escalas de tablet deben quedar igual | `fin_sprint_test`, `resultados_tablet_test`, `juicio_test`, auditoría de juego |
| P-12 | **Hoja o diálogo adaptativo**: en tablet, `showDialog(Dialog(transparente, elevation 0, insetPadding 32, ConstrainedBox(maxWidth)))`; en móvil, `showModalBottomSheet(transparente, velo, isScrollControlled)` | `funciones/ajustes/pantalla_ajustes.dart:76`, `notificaciones/selector_hora.dart:57`, `juego/pantalla_juego.dart:206` (variante con `HojaLateral`) | 3 × ~25 = 75; **ahorro ≈ 35** | `mostrarHojaAdaptativa<T>(BuildContext context, {required double anchoDialogo, required Widget Function(BuildContext, {required bool enDialogo}) constructor})` en `lib/componentes/hoja_adaptativa.dart`. El panel del juego se queda con su `HojaLateral` y solo comparte la rama móvil | medio | `ajustes_test` (selector de tamaño), `notificaciones_test` (hoja o diálogo), auditoría (diálogos) |
| P-13 | **Desplazable con alto mínimo**: `LayoutBuilder → SingleChildScrollView → ConstrainedBox(minHeight: max(0, restricciones.maxHeight − relleno))` | `componentes/disposicion_ilustracion_tablet.dart:72`, `disposicion_resultado_tablet.dart:86`, `riel_navegacion.dart:124`, `funciones/acceso/panel_marca.dart:381`, `acceso/recuperacion/marco_recuperacion.dart:66`, `apelaciones/pantalla_juicio.dart:410`, `bienvenida/pantalla_onboarding.dart:306`, `jefe/pantalla_jefe.dart:881`, `juego/pantalla_juego.dart:628`, `mapa/pantalla_mapa_sprints.dart:679`, `notificaciones/pantalla_notificaciones.dart:286` | 11 × ~10 = 110; **ahorro ≈ 60** | `DesplazableAltoMinimo({EdgeInsets relleno, Key? claveDesplazable, bool alturaIntrinseca = false, bool centrar = false, required Widget child})` | medio: hay que conservar las claves de desplazamiento y no usar medidas intrínsecas con `LayoutBuilder` (error ya visto en T-13b) | pruebas de desplazamiento (`scrollUntilVisible` por clave), auditoría a 200 % |
| P-14 | **Teclado del mazo y envoltura con tinte**: `_alTeclear` (flechas para previsualizar, Enter para confirmar, Esc para cancelar) y `_envolver` (`Focus(autofocus)` + `Stack` con `TinteVeredicto` sobre `ValueListenableBuilder<ArrastreVisible>`) copiados en las tres pantallas con mazo | `funciones/juego/pantalla_juego.dart:372` y `:649`, `jefe/pantalla_jefe.dart:602`, `apelaciones/pantalla_juicio.dart:264` (más los tramos de acciones y foco: juego `:602`, `:650`; jefe `:785`, `:827`; juicio `:354`, `:372`) | 3 × ~45 = 135 (el detector marca 81 + 32 + 29); **ahorro ≈ 100** | `MarcoMazo({required GlobalKey<EstadoMazoSwipe> mazo, required ValueListenable<ArrastreVisible> arrastre, KeyEventResult Function(KeyEvent)? extra, required Widget child})` en `mazo_swipe.dart`. Se queda con el teclado y el tinte; la tecla P del Examen entra por `extra` | alto: teclado y foco del juego, Examen y juicio | `juego_test`, `veredicto_test`, `jefe_test` (tecla P), `juicio_test`, `pulido_test`, auditoría de teclado |
| P-15 | **Examen móvil y tablet**: el pie con «Enfrentar auditoría», el aviso sin conexión y «Ahora no» (`TextButton` 48 en color crisis), y la alerta del jefe, copiados en la vista móvil y en `_CrisisTablet` | `funciones/jefe/pantalla_jefe.dart:353-417` y `:1118-1174` (58 + 18 + 14 líneas repetidas); alerta `:235` y `:298`; además `componentes/piezas_jefe.dart:216` | ~120; **ahorro ≈ 90** | Piezas privadas en `pantalla_jefe.dart` (`_PieEnfrentar`, `_AlertaJefe`) y `BotonTextoApp(texto, color, alPresionar)` si se confirma un tercer uso (ver D5) | alto: el Examen tiene cronómetro y foco propios | `jefe_test`, `examen_tablet_test`, `auditoria_examen_test` |
| P-16 | **Inicio móvil y tablet**: encabezado, `TarjetaRetoDiario`, `TarjetaModulo`, `Semantics` de la sección y tramo actual, armados igual en `_Contenido` y `_ContenidoTablet` | `funciones/inicio/pantalla_inicio.dart:89-128` y `:184-240` (16 + 14 + 20 + 22 líneas repetidas) | ~72; **ahorro ≈ 55** | Métodos o widgets privados (`_SeccionReto`, `_TarjetasModulo`) que usan las dos vistas | medio | `inicio_test`, `inicio_tablet_test`, auditoría de navegación |
| P-17 | **Dos columnas en tablet (Perfil y Ajustes)**: `final Widget cuerpo = dosColumnas ? Row(…) : Column(…)` con el mismo relleno `fromLTRB` | `funciones/ajustes/pantalla_ajustes.dart:401` y `:439`, `perfil/pantalla_perfil.dart:325` y `:359` (más `:252`/`:258` contra `:304`), `apelaciones/pantalla_buzon.dart:205` | ~60; **ahorro ≈ 40** | `DosColumnasTablet({required List<Widget> izquierda, required List<Widget> derecha, required bool dosColumnas, double separacion = 24})` | medio | `cuenta_tablet_test`, `ajustes_test`, auditoría de cuenta |
| P-18 | **Píldoras**: `Container(padding, BoxDecoration(color, borderRadius: 999))` con texto o ícono | `componentes/piezas_tienda.dart:30`, `panel_evidencia.dart:193`, `piezas_apelacion.dart:83`, `piezas_jefe.dart:216`, `funciones/jefe/pantalla_jefe.dart:237` y `:300` (más `PildoraComodin`, `PildoraPlazo` y `PildoraRepaso`) | 6 × ~7 = 42; **ahorro ≈ 30** | `Pildora({required Color fondo, EdgeInsets relleno, required Widget child, Key? clave})` | bajo | pruebas de tienda, evidencia, apelación y Examen; contraste |
| P-19 | **Campos de acceso armados dos veces**: `_campos(estado, notifier)` + botones en la vista móvil y en la de tablet; `CampoTextoApp` de correo igual en Login y Registro; `Scaffold` igual | `funciones/acceso/pantalla_inicio_sesion.dart:136` y `:227`, `:68`; `acceso/pantalla_registro.dart:159`; `Scaffold` en `pantalla_inicio_sesion.dart:184` y `pantalla_registro.dart:258` | ~50; **ahorro ≈ 30** | Una sola lista de hijos por pantalla que reciben `DisposicionAccesoTablet` y la vista móvil; `CampoCorreo` solo si llega a 3 usos (recuperación también pide correo: `pantallas_recuperacion.dart`) | bajo-medio | `inicio_sesion_test`, `registro_test`, `acceso_tablet_test`, `recuperacion_test` |
| P-20 | **Varios repetidos dentro de un mismo archivo**: `FilaVidas` (`funciones/vidas/pantalla_sin_vidas.dart:149` y `:182`), las piezas de `PanelMarca` (`acceso/panel_marca.dart:182` y `:251`), los parámetros de `BarraJuego` contra `BarraJuegoTablet` (`componentes/barra_juego.dart:39` y `:122`), y el confeti (`componentes/confeti_sprint.dart:52` y `:88`) | 4 lugares (2 veces cada uno) | ~80; **ahorro ≈ 45** | Variables locales o una clase de parámetros compartida; sin componente global (menos de 3 usos) | bajo-medio | `sin_vidas_test`, `acceso_tablet_test`, `juego_tablet_test`, `fin_sprint_componentes_test` |

### Pruebas (`test/`)
| # | Patrón | Dónde | Líneas | Ayudante propuesto | Riesgo |
|---|---|---|---|---|---|
| T-01 | **Matriz «sin desbordes»**: el mismo `group('sin desbordes')` con 6 combinaciones (390×844, 360×640 y 320×640, a 1.0 y 2.0) y `textScaleFactorTestValue` | `test/funciones/perfil/perfil_test.dart:386`, `ajustes/ajustes_test.dart:678`, `apelaciones/buzon_test.dart:282`, `apelaciones/juicio_test.dart:368`, `inicio/inicio_test.dart:375`, `juego/comodines_test.dart:428`, `juego/fin_sprint_test.dart:386`, `tienda/tienda_test.dart:352` y uno más | 9 × ~13 = 119; **ahorro ≈ 90** | `probarSinDesbordes(String nombre, Future<void> Function(WidgetTester, Size) abrir, {List<(Size, double)> casos = casosMovil})` en `test/ayudantes/sin_desbordes.dart` | bajo (ver D1) |
| T-02 | **Falsos y datos repetidos**: `ProgresoFalso` (`inicio_test.dart:71`, `mapa_test.dart:53`, idénticos, 32 líneas), `ApelacionesFalsas` y sus listas de `Apelacion(...)` (`inicio_test.dart:102`, `mapa_test.dart:84`, `buzon_test.dart:59`, `sin_vidas_test.dart:45`), `HapticaFalsa` (`ajustes_test.dart:43`, `jefe_test.dart:77`), `CronometroFalso` (`jefe_test.dart:47`, `sin_vidas_test.dart:26`), el usuario `ana` (`inicio_test.dart:39`, `mapa_test.dart:43`, `ayudante_juego.dart:40`) y `tocar` (`buzon_test.dart:99`, `juicio_test.dart:63`, `comodines_test.dart:44`) | ~200; **ahorro ≈ 130** | `test/ayudantes/falsos.dart` (`ProgresoFalso`, `ApelacionesFalsas`, `HapticaFalsa`, `CronometroFalso`) y `test/ayudantes/datos.dart` (usuario `ana` y apelaciones de ejemplo); `tocar` va a `test/ayudantes/montar.dart` | bajo |
| T-03 | **Bloques de tablet repetidos**: el mismo cierre de prueba de tamaño u orientación | `test/funciones/apelaciones/buzon_tablet_test.dart:153`, `jefe/examen_tablet_test.dart:113`, `juego/juego_tablet_test.dart:295`, `juego/resultados_tablet_test.dart:145` | 4 × 8 = 32; **ahorro ≈ 20** | Se suma a `test/ayudantes/tamano_pantalla.dart` | bajo |

## Código muerto
| Qué | Dónde | Líneas | Acción |
|---|---|---|---|
| `PantallaPendiente` (ninguna ruta la usa desde la T-13b) | `lib/app/pantalla_pendiente.dart` | 49 | Borrar el archivo y el nodo PANT-PENDIENTE |
| `mostrarAvisoBreve` (sin uso; otro estilo de `SnackBar`) | `lib/funciones/acceso/aviso_error.dart:41` | 15 | Borrarla, o convertirla en el `mostrarAviso` de P-02 (D2) |
| `Textos.buzonApelaciones` | `lib/core/textos/textos.dart:236` | 1 | **No es muerto** (T-15b): lo usa `buzonSemantica` dentro de `textos.dart` sin el prefijo `Textos.` |
| `Textos.veredictoAnuncio` | `textos.dart:470` | 1 | Borrar |
| `Textos.sinCambios` | `textos.dart:492` | 1 | **No es muerto** (T-15b): lo usa `impactoSemantica` en el mismo archivo |
| `Textos.noSeleccionada` | `textos.dart:500` | 1 | **No es muerto** (T-15b): se usa en el mismo archivo |
| `Textos.noMarcada` y `Textos.lineaClave` | `textos.dart:528` y `:529` | 2 | **No son muertos** (T-15b): se usan en el mismo archivo |
| `Textos.notificacionApelacionPie` | `textos.dart:692` | 1 | Borrar |
| `MedidasAdaptativas.lienzoTablet` | `lib/core/adaptativo/clase_pantalla.dart:58` | 1 | Borrar |
| `Rutas.juicioApelacion` (plantilla documental; el enrutador usa los segmentos) | `lib/app/rutas.dart:53` | 1 | Borrar o dejar como comentario |
| 21 clases públicas que solo usa su propio archivo (`PintorCamino`, `PiezaConfeti`, `PintorCorazon`, `PildoraPlazo`, `EstrellasNodo`, `ChipBonusEvidencia`, `PildoraRepaso`, `AvatarJefe`, `PintorAnillo`, `PintorBordePunteado`, `TarjetaResumenExamen`, `BotonPrecio`, `TextoConTrampas`, `PintorTrampas`, `ChipTipoTarjeta`, `BotonEvidencia`, `AvisoDilema`, `PistaGesto`, `PildoraComodin`…) | `lib/componentes/*` | — | **No son código muerto.** Se pueden volver privadas (`_`) para que la API pública muestre solo lo reutilizable (D4) |
| Imports sobrantes | — | 0 | `flutter analyze` ya está limpio |

`Rutas.mapaSprints`, `introSprint`, `recuperarNueva` y `segmentoNotificaciones` **no** son código muerto: solo se usan dentro de `rutas.dart`, pero para componer las demás rutas.

## Lotes propuestos (T-15b en adelante)
Cada lote es una rama y un PR. Se ordenan de lo seguro y compartido a lo delicado. Las cifras son el ahorro estimado de líneas.

| Lote | Rama | Patrones | Ahorro | Riesgo | Pruebas que lo protegen |
|---|---|---|---|---|---|
| **T-15b** | `15b-limpieza-y-piezas-pequenas` | código muerto, P-03 (color redundante), P-02 (`mostrarAviso`), P-06 (`AgarreHoja`), P-07 (`BotonIconoCaja`), P-18 (`Pildora`) | ≈ 280 | bajo | suite completa; auditoría; pruebas de avisos, atrás y cerrar; contrastes |
| **T-15c** | `15c-superficies-y-estados` | P-04 (`CajaSuperficie`), P-05 (`TarjetaLista`), P-01 (`EsqueletoPantalla`), P-09 (`VistaAsincrona`), P-10 (`TituloEnfocado`) | ≈ 385 | bajo-medio | claves `esqueleto-*`; pruebas de error con «Reintentar»; foco inicial (`criterios_test`); medidas por clave |
| **T-15d** | `15d-ayudantes-de-pruebas` | T-01, T-02, T-03 (solo `test/`; sin tocar `lib/`) | neto ≈ −150 en `test/` (antes ≈ 240); puntos: 9 matrices → 1, 4 falsos duplicados → 1 | bajo | el mismo número de pruebas antes y después (salvo D1) |
| **T-15e** | `15e-marcos-y-disposiciones` | P-08 (`AccionEnfocable.boton`), P-13 (`DesplazableAltoMinimo`), P-12 (`mostrarHojaAdaptativa`), P-17 (`DosColumnasTablet`), P-16 (Inicio), P-19 (Acceso) | neto ≈ −210 (antes ≈ 310): P-08 −75, P-16 −55, P-19 −30, P-13 −25, P-12 −15, P-17 −10; puntos: 18 semánticas → 1, 11 desplazables → 1, 3 hojas → 1 | medio | auditoría completa (etiquetas, desbordes al 200 %); pruebas de tablet de cada área; `ajustes_test` y `notificaciones_test` (hojas) |
| **T-15f** | `15f-fin-de-sprint-examen-y-resumenes` | P-11 (`ColumnaFinSprint`), P-15 (Examen), P-20 | real **−92** (estimado ≈ −235: P-11 −100, P-15 −90, P-20 −45) | medio-alto | `jefe_test`, `examen_tablet_test`, `juicio_test`, `fin_sprint_test`, `resultados_tablet_test`, `sin_vidas_test`, auditoría de juego y de Examen |
| **T-15g** | `15g-marco-del-mazo` | P-14 (`MarcoMazo`), solo | neto ≈ −75; puntos: teclado del mazo 3 → 1 | alto | `juego_test`, `veredicto_test`, `jefe_test` (tecla P), `juicio_test`, `pulido_test`, auditoría de teclado |

- **Total estimado (original):** ≈ 1 310 líneas menos en `lib/` y ≈ 240 en `test/`. **Corregido tras T-15b y T-15c (neto):** T-15b −76 y T-15c −23 (reales); T-15e ≈ −210 y T-15f ≈ −310 (estimados) → ≈ −620 en `lib/` (≈ 1,7 %); T-15d ≈ −150 en `test/`. El beneficio principal de la T-15 son los **puntos de cambio únicos**, más que las líneas.
- La T-15d puede hacerse cuando se quiera, porque no toca `lib/`. Conviene **no** juntarla con un lote de `lib/`, para que un cambio de app nunca coincida con un cambio de las pruebas que lo protegen.
- Si un lote queda grande, se puede partir. P-14 (el mazo) se separó de la T-15f y va sola como T-15g.

## Resultados por lote
| Lote | `lib/` antes | `lib/` después | Diferencia | `test/` antes → después | Pruebas |
|---|---|---|---|---|---|
| T-15b | 35 552 (211 archivos) | 35 476 (214 archivos) | **−76** | 19 673 → 19 832 (+159, pruebas nuevas) | 3025 → 3034 |
| T-15c | 35 476 (214 archivos) | 35 453 (218 archivos) | **−23** | 19 832 → 20 077 (+245, pruebas nuevas) | 3034 → 3045 |
| T-15e | 35 453 (218 archivos) | 35 373 (219 archivos) | **−80** | 20 077 → 20 253 (+176, pruebas nuevas) | 3045 → 3052 |
| T-15e-fix | 35 373 | 35 355 | **−18** | 20 253 → 20 452 (+199, pruebas nuevas) | 3052 → 3309 |
| T-15f | 35 355 (219 archivos) | 35 263 (219 archivos) | **−92** | 20 452 → 20 452 (sin cambios) | 3309 → 3309 |

- **T-15b, desglose:**
  - En los archivos que ya existían se fueron 237 líneas netas: 49 de `pantalla_pendiente.dart`, 17 de `mostrarAvisoBreve`, unas 100 de los botones de caja y los agarres, unas 50 de las 22 píldoras y unas 20 de los avisos.
  - Los cuatro componentes nuevos, con su documentación, suman 161 líneas; la sección de la galería, 24.
- **Corrección a la estimación:** el ahorro esperado (≈ 280) contaba las líneas repetidas, pero no restaba bien el costo de los componentes nuevos. Además, 5 de los 7 «textos sin uso» no lo eran. Para los lotes siguientes, conviene estimar el ahorro **neto**: líneas quitadas menos el componente y su entrada en la galería.

- **T-15c, por patrón** (medido aplicando cada patrón solo sobre el punto de partida; «neto» resta el componente nuevo):

| Patrón | Usos | Archivos existentes | Componente | Neto | Puntos de cambio (antes → después) |
|---|---|---|---|---|---|
| P-01 `EsqueletoPantalla` + `BloqueEsqueleto` | 9 esqueletos + el bloque del certificado | −130 | +68 | **−62** | armazón (región en vivo, sin desplazamiento, bloque gris): 10 → 1 |
| P-04 `CajaSuperficie` | 30 cajas en 23 archivos | −84 | ≈ +60 | **−24** | fondo, radio y borde de las cajas: 30 → 1 |
| P-05 `TarjetaLista` (en `caja_superficie.dart`) | `MenuAgrupado` (8 usos), Buzón ×2 y notificaciones | −43 | ≈ +38 | **−5** | divisores y recorte de las listas: 4 → 1 |
| P-10 `TituloEnfocado` | 12 títulos (11 automáticos y el legal a mano) | −68 | +49 | **−19** | encabezado, foco inicial y radio del anillo: 12 → 1 |
| P-09 `VistaAsincrona` | 7 pantallas | ≈ −8 | +55 | **≈ +47** | mensaje de error con «Reintentar» y política de carga: 7 → 1 |
| Galería y textos | — | +38 | — | **+38** | — |

  - **P-09 aumenta líneas pero se hizo** porque reduce los puntos de cambio de 7 a 1, como permite la regla del lote. Queda como duda D1 del reporte de la T-15c.
  - **Quedaron fuera:**
    - el Examen (`pantalla_jefe`), que tiene un error propio «no disponible»;
    - el juicio, que revisa «sin conexión» antes que los datos y no ofrece «Reintentar»;
    - los paneles del juego (`panel_*`), cuyos títulos llevan etiqueta propia y excluyen los hijos;
    - el resultado del juicio, que tiene `nodoFoco`;
    - las cajas con sombra, degradado, borde de otro color u otro fondo.

- **T-15e, por patrón** (neto = archivos existentes − componente nuevo):

| Patrón | Usos | Archivos existentes | Componente | Neto | Puntos de cambio |
|---|---|---|---|---|---|
| P-08 `AccionEnfocable.boton` | 13 controles (7 iguales y 6 con `enabled`, `selected`, `link` o `expanded`) | −78 | +43 | **−35** | semántica de botón: 13 → 1 |
| P-13 `DesplazableAltoMinimo` | 10 desplazables | −60 | +48 | **−12** | alto mínimo con relleno: 10 → 1 |
| P-16 Inicio (piezas privadas) | héroe, reto, título de la ruta y tarjeta de módulo | −23 | — | **−23** | móvil y tablet: 2 → 1 |
| P-19 Acceso (piezas privadas) | enlace «¿Olvidaste…?», error y los dos botones | −10 | — | **−10** | móvil y tablet: 2 → 1 |

  - **No se hicieron:**
    - **P-12 `mostrarHojaAdaptativa`:** solo 2 usos iguales (Ajustes y el selector de hora). El del juego usa `HojaLateral`, no deja arrastrar y tiene su propia animación.
    - **P-17 `DosColumnasTablet`:** solo Ajustes y Perfil coinciden. Inicio tiene alto mínimo y `spaceBetween` a la derecha, y el Buzón no tiene ese patrón.
    - **`BotonIconoCuadrado` → `BotonIconoCaja`:** su `Semantics` no tiene `onTap`. Pasarlo daría a los lectores de pantalla una acción que hoy no tienen (D1 del reporte de la T-15e).
  - **Quedan con su propia semántica en P-08** (tienen `checked`, `toggled`, grupo excluyente, `container` o no tienen `onTap`): `casilla_app`, `chip_seleccion`, `opcion_justificacion`, `barra_comodines`, `piezas_ajustes` ×3, `piezas_perfil` ×2 y `piezas_tienda`.

- **T-15f, por patrón** (sin componentes nuevos: todo queda en variables locales o widgets privados del mismo archivo, así que el neto es la diferencia de cada archivo):

| Patrón | Dónde | Neto | Puntos de cambio (antes → después) |
|---|---|---|---|
| P-11 Sprint completado | Sarko, estrellas, y título con subtítulo (la separación, 16 en tablet y 4 en móvil, es un parámetro) | **−19** | 3 piezas: 2 → 1 cada una |
| P-11 Startup en quiebra | Sarko triste, etiqueta de la causa y título | **−6** | 3 piezas: 2 → 1 cada una |
| P-11 Juicio (resultado) | Sarko, corazones e insignia de vida | **−18** | 3 piezas: 2 → 1 cada una |
| P-15 Examen (`pantalla_jefe.dart`) | `alerta` (ya existía, el móvil la copiaba), `_ReglasCrisis`, `_TiempoExtendido` y `_PieEnfrentar` (aviso sin conexión, «Enfrentar auditoría» y «Ahora no»); `_CrisisTablet` recibe las piezas armadas | **−36** | alerta, reglas, tiempo extendido y pie: 2 → 1 cada uno |
| P-20 Sin vidas | `FilaVidas` y el Sarko triste | **−13** | 2 piezas: 2 → 1 cada una |
| **Total** | | **−92** | 15 piezas: 30 → 15 |

  - **El ahorro quedó por debajo de lo estimado** (≈ −235). La estimación contaba como repetidas piezas que no lo son: en las tres pantallas de fin de sprint, el contenido del móvil y el de tablet difieren en separaciones y, a veces, en la composición (el estado final de la Startup va en una caja con borde solo en tablet; en la quiebra, las separaciones del móvil son 10, 12, 8, 8 y 30, y las de tablet, 16).
  - **No se tocaron** el cronómetro, el foco propio del Examen, la tecla P ni las políticas de error y sin conexión. `jefe_test` y `examen_tablet_test` pasan sin cambios.
  - **No se hicieron:**
    - **`ColumnaFinSprint(ilustracion, cuerpo)` (la opción de P-11):** el orden y las separaciones de las piezas cambian entre móvil y tablet en las cuatro pantallas, así que `ColumnaFinSprint` no podría repartirlas sola sin una lista de excepciones.
    - **`_AlertaJefe` contra `ChipHoraCrisis` (`piezas_jefe.dart:216`):** no coinciden (relleno 12/6 contra 10-12/5, ícono 16 contra 14, texto flexible solo en la alerta) y son 2 usos.
    - **`BotonTextoApp`:** «Ahora no» sigue con 2 usos, ahora en un solo lugar (`_PieEnfrentar`).
    - **P-20 `PanelMarca` (`panel_marca.dart:184` y `:253`):** el logo y Sarko cambian de ancho, de posición y de contenedor en cada variante; un ayudante privado agregaría más líneas de las que quita (≈ +4).
    - **P-20 `BarraJuego` contra `BarraJuegoTablet`:** la columna del progreso usa otro estilo (Leyenda contra Etiqueta) y otra separación (6 contra 8), y los parámetros compartidos son solo 6 campos; una clase de parámetros o un widget privado agregaría ≈ 8 líneas.
    - **P-20 confeti (`confeti_sprint.dart`):** son coordenadas de Figma. Las `x` de tablet son las del móvil × 1,5, pero las `y` no siguen ninguna regla; derivarlas escondería los valores de Figma sin ahorrar líneas.

## Reglas de toda la T-15
1. **Cero cambios visibles.** Se mantienen las mismas medidas, textos, colores, foco, orden de lectura, semántica y animaciones. La auditoría de `test/auditoria/` debe seguir verde **sin tocar sus escenas**. Las demás pruebas solo cambian si un lote lo autoriza de forma explícita (T-15d).
2. **Dónde van los componentes:** en `lib/componentes/`, con nombre en español, un comentario breve de documentación y una entrada en la galería (`galeria_componentes.dart`). Las funciones y envolturas sin vista propia (`mostrarAviso`, `mostrarHojaAdaptativa`, `VistaAsincrona` y `DesplazableAltoMinimo`) quedan exentas de la galería (D3).
3. **Regla de tres:** un componente nuevo solo se crea si se usa **3 veces o más**. Lo que se repite 2 veces se resuelve dentro del archivo, con variables locales o widgets privados.
4. **Lo que queda sin uso se borra** en el mismo lote, y el grafo se actualiza en cada lote (nodos COMP-* nuevos, obsoletos y registro de cambios).
5. **No se tocan:** las reglas del juego (`estado_*`, `logica_*`), los repositorios (`lib/datos/repositorios/`) ni los mocks (`lib/datos/mocks/`).
6. **Claves estables:** las `ValueKey` que usan las pruebas se conservan. El componente las recibe por parámetro (`clave`) o pone por defecto la misma.
7. **Verificación en cada lote:** `dart format`, `flutter analyze` sin avisos y la suite completa con el mismo número de pruebas o más. En el reporte se anotan las líneas antes y después del lote.
8. **Sin dependencias nuevas.**
