# Reporte
- **Tarea:** T-07b · Comodines (pantallas 10b y 10c, y el Amparo)
- **Rama:** `07b-comodines`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- **Comparé contra Figma** con el conector (solo lectura): contexto de diseño de 10b (`38:4914`) y 10c (`38:5065`). De ahí salen el subrayado (`#FFD84D` al 65 %, 11 de grosor), la etiqueta de la Lupa en (41, 150), el panel del Abogado y el contenido de la GPL (trampas, traducción y las dos normas).
- **Prueba en el navegador:** compilé la app para web y jugué `spr-1-3` a 390×844.
  - **Lupa:** en la tarjeta 1 y en la GPL marca las trampas, aparece la etiqueta y la píldora pasa a "Lupa ×1" activa. En oscuro el resaltado se lee bien.
  - **Abogado:** el panel empieza a la misma altura que en Figma (419); al cerrarlo, el foco vuelve a la píldora, que queda activa con "Abogado ×0".
  - **Amparo:** lo armé y fallé: sale 14b "¡El Amparo te protegió!", las vidas siguen en 5 y la cantidad baja a 0.
  - En la primera prueba el subrayado salía desplazado: el pintor acomodaba el texto con otro ancho y otro estilo. Lo corregí (mismo ancho del globo y mismo estilo efectivo) y lo volví a comprobar.

## Qué se hizo
1. **Datos:**
   - `RepositorioTienda.obtenerComodines()` y `consumirComodin(c)` (resta 1, nunca baja de 0). `MockTienda` los guarda en memoria por instancia y empieza con lupa 2, abogado 1 y amparo 1. No implementé la compra (T-10).
   - Descripciones de `MockTienda.articulos`: Lupa "Resalta las palabras trampa del caso.", Abogado "Traduce el caso a términos legales y cita la norma.", Amparo igual.
   - `Tarjeta` con `palabrasTrampa`, `traduccionLegal`, `normas` e `iniciales` (opcionales). La Lupa solo aplica con trampas y el Abogado con traducción y al menos una norma.
   - **Contenido:** las 42 tarjetas del módulo 1 tienen 2 a 4 trampas copiadas tal cual del texto, una traducción de una frase y 1 o 2 normas por nombre. Solo las dos normas de Figma (GPL) llevan número de sección o de artículo. Sin plazos, montos ni cifras legales.
   - **Iniciales:** "QA" (QA y QA Tester) y "CL" (Cliente), como en Figma; y para que ninguna quede de una letra, "MK" (Marketing), "CT" (CTO), "CE" (CEO) y "SP" (Soporte).
2. **Estado y lógica:**
   - Se quitó `ComodinesJuego`; `datosJuegoProvider` carga las cantidades de la tienda.
   - `EstadoJuego` lleva `comodines`, `lupaUsada` y `abogadoUsado` (por tarjeta).
   - `usarLupa` (una vez por tarjeta), `consultarAbogado` (gasta la primera vez; reabrir es gratis) y `alternarAmparo` (armar y desarmar es gratis; no se arma con 0).
   - El gasto se guarda con `consumirComodin` **al usarlo**; el del Amparo, cuando absorbe el error (resultado `amparo`). Si se acierta, el Amparo sigue armado.
   - Lógica pura en `LogicaComodines`: estado de cada píldora y si es tocable. Nada se puede tocar con un panel abierto (veredicto, justificación, evidencia o Abogado) ni con `habilitados: false`.
   - Al salir y volver a entrar, lo gastado sigue gastado (se recarga de la tienda).
3. **Barra de comodines:** cada píldora es un botón (≥ 48, foco, Enter y Espacio). Estados (los dos últimos no están en Figma):
   - **Disponible:** como en Figma.
   - **Activa:** Lupa usada en la tarjeta, Abogado consultado o Amparo armado. Fondo `accion/acento` con texto e ícono `texto/en-primario`; se lee "activa" (el Amparo, "Amparo armado: tu próximo error no te quita vida"). La Lupa activa no responde al toque; el Abogado activo se reabre gratis y el Amparo activo se desarma.
   - **Deshabilitada:** sin cantidad, sin trampas o traducción en la tarjeta, con un panel abierto o en el Examen. Fondo `fondo/superficie-alt`, borde `borde/default` y `texto/secundario`; se lee "no disponible" y sigue mostrando la cantidad ("Abogado ×0").
   - Al usar uno se anuncia cuántos quedan ("Lupa, quedan 1").
