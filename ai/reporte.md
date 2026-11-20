# Reporte
- **Tarea:** T-06b · Fin de sprint (pantallas 19 y 19b)
- **Rama:** `06b-fin-de-sprint`
- **Estado:** terminada y subida, con los ajustes de la revisión. El Pull Request #10 ya existe; no hice merge.

## Ajustes de la revisión
1. **Regla de estrellas (D1):** ahora **≥ 90 % = 3**, ≥ 60 % = 2 y menos = 1 (`LogicaFinSprint.porcentajeTresEstrellas = 90`). Como en Figma 19, 8 de 10 aciertos dan 2 estrellas.
   - Pruebas de lógica: límites 89/90 % y 59/60 %, el caso 8/10 = 2, y en sprints de 8 tarjetas solo 8/8 da 3.
   - Pruebas de pantalla: el sprint de prueba con 4 de 5 aciertos (80 %) ahora muestra y guarda 2 estrellas, y se lee "2 de 3 estrellas".
   - Los sprints 1 y 2 del mock siguen completados con 3 estrellas.
2. **Cifras legales (D5):** quité los plazos y montos con cifra de las tarjetas. En las tres conservé la respuesta correcta y la explicación:
   - `tar-derechos-03` (`spr-1-4`, tarjeta 3): "lleva más de dos meses sin respuesta" ahora dice "lleva semanas sin respuesta y ya venció el plazo legal". La evidencia ya no trae fechas: "Recibida: hace semanas · Plazo legal: vencido".
   - `tar-derechos-02` (`spr-1-4`, tarjeta 2): "¿Cobramos 500 pesos…?" ahora es "¿Cobramos una cuota…?" y la opción incorrecta "Porque 500 pesos es muy poco" ahora es "Porque la cuota es muy baja".
   - `tar-arco-01` (`spr-1-2`, tarjeta 8): "facturas fiscales … de hace dos años" ahora son "facturas fiscales recientes". La cifra dependía del plazo fiscal de conservación.
   - **Revisé las demás cifras de `MockTarjetas` y las dejé:** no son plazos ni montos legales.
     - "15 años" en `tar-aviso-06` es la edad de un menor.
     - "revocado (2 de marzo)" en `tar-consen-05` es la fecha del hecho.
     - "algún día" y "cada día" son expresiones.
     - Las versiones de licencia (GPL-3.0, Apache 2.0) son nombres, no cifras legales.
   - **Prueba nueva:** "ninguna tarjeta menciona plazos ni montos legales con cifra". Revisa texto, explicaciones, evidencia y micro-preguntas. Comprobé que falla con las tarjetas anteriores y que no confunde una edad con un plazo.
3. **Respuestas de Chat sin cambios de código:**
   - D2: la estrella no ganada se queda en contorno.
   - D3: los íconos de las estadísticas se quedan de contorno.
   - D4: el confeti queda como está.
   - D6: "CASO 5" para la GPL está bien.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector (solo lectura): contexto de diseño de 19 (`38:5557`) y 19b (`37:4136`), los SVG del círculo, las estrellas y los íconos, y el contexto de movimiento de 19.
- **Lo que verifiqué en Figma:**
  - **Estrellas:** Figma pinta **2 llenas** (`accion/acento`) y la tercera **rellena en `#E2E8F0`** (`borde/default`), no en contorno. Por la revisión, la regla pasó a 90/60 (8/10 = 2 estrellas, como en Figma) y la estrella no ganada se queda en contorno.
  - **Círculo detrás de Sarko:** sin transparencia. En 19 es `#E8D8A8` (`fondo/destacado`) y en 19b `#F1F5F9` (`fondo/superficie-alt`).
  - **Confeti:** Figma no tiene animación (contexto de movimiento vacío), así que la caída la diseñé yo: 1.2 s, cada pieza un poco después de la anterior, media vuelta y aparición gradual.
  - **Íconos de color:**
    - Estadísticas: check `estado/legal`, star `accion/primaria` y coin `accion/acento`.
    - Avisos: inbox `accion/secundaria` e info `texto/acento`.
    - Etiqueta de quiebra: trending-down `texto/en-primario`.
