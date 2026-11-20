# T-10 · Tienda y Perfil y progreso

**Rama:** `10-tienda-perfil-ajustes` (ya creada desde `develop`; el nombre se conserva aunque los ajustes pasaron a la T-10b)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-10**).
**Pantallas:** 24 Tienda y 25 Perfil y progreso. Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 24 = `18:2347`, 25 = `18:2492`. Compara en Chrome con el conector. **Los ajustes (26), el modo oscuro forzado y sus efectos son la T-10b**: aquí solo se deja el camino hacia ellos.

## Objetivo
Dos pestañas de la navegación inferior con datos reales de los repositorios: en la Tienda se pueden **comprar** comodines (y "Congelar racha") con monedas; en el Perfil se ven los datos y logros de la persona, se cierra sesión y se llega a los ajustes.

## Reglas
- Las monedas y las compras **las manda el servidor**; la app nunca calcula un saldo por su cuenta. Comprar **necesita conexión** (`conexionProvider`): sin conexión, los botones de precio quedan deshabilitados y se muestra el aviso "Necesitas conexión para comprar." (`AvisoConexion` no; usa una nota `fondoSuperficieAlt` igual a la de RN03, encima del catálogo).
- Máximo **9** unidades de cada artículo. Con 9, el botón dice "Máximo" y queda deshabilitado.
- Los comodines solo funcionan en lecciones normales; en el Examen Final están bloqueados (RN03). Esa nota va al final de la Tienda, como en Figma.
- "Congelar racha" **no es un comodín** (no se usa en el juego): se compra y queda en el inventario; el servidor lo gasta solo si un día no se juega (T-14). Aquí solo se guarda la cantidad.

## Datos
### Tienda
- `ArticuloTienda.comodin` pasa a `Comodin?` (nulo = Congelar racha). Ids estables: `lupa`, `abogado`, `amparo`, `congelar-racha`. Ajusta los usos existentes.
- **Precios y textos de Figma** (reemplazan los del mock): Lupa de Auditor **60**, Abogado Senior **90**, Amparo / Fianza **120**, Congelar racha **100**. Descripciones: "Resalta en amarillo las palabras trampa del caso.", "Traduce el caso al artículo o licencia exacta.", "Escudo: tu próximo error no te quita vida.", "Protege tu racha si no juegas un día." Actualiza lo que dependa de ellos (pruebas, panel del Abogado, galería, textos).
- `RepositorioTienda.comprarArticulo(String articuloId)` → `ResultadoCompra{articulo, cantidadNueva, monedasRestantes}`. Lanza `ExcepcionTienda` con un `motivo` (`monedasInsuficientes`, `maximoAlcanzado`, `articuloInexistente`); el mock valida las tres.
- `RepositorioTienda.obtenerCongeladoresRacha()` → `int`. El mock empieza con **0**.
- El inventario de Figma (Lupa ×2, Abogado ×1, Amparo ×1) coincide con el mock.
- Tras una compra se invalidan los proveedores que leen monedas o comodines (Inicio, Mapa, `datosJuegoProvider`, el de la propia Tienda). Que el juego en curso no se rompa: solo se recargan al entrar.

### Perfil
- Nuevo `RepositorioPerfil.obtenerPerfil()` → `ResumenPerfil{usuario, precision (0–100), certificados, certificadosTotales, sprintsPerfectos, insignias}`; `Insignia{id, nombre, icono, moduloId (solo para el color), desbloqueada}`. Interfaz en `lib/datos/repositorios/`, `MockPerfil` en `mocks/`, proveedor en `proveedores_repositorios.dart` (único sitio donde se elige la implementación).
- Mock para Ana López: precisión 82, certificados 0 de 5, sprints perfectos 12; insignias "Guardián de datos" (`shield-check`, módulo Protección de datos), "Racha de 7" (`flame`, módulo Licencias), "Sprint perfecto" (`star`, módulo Contratos digitales) y "Abogado de código" (bloqueada, `lock`). Usa `ColoresModulo` para los colores, no hex nuevos.
- Racha, nivel, XP y nombre vienen de `Usuario` (mock: 7, 4, 1250). El XP se formatea con separador de miles ("1,250"; Figma dice "1,240", es solo un dato de ejemplo). Sin sesión, las rutas Tienda y Perfil redirigen a `Rutas.inicioSesion`, como el Buzón.