4. **10b · Lupa:**
   - `TextoConTrampas` pinta detrás del texto un subrayado de 11 (escalado con el texto) centrado en la línea base. Lo calcula con las cajas del texto, así que sigue a las trampas aunque cambien de línea.
   - En claro es `#FFD84D` al 65 %. En oscuro baja al 35 %, porque al 65 % el texto claro no llegaba a AA (al 35 % da 5.5:1). No tiene animación.
   - La etiqueta `EtiquetaLupa` flota sobre la tarjeta, se anuncia y no recibe foco; desaparece al pasar de tarjeta.
   - El lector lee "palabra trampa: …" en el texto de la tarjeta.
5. **10c · Abogado:** `PanelAbogado` usa el `ContenedorPanelModal` de la T-07 y se cierra con el botón, atrás o Esc. El foco va al título al abrir y vuelve a la píldora al cerrar.
6. **Galería:** barra en sus estados y apagada, etiqueta de la Lupa, tarjeta de la GPL con trampas y panel del Abogado.

## Bases legales por tarjeta (para verificar)
"LDP" es la ley de datos personales en posesión de particulares vigente; en la app aparece como "Ley de datos personales en posesión de particulares: …". Las únicas normas con número son las dos de Figma.

| Tarjeta | Correcta | Normas |
|---|---|---|
| `tar-datos-01` (spr-1-1, 1) | ilegal | LDP: definición de dato personal; LDP: principios de licitud y finalidad |
| `tar-datos-02` (spr-1-1, 2) | legal | LDP: datos disociados o anonimizados |
| `tar-datos-03` (spr-1-1, 3) | escalar | LDP: datos personales sensibles; LDP: consentimiento expreso y por escrito para datos sensibles |
| `tar-datos-04` (spr-1-1, 4) | legal | LDP: principios de finalidad y proporcionalidad; LDP: aviso de privacidad |
| `tar-datos-05` (spr-1-1, 5) | ilegal | LDP: deber de seguridad; LDP: deber de confidencialidad |
| `tar-datos-06` (spr-1-1, 6) | ilegal | LDP: principio de proporcionalidad (minimización de datos); LDP: principio de finalidad |
| `tar-datos-07` (spr-1-1, 7) | condicional | LDP: principio de finalidad y consentimiento para finalidades nuevas; Derecho a la propia imagen |
| `tar-datos-08` (spr-1-1, 8) | escalar | LDP: datos personales sensibles (salud); LDP: transferencias y consentimiento del titular |
| `tar-consen-01` (spr-1-2, 1) | legal | LDP: excepciones al consentimiento por una relación jurídica con el titular |
| `tar-consen-02` (spr-1-2, 2) | ilegal | LDP: consentimiento expreso y por escrito para datos sensibles; LDP: principio de licitud |
| `tar-consen-03` (spr-1-2, 3) | ilegal | LDP: consentimiento expreso y por escrito para datos sensibles; LDP: consentimiento tácito y expreso |
| `tar-arco-02` (spr-1-2, 4) | ilegal | LDP: transferencias y consentimiento del titular; LDP: aviso de privacidad |
| `tar-consen-04` (spr-1-2, 5) | condicional | LDP: principio de finalidad; LDP: cambios al aviso de privacidad |
| `tar-consen-05` (spr-1-2, 6) | ilegal | LDP: revocación del consentimiento; LDP: principio de finalidad |
| `tar-consen-06` (spr-1-2, 7) | legal | LDP: consentimiento expreso y por escrito para datos sensibles; LDP: firma electrónica o medio de autenticación |
| `tar-arco-01` (spr-1-2, 8) | condicional | LDP: derecho de cancelación: bloqueo y supresión; Obligaciones fiscales de conservación de comprobantes |
| `tar-aviso-01` (spr-1-3, 1) | ilegal | LDP: aviso de privacidad; LDP: principio de información |
| `tar-aviso-02` (spr-1-3, 2) | legal | LDP: modalidades del aviso de privacidad: integral, simplificado y corto |
| `tar-aviso-03` (spr-1-3, 3) | ilegal | LDP: principio de finalidad; LDP: aviso de privacidad |
| `tar-aviso-04` (spr-1-3, 4) | condicional | LDP: finalidades secundarias y mecanismo para negarse; LDP: aviso de privacidad |
| `tar-gpl-01` (spr-1-3, 5) | ilegal | Licencia GPL-3.0, sección 5: obras derivadas; Ley Federal del Derecho de Autor, art. 102 (programas de cómputo) |
| `tar-registro-01` (spr-1-3, 6) | ilegal | LDP: consentimiento libre, específico e informado; LDP: aviso de privacidad |
| `tar-aviso-07` (spr-1-3, 7) | legal | LDP: remisiones al encargado; LDP: responsable y encargado del tratamiento |
| `tar-aviso-06` (spr-1-3, 8) | escalar | LDP: datos de menores: consentimiento de quien ejerce la patria potestad; Interés superior de la niñez |
| `tar-aviso-09` (spr-1-3, 9) | ilegal | LDP: cambios al aviso de privacidad; LDP: principio de finalidad |
| `tar-contrasenas-01` (spr-1-3, 10) | ilegal | LDP: deber de seguridad: medidas técnicas; LDP: responsable y encargado del tratamiento |
| `tar-derechos-01` (spr-1-4, 1) | legal | LDP: derecho de acceso; LDP: acreditación de la identidad del titular |
| `tar-derechos-02` (spr-1-4, 2) | ilegal | LDP: gratuidad de los derechos ARCO; LDP: costos de envío o de reproducción |
| `tar-derechos-03` (spr-1-4, 3) | ilegal | LDP: plazos de respuesta a los derechos ARCO; LDP: derecho de acceso |
| `tar-derechos-04` (spr-1-4, 4) | legal | LDP: derecho de rectificación; LDP: principio de calidad de los datos |
| `tar-derechos-05` (spr-1-4, 5) | condicional | LDP: derecho de cancelación: periodo de bloqueo; LDP: excepciones a la cancelación |
| `tar-derechos-06` (spr-1-4, 6) | ilegal | LDP: derecho de cancelación: bloqueo y supresión; LDP: principio de calidad: conservación limitada |
| `tar-derechos-07` (spr-1-4, 7) | legal | LDP: derecho de oposición; LDP: finalidades secundarias |
| `tar-derechos-08` (spr-1-4, 8) | escalar | LDP: ejercicio de los derechos ARCO por representante; LDP: acreditación de la identidad y la representación |
| `tar-brecha-01` (spr-1-5, 1) | ilegal | LDP: vulneraciones de seguridad: aviso a los titulares; LDP: deber de seguridad |
| `tar-brecha-02` (spr-1-5, 2) | legal | LDP: deber de seguridad; LDP: vulneraciones de seguridad: acciones correctivas |
| `tar-brecha-03` (spr-1-5, 3) | condicional | LDP: vulneraciones de seguridad: contenido del aviso a los titulares |
| `tar-brecha-04` (spr-1-5, 4) | ilegal | LDP: deber de seguridad: medidas técnicas; LDP: vulneraciones de seguridad |
| `tar-brecha-05` (spr-1-5, 5) | legal | LDP: vulneraciones de seguridad: registro de incidentes; LDP: principio de responsabilidad |
| `tar-brecha-06` (spr-1-5, 6) | escalar | LDP: vulneraciones de seguridad: comunicación a los titulares; Código Civil Federal: responsabilidad por daño moral |
| `tar-brecha-07` (spr-1-5, 7) | ilegal | LDP: responsable y encargado del tratamiento; LDP: vulneraciones de seguridad: aviso a los titulares |
| `tar-brecha-08` (spr-1-5, 8) | escalar | LDP: vulneraciones de seguridad: aviso y acciones correctivas; Denuncia ante las autoridades competentes |