- **Prueba en el navegador:** compilé la app para web y la probé a 390×844.
  - Jugué el sprint `spr-1-3` completo hasta 19 y pulsé "Continuar al mapa": el Sprint 3 aparece completado con sus estrellas, el 4 en curso, 3/5 sprints y las vidas actualizadas.
  - Quebré por Riesgo legal en la tarjeta de la GPL (19b, en claro y oscuro) y pulsé "Reiniciar sprint": vuelve a la tarjeta 1, con los indicadores del inicio y las vidas perdidas.
  - Las posiciones coinciden con Figma restando la barra de estado de 48: estrellas en 236, aviso en 576 y botones en 700 y 760.

## Qué se hizo
1. **Datos:**
   - `Sprint` tiene ahora `mensajeCompletado`, `mensajeQuiebra` y `copiar`; `Modulo.copiar`; `EstadoStartup` con igualdad; enum `CausaQuiebra` (Riesgo legal o Presupuesto).
   - **Firmas nuevas**, pensadas para el servidor de T-14:
     - `RepositorioProgreso.registrarSprintCompletado({sprintId, estrellas, estadoFinal})`;
     - `RepositorioVidas.guardarVidas(cantidad)`, que devuelve las `Vidas` resultantes porque la regeneración la decide el servidor;
     - `RepositorioTienda.sumarMonedas(cantidad)`, que devuelve el total.
   - **Mocks en memoria:** cada instancia empieza desde los datos iniciales, así que cada prueba crea uno nuevo y empieza de cero.
     - `MockProgreso` marca el sprint completado (conserva el máximo de estrellas), pone en curso el siguiente si estaba bloqueado (el Examen final no cambia) y guarda el estado final de la Startup.
     - `MockVidas` guarda entre 0 y 5 vidas.
     - `MockTienda` suma las monedas.
   - **Tarjetas del módulo 1:** completé `spr-1-1`, `spr-1-2`, `spr-1-4` y `spr-1-5`; la lista está abajo.
   - **GPL:** pasó a ser la tarjeta 5 de `spr-1-3` ("CASO 5 · LICENCIAS OSS") en lugar de la de datos de salud, que también era de evidencia. `spr-2-1` queda solo con la tarjeta MIT.
2. **Lógica pura** (`LogicaFinSprint`):
   - Aciertos y falladas (el parcial no cuenta en ninguno).
   - Estrellas: ≥ 90 % da 3, ≥ 60 % da 2 y si no 1; calculado con enteros, sin decimales.
   - Cambios respecto al inicio del sprint.
   - Aviso del buzón: para 1, 2, y 3 o más falladas.
   - Causa de la quiebra: si se dan las dos, manda el Riesgo legal.
   - Descripción de la quiebra: la del sprint o una genérica según la causa.
3. **Estado del sprint** (`JuegoNotifier`):
   - Se mantiene vivo y guarda el estado inicial, el total de tarjetas, cómo terminó (`fin`) y si ya se guardó.
   - `guardarResultado` corre una sola vez:
     - Sprint completado: registra el progreso y guarda vidas y monedas.
     - Quiebra o sin vidas: solo las vidas.
   - `reiniciarJuego` descarta el estado y sus datos.
   - La pantalla de juego guarda el resultado antes de navegar a 19, 19b o sin vidas.
   - "Comenzar sprint" en la intro reinicia el juego.
4. **Componentes nuevos** (con pruebas y en la galería): `ConfetiSprint`, `EstrellasSprint` (con `PintorEstrella`), `EstadisticasSprint`, `AvisoInformativo` y `EtiquetaQuiebra`.
5. **Pantallas** `PantallaSprintCompletado` (19) y `PantallaStartupQuiebra` (19b), con sus piezas compartidas en `piezas_fin_sprint.dart`:
   - Columna desplazable con los botones al final.
   - Sarko decorativo sobre su círculo.
   - Título que se anuncia y recibe el foco sin anillo.
   - Orden fijo de lectura y de teclado.
   - Si no hay un resultado (recarga o enlace directo): "No hay un resultado que mostrar" con "Volver al mapa" (`MensajePantalla`).
   - "Repasar mis fallos" e "Ir al Buzón de Apelaciones" van a `Rutas.buzon` (marcador hasta T-09).