## 24 · Tienda (marco 390×844, pestaña "Tienda", dentro de `MarcoPrincipal`)
Columna desplazable, relleno horizontal 24, `fondoApp`; navegación inferior de 84 abajo.
- **Encabezado** (y=58): "Tienda" Fredoka Bold 26/32 `textoPrimario` a la izquierda y a la derecha la **píldora de saldo** (279,58): `fondoDestacado`, radio 999, relleno izq. 12 / der. 16 / vert. 8, separación 8, moneda de 22 (la misma del chip HUD) y el saldo en Fredoka SemiBold 17/22. Se lee "Tienes 240 monedas".
- **"Tu inventario"** (H2, Fredoka SemiBold 20/26, y=110) y debajo (y=144) una fila `Wrap` con separación 8 de píldoras: `fondoSuperficie`, borde 1 `bordeDefault`, radio 999, relleno izq. 10 / der. 12 / vert. 8, separación 6, ícono 16 y Etiqueta 12: "Lupa ×2" (`search`), "Abogado ×1" (`briefcase`), "Amparo ×1" (`shield-check`). Siempre las tres (aun con ×0); una cuarta, "Congelar racha ×N" (`snowflake`), solo si N > 0. Se leen "Lupa de Auditor, 2 en inventario".
- **"Comodines"** (H2, y=196) y el **catálogo** (y=232, ancho 342): `Wrap` de 2 columnas, separación 12; las tarjetas de una fila miden lo mismo de alto.
- **Tarjeta de artículo** (ancho 165): `fondoSuperficie`, borde 1 `bordeDefault`, radio 22, sombra (0, 8, 12, 14 %) como las demás, relleno 16, separación 10.
  - Cuadro de ícono 52, `fondoDestacado`, radio 16, ícono 28 (`search`, `briefcase`, `shield-check`, `snowflake`).
  - Nombre: Fredoka SemiBold 17/22 ("Lupa de Auditor", "Abogado Senior", "Amparo / Fianza", "Congelar racha").
  - Descripción: Leyenda `textoSecundario`.
  - **Botón de precio** (alto 48, radio 12, `accionPrimaria`): moneda de 18 + precio en Fredoka SemiBold 16 `textoEnPrimario`. Deshabilitado (sin saldo, sin conexión o en máximo): `fondoSuperficieAlt`, texto `textoSecundario`; con saldo insuficiente aparece bajo el botón la Leyenda "Te faltan N" (`textoSecundario`); en máximo el botón dice "Máximo".
  - Etiqueta semántica del botón: "Comprar Lupa de Auditor por 60 monedas" / "…, te faltan 20 monedas" / "…, máximo alcanzado".
- **Nota RN03** (al final del contenido; en Figma y=692): `fondoSuperficieAlt`, radio 16, relleno 14×12, separación 10, ícono `info` de 20 y Leyenda "Los comodines solo funcionan en lecciones normales. En el Examen Final están bloqueados (RN03)." Deja 24 de aire antes de la navegación inferior.

### Flujo de compra
1. Tocar el precio abre un **diálogo de confirmación** (`showDialog`; `fondoSuperficie`, radio 22, relleno 24): título "¿Comprar {nombre}?" (Fredoka SemiBold 20), texto "Cuesta {precio} monedas. Te quedarían {saldo − precio}." y dos botones: primario "Comprar" y fantasma "Cancelar" (alto 48). Esc o tocar fuera cancelan. El foco inicial va al título.
2. Al confirmar: botón en estado de carga (sin doble toque); se llama a `comprarArticulo`; vibración ligera (ignorar en web); se refrescan saldo e inventario y un `SnackBar` en región en vivo dice "Compraste {nombre}. Ahora tienes {N}. Te quedan {M} monedas."
3. Errores: `monedasInsuficientes` / `maximoAlcanzado` (el saldo cambió desde el servidor): refresca los datos y avisa con `SnackBar` ("Ya no te alcanzan las monedas." / "Ya tienes el máximo."); cualquier otro: "No se pudo completar la compra. Inténtalo de nuevo." y no cambia nada.
- Estados de la pantalla: esqueleto mientras carga; error con `MensajePantalla` y "Reintentar".