## Accesibilidad
- Orden de foco de 26b: acciones y luego Lupa, Abogado y Amparo (probado con Tab).
- Las píldoras muestran el anillo de foco. El estado no depende solo del color: se lee "activa" o "no disponible" y la cantidad siempre se ve.
- Contraste AA verificado en pruebas: el texto en cada estado de la barra (claro y oscuro) y el texto sobre el subrayado de las trampas.
- Al 200 % la barra baja de línea y el panel del Abogado se desplaza, sin desbordes.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test` (691 pruebas; antes de T-07b, 647):
```
+691: All tests passed!
```
- **Pruebas nuevas o cambiadas:**
  - **`comodines_test.dart`:**
    - tienda: cantidades, consumo sin bajar de 0 y descripciones;
    - contenido de las 42 tarjetas, normas sin artículos fuera de Figma e iniciales de dos letras;
    - lógica: Lupa, Abogado, Amparo, cantidad 0, panel abierto y `habilitados: false`;
    - pantalla 10, Lupa: resalta, gasta, solo una vez y desaparece al cambiar de tarjeta;
    - pantalla 10, Abogado: abre, gasta una vez, se reabre gratis, se cierra con Esc y atrás, y devuelve el foco;
    - pantalla 10, Amparo: armar y desarmar es gratis, 14b sin perder vida y sigue armado al acertar;
    - la barra con un panel abierto, el gasto que se conserva al volver a entrar y sin desbordes en 390×844, 360×640 y 320×640 al 100 % y 200 %.
  - **`comodines_componentes_test.dart`:** barra en claro y oscuro, semántica, teclado, `habilitados: false` y 200 %; subrayado de las trampas y su contraste; etiqueta de la Lupa; panel del Abogado con normas largas al 200 %.
  - La prueba de cifras legales revisa también trampas, traducciones y normas; la de orden de foco recorre las tres píldoras.

## Grafo
- **Actualizados (`en curso`):** MOD, REPO-TIENDA, MOCK-TIENDA, MOCK-TARJ, TEMA-EFECTOS, TEXTOS, PANT-GALERIA, EST-JUEGO, CODIGO-PANT-10, COMP-TARJETA-CASO, COMP-COMODINES, TEST-JUEGO, TEST-FIN-SPRINT, TEST-COMP, TEST-AYUDA y TEST-GALERIA.
- **Nuevos:** LOGICA-COMODINES, COMP-ETIQUETA-LUPA, COMP-PANEL-ABOGADO y TEST-COMODINES.
- **Obsoletos:** ninguno (`ComodinesJuego` se eliminó del código). Agregué una línea en el registro de cambios.

## Dudas
1. **Nombre de la ley:** usé "Ley de datos personales en posesión de particulares", sin nombre oficial ni número, porque la LFPDPPP se reemplazó en 2025. ¿Quieres el nombre oficial de la ley vigente?
2. **Normas fuera de la ley de datos:** conviene confirmarlas con el usuario:
   - "Derecho a la propia imagen" (`tar-datos-07`);
   - "Obligaciones fiscales de conservación de comprobantes" (`tar-arco-01`);
   - "Interés superior de la niñez" (`tar-aviso-06`);
   - "Código Civil Federal: responsabilidad por daño moral" (`tar-brecha-06`);
   - "Denuncia ante las autoridades competentes" (`tar-brecha-08`).
3. **Estado activo:** en Figma 10b la píldora de la Lupa sigue como Disponible ("Lupa ×1") aunque la Lupa ya se usó; seguí la tarea y la marqué como activa. ¿Está bien?
4. **Iniciales nuevas:** "MK", "CT", "CE" y "SP" no están en Figma; las elegí para que ninguna quede de una letra.
5. **Resaltado en oscuro:** baja al 35 % para que el texto siga en AA. ¿Está bien o prefieres otro color en oscuro?
6. **Etiqueta de la Lupa:** se queda fija mientras la tarjeta se arrastra (no se mueve con ella).