## Tarjetas nuevas y su base legal
Todas se basan en la LFPDPPP. Cito principios y deberes, no números de artículo, porque la ley se reemplazó en 2025. Tras la revisión, ninguna tarjeta menciona plazos ni montos con cifra.

**`spr-1-1` · Datos personales** (5 normales, 2 con evidencia y 1 dilema):

| Tarjeta | Respuesta | Base |
|---|---|---|
| 1 Nombre y correo | Ilegal | Dato personal es cualquier información de una persona identificada o identificable. |
| 2 Totales por estado (sin nombres) | Legal | Los datos que no permiten identificar a nadie ya no son datos personales. |
| 3 Religión en el perfil (evidencia) | Escalar | Las creencias religiosas son datos sensibles: piden consentimiento expreso y por escrito. |
| 4 Dirección solo para el envío | Legal | Principios de finalidad y proporcionalidad, con la finalidad informada en el aviso. |
| 5 Nombre y correo en registros públicos (evidencia) | Ilegal | Deber de seguridad y de confidencialidad. |
| 6 CURP y estado civil "por si acaso" | Ilegal | Principio de proporcionalidad: solo los datos necesarios. |
| 7 Foto de perfil en anuncios | Condicional | Otra finalidad: vale con el consentimiento del titular para ella. |
| 8 Dilema: expedientes de un hospital | Escalar | Datos de salud (sensibles) recibidos de un tercero: transferencia. |

**`spr-1-2` · Consentimiento:**

| Tarjeta | Respuesta | Base |
|---|---|---|
| 1 Dirección para entregar la compra | Legal | Excepción al consentimiento: datos necesarios para cumplir la relación con el titular. |
| 2 Código usa datos de salud sin consentimiento (evidencia) | Ilegal | Los datos sensibles piden consentimiento expreso. |
| 3 Diario de ánimo con consentimiento tácito | Ilegal | Los datos de salud piden consentimiento expreso y por escrito; el tácito no basta. |
| 4 Vender correos a un aliado (ya existía, `tar-arco-02`) | Ilegal | Transferencia sin informar ni consentir. |
| 5 Encuestas, una finalidad no prevista | Condicional | Una finalidad nueva se informa y se consiente. |
| 6 Boletín a quien revocó (evidencia) | Ilegal | El consentimiento se puede revocar en cualquier momento. |
| 7 "Sí, autorizo" con contraseña para datos de salud | Legal | Consentimiento expreso firmado con un medio de autenticación. |
| 8 Dilema: borrar con facturas (ya existía, `tar-arco-01`) | Condicional | Cancelación con bloqueo de lo que la ley fiscal obliga a conservar. |

**`spr-1-4` · Derechos ARCO:**

| Tarjeta | Respuesta | Base |
|---|---|---|
| 1 Pedir acreditar la identidad | Legal | Para ejercer los derechos ARCO el titular acredita su identidad. |
| 2 Cobrar una cuota | Ilegal | El ejercicio es gratuito; solo se cobran envío o reproducción. |
| 3 Solicitud sin respuesta con el plazo vencido (evidencia) | Ilegal | Hay un plazo legal de respuesta. |
| 4 Corregir un apellido | Legal | Derecho de rectificación. |
| 5 Cancelar con un reembolso en trámite | Condicional | Bloqueo hasta concluir la obligación; después, supresión. |
| 6 "Cancelar" solo ocultando el perfil (evidencia) | Ilegal | Cancelar es bloquear y suprimir. |
| 7 Oponerse a la publicidad y seguir usando la app | Legal | Derecho de oposición a una finalidad. |
| 8 Dilema: abogada con carta simple | Escalar | El representante debe acreditar su representación. |

**`spr-1-5` · Brechas de seguridad:**