## 25 · Perfil y progreso (marco 390×844, pestaña "Perfil")
Columna desplazable, relleno horizontal 24.
- **Encabezado** (y=54): "Mi perfil" Fredoka Bold 26/32 y a la derecha el botón de ajustes (322,54; 48×48): `fondoSuperficie`, borde 1 `bordeDefault`, radio 12, ícono `settings` de 20; etiqueta "Accesibilidad y ajustes"; va a `Rutas.ajustes`.
- **Tarjeta de perfil** (y=112, ancho 342): `accionPrimaria`, radio 22, relleno 16, separación 14. Avatar de 60, `fondoDestacado`, con las iniciales (primera letra de las dos primeras palabras del nombre, en mayúsculas: "AL") en Fredoka SemiBold 20 `accionSecundaria`; a su lado el nombre (Fredoka SemiBold 20, `textoEnPrimario`) y "Desarrollador · Nivel 4 · 1,250 XP" (Leyenda `textoEnPrimario`). El rol usa los textos de `Textos` del registro (`perfilDesarrollador`, etc.); Figma dice "Desarrolladora" porque es el ejemplo de Ana: anota en el reporte que seguimos los textos neutros del registro.
- **Estadísticas** (y=214): `Wrap` de 2 columnas, separación 10, tarjetas de 166: `fondoSuperficie`, borde 1 `bordeDefault`, radio 16, relleno 14×12, separación 10, ícono de 22, valor Fredoka SemiBold 17 y Leyenda `textoSecundario`: "7 días / Racha actual" (`flame`), "82 % / Precisión" (`check`), "0 / 5 / Certificados" (`trophy`), "12 / Sprints perfectos" (`star`). Cada una se lee como un bloque ("Racha actual: 7 días").
- **"Insignias"** (H2, y=366) y la fila (y=402), separación 8, cada una de ancho 79 y centrada: medalla circular de 60, borde 3 `accionAcento`, fondo del color del módulo y ícono blanco de 26; debajo el nombre en Leyenda centrada (máximo dos líneas). **Bloqueada:** fondo `fondoSuperficieAlt`, borde `bordeDefault`, ícono `lock` y nombre en `textoSecundario`. Se leen "Guardián de datos, obtenida" / "Abogado de código, bloqueada". Si no caben en 342, la fila se desplaza en horizontal (sin barra visible), nunca se corta ni se encoge la medalla.
- **Menú** (y=520, ancho 342): `fondoSuperficie`, borde 1 `bordeDefault`, radio 18, filas de relleno 16×14, separación 12, ícono de 20, texto Cuerpo/Énfasis, chevron `chevron-right` de 18, separadas por divisores de 1 `bordeDefault` (sin borde doble al final; Figma lo repite abajo: anótalo). Filas, todas con alto ≥ 48:
  - "Accesibilidad" (`accessibility`) → `Rutas.ajustes`.
  - "Notificaciones de racha" (`bell`) → `Rutas.notificacionesRacha` (nueva, `/perfil/notificaciones`).
  - "Aviso de privacidad" (`doc`) → `Rutas.avisoPrivacidad` (si ya existe una ruta del aviso del registro, reúsala; si no, `/perfil/aviso-privacidad`).
  - "Cerrar sesión" (`logout`), texto e ícono en `estadoIlegal`.
- **Destinos aún sin pantalla** (ajustes → T-10b; notificaciones y aviso → faltan en Figma): usa `PantallaPendiente` con textos propios en `Textos` ("Ajustes de accesibilidad · llega en T-10b", "Notificaciones de racha · pantalla pendiente de diseño", "Aviso de privacidad · pantalla pendiente de diseño"). Quita `pendienteTienda` y `pendientePerfil`. La ruta `Rutas.ajustes` queda hija de `perfil` y **sin** navegación inferior.

### Cerrar sesión
- Diálogo igual al de compra: "¿Cerrar sesión?" / "Tus datos de la cuenta quedan guardados en el servidor." (y si `respuestasPendientesProvider` > 0, añade "Tienes N respuestas guardadas en este dispositivo; se enviarán cuando vuelvas a entrar.") / "Cerrar sesión" (primario, `estadoIlegal` no: usa `accionPrimaria`) y "Cancelar".
- Al confirmar: `repositorioAutenticacion.cerrarSesion()`, `sesionProvider.cerrar()`, se invalidan los proveedores que guardan datos de la persona (Inicio, Mapa, Buzón, Tienda, Perfil, juego, sesión de apelaciones, vidas…; identifícalos y lístalos en el reporte) y `go(Rutas.inicioSesion)`. **No** se borra la cola local de respuestas ni el onboarding visto.
- Si falla, `SnackBar` "No se pudo cerrar la sesión. Inténtalo de nuevo." y se queda.

