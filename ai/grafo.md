# Grafo de conocimiento · AboGator Frontend

Mapa navegable del proyecto: qué existe, dónde está y con qué se relaciona. **Se actualiza cada vez que se crea, mueve, renombra o elimina algo** (reglas en `ai/conocimiento/06-grafo-de-conocimiento.md`). Si algo de aquí no coincide con la realidad, el grafo está mal y hay que corregirlo.

Última actualización: 2026-11-19 · por Claude Code · tarea: T-04b

## Cómo leerlo
- Cada fila es un **nodo** con un ID único. La columna **Relaciones** son las **aristas**: `→` apunta a otro nodo, con un verbo corto (`usa`, `muestra`, `navega a`, `implementa`, `depende de`, `define`).
- **Estado**: `planeado` · `en curso` · `hecho` (ya mergeado a `develop`) · `obsoleto`.
- **Ruta**: ruta real en el repo. `—` si aún no existe.
- Para encontrar algo: buscar su ID o nombre en este archivo y seguir las aristas.

## Vista general
```mermaid
flowchart LR
  FIGMA[Figma: diseño] --> DOC[ai/conocimiento]
  DOC --> TAREAS[Tareas T-00..T-14]
  TAREAS --> CODIGO[lib/: tema, datos, funciones, componentes]
  CODIGO --> MOCKS[Repositorios mock]
  MOCKS -.T-14.-> API[Backend: otro equipo]
  TAREAS --> PANT[46 pantallas]
```

## 1 · Documentos del flujo (los mantiene Claude Chat)
| ID | Nombre | Ruta | Estado | Relaciones |
|---|---|---|---|---|
| DOC-00 | Proyecto | ai/conocimiento/00-proyecto.md | hecho | → define alcance; → EXT-FIGMA |
| DOC-01 | Flujo de trabajo | ai/conocimiento/01-flujo-de-trabajo.md | hecho | → define ramas y ciclo; → GRAFO |
| DOC-02 | Diseño: tokens | ai/conocimiento/02-diseno-tokens.md | hecho | → define TEMA |
| DOC-03 | Pantallas | ai/conocimiento/03-pantallas.md | hecho | → lista PANT-* |
| DOC-04 | Plan de tareas | ai/conocimiento/04-plan-de-tareas.md | hecho | → lista T-* |
| DOC-05 | Reglas y seguridad | ai/conocimiento/05-reglas-y-seguridad.md | hecho | → aplica a todo el código |
| DOC-06 | Reglas del grafo | ai/conocimiento/06-grafo-de-conocimiento.md | hecho | → define GRAFO |
| DOC-07 | Especificación de componentes | ai/conocimiento/07-componentes.md | hecho | → define COMP-*; ← lo usan T-01 y las tareas de pantallas |
| GRAFO | Este archivo | ai/grafo.md | hecho | ← lo actualizan Claude Chat y Claude Code |
| SIG | Tarea actual (T-04b: Mapa de sprints e Intro del sprint) | ai/siguiente.md | en curso | → apunta a la tarea vigente |
| REP | Reporte | ai/reporte.md | en curso | ← lo escribe Claude Code; → responde a SIG |

## 2 · Externos
| ID | Nombre | Dónde | Relaciones |
|---|---|---|---|
| EXT-FIGMA | Diseño de Figma | fileKey SYNAyUal3xVk4k8SEBEb7f | → fuente de PANT-*, TEMA, COMP-* |
| EXT-BACK | Backend (FastAPI) | repositorio de otros compañeros | ← lo consume REPO-* en T-14 |
| EXT-BD | Base de datos (PostgreSQL) | repositorio de otros compañeros | ← la usa EXT-BACK |
| EXT-ASSETS | Logos, poses de Sarko, íconos y fuentes | Originales de Figma en la computadora del usuario (`Imegenes/Logo-Isotipo/`, fuera de git); copias renombradas en `assets/imagenes/` (FIX-02). Íconos: Lucide. Fuentes: `assets/fuentes/`. Pendiente: reexportar a 3x | → los usan COMP-SARKO, COMP-ICONO, COMP-LOGO y TEMA-TIPO |

## 3 · Tareas
| ID | Rama | Estado | Pantallas / áreas | Depende de |
|---|---|---|---|---|
| T-00 | 00-base-del-proyecto | hecho | proyecto Flutter, TEMA, DATOS, RUTAS | — |
| T-01 | 01-componentes-base | hecho | COMP-*, fuentes locales, íconos, imágenes, plataforma web de desarrollo | T-00 |
| T-02 | 02-bienvenida | hecho | PANT-01..04, COMP-VEREDICTO, token estado/escalar | T-01 |
| FIX-02 | fix/02-imagenes-figma | hecho | imágenes de Figma (logos, Sarko, íconos) y Splash con verde de marca | T-02 |
| T-03 | 03-acceso | hecho | PANT-05, PANT-06 | T-01, T-02 |
| T-04 | 04-inicio | hecho | PANT-07, 07b | T-01, T-03 |
| T-04b | 04b-mapa-e-intro | en curso | PANT-08, 09 | T-04 |
| T-05 | 05-tarjeta-swipe | planeado | PANT-10, 11, 11b, 11c, 13 | T-01 |
| T-06 | 06-veredictos | planeado | PANT-12, 12b, 12c, 14, 14b, 19, 19b | T-05 |
| T-07 | 07-evidencia-y-comodines | planeado | PANT-15, 16, 16b, 17, 18, 10b, 10c | T-05 |
| T-08 | 08-vidas-y-offline | planeado | PANT-20, 23 | T-06 |
| T-09 | 09-apelaciones | planeado | PANT-21b, 21, 22, 22b | T-06 |
| T-10 | 10-tienda-perfil-ajustes | planeado | PANT-24, 25, 26, 26b | T-01 |
| T-11 | 11-nivel-jefe | planeado | PANT-27, 28, 28b, 28c, 29, 30 | T-05 |
| T-12 | 12-tablet | planeado | variantes de tablet | T-02..T-11 |
| T-13 | 13-accesibilidad-y-pulido | planeado | todas | T-12 |
| T-14 | 14-integracion-api | planeado | REPO-* → HTTP | EXT-BACK listo |