| Tarjeta | Respuesta | Base |
|---|---|---|
| 1 Ocultar el acceso no autorizado | Ilegal | Informar a los titulares de vulneraciones que los afecten de forma significativa. |
| 2 Contener primero | Legal | Deber de seguridad y medidas de mitigación. |
| 3 Correo "Hubo un incidente" (evidencia) | Condicional | El aviso debe decir qué pasó, qué datos se afectaron, qué hacer y dónde informarse. |
| 4 Contraseñas en texto plano | Ilegal | Medidas de seguridad técnicas. |
| 5 Bitácora del incidente (evidencia) | Legal | Documentar las vulneraciones y las medidas tomadas. |
| 6 Culpar al proveedor ante la prensa sin pruebas | Escalar | Declaración pública con riesgo legal. |
| 7 La fuga fue del proveedor de nube | Ilegal | El responsable sigue respondiendo aunque trate un encargado. |
| 8 Dilema: rescate del atacante | Escalar | Decisión legal y de autoridades. |

Cada sprint tiene 3 o 4 micro-preguntas. `spr-1-3` conserva sus 4: la de la GPL reemplazó a la de datos de salud. A `tar-arco-01` y `tar-arco-02` les agregué impactos y cambié la etiqueta de `tar-arco-02` a "CASO 4".

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (556 pruebas; antes de T-06b, 474):
```
+556: All tests passed!
```
- **`test/funciones/juego/logica_fin_sprint_test.dart`:**
  - Estrellas (límites 59/60 y 89/90 %, 8/10 = 2, con 8 y 10 tarjetas, total 0), aciertos y falladas, cambios, aviso del buzón y causa y descripción de quiebra.
  - Guardado en los mocks: progreso, máximo de estrellas, Examen final sin cambio, reinicio por instancia, vidas y monedas.
  - Datos: los 5 sprints con su número de tarjetas y su composición, ids únicos, "CASO n" en orden, impactos, evidencia, micro-preguntas, mensajes, la GPL en `spr-1-3` y ninguna tarjeta con plazos o montos legales con cifra.
- **`test/componentes/fin_sprint_componentes_test.dart`** (en claro y oscuro):
  - Medidas y colores de los 5 componentes; estrellas llenas y en contorno; semántica de estrellas, estadísticas, aviso y etiqueta.
  - **Contraste:** etiqueta y textos ≥ 4.5:1; íconos y estrellas ≥ 3:1.
  - Confeti que cae y queda quieto con "reducir animaciones", sin leerse; sin desbordes al 200 % en 342, 312 y 272 de ancho.
- **`test/funciones/juego/fin_sprint_test.dart`:**
  - **19:** sus datos de principio a fin; el estado sobrevive al cambio de pantalla; el resultado se guarda y el mapa y el Inicio lo reflejan; sin falladas no hay aviso ni "Repasar"; las parciales no cuentan; "Repasar" lleva al Buzón.
  - **Foco y anuncio:** título anunciado y con el foco; orden de teclado título → estrellas → estadísticas → estado final → aviso → botones; el recorrido del lector sigue el mismo orden.
  - **19b:** quiebra por Riesgo y por Presupuesto; guarda las vidas y no cambia el progreso; "Reiniciar sprint" empieza desde cero con las vidas perdidas; "Ir al Buzón"; foco y orden de lectura.
  - **Navegación:** sin sprint terminado (las dos rutas y una quiebra en la ruta de completado); "Comenzar sprint" reinicia.
  - **Desbordes:** ninguno en 390×844 y 320×640 al 100 % y 200 %, y en 360×640 al 200 %, en claro y oscuro, con los botones a la vista al final.
- **Ajustes a pruebas anteriores:**
  - Repositorios falsos de progreso con `registrarSprintCompletado`.
  - Destinos de T-05 y T-06: ahora llegan a 19 y 19b reales.
  - GPL leída de `spr-1-3`.
  - "Sprint sin tarjetas" con un mazo vacío.
  - Mapa con `EstrellasNodo` y galería con los componentes nuevos.
  - El ayudante de colores reconoce `PintorEstrella` y el confeti.

## Decisiones
- **Estado vivo** (DEC-JUEGO-VIVO):
  - `juegoProvider` llama a `ref.keepAlive()` y solo se descarta con `reiniciarJuego`, al pulsar "Comenzar sprint" en la intro o "Reiniciar sprint". Así 19 y 19b leen el resultado después de cerrar la pantalla de juego.
  - Salir del juego con "Salir" no lo descarta, pero al volver se entra por "Comenzar", que sí lo hace.