## Accesibilidad
- Orden de foco: título → saldo → inventario → catálogo (cada tarjeta: botón de precio) → nota; en el Perfil: título → ajustes → tarjeta → estadísticas → insignias → menú.
- Títulos como encabezados semánticos; saldo, inventario, estadísticas e insignias como bloques con etiqueta completa; íconos decorativos sin etiqueta; todo objetivo táctil ≥ 48 dp.
- Nada depende solo del color: lo bloqueado lleva `lock` y la palabra "bloqueada"; lo no comprable lleva texto ("Te faltan 20", "Máximo").
- Contrastes AA verificados con pruebas: `textoEnPrimario` sobre `accionPrimaria`, `textoSecundario` sobre `fondoSuperficieAlt`, `estadoIlegal` sobre `fondoSuperficie` (fila "Cerrar sesión"), ícono blanco sobre cada color de módulo, en claro y oscuro.
- Texto al 200 % sin desbordes en 390×844, 360×640 y 320×640.

## Archivos permitidos
`lib/datos/` (tienda: interfaz, mock y modelos —`resultado_compra.dart`, `excepcion_tienda.dart`—; perfil: modelos `resumen_perfil.dart` e `insignia.dart`, `repositorio_perfil.dart`, `mock_perfil.dart`; `proveedores_repositorios.dart`), `lib/app/enrutador.dart` y `rutas.dart`, `lib/funciones/tienda/` y `lib/funciones/perfil/` (pantallas, estado y lógica), `lib/funciones/acceso/` solo para cerrar sesión, `lib/componentes/` (nuevos: píldora de saldo, píldora de inventario, tarjeta de artículo, botón de precio, tarjeta de perfil, tarjeta de estadística, medalla de insignia, fila de menú, diálogo de confirmación), proveedores de otras funciones solo para invalidarlos, `lib/core/textos/textos.dart`, `lib/core/tema/efectos.dart` e `iconos_app.dart` si falta `snowflake`, `chevron-right` u otro, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **Sin dependencias nuevas.** No toques `modo_tema.dart` ni la base local: es de la T-10b.

## Pruebas
- **Mock de tienda:** compra suma al inventario y resta monedas; sin saldo, en máximo (9) y con id inexistente lanzan `ExcepcionTienda` con su motivo y no cambian nada; Congelar racha cuenta aparte; precios y textos nuevos.
- **Mock de perfil:** datos del resumen; iniciales (una palabra, dos, tres, con acentos y espacios de más); formato del XP.
- **Pantalla 24:** estructura y medidas de Figma (claro y oscuro); inventario con ×0 y la píldora de Congelar racha solo con N > 0; botones habilitados, sin saldo ("Te faltan N"), en máximo y sin conexión (con su nota); diálogo (cancelar, Esc, confirmar), carga sin doble toque, saldo e inventario actualizados, anuncio, errores (saldo cambiado, máximo, genérico); Inicio y el juego ven el nuevo saldo y las nuevas cantidades; sin sesión redirige.
- **Pantalla 25:** estructura y medidas de Figma (claro y oscuro); insignias desbloqueadas y bloqueada, desplazamiento horizontal si no caben; las cuatro filas del menú navegan a su destino; el botón de ajustes va a `Rutas.ajustes` sin navegación inferior; rol, nivel y XP; cerrar sesión (con y sin pendientes, cancelar, éxito invalida los proveedores y va al inicio de sesión, error); sin sesión redirige.
- **Navegación:** las pestañas Tienda y Perfil conservan la barra inferior y la pestaña activa correcta; atrás desde ajustes vuelve al Perfil.
- Texto al 200 % y tamaños pequeños sin desbordes; contrastes; semántica de bloques; orden de foco.
- Las 840 pruebas previas siguen verdes (ajusta las que dependían de los precios 50/80/120 o de los marcadores).

## Criterios de aceptación
- [ ] 24 y 25 coinciden con Figma; las decisiones que no vienen de Figma (confirmación, máximo 9, sin conexión, Congelar racha como artículo, destinos pendientes, cierre de sesión, rol neutro, divisor final del menú) quedan en el reporte.
- [ ] Comprar descuenta monedas y suma al inventario, con confirmación y anuncio; Inicio y el juego reflejan el cambio; las compras imposibles se rechazan con aviso.
- [ ] El Perfil muestra los datos del repositorio y cierra sesión sin dejar datos de la persona en los proveedores.
- [ ] Ya no quedan los marcadores `pendienteTienda` y `pendientePerfil`; los destinos sin diseño usan `PantallaPendiente` con textos propios.
- [ ] Sin dependencias nuevas; análisis, formato y pruebas en verde; commits sin prefijo y sin menciones a Claude.
