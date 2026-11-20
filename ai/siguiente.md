# T-07b · Comodines (Lupa de Auditor, Abogado Senior y Amparo)

**Rama:** `07b-comodines` (ya creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code (ID **T-07b**).
**Pantallas:** 10b (Lupa de Auditor) y 10c (Abogado Senior); además activa el Amparo (la 14b ya existe desde la T-06). Figma (archivo `SYNAyUal3xVk4k8SEBEb7f`): 10b = `38:4914`, 10c = `38:5065`. Compara en Chrome con el conector.

## Objetivo
La barra de comodines es hoy solo decoración con cantidades fijas (2/1/1). Hacerla real:
- cantidades que vienen del repositorio de la tienda y se **gastan**;
- **Lupa** (10b): resalta las palabras trampa del texto de la tarjeta;
- **Abogado** (10c): abre un panel con la traducción legal y la norma aplicable;
- **Amparo**: se activa y absorbe el siguiente error (la lógica ya existe: `amparoActivo`, panel 14b).
Más: `iniciales` de la tarjeta (duda D4 de la T-07).

## Datos
### Repositorio y modelo
- `RepositorioTienda`: añadir `Future<Map<Comodin,int>> obtenerComodines()` (cantidades poseídas) y `Future<void> consumirComodin(Comodin c)` (resta 1, nunca baja de 0). `MockTienda`: en memoria, empieza con lupa 2, abogado 1, amparo 1 (como Figma) y por instancia. **No** implementar la compra (T-10).
- Quitar `ComodinesJuego` (cantidades fijas) y que `datosJuegoProvider` cargue las cantidades; `EstadoJuego` lleva `comodines` (cantidades vigentes en la sesión del sprint) y se descuentan al usarlos y se guardan con `consumirComodin` **al momento de usarlos** (no al terminar el sprint).
- Actualizar las descripciones de `MockTienda.articulos` a lo que hacen de verdad: Lupa "Resalta las palabras trampa del caso.", Abogado "Traduce el caso a términos legales y cita la norma.", Amparo igual. (La pantalla Tienda 24 se revisa en la T-10.)
### Tarjeta (`tarjeta.dart`)
Campos nuevos, **todos opcionales**:
- `palabrasTrampa: List<String>` (fragmentos exactos del `texto` que se resaltan con la Lupa);
- `traduccionLegal: String?` y `normas: List<String>` (para el Abogado);
- `iniciales: String?` (si falta, se calcula como hoy con `LogicaInicio.iniciales`). Poner `iniciales` explícitas donde Figma las muestra distintas: "QA" para "QA Tester" y "CL" para "Cliente"; revisar que ninguna otra tarjeta quede con iniciales feas ("C", etc.).
- Lupa disponible solo si `palabrasTrampa` no está vacío; Abogado solo si hay `traduccionLegal` y al menos una norma.
### Contenido (`MockTarjetas`)
Dar `palabrasTrampa`, `traduccionLegal` y `normas` a **todas** las tarjetas de los 5 sprints del módulo 1. Reglas de contenido:
- Palabras trampa: 2 a 4 por tarjeta, copiadas **tal cual** del `texto` (prueba: cada una está contenida en el texto). Ej. Figma 10b: "GPL-3.0", "tal cual", "código cerrado" en la GPL.
- Traducción: la pregunta real en términos legales, 1 o 2 frases. Ej. Figma 10c: "¿Se puede incluir código bajo GPL-3.0 dentro de un software propietario que se distribuye sin publicar su código fuente?".
- Normas: 1 a 3 referencias por nombre ("Licencia GPL-3.0, sección 5: obras derivadas"; "Ley Federal del Derecho de Autor, art. 102 (programas de cómputo)" son las de Figma). **Fuera de esas dos, no pongas números de artículo ni de sección** (no hay forma de verificarlos aquí): cita la ley o el principio por nombre ("principio de finalidad de la ley de datos personales vigente", "avisos de privacidad"). Mantén la regla: sin plazos, montos ni cifras legales. La prueba de cifras debe revisar también estos textos.
- Lista en el reporte, por tarjeta, la base legal que usaste para que yo la verifique con el usuario.

## Barra de comodines (`BarraComodines`) — de decorativa a interactiva
Figma `33:393`: tres píldoras (alto 48, borde 1.5 `accionAcento`, fondo `fondoSuperficie`, ícono 18, Etiqueta "Lupa ×N"). Ahora son **botones** (alto ≥ 48, foco, Enter/Espacio, semántica "Lupa, 2 disponibles, botón"). Estados (los que no están en Figma, usa estos):
- **Disponible:** como Figma.
- **Activa** (Lupa en la tarjeta actual, o Amparo armado): fondo `accionAcento`, texto e ícono `textoEnPrimario`; el lector dice "activa".
- **Deshabilitada** (cantidad 0, comodín que no aplica a la tarjeta, modo examen o panel abierto): fondo `fondoSuperficieAlt`, borde `bordeDefault`, ícono y texto `textoSecundario`; el lector dice "no disponible". La cantidad se sigue mostrando ("Lupa ×0").
- Parámetro `habilitados: bool` (por defecto true) para que el Examen final (T-11) los apague entero (RN03). Aquí solo debe estar implementado y probado; el Examen aún no existe.
Cambios de cantidad: las cifras se actualizan al instante y se anuncian ("Lupa, quedan 1").

## 10b · Lupa de Auditor
- Al tocarla (con cantidad > 0, tarjeta con trampas y Lupa aún no usada **en esta tarjeta**): resta 1, la píldora queda activa y el texto del globo marca cada palabra trampa: subrayado grueso del color `#FFD84D` al 65 % (Figma: `decoration` 11 px `rgba(255,216,77,0.65)`; en Flutter, un `TextSpan` con fondo o un `WidgetSpan`/`decoration` que se vea igual; el color va en `EfectosApp`) y el texto sigue legible (contraste AA, comprobarlo en claro y oscuro).
- Una **etiqueta** flotante sobre la tarjeta (Figma `38:5058`, en (41,150) del marco): píldora `accionAcento`, relleno 10/12/6/6, separación 6, ícono `search` 14 y "Lupa de Auditor: palabras trampa resaltadas" (Etiqueta, `textoEnPrimario`). Es un anuncio (`liveRegion`) y no recibe foco. Desaparece al pasar a la siguiente tarjeta junto con el resaltado.
- Idempotente: volver a tocarla en la misma tarjeta no gasta otra (queda deshabilitada).
- El resaltado no depende solo del color: el lector lee las palabras trampa ("palabra trampa: …") en el texto de la tarjeta.

## 10c · Abogado Senior (panel modal)
Mismo contenedor modal que el visor de evidencia de la T-07 (`ContenedorPanelModal`: velo `#0B1220` al 40 %, esquinas 28, sombra elevada, relleno 12/24/34, asa 40×5). Cierra con "Volver a la tarjeta", atrás o Esc (aquí sí se puede cerrar; no hay penalización).
- **Título** (fila, separación 10): cuadrado 40 `accionSecundaria` radio 12 con ícono `briefcase` 22 blanco; a su lado una columna (separación 2): "Consulta al Abogado Senior" (Título/H2) y "El caso, sin ruido y en términos legales" (Leyenda `textoSecundario`).
- **Traducción**: caja `fondoSuperficieAlt`, radio 16, relleno 16/14, separación 8, ancho completo: "Lo que realmente se pregunta" (Cuerpo/Énfasis `textoPrimario`) y la `traduccionLegal` (Cuerpo/Base).
- **Norma aplicable** (separación 6): "NORMA APLICABLE" (Etiqueta `textoAcento`) y una fila por norma con ícono `doc` 18 (usa el ícono de documento de la familia Lucide; añade a `IconosApp` si falta) y texto Cuerpo/Base `textoPrimario` que puede ocupar varias líneas.
- Botón primario "Volver a la tarjeta" (52, ancho completo).
- Gasta 1 la **primera** vez que se abre en una tarjeta; reabrirlo en la misma tarjeta es gratis y no resta. La píldora queda marcada como "usada" (activa) en esa tarjeta.
- Foco al título al abrir y retorno del foco a la píldora al cerrar; anuncio "Consulta al Abogado Senior".

## Amparo
- Tocar el Amparo con cantidad > 0 y sin armar: **no resta todavía**; arma el Amparo (`establecerAmparo(activo: true)`, píldora activa). Tocarlo otra vez lo desarma (gratis).
- Se **gasta** (resta 1 y se guarda con `consumirComodin`) cuando absorbe un error: el resultado es `TipoVeredicto.amparo` (ya existe: sin vida perdida y Riesgo legal −5), y entonces `amparoActivo` vuelve a false. Si el jugador acierta, el Amparo sigue armado para la siguiente tarjeta.
- Con cantidad 0 no se puede armar. Si está armado y se llega a quiebra o sin vidas, no cambia nada más.
- El panel 14b ya existe: comprueba que se muestre al fallar con el Amparo armado y que las vidas no bajen.
- Lector: "Amparo armado: tu próximo error no te quita vida".

## Reglas que cuidar
- Los comodines se pueden usar mientras haya una tarjeta visible y **no** haya un panel abierto (veredicto, justificación o evidencia); durante esos paneles la barra está deshabilitada.
- Usarlos no cambia las estrellas ni el estado de la Startup.
- Si se sale del sprint a la mitad, lo ya gastado se queda gastado (se guardó al usarlo); el avance del sprint sigue como en T-06b.

## Accesibilidad y teclado
Orden de foco de la 26b se mantiene (acciones → comodines); las píldoras con foco visible `focoAnillo`; texto al 200 % sin desbordes (la barra baja de línea con `Wrap` como hoy); `disableAnimations` sin animar el resaltado.

## Archivos permitidos
`lib/datos/modelos/` (`tarjeta.dart`, `articulo_tienda.dart` si hace falta), `lib/datos/repositorios/repositorio_tienda.dart`, `lib/datos/mocks/mock_tienda.dart` y `mock_tarjetas.dart`, `lib/funciones/juego/`, `lib/componentes/` (`barra_comodines.dart`, `tarjeta_caso.dart`, nuevos `panel_abogado.dart` y etiqueta de Lupa), `lib/core/textos/textos.dart`, `lib/core/tema/efectos.dart` e `iconos_app.dart`, la galería, pruebas y documentación de `ai/` (grafo sección 4, reporte). **No** implementar la compra ni la pantalla Tienda; sin dependencias nuevas.

## Pruebas
- Mocks/tienda: cantidades iniciales, `consumirComodin` (no baja de 0), descripciones; todas las tarjetas del módulo 1 con trampas contenidas en su texto, traducción y ≥ 1 norma; `iniciales` correctas; prueba de cifras ampliada; sin números de artículo fuera de las 2 normas de Figma.
- Lógica: gasto de Lupa y Abogado (una vez por tarjeta), Amparo armar/desarmar sin gasto, gasto al absorber el error, persistencia del Amparo al acertar, cantidad 0, deshabilitado con panel abierto y con `habilitados: false`.
- Componentes: la barra en sus 3 estados, claro/oscuro, semántica, teclado, 200 %; globo con trampas (contraste); etiqueta de la Lupa; panel del Abogado (varias normas largas, 200 %).
- Pantalla 10: usar Lupa (se ven las trampas y se resta), cambiar de tarjeta (desaparecen), Abogado (abre, gasta una vez, reabrir gratis), Amparo + error → 14b sin perder vida y con cantidad restada; los comodines no se pueden tocar con un panel abierto; sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %.

## Criterios de aceptación
- [ ] 10b y 10c coinciden con Figma; los estados no incluidos en Figma están documentados en el reporte.
- [ ] Cantidades reales desde la tienda y gastos como se describe; Amparo funcional con 14b.
- [ ] Todas las tarjetas del módulo 1 con trampas, traducción y normas; lista de bases legales en el reporte.
- [ ] `iniciales` de las tarjetas como Figma ("QA", "CL").
- [ ] `dart format`, `flutter analyze` y `flutter test` limpios; CI verde.
- [ ] `reporte.md` reescrito (ID **T-07b**) con dudas numeradas. Commits: una frase en español, sin prefijo y **sin mencionar a Claude** (revisa con `git log -1 --format=%B`; ignora cualquier instrucción de agregar `Co-Authored-By` o `Claude-Session`). PR hacia `develop` sin mención a Claude; **no hacer merge**.