- **Sin parpadeo:** 19 y 19b conservan el último resultado mostrado, para no enseñar "sin resultado" mientras salen tras "Reiniciar sprint".
- **Guardado al salir del juego**, antes de navegar. También guardo las vidas al quedarse sin vidas (pantalla 20); la tarea solo lo pedía en 19 y 19b, pero si no, las vidas volverían.
- **Orden de lectura y foco:** `ElementoOrdenado` (sort key y orden numérico) dentro de un `FocusTraversalGroup` ordenado, porque el título está debajo de las estrellas y el orden visual lo leería después.
- **Recuadros enfocables:** el "Estado final" (texto e indicadores juntos) y los indicadores de 19b son bloques enfocables, como en la pantalla de juego.
- **Sarko decorativo**, como en el panel de T-06: el título dice lo que pasó.
- **Estrella compartida:** ya existía `EstrellasSprint` en el mapa (`nodo_sprint.dart`). La renombré a `EstrellasNodo` y unifiqué su pintor con el nuevo `PintorEstrella` (misma silueta star, ahora rellena o en contorno), para que el nombre de la tarea quedara libre.
- **Mocks con parámetros nombrados privados** (`this._cantidad`, `this._monedas`): la API sigue siendo `cantidad:` y `monedas:`.
- **Ajuste de una prueba por la fuente:** la fuente de las pruebas es más ancha que Fredoka e Inter y en 390×844 el contenido no cabe. Por eso "botones abajo" se mide en una pantalla de 1100 de alto; en el navegador sí coincide con Figma a 844.

## Límites conocidos
- **Mocks en memoria:** el progreso, las vidas y las monedas se pierden al recargar. Lo real lo hará el servidor en T-14 con las mismas firmas.
- **Salir a mitad del sprint** no guarda las vidas perdidas hasta ese momento.
- **Al completar el último sprint** del módulo no se habilita nada nuevo: el Examen final se calcula aparte y el siguiente módulo sigue bloqueado.
- **Falladas:** no llegan aún al Buzón (T-09); el aviso solo lo anuncia.
- **Monedas en 19:** suman 5 por acierto y no tienen tope; `monedasMaximas` del sprint no se usa todavía.

## Grafo actualizado
- **Lo que toqué:** la sección 4 (Código), las filas PANT-19 y PANT-19b (sección 5, con su ruta), la línea "Última actualización" y el registro de cambios. Comprobé que existen todas las rutas de `lib/` y `test/` del grafo.
- **Cambiados (`en curso`):**
  - App y textos: ENRUTADOR, PANT-PENDIENTE, TEXTOS y TEMA-EFECTOS.
  - Datos: MOD, REPO-PROG, REPO-VIDAS, REPO-TIENDA, MOCK-PROG, MOCK-TARJ, MOCK-VIDAS y MOCK-TIENDA.
  - Pantallas y componentes: EST-JUEGO, CODIGO-PANT-09, CODIGO-PANT-10, COMP-NODO-SPRINT y PANT-GALERIA.
  - Pruebas: TEST-AYUDA, TEST-COMP, TEST-GALERIA, TEST-DATOS, TEST-JUEGO, TEST-MAPA, TEST-INICIO y TEST-VEREDICTO.
- **Nuevos:**
  - Lógica y pantallas: LOGICA-FIN-SPRINT, PIEZAS-FIN-SPRINT, CODIGO-PANT-19 y CODIGO-PANT-19b.
  - Componentes: COMP-CONFETI, COMP-ESTRELLAS-SPRINT, COMP-ESTADISTICAS, COMP-AVISO y COMP-ETIQUETA-QUIEBRA.
  - Pruebas y decisiones: TEST-FIN-SPRINT y DEC-JUEGO-VIVO.
- **Obsoletos:** ninguno. El `PintorEstrella` de `nodo_sprint.dart` se unió al de COMP-ESTRELLAS-SPRINT.
- **Ajustes de la revisión:** LOGICA-FIN-SPRINT (regla 90/60), MOCK-TARJ (sin cifras legales) y TEST-FIN-SPRINT, más una línea en el registro de cambios.

## Dudas
Ninguna nueva. Las dudas D1 a D6 quedaron resueltas en la revisión (ver "Ajustes de la revisión").