## 4 · Código (lo mantiene Claude Code)
| ID | Nombre | Ruta | Estado | Relaciones |
|---|---|---|---|---|
| MAIN | Punto de entrada (orientación vertical, ProviderScope) | lib/main.dart | hecho | → arranca APP |
| APP | App y configuración (MaterialApp.router, es_MX, tema claro/oscuro) | lib/app/app.dart | hecho | → usa ENRUTADOR, TEMA, MODO-TEMA, TEXTOS |
| ENRUTADOR | GoRouter (proveedor Riverpod): arranca en `/splash`; `/` redirige al Splash; onboarding, inicio de sesión, registro, Inicio real con el mapa de sprints y la intro **anidados** (la redirección sin sesión cubre los tres), marcadores de juego, Examen final, Buzón, Tienda y Perfil, y `/galeria` solo en debug | lib/app/enrutador.dart | en curso | → usa RUTAS, SESION; → navega a PANT-01..09, PANT-PENDIENTE, PANT-GALERIA; → DEC-RUTAS-ANIDADAS |
| RUTAS | Constantes de rutas de todas las pantallas; tramos anidados `segmentoMapa` y `segmentoIntro`; ayudantes `mapaSprintsDe`, `introSprintDe`, `juegoDe` y `crisisJefeDe` | lib/app/rutas.dart | en curso | → nombra PANT-*; ← lo usan ENRUTADOR y MARCO-PRINCIPAL |
| PANT-PENDIENTE | Marcador temporal de pantallas que llegan en otra tarea: Juego (T-05), Buzón (T-09), Tienda y Perfil (T-10) y Examen final (T-11) | lib/app/pantalla_pendiente.dart | en curso | ← lo usa ENRUTADOR; → se reemplaza por PANT-10, 21, 24, 25 y 27 |
| MARCO-PRINCIPAL | Marco compartido de las pantallas con barra inferior (`MarcoPrincipal`: cuerpo, navegación inferior, Buzón fijo y foco ordenado opcional) y `irAPestana` (Mapa vuelve al Inicio) | lib/app/marco_principal.dart | en curso | → usa COMP-NAV, COMP-BUZON, RUTAS; ← lo usan CODIGO-PANT-07 y CODIGO-PANT-08 |
| TEMA | Tema claro/oscuro y tokens | lib/core/tema/ | hecho | ← define DOC-02; → lo usan todos los COMP-* y PANT-* |
| TEMA-TOKENS | 18 tokens de color (ThemeExtension `TokensColor.claro/oscuro`; T-01 agrega borde/control, estado/condicional y foco/anillo; T-02 agrega estado/escalar) | lib/core/tema/tokens_color.dart | hecho | ← define DOC-02, DOC-07; ← verifica TEST-TEMA |
| TEMA-MARCA | Colores de marca (15) y de módulo (5), solo decorativos | lib/core/tema/colores_marca.dart | hecho | ← define DOC-02; → lo usa MOCK-PROG |
| TEMA-TIPO | 11 estilos de texto (`TipografiaBase`, `EstilosTexto`); tracking 0.2 en Botón, Etiqueta y Leyenda; fuentes locales | lib/core/tema/tipografia.dart | hecho | → usa ASSETS-FUENTES; → DEC-FUENTES; ← verifica TEST-TEMA |
| TEMA-APP | Construcción del `ThemeData` a partir de los tokens | lib/core/tema/tema_app.dart | hecho | → usa TEMA-TOKENS, TEMA-TIPO; ← lo usa APP |
| TEMA-EFECTOS | Efectos que no son tokens: sombras (botón, veredicto, tarjeta de caso, héroe, módulo, Buzón, globo), brillo de barra, elipse del héroe, ícono sobre color de módulo, encabezado del módulo (blancos, pista, relleno `#E0A060`, etiqueta al 85 %, fondo oscurecido por contraste), camino (8, guion 2, hueco 15), pulso al 40 %, bases de los nodos, opacidades y duración con "reducir animaciones" | lib/core/tema/efectos.dart | en curso | → usa UTIL-CONTRASTE; ← lo usan COMP-BOTON, COMP-VEREDICTO, COMP-PROGRESO, COMP-PAGINADOR, COMP-IMPACTO, COMP-HEROE, COMP-MODULO, COMP-BUZON, COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, COMP-CAMINO, COMP-GLOBO-SPRINT, PANT-01, PANT-02..04; → DEC-ENCABEZADO-CONTRASTE, DEC-BASES-NODO |
| TEMA-ICONOS | Catálogo `IconosApp` (45 nombres de Figma → Lucide, más eyeOff) | lib/core/tema/iconos_app.dart | hecho | → usa DEP-LUCIDE; ← lo usan COMP-ICONO y los COMP-* |
| MODO-TEMA | Proveedor del modo claro/oscuro (sigue al sistema; se fuerza en T-10) | lib/core/tema/modo_tema.dart | hecho | ← lo usan APP y PANT-GALERIA; → lo usará PANT-26 |
| TEXTOS | Textos centralizados (componentes, galería, Splash, onboarding, acceso, Inicio con nombres cortos y tramos de módulos, mapa de sprints, intro del sprint con singular/plural, validaciones y marcadores) | lib/core/textos/textos.dart | en curso | → los usan las pantallas, VALIDADORES, LOGICA-INICIO, LOGICA-MAPA y MOCK-* |
| UTIL | Extensiones de contexto (`context.tokens`, `context.estilos`) | lib/core/utilidades/extensiones_contexto.dart | hecho | → usa TEMA-TOKENS, TEMA-TIPO |
| UTIL-CONTRASTE | Cálculo de contraste WCAG 2.1 | lib/core/utilidades/contraste.dart | hecho | ← lo usa TEST-TEMA |
| RECURSOS | Rutas de las imágenes (`ImagenesApp`): `logo(FormaLogo, TonoLogo)`, piezas base, poses de Sarko e íconos de app; enums `FormaLogo` (con medidas en px) y `TonoLogo` | lib/core/recursos/imagenes_app.dart | hecho | → apunta a ASSETS-LOGOS, ASSETS-SARKO, ASSETS-ICONO-APP; ← lo usan COMP-SARKO, COMP-LOGO, CODIGO-PANT-01, PANT-GALERIA |
| MOD | Modelos de datos (Usuario, Modulo, Sprint, Tarjeta, EstadoStartup, Vidas, Apelacion, ArticuloTienda). Desde T-04b, `Sprint` tiene objetivo, tarjetas normales / con evidencia / dilemas, monedas máximas, minutos estimados y estrellas; `numeroTarjetas` es la suma | lib/datos/modelos/ | en curso | → los usan REPO-* |
| REPO-* | Interfaces de repositorio (auth, progreso, tarjetas, vidas, apelaciones, tienda) | lib/datos/repositorios/ | hecho | → implementan MOCK-*; en T-14 → HTTP |
| REPO-AUTH | Autenticación (inicio de sesión, registro con dos consentimientos) | lib/datos/repositorios/repositorio_autenticacion.dart | hecho | → usa MOD; ← implementa MOCK-AUTH; → servirá a PANT-05, PANT-06 |
| REPO-PROG | Progreso: módulos, sprints y estado de la Startup | lib/datos/repositorios/repositorio_progreso.dart | hecho | → usa MOD; ← implementa MOCK-PROG; → servirá a PANT-07..09 |
| REPO-TARJ | Tarjetas de un sprint | lib/datos/repositorios/repositorio_tarjetas.dart | hecho | → usa MOD; ← implementa MOCK-TARJ; → servirá a PANT-10..19b |
| REPO-VIDAS | Vidas (regeneración del servidor) | lib/datos/repositorios/repositorio_vidas.dart | hecho | → usa MOD; ← implementa MOCK-VIDAS; → servirá a PANT-20 |
| REPO-APEL | Apelaciones pendientes | lib/datos/repositorios/repositorio_apelaciones.dart | hecho | → usa MOD; ← implementa MOCK-APEL; → servirá a PANT-21..22b |
| REPO-TIENDA | Tienda de comodines y monedas | lib/datos/repositorios/repositorio_tienda.dart | hecho | → usa MOD; ← implementa MOCK-TIENDA; → servirá a PANT-24 |
| REPO-ONBOARDING | Estado "onboarding visto" (`fueVisto`, `marcarVisto`) | lib/datos/repositorios/repositorio_onboarding.dart | hecho | ← implementa MEM-ONBOARDING; ← lo usa FLUJO-BIENVENIDA; en T-08 → SQLite |
| PROV-REPO | Proveedores Riverpod: único lugar donde se elige mock o HTTP (T-02 agrega el de onboarding) | lib/datos/repositorios/proveedores_repositorios.dart | hecho | → expone REPO-*; → hoy usa MOCK-* y MEM-ONBOARDING; en T-14 → HTTP |
| MOCK-* | Repositorios simulados; desde T-04b `esperar` no crea temporizador con espera cero | lib/datos/mocks/ | en curso | → implementan REPO-* |
| MOCK-AUTH | Autenticación simulada: usuario demo Ana López (Dev, nivel 4, racha 7); rechaza registro sin ambos consentimientos y la contraseña `incorrecta` | lib/datos/mocks/mock_autenticacion.dart | en curso | → implementa REPO-AUTH; → usa TEXTOS |
| MOCK-PROG | 5 módulos de 5 sprints más el Examen final (6 nodos); módulo 1 como Figma (Datos personales y Consentimiento completados con 3 estrellas, Aviso de privacidad en curso con 10 tarjetas, Derechos ARCO, Brechas de seguridad, Auditoría de inversores); los demás bloqueados | lib/datos/mocks/mock_progreso.dart | en curso | → implementa REPO-PROG; → usa TEMA-MARCA |
| MOCK-TARJ | Tarjetas de ejemplo (incluye "Librería GPL en app cerrada") | lib/datos/mocks/mock_tarjetas.dart | hecho | → implementa REPO-TARJ |
| MOCK-VIDAS | Vidas (5 de 5 por defecto, cantidad configurable) con hora del servidor simulada si faltan | lib/datos/mocks/mock_vidas.dart | en curso | → implementa REPO-VIDAS |
| MOCK-APEL | Seis apelaciones pendientes (como el contador de Figma) | lib/datos/mocks/mock_apelaciones.dart | hecho | → implementa REPO-APEL |
| MOCK-TIENDA | Los tres comodines y 240 monedas | lib/datos/mocks/mock_tienda.dart | en curso | → implementa REPO-TIENDA |
| MEM-ONBOARDING | Implementación en memoria del estado "onboarding visto" (dura mientras la app está abierta) | lib/datos/mocks/onboarding_en_memoria.dart | hecho | → implementa REPO-ONBOARDING |
| PANT-PRUEBA | Pantalla temporal "Tema de prueba" (eliminada en T-01; la reemplaza PANT-GALERIA) | — | obsoleto | → reemplazada por PANT-GALERIA |
| PANT-GALERIA | Galería temporal de componentes (todos los tipos y estados, claro/oscuro; 20 logos, 4 poses, componentes de acceso, del Inicio y del mapa: 2 encabezados, 4 nodos y estrellas parciales, globo y filas de detalle); ruta `/galeria` solo en debug; se elimina con las pantallas reales | lib/funciones/bienvenida/galeria_componentes.dart | en curso | → usa COMP-*, RECURSOS, MODO-TEMA, TEXTOS, TEMA-ICONOS; ← verifica TEST-GALERIA |
| FLUJO-BIENVENIDA | Reglas del flujo Splash → Onboarding → Inicio de sesión (destino tras el Splash, terminar onboarding) | lib/funciones/bienvenida/flujo_bienvenida.dart | hecho | → usa REPO-ONBOARDING, RUTAS; ← lo usan PANT-01 y PANT-02..04 |
| CODIGO-PANT-01 | Pantalla 01 Splash (logo vertical sobre verde real a 323.7×187.9, lema, puntos de carga, avance a los 2 s; colores de marca fijos en ambos modos) | lib/funciones/bienvenida/pantalla_splash.dart | hecho | → implementa PANT-01; → usa COMP-LOGO, RECURSOS, FLUJO-BIENVENIDA, TEMA-EFECTOS; → DEC-SPLASH-MARCA |
| CODIGO-PANT-02..04 | Pantallas 02, 03, 03b y 04 Onboarding (un `PageView`, Omitir, paginador y botón) | lib/funciones/bienvenida/pantalla_onboarding.dart | hecho | → implementa PANT-02, PANT-03, PANT-03b, PANT-04; → usa COMP-BOTON, COMP-PAGINADOR, COMP-FOCO, FLUJO-BIENVENIDA, ILUS-ONBOARDING |
| ILUS-ONBOARDING | Ilustraciones decorativas del onboarding (lienzo 390×400, miniatura de tarjeta de caso) | lib/funciones/bienvenida/ilustraciones_onboarding.dart | hecho | → usa COMP-SARKO, COMP-VEREDICTO, COMP-INDICADORES, COMP-CORAZON, COMP-CHIP |
| FUNC | Carpetas por área (bienvenida, acceso, inicio, mapa, juego, apelaciones, tienda, perfil, jefe) | lib/funciones/ | en curso | → contienen PANT-* (bienvenida, acceso, inicio y mapa ya implementadas) |
| VALIDADORES | Validaciones puras de acceso: nombre (2–60), correo (formato, ≤ 254), contraseña de inicio (no vacía) y de registro (≥ 8 con un número), perfil y consentimientos | lib/funciones/acceso/validadores.dart | hecho | → usa TEXTOS; ← lo usan EST-INICIO-SESION y EST-REGISTRO; ← verifica TEST-ACCESO |
| SESION | Proveedor de sesión (`sesionProvider`, `Usuario?`); nunca guarda credenciales | lib/funciones/acceso/sesion.dart | hecho | → usa MOD; ← lo llenan EST-INICIO-SESION y EST-REGISTRO; ← lo usan CODIGO-PANT-07 y ENRUTADOR |
| EST-INICIO-SESION | Estado y envío del inicio de sesión (errores por campo, error del repositorio, cargando); no guarda la contraseña | lib/funciones/acceso/estado_inicio_sesion.dart | hecho | → usa REPO-AUTH (vía PROV-REPO), VALIDADORES, SESION |
| EST-REGISTRO | Estado y envío del registro (perfil sin selección inicial, dos consentimientos independientes, errores por campo, primer error para el foco) | lib/funciones/acceso/estado_registro.dart | hecho | → usa REPO-AUTH (vía PROV-REPO), VALIDADORES, SESION |
| AVISO-ERROR | Error general anunciado (`AvisoError`) y aviso breve no bloqueante (`mostrarAvisoBreve`) | lib/funciones/acceso/aviso_error.dart | hecho | ← lo usan CODIGO-PANT-05 y CODIGO-PANT-06 |
| CODIGO-PANT-05 | Pantalla 05 Inicio de sesión | lib/funciones/acceso/pantalla_inicio_sesion.dart | hecho | → implementa PANT-05; → usa EST-INICIO-SESION, COMP-LOGO, COMP-SARKO, COMP-CAMPO, COMP-ENLACE, COMP-BOTON, AVISO-ERROR |
| CODIGO-PANT-06 | Pantalla 06 Registro | lib/funciones/acceso/pantalla_registro.dart | hecho | → implementa PANT-06; → usa EST-REGISTRO, COMP-ATRAS, COMP-CHIP-SEL, COMP-CAMPO, COMP-CASILLA, COMP-ENLACE, COMP-BOTON, AVISO-ERROR |
| LOGICA-INICIO | Reglas puras del Inicio: iniciales, primer nombre, perfil corto, estado de módulo, sprints normales y total sin el Examen final, completados, módulo/sprint actual, nombre corto, tramo e ícono por número; reto diario fijo | lib/funciones/inicio/logica_inicio.dart | en curso | → usa MOD, TEXTOS, TEMA-ICONOS, COMP-MODULO (enum `EstadoModulo`); ← lo usa LOGICA-MAPA; ← verifica TEST-INICIO |
| EST-INICIO | Carga en paralelo de módulos, monedas, vidas y apelaciones pendientes (`datosInicioProvider`); reintento con `invalidate` | lib/funciones/inicio/estado_inicio.dart | hecho | → usa REPO-PROG, REPO-TIENDA, REPO-VIDAS, REPO-APEL (vía PROV-REPO) |
| CODIGO-PANT-07 | Pantalla 07 Inicio (07b por tema): encabezado, héroe, reto, módulos; Buzón y pestañas con MARCO-PRINCIPAL; esqueleto, error con reintento | lib/funciones/inicio/pantalla_inicio.dart | en curso | → implementa PANT-07, PANT-07b; → usa EST-INICIO, LOGICA-INICIO, SESION, MARCO-PRINCIPAL, COMP-MENSAJE, COMP-AVATAR, COMP-CHIP, COMP-HEROE, COMP-RETO, COMP-MODULO |
| LOGICA-MAPA | Reglas puras del mapa y la intro: zigzag 50/28/50/72 %, lado de la etiqueta, sprint actual, número sin el Examen final, Examen disponible solo con todo completado, qué nodos abren, tipo de nodo, semántica con estrellas, búsqueda por id y desglose de tarjetas | lib/funciones/mapa/logica_mapa.dart | en curso | → usa MOD, TEXTOS, LOGICA-INICIO, COMP-NODO-SPRINT (enum `TipoNodoSprint`); ← verifica TEST-MAPA |
| EST-MAPA | Carga en paralelo de módulos, vidas y apelaciones pendientes y elige el módulo (`datosModuloProvider`, por id); reintento con `invalidate` | lib/funciones/mapa/estado_mapa.dart | en curso | → usa REPO-PROG, REPO-VIDAS, REPO-APEL (vía PROV-REPO), LOGICA-MAPA; ← lo usan CODIGO-PANT-08 y CODIGO-PANT-09 |
| CODIGO-PANT-08 | Pantalla 08 Mapa de sprints: encabezado fijo, mapa desplazable con nodos, camino medido tras el diseño, etiquetas, globo y Sarko; desplazamiento inicial al sprint actual; foco y lectura ordenados; esqueleto, error con reintento y módulo no encontrado | lib/funciones/mapa/pantalla_mapa_sprints.dart | en curso | → implementa PANT-08; → usa EST-MAPA, LOGICA-MAPA, LOGICA-INICIO, MARCO-PRINCIPAL, COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, COMP-CAMINO, COMP-GLOBO-SPRINT, COMP-SARKO, COMP-MENSAJE; → navega a PANT-09, PANT-PENDIENTE (Examen final) |
| CODIGO-PANT-09 | Pantalla 09 Intro del sprint: Cerrar, vidas, Sarko sobre elipse fondo/destacado, etiqueta, título, objetivo, tarjeta de detalles y "Comenzar sprint" fijo abajo; aviso y botón deshabilitado si está bloqueado; esqueleto, error y no encontrado | lib/funciones/mapa/pantalla_intro_sprint.dart | en curso | → implementa PANT-09; → usa EST-MAPA, LOGICA-MAPA, COMP-CHIP, COMP-SARKO, COMP-FILA-DETALLE, COMP-BOTON, COMP-ACCION, COMP-MENSAJE; → navega a PANT-08, PANT-PENDIENTE (juego) |
| COMP-* | Componentes reutilizables (un archivo por componente) | lib/componentes/ | hecho | ← define DOC-07; → los usan PANT-*; → usan TEMA, TEXTOS |
| COMP-BOTON | `BotonApp`: primario, secundario, acento, peligro, fantasma y deshabilitado; estado presionado; estado de carga (`cargando`, `textoCargando`) desde T-03; alto mínimo configurable (`altoMinimo`, 48 en el globo) desde T-04b | lib/componentes/boton_app.dart | en curso | → usa COMP-FOCO, COMP-ICONO, TEMA-EFECTOS; → DEC-PRESIONADO, DEC-CARGA |
| COMP-CAMPO | `CampoTextoApp`: reposo, foco, error; tipos texto/nombre/correo/contraseña; envío con Enter (`alEnviar`) y pistas de autocompletado desde T-03 | lib/componentes/campo_texto_app.dart | hecho | → usa COMP-FOCO, COMP-ICONO |
| COMP-CHIP | `ChipHud`: vidas, monedas, racha, comodines, amparo | lib/componentes/chip_hud.dart | hecho | → usa COMP-CORAZON, COMP-ICONO |
| COMP-CORAZON | `CorazonVida` y `FilaVidas` (silueta de Lucide dibujada para poder rellenarla) | lib/componentes/corazon_vida.dart | hecho | → usa MOD (Vidas.maximo); ← lo usa COMP-CHIP |
| COMP-INDICADORES | `IndicadoresStartup` y enum `IndicadorStartup` | lib/componentes/indicadores_startup.dart | hecho | → usa MOD (EstadoStartup), COMP-ICONO; → DEC-INDICADORES |
| COMP-IMPACTO | `ImpactoStartup`: chips con signo y color tras un veredicto | lib/componentes/impacto_startup.dart | hecho | → usa COMP-INDICADORES, TEMA-EFECTOS |
| COMP-NAV | `NavegacionInferiorApp`: Mapa, Buzón, Tienda, Perfil | lib/componentes/navegacion_inferior_app.dart | hecho | → usa COMP-FOCO, COMP-ICONO; → navegará a PANT-07, 21, 24, 25; → DEC-ZONA-SEGURA |
| COMP-PROGRESO | `BarraProgreso` con brillo y animación | lib/componentes/barra_progreso.dart | hecho | → usa TEMA-EFECTOS |
| COMP-PAGINADOR | `PaginadorPuntos` | lib/componentes/paginador_puntos.dart | hecho | ← lo usa CODIGO-PANT-02..04 |
| COMP-FOCO | `AnilloFoco`: anillo de 3 en foco/anillo a 2 del control | lib/componentes/anillo_foco.dart | hecho | ← lo usan COMP-BOTON, COMP-CAMPO, COMP-NAV |
| COMP-ICONO | `IconoApp` (decorativo sin etiqueta) | lib/componentes/icono_app.dart | hecho | → usa TEMA-ICONOS |
| COMP-SARKO | `SarkoImagen` y enum `PoseSarko` (alegre, enojado, sorprendido, triste): caja 4:5, `BoxFit.contain` alineado abajo al centro (pies en la misma línea), texto alternativo y marcador | lib/componentes/sarko_imagen.dart | hecho | → usa RECURSOS, ASSETS-SARKO; ← EXT-ASSETS |
| COMP-LOGO | `LogoApp`: PNG de Figma por `forma` (vertical, horizontal, extendido, isotipo) y `tono` (automático: color en claro, negativo en oscuro); alto según la proporción del archivo | lib/componentes/logo_app.dart | hecho | → usa RECURSOS, ASSETS-LOGOS; ← lo usan CODIGO-PANT-01 y PANT-GALERIA |
| COMP-VEREDICTO | `BotonVeredicto`: ilegal, legal, condicional y escalar; decorativo sin `alPresionar`, con anillo de foco y nombre accesible con él | lib/componentes/boton_veredicto.dart | hecho | → usa MOD (Veredicto), COMP-FOCO, COMP-ICONO, TEMA-EFECTOS; ← lo usan ILUS-ONBOARDING y PANT-GALERIA; → lo usará PANT-10 |
| COMP-ACCION | `AccionEnfocable`: base de los controles propios (toque, Enter/Espacio, anillo de foco con teclado, semántica a cargo de quien lo usa) | lib/componentes/accion_enfocable.dart | hecho | → usa COMP-FOCO; ← lo usan COMP-CASILLA, COMP-CHIP-SEL, COMP-ENLACE, COMP-ATRAS |
| COMP-CASILLA | `CasillaApp`: cuadro de 22, texto Leyenda, fila táctil ≥ 48, semántica de casilla y error anunciado | lib/componentes/casilla_app.dart | hecho | → usa COMP-ACCION, COMP-ICONO; ← lo usa CODIGO-PANT-06 |
| COMP-CHIP-SEL | `ChipSeleccion`: chip de selección única (perfil), zona ≥ 48 sin cambiar el aspecto, semántica de opción seleccionada | lib/componentes/chip_seleccion.dart | hecho | → usa COMP-ACCION; ← lo usa CODIGO-PANT-06 |
| COMP-ENLACE | `EnlaceTexto`: Cuerpo/Énfasis en texto/acento, zona ≥ 48, semántica de enlace | lib/componentes/enlace_texto.dart | hecho | → usa COMP-ACCION; ← lo usan CODIGO-PANT-05 y CODIGO-PANT-06 |
| COMP-ATRAS | `BotonAtras`: cuadro de 48 con ícono back, etiqueta "Atrás" | lib/componentes/boton_atras.dart | hecho | → usa COMP-ACCION, COMP-ICONO; ← lo usa CODIGO-PANT-06 |
| COMP-AVATAR | `AvatarApp`: círculo de 44 con iniciales, decorativo | lib/componentes/avatar_app.dart | hecho | ← lo usa CODIGO-PANT-07 |
| COMP-HEROE | `TarjetaHeroeStartup`: 342×168 en accion/primaria, elipse, botón "Continuar sprint" y Sarko 120×150 (oculto con menos de 320 de ancho, D4 de T-04) | lib/componentes/tarjeta_heroe_startup.dart | en curso | → usa COMP-ACCION, COMP-SARKO, COMP-ICONO, TEMA-EFECTOS; ← lo usa CODIGO-PANT-07 |
| COMP-RETO | `TarjetaRetoDiario`: 342×60 en fondo/destacado, solo presentación | lib/componentes/tarjeta_reto_diario.dart | hecho | → usa COMP-ICONO; ← lo usa CODIGO-PANT-07 |
| COMP-MODULO | `TarjetaModulo` y enum `EstadoModulo`: en curso, disponible, completado y bloqueado (sin acción) | lib/componentes/tarjeta_modulo.dart | hecho | → usa COMP-ACCION, COMP-ICONO, TEMA-EFECTOS; ← lo usa CODIGO-PANT-07; → navega a PANT-08 |
| COMP-BUZON | `BotonBuzon`: 60×60 en accion/secundaria con contador de pendientes | lib/componentes/boton_buzon.dart | hecho | → usa COMP-ACCION, COMP-ICONO, TEMA-EFECTOS; ← lo usa MARCO-PRINCIPAL; → navega a PANT-21 |
| COMP-ENCABEZADO-MODULO | `EncabezadoModulo`: color del módulo (oscurecido si no alcanza 4.5:1), atrás blanco al 18 %, etiqueta, tramo en H2 blanco, chip de vidas y barra de avance n/total; 48 de barra de estado (o la zona segura, si es mayor) + 102 | lib/componentes/encabezado_modulo.dart | en curso | → usa COMP-ACCION, COMP-CHIP, COMP-ICONO, TEMA-EFECTOS; ← lo usan CODIGO-PANT-08 y PANT-GALERIA; → DEC-ENCABEZADO-ALTO, DEC-ENCABEZADO-CONTRASTE |
| COMP-NODO-SPRINT | `NodoSprint` y enum `TipoNodoSprint` (completado, actual, bloqueado, jefe): cara sobre base, pulso y estrellas (`EstrellasSprint`, `PintorEstrella`); sin acción no responde ni recibe foco y se anuncia deshabilitado | lib/componentes/nodo_sprint.dart | en curso | → usa COMP-ACCION, COMP-ICONO, TEMA-EFECTOS; ← lo usan CODIGO-PANT-08, LOGICA-MAPA y PANT-GALERIA; → DEC-BASES-NODO |
| COMP-CAMINO | `CaminoSprints` (`PintorCamino`): línea punteada de 8 en borde/default que une los centros de los nodos; decorativa | lib/componentes/camino_sprints.dart | en curso | → usa TEMA-EFECTOS; ← lo usa CODIGO-PANT-08 |
| COMP-GLOBO-SPRINT | `GloboSprintActual`: fondo/superficie, radio 16, sombra elevada, título, detalle y botón acento "Comenzar" 170×48 | lib/componentes/globo_sprint_actual.dart | en curso | → usa COMP-BOTON, TEMA-EFECTOS; ← lo usan CODIGO-PANT-08 y PANT-GALERIA |
| COMP-FILA-DETALLE | `FilaDetalleSprint` (ícono 22 en accion/primaria, título y texto; se lee como bloque) y `TarjetaDetallesSprint` (342, borde 1, radio 18) | lib/componentes/fila_detalle_sprint.dart | en curso | → usa COMP-ICONO; ← lo usan CODIGO-PANT-09 y PANT-GALERIA |
| COMP-MENSAJE | `MensajePantalla`: mensaje anunciado con botón secundario (error con "Reintentar", no encontrado con "Volver") | lib/componentes/mensaje_pantalla.dart | en curso | → usa COMP-BOTON; ← lo usan CODIGO-PANT-07, CODIGO-PANT-08 y CODIGO-PANT-09 |
| ASSETS-IMG | Imágenes de la app en subcarpetas (cada una declarada en `pubspec.yaml`); los provisionales de T-01 se eliminaron | assets/imagenes/ | hecho | ← EXT-ASSETS; → contiene ASSETS-LOGOS, ASSETS-SARKO, ASSETS-ICONO-APP |
| ASSETS-LOGOS | 20 logos (4 formas × 5 tonos, ≈ 1x) y 2 piezas base de alta resolución | assets/imagenes/logos/ | hecho | ← lo usa COMP-LOGO vía RECURSOS |
| ASSETS-SARKO | 4 poses de Sarko sin texto incrustado (alegre 432×432; enojado 269×312; sorprendido 256×283; triste 216×283) | assets/imagenes/sarko/ | hecho | ← lo usa COMP-SARKO vía RECURSOS |
| ASSETS-ICONO-APP | Ícono de la app en 180, 120, 64 y 40 px (falta 1024 para las tiendas) | assets/imagenes/icono_app/ | hecho | → servirá para generar los íconos de Android/iOS |
| ASSETS-FUENTES | Fredoka (600, 700), Inter (400–700), JetBrains Mono (400) y licencias OFL | assets/fuentes/ | hecho | ← EXT-ASSETS; ← lo usa TEMA-TIPO |
| TEST-TEMA | Pruebas del tema (hex de los 18 tokens, contraste de los tokens nuevos, 11 estilos y tracking) | test/core/tema/ | hecho | → verifican TEMA-TOKENS, TEMA-TIPO; → usa UTIL-CONTRASTE |
| TEST-PRUEBA | Prueba de la pantalla de prueba (eliminada en T-01 junto con PANT-PRUEBA) | — | obsoleto | → reemplazada por TEST-GALERIA |
| TEST-GALERIA | Galería (se abre en `/galeria`): todos los componentes (20 logos, acceso, Inicio y mapa), claro/oscuro, navegación y texto al 200 % sin desbordes | test/funciones/bienvenida/galeria_componentes_test.dart | en curso | → verifica PANT-GALERIA, APP, MODO-TEMA |
| TEST-BIENVENIDA | Splash y onboarding: logo sobre verde real, verde de marca también en oscuro, destino a los 2 s (al inicio de sesión real desde T-03), onboarding visto, 4 páginas, Omitir, ¡Comenzar!, foco, semántica, texto al 200 % en 390×844 y 360×640 | test/funciones/bienvenida/bienvenida_test.dart | hecho | → verifica CODIGO-PANT-01, CODIGO-PANT-02..04, FLUJO-BIENVENIDA |
| TEST-ACCESO | Validadores, inicio de sesión (errores, carga, éxito, error del repositorio, Enter, aviso de recuperación, orden de foco) y registro (perfil sin selección, casillas independientes, foco al primer error, datos recortados, regreso); contraseña fuera de la semántica; texto al 200 % en 390×844 y 360×640 | test/funciones/acceso/ | hecho | → verifica VALIDADORES, EST-INICIO-SESION, EST-REGISTRO, CODIGO-PANT-05, CODIGO-PANT-06 |
| TEST-INICIO | Lógica del Inicio (incluye el Examen final fuera del progreso) y pantalla: datos de la sesión, 4 secciones, estados de los 5 módulos, Continuar abre la intro, tarjetas abren el mapa (bloqueada no navega), Buzón fijo y sin tapar la última tarjeta, pestañas, esqueleto, error con reintento, sin sesión, orden de foco y sin desbordes (390×844 y 360×640 al 200 %, 320×640 al 100 % y 200 %) | test/funciones/inicio/ | en curso | → verifica LOGICA-INICIO, EST-INICIO, CODIGO-PANT-07 |
| TEST-MAPA | Lógica del mapa y pantallas 08 y 09: encabezado y 2/5, 6 nodos y estados, zigzag y separaciones de Figma, etiquetas, globo, camino por los centros, desplazamiento inicial, navegación (actual/completado abren la intro; bloqueados y Examen bloqueado no; Examen con todo completado), atrás y Cerrar con y sin pila, pestañas, cargando/error/no encontrado, sin sesión, semántica, orden de foco y sin desbordes (390×844 al 100 % y 200 %, 360×640 al 200 %, 320×640 al 100 % y 200 %, claro y oscuro) | test/funciones/mapa/ | en curso | → verifica LOGICA-MAPA, EST-MAPA, CODIGO-PANT-08, CODIGO-PANT-09, MARCO-PRINCIPAL; → usa TEST-AYUDA |
| TEST-COMP | Pruebas de cada componente (incluye acceso, Inicio con Sarko oculto < 320, y mapa: encabezado con contraste sobre los 5 colores, nodo en 4 estados con bases de Figma, estrellas, camino, globo y filas): claro y oscuro, estados, semántica, foco con teclado y solo colores del tema; rutas e imágenes | test/componentes/ | en curso | → verifican COMP-*, RECURSOS, ASSETS-IMG; → usa TEST-AYUDA |
| TEST-AYUDA | Ayudantes de pruebas: montar en claro/oscuro y comprobar que solo se usan colores del tema (incluye las bases de los nodos), y crear sprints y módulos de prueba | test/ayudantes/montar.dart, test/ayudantes/datos.dart | en curso | ← lo usan TEST-COMP, TEST-INICIO, TEST-MAPA |
| TEST-DATOS | Pruebas de los mocks (contraseña `incorrecta`, 5 sprints + Examen final con los títulos y datos de Figma, Ana López, 5 vidas y 240 monedas, 6 apelaciones) y de la sustitución de proveedores | test/datos/mocks_test.dart | en curso | → verifican MOCK-*, PROV-REPO |
| CI | Flujo de integración continua (pub get, formato, analyze, test; Flutter 3.50.0) | .github/workflows/ci.yml | hecho | → ejecuta TEST-*; → usa CONF |
| CONF | Configuración del proyecto (dependencias, assets por subcarpeta y fuentes, reglas de análisis, formato a 100 columnas, saltos de línea LF; `Imegenes/` ignorada) | pubspec.yaml, analysis_options.yaml, .gitattributes, .gitignore | hecho | → define DEP-*; ← lo usa CI |
| PLAT | Proyectos nativos generados por `flutter create` (mx.abogator.abogator) | android/, ios/ | hecho | ← arranca MAIN |
| PLAT-WEB | Plataforma web solo para desarrollo (ver PANT-GALERIA en Chrome); fuera del alcance del producto | web/ | hecho | ← arranca MAIN |
| DEP-RIVERPOD | flutter_riverpod 3.5.0 (estado e inyección de repositorios) | pubspec.yaml | hecho | ← lo usan APP, MODO-TEMA, PROV-REPO |
| DEP-GOROUTER | go_router 18.1.4 | pubspec.yaml | hecho | ← lo usa ENRUTADOR |
| DEP-LUCIDE | lucide_icons_flutter 4.0.3 (íconos estilo Lucide) | pubspec.yaml | hecho | ← lo usa TEMA-ICONOS |
| DEP-MATERIAL-UI | material_ui 1.x (reemplaza a `package:flutter/material.dart`, obsoleto en Flutter 3.50) | pubspec.yaml | hecho | ← lo usa todo lib/; → DEC-MATERIAL-UI |
| DEC-FUENTES | Decisión: en T-00 se usó google_fonts; **en T-01 se quitó y se usan .ttf locales en assets/fuentes/** (la app funciona sin conexión) | lib/core/tema/tipografia.dart, assets/fuentes/ | hecho | → usa ASSETS-FUENTES |
| DEC-MATERIAL-UI | Decisión: importar `package:material_ui/material_ui.dart` porque `flutter/material.dart` está obsoleto (reporte T-00, D2) | — | hecho | → DEP-MATERIAL-UI |
| DEC-PRESIONADO | Decisión: el botón presionado baja 2 dp y su sombra pasa de 4 a 2; sin transición con "reducir animaciones" (reporte T-01) | lib/componentes/boton_app.dart | hecho | ← COMP-BOTON |
| DEC-ZONA-SEGURA | Decisión: la navegación inferior mide 58 + la zona segura del sistema (`SafeArea`), no 26 fijos (reporte T-01) | lib/componentes/navegacion_inferior_app.dart | hecho | ← COMP-NAV |
| DEC-INDICADORES | Decisión: columnas de ancho intrínseco en un `Wrap`; con texto grande o pantallas angostas pasan a dos filas en vez de cortar palabras (reporte T-01) | lib/componentes/indicadores_startup.dart | hecho | ← COMP-INDICADORES |
| DEC-SPLASH-MARCA | Decisión (Chat, D2 de T-02): el Splash usa siempre verde bosque `TokensColor.claro.accionPrimaria`, puntos en blanco y textos en `fondo/destacado` claros, también en modo oscuro (FIX-02) | lib/funciones/bienvenida/pantalla_splash.dart | hecho | ← CODIGO-PANT-01 |
| DEC-CARGA | Decisión: el botón en carga conserva los colores de su tipo (no el gris de deshabilitado), no responde y muestra un indicador de progreso; el lector anuncia el texto de carga (T-03) | lib/componentes/boton_app.dart | hecho | ← COMP-BOTON |
| DEC-INICIO-NOMBRES | Decisión: nombres cortos y tramos de módulos en `Textos` por número de módulo (sin campo nuevo en el modelo) (T-04) | lib/core/textos/textos.dart | hecho | ← LOGICA-INICIO |
| DEC-INICIO-ENCABEZADO | Decisión: con texto ≥ 130 % o menos de 300 dp útiles, los chips del encabezado bajan a una segunda fila (T-04) | lib/funciones/inicio/pantalla_inicio.dart | hecho | ← CODIGO-PANT-07 |
| DEC-RUTAS-ANIDADAS | Decisión: mapa (`modulo/:moduloId`) e intro (`sprint/:sprintId`) cuelgan del Inicio; así "atrás" y "Cerrar" usan `pop` y la redirección sin sesión aplica a las tres (T-04b) | lib/app/enrutador.dart | en curso | ← ENRUTADOR |
| DEC-ENCABEZADO-CONTRASTE | Decisión: el fondo del encabezado se oscurece lo mínimo (pasos de 2 % hacia negro) hasta que el blanco y la etiqueta lleguen a 4.5:1; solo cambian los módulos 2 (ámbar) y 5 (turquesa) (T-04b) | lib/core/tema/efectos.dart | en curso | ← COMP-ENCABEZADO-MODULO |
| DEC-ENCABEZADO-ALTO | Decisión: el encabezado mide 48 (o la zona segura, si es mayor) + 102, para que en un teléfono con barra de estado de ≈ 48 mida 150 como en Figma (T-04b) | lib/componentes/encabezado_modulo.dart | en curso | ← COMP-ENCABEZADO-MODULO |
| DEC-BASES-NODO | Decisión: las bases de los nodos usan los 4 colores de Figma en claro; en oscuro (sin valores en Figma) son la cara oscurecida un 35 % (T-04b) | lib/core/tema/efectos.dart | en curso | ← COMP-NODO-SPRINT |

## 5 · Pantallas (46, según Figma) y a dónde llevan
Código de cada pantalla: `lib/funciones/<área>/` (— hasta que exista).

| ID | Pantalla | Tarea | Navega a |
|---|---|---|---|
| PANT-01 | Splash · `lib/funciones/bienvenida/pantalla_splash.dart` (hecho) | T-02 | 02 (a los 2 s) |
| PANT-02 | Onboarding 1: Sarko se presenta · `lib/funciones/bienvenida/pantalla_onboarding.dart` (hecho) | T-02 | 03 · Omitir → 05 |
| PANT-03 | Onboarding 2: swipe en 4 direcciones · `lib/funciones/bienvenida/pantalla_onboarding.dart` (hecho) | T-02 | 03b · Omitir → 05 |
| PANT-03b | Onboarding 3: indicadores de la Startup · `lib/funciones/bienvenida/pantalla_onboarding.dart` (hecho) | T-02 | 04 · Omitir → 05 |
| PANT-04 | Onboarding 4: vidas y apelaciones · `lib/funciones/bienvenida/pantalla_onboarding.dart` (hecho) | T-02 | 05 |
| PANT-05 | Inicio de sesión · `lib/funciones/acceso/pantalla_inicio_sesion.dart` (hecho) | T-03 | 07 · Crear cuenta → 06 |
| PANT-06 | Registro (dos consentimientos separados) · `lib/funciones/acceso/pantalla_registro.dart` (hecho) | T-03 | 07 · Iniciar sesión → 05 |
| PANT-07 | Inicio: mapa de módulos · `lib/funciones/inicio/pantalla_inicio.dart` (hecho) | T-04 | 08 · pestañas 21, 24, 25 |
| PANT-07b | Inicio en modo oscuro · `lib/funciones/inicio/pantalla_inicio.dart` (hecho) | T-04 | igual que 07 |
| PANT-08 | Mapa de sprints · `lib/funciones/mapa/pantalla_mapa_sprints.dart` (en curso) | T-04b | 09 · nodo Examen final → 27 (solo con los 5 sprints completados) · atrás → 07 |
| PANT-09 | Intro del sprint · `lib/funciones/mapa/pantalla_intro_sprint.dart` (en curso) | T-04b | 10 · Cerrar → 08 |
| PANT-10 | Tarjeta normal | T-05 | 11, 13, 11b, 11c |
| PANT-11 | Arrastrando a Ilegal (←) | T-05 | 12 o 14 |
| PANT-11b | Arrastrando a Condicional (↑) | T-05 | 12, 12c o 14 |
| PANT-11c | Arrastrando a Escalar (↓) | T-05 | 12, 12c o 14 |
| PANT-13 | Arrastrando a Legal (→) | T-05 | 12 o 14 |
| PANT-12 | Veredicto correcto (¿Por qué?) | T-06 | 12b o siguiente tarjeta |
| PANT-12b | Bonus ganado (+5 XP) | T-06 | siguiente tarjeta |
| PANT-12c | Respuesta parcial | T-06 | siguiente tarjeta |
| PANT-14 | Veredicto incorrecto (−1 vida) | T-06 | siguiente · Riesgo 100% → 19b · vidas 0 → 20 |
| PANT-14b | Amparo activado | T-06 | siguiente tarjeta |
| PANT-19 | Sprint completado | T-06 | 08 · Repasar fallos → 21 |
| PANT-19b | Startup en quiebra | T-06 | 09 · buzón → 21 |
| PANT-15 | Tarjeta con evidencia | T-07 | 16 |
| PANT-16 | Inspeccionar evidencia | T-07 | 16b · volver a 15 |
| PANT-16b | Línea subrayada | T-07 | volver y decidir (15) |
| PANT-17 | Tarjeta de justificación | T-07 | 18 |
| PANT-18 | Justificar veredicto | T-07 | 12b |
| PANT-10b | Comodín Lupa de Auditor | T-07 | 10 |
| PANT-10c | Comodín Abogado Senior | T-07 | 10 |
| PANT-20 | Sin vidas (cuenta regresiva del servidor) | T-08 | 21 · volver |
| PANT-23 | Sin conexión (offline-first) | T-08 | tarjeta normal |
| PANT-21b | Notificación de apelación | T-09 | 22 |
| PANT-21 | Buzón de Apelaciones | T-09 | 22 |
| PANT-22 | Juicio de apelación | T-09 | 22b |
| PANT-22b | Apelación ganada (+1 vida) | T-09 | 21 |
| PANT-24 | Tienda | T-10 | pestañas |
| PANT-25 | Perfil y progreso | T-10 | 26 |
| PANT-26 | Ajustes de accesibilidad | T-10 | 25 |
| PANT-26b | Orden de foco por teclado sobre la tarjeta del juego (no es una pantalla aparte; es una especificación) | T-05 y T-13 | — |
| PANT-27 | Crisis: ransomware | T-11 | 28 · ahora no → 08 |
| PANT-28 | Decisión de crisis | T-11 | 28b |
| PANT-28b | Contraargumento del Jefe | T-11 | 28c |
| PANT-28c | Golpe al Jefe (−20 HP) | T-11 | 28 · HP 0 → 29 · 0 vidas o tiempo → 30 |
| PANT-29 | Auditoría superada (certificado) | T-11 | 07 (Módulo 2) |
| PANT-30 | La Inspectora ganó | T-11 | 21 |

## 6 · Conceptos del juego (para saber qué pantallas los tocan)
| ID | Concepto | Pantallas que lo muestran | Reglas |
|---|---|---|---|
| CON-SWIPE | Swipe en 4 direcciones | 03, 10, 11*, 13, 22, 28 | → Legal, ← Ilegal, ↑ Condicional, ↓ Escalar; siempre con botón equivalente |
| CON-VIDAS | Vidas (máx. 5, +1 cada 2 h, tiempo del servidor) | 04, 14, 20, 22b, 30 | — |
| CON-STARTUP | Indicadores (Presupuesto, Reputación, Velocidad, Riesgo legal) | 03b, 10, 12, 14, 19b | Riesgo 100% o sin presupuesto → quiebra |
| CON-APELA | Apelaciones (día 3, 7 y 14) | 21, 21b, 22, 22b | +1 vida al ganar; no avanzan el mapa |
| CON-COMODIN | Comodines (Lupa, Abogado, Amparo) | 10b, 10c, 14b, 24 | Desactivados en el Examen Final (RN03) |
| CON-JEFE | Nivel Jefe de 72 h | 27, 28, 28b, 28c, 29, 30 | 10 decisiones de 15 s (22 s con tiempo extendido) |
| CON-OFFLINE | Modo sin conexión | 23 | Respuestas en SQLite con UUID de cliente |

## Registro de cambios del grafo
- 2026-11-18 · Claude Chat · creación del grafo con documentos, tareas, pantallas y conceptos; código aún sin nodos reales.
- 2026-11-18 · Claude Code · T-00: rutas reales y estado `en curso` para APP, RUTAS, TEMA, TEXTOS, MOD, REPO-*, MOCK-*, TEST-TEMA y CI. Nodos nuevos: MAIN, ENRUTADOR, TEMA-TOKENS, TEMA-MARCA, TEMA-TIPO, TEMA-APP, MODO-TEMA, UTIL, REPO-AUTH/PROG/TARJ/VIDAS/APEL/TIENDA, PROV-REPO, MOCK-AUTH/PROG/TARJ/VIDAS/APEL/TIENDA, PANT-PRUEBA, FUNC, TEST-PRUEBA, TEST-DATOS, CONF, PLAT, DEP-RIVERPOD, DEP-GOROUTER, DEP-MATERIAL-UI, DEC-FUENTES y DEC-MATERIAL-UI. COMP-* y COMP-SARKO siguen sin ruta (`lib/componentes/` solo tiene `.gitkeep` hasta T-01).
- 2026-11-18 · Claude Chat · cierre de T-00: tarea y nodos de código pasan a `hecho` (merge del PR #1). T-01 `en curso`. Nuevo DOC-07 (componentes). EXT-ASSETS y DEC-FUENTES actualizados; PANT-26b aclarada (es orden de foco, no pantalla).
- 2026-11-18 · Claude Code · T-01: `en curso` para APP, ENRUTADOR, TEMA, TEMA-TOKENS (17 tokens), TEMA-TIPO, TEMA-APP, TEXTOS, TEST-TEMA, CONF y DEC-FUENTES (ya sin google_fonts). COMP-* y COMP-SARKO con ruta real. Nodos nuevos: TEMA-EFECTOS, TEMA-ICONOS, UTIL-CONTRASTE, RECURSOS, COMP-BOTON, COMP-CAMPO, COMP-CHIP, COMP-CORAZON, COMP-INDICADORES, COMP-IMPACTO, COMP-NAV, COMP-PROGRESO, COMP-PAGINADOR, COMP-FOCO, COMP-ICONO, COMP-LOGO, ASSETS-IMG, ASSETS-FUENTES, PANT-GALERIA, TEST-GALERIA, TEST-COMP, TEST-AYUDA, PLAT-WEB, DEP-LUCIDE, DEC-PRESIONADO, DEC-ZONA-SEGURA y DEC-INDICADORES. Obsoletos: PANT-PRUEBA y TEST-PRUEBA (archivos eliminados).
- 2026-11-18 · Claude Chat · cierre de T-01: tarea y nodos de código pasan a `hecho` (merge del PR #2). T-02 `en curso` (nuevo COMP-VEREDICTO y token estado/escalar). EXT-ASSETS actualizado; ENRUTADOR anota el cambio de T-02.
- 2026-11-18 · Claude Code · T-02: `en curso` para ENRUTADOR (arranca en el Splash), RUTAS, TEMA-TOKENS (18 tokens, estado/escalar), TEMA-EFECTOS, TEXTOS, PROV-REPO, PANT-GALERIA (ahora en `/galeria`, solo debug), COMP-LOGO (proporciones de Figma), TEST-TEMA, TEST-GALERIA y TEST-COMP. Nodos nuevos: COMP-VEREDICTO, PANT-PENDIENTE, REPO-ONBOARDING, MEM-ONBOARDING, FLUJO-BIENVENIDA, CODIGO-PANT-01, CODIGO-PANT-02..04, ILUS-ONBOARDING y TEST-BIENVENIDA. Ruta del código anotada en PANT-01, PANT-02, PANT-03, PANT-03b y PANT-04. APP y COMP-PAGINADOR sin cambios de código (solo relaciones).
- 2026-11-19 · Claude Chat · cierre de T-02 (PR #3) y planeación de FIX-02: renombrado y orden de logos y poses de Sarko en `assets/imagenes/`; EXT-ASSETS actualizado.
- 2026-11-19 · Claude Code · FIX-02: `en curso` para RECURSOS (forma × tono), COMP-LOGO (PNG de Figma, tono automático), COMP-SARKO (alineado abajo), CODIGO-PANT-01 (logo sobre verde real, verde fijo), PANT-GALERIA, ASSETS-IMG, CONF (`.gitignore`), TEST-COMP, TEST-BIENVENIDA y TEST-GALERIA. Nodos nuevos: ASSETS-LOGOS, ASSETS-SARKO, ASSETS-ICONO-APP y DEC-SPLASH-MARCA. Sin obsoletos (los PNG provisionales de T-01 se eliminaron y no tenían nodo propio).
- 2026-11-19 · Claude Chat · cierre de T-02 y FIX-02 (PR #3 y #4): nodos de código en `hecho`. T-03 `en curso` (nuevos componentes de casilla, chip de perfil y enlace de texto).
- 2026-11-19 · Claude Code · T-03: `en curso` para ENRUTADOR (inicio de sesión y registro reales), RUTAS, PANT-PENDIENTE (ahora solo el Inicio), TEXTOS, COMP-BOTON (carga), COMP-CAMPO (Enter y autocompletado), PANT-GALERIA, FUNC, TEST-COMP, TEST-GALERIA y TEST-BIENVENIDA. Nodos nuevos: COMP-ACCION, COMP-CASILLA, COMP-CHIP-SEL, COMP-ENLACE, COMP-ATRAS, VALIDADORES, SESION, EST-INICIO-SESION, EST-REGISTRO, AVISO-ERROR, CODIGO-PANT-05, CODIGO-PANT-06, TEST-ACCESO y DEC-CARGA. Ruta del código anotada en PANT-05 y PANT-06.
- 2026-11-19 · Claude Chat · cierre de T-03 (PR #5): nodos de código en `hecho`. T-04 se divide: T-04 `04-inicio` (PANT-07, 07b) `en curso` y T-04b `04b-mapa-e-intro` (PANT-08, 09) `planeado`.
- 2026-11-19 · Claude Code · T-04: `en curso` para ENRUTADOR (Inicio real y marcadores), RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, MOCK-AUTH (rechaza `incorrecta`), MOCK-PROG (5×5 sprints), MOCK-APEL (6 pendientes), PANT-GALERIA, SESION, TEST-GALERIA, TEST-COMP y TEST-DATOS. Nodos nuevos: LOGICA-INICIO, EST-INICIO, CODIGO-PANT-07, COMP-AVATAR, COMP-HEROE, COMP-RETO, COMP-MODULO, COMP-BUZON, TEST-INICIO, DEC-INICIO-NOMBRES y DEC-INICIO-ENCABEZADO. Ruta del código anotada en PANT-07 y PANT-07b.
- 2026-11-19 · Claude Chat · cierre de T-04 (PR #6): nodos de código en `hecho`. T-04b `en curso` (Mapa de sprints PANT-08 e Intro del sprint PANT-09).
- 2026-11-19 · Claude Code · T-04b: `en curso` para ENRUTADOR (rutas anidadas, marcadores de juego y Examen final), RUTAS, PANT-PENDIENTE, TEXTOS, TEMA-EFECTOS, MOD (`Sprint` con los datos de la intro), MOCK-* (`esperar` sin temporizador en cero), MOCK-AUTH (Ana López), MOCK-PROG (5 sprints + Examen final), MOCK-VIDAS (5), MOCK-TIENDA (240), FUNC, LOGICA-INICIO (sin el Examen final), CODIGO-PANT-07 (marco compartido), COMP-BOTON (`altoMinimo`), COMP-HEROE (Sarko < 320), PANT-GALERIA, TEST-INICIO, TEST-COMP, TEST-AYUDA, TEST-DATOS y TEST-GALERIA. Solo relaciones: COMP-MODULO y COMP-BUZON. Nodos nuevos: MARCO-PRINCIPAL, LOGICA-MAPA, EST-MAPA, CODIGO-PANT-08, CODIGO-PANT-09, COMP-ENCABEZADO-MODULO, COMP-NODO-SPRINT, COMP-CAMINO, COMP-GLOBO-SPRINT, COMP-FILA-DETALLE, COMP-MENSAJE, TEST-MAPA, DEC-RUTAS-ANIDADAS, DEC-ENCABEZADO-CONTRASTE, DEC-ENCABEZADO-ALTO y DEC-BASES-NODO. Ruta del código anotada en PANT-08 y PANT-09. Sin obsoletos.
