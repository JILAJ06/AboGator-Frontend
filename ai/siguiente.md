# T-03 · Acceso: Inicio de sesión y Registro

**Rama:** `03-acceso` (creada desde `develop`)
**Escribe este archivo:** Claude Chat. **Escribe `reporte.md`:** Claude Code.

## Objetivo
Implementar las pantallas **05 Inicio de sesión** y **06 Registro** con validaciones, estados de error y carga, y **dos consentimientos separados** (Aviso de Privacidad y Términos de uso), usando el repositorio de autenticación que ya existe (mock). Incluye 4 componentes nuevos de acceso.

## Antes de empezar
- `git fetch`, `git checkout 03-acceso`, `git pull`. Leer `ai/conocimiento/` (00 a 07): `03-pantallas.md` (flujo 1), `05-reglas-y-seguridad.md` (¡importante para contraseñas y consentimientos!) y `07-componentes.md` (sección "Componentes de acceso").
- Commits pequeños, **una frase en español, sin prefijo y sin mencionar a Claude** (ni `Co-Authored-By`, ni `Generated with`, ni `Claude-Session`). Revisar con `git log -1 --format=%B`. Subir la rama; **no abrir Pull Request**.
- Medidas en dp del marco de Figma de 390×844. Solo tokens/estilos del tema, textos en `core/textos`, y reutiliza `BotonApp`, `CampoTextoApp`, `LogoApp`, `SarkoImagen`, `AnilloFoco`, `IconoApp`. Sin dependencias nuevas.

## Componentes nuevos (`lib/componentes/`, con pruebas y en la galería)
Especificación completa en `07-componentes.md` → "Componentes de acceso":
`CasillaApp` (casilla con texto y error), `ChipSeleccion` (chip de perfil), `EnlaceTexto` y `BotonAtras`.

## Pantalla 05 · Inicio de sesión (`lib/funciones/acceso/`)
Fondo `fondo/app`, contenido en una columna desplazable (el teclado no debe tapar el campo enfocado ni producir desbordes; con texto al 200 % todo sigue alcanzable).
- **Logo horizontal** a color (`LogoApp` horizontal, tono por defecto) de ≈ 306.9×74.4, centrado, con su parte superior en y=96.
- **Sarko alegre** decorativo de 96 de ancho (caja 96×120) en (270,190), a la derecha del título.
- **Título** "Bienvenido de vuelta" en dos líneas (Fredoka Bold 26/32, `texto/primario`), x=24, y=210, ancho 220. **Subtítulo** "Continúa tu racha de 7 días" (Cuerpo/Base, Inter 14/20, `texto/secundario`), x=24, y=280, ancho 220 (texto fijo del diseño; no lo conectes a datos).
- **Formulario** en x=24, y=340, ancho 342, hueco 16:
  - `CampoTextoApp` "Correo electrónico" (ícono mail, teclado de correo, autocompletado de usuario/correo, sin autocorrección).
  - `CampoTextoApp` "Contraseña" (ícono lock, contraseña oculta con botón de mostrar/ocultar, autocompletado de contraseña).
  - `EnlaceTexto` "¿Olvidaste tu contraseña?" (zona 48 de alto, alineado a la izquierda). La pantalla de recuperación no existe: al tocarlo muestra un aviso breve no bloqueante ("La recuperación de contraseña estará disponible pronto") y anótalo como pendiente en el reporte.
- **Botón primario** "Iniciar sesión" (342×52) en y=560. Mientras se envía: queda deshabilitado, muestra un indicador de progreso accesible y se anuncia "Iniciando sesión".
- **Separador** en y=632: línea de 1 `borde/default` de 140 – "o" (Cuerpo/Base, `texto/secundario`) – línea de 140, hueco 12.
- **Botón secundario** "Crear una cuenta" (342×52) en y=668 → va a `Rutas.registro`.
- **Nota** centrada en y=750, Leyenda (`texto/secundario`): "Conexión cifrada (TLS 1.2+) · Autenticación JWT".
- Estados: error de campo (correo vacío o con formato inválido: "Ingresa un correo válido"; contraseña vacía: "Ingresa tu contraseña") y error general del repositorio (`ExcepcionAutenticacion.mensaje`, mostrado arriba del botón con ícono y color `estado/ilegal`, anunciado por el lector). Los errores se muestran al enviar y se limpian al editar el campo.
- Al iniciar sesión con éxito → `Rutas.inicio` (aún no existe: usa `PantallaPendiente` con "Inicio · llega en T-04").

## Pantalla 06 · Registro
- **Botón atrás** (`BotonAtras`) en (20,54) → regresa al inicio de sesión (`context.go` a `Rutas.inicioSesion`, porque el onboarding ya se vio).
- **Título** "Crea tu cuenta" (Fredoka Bold 26/32) en x=24, y=116, ancho 342. **Subtítulo** "Elige tu perfil para ajustar el ritmo de los sprints." (Cuerpo/Base, `texto/secundario`) en y=154.
- **Perfil** en y=196: tres `ChipSeleccion` ("🎓 Estudiante", "💻 Desarrollador", "⚖️ Legal"), hueco 8. Es un grupo de selección única. En el diseño aparece "Desarrollador" seleccionado solo como ejemplo: **al abrir la pantalla no hay ninguno seleccionado**, y si el usuario no elige se muestra el error "Elige tu perfil". La etiqueta semántica **no** incluye el emoji ("Estudiante", "Desarrollador", "Legal"); el emoji es solo visual.
- **Formulario** en y=256, ancho 342, hueco 14: `CampoTextoApp` "Nombre" (ícono user, capitalización de nombres, autocompletado de nombre), "Correo electrónico" (ícono mail) y "Contraseña" (ícono lock, ocultable). En el diseño el campo de contraseña aparece con error "Mínimo 8 caracteres, incluye un número" (Leyenda, `estado/ilegal`, borde de 2): ese es el estado de error cuando la contraseña no cumple. Los valores de ejemplo del diseño (Ana López, ana.dev@startup.mx) **no** son valores por defecto: los campos inician vacíos.
- **Consentimientos** (dos `CasillaApp` **independientes y sin marcar por defecto**): en y=548 "He leído y acepto el Aviso de Privacidad." y en y=584 "He leído y acepto los Términos de uso." No hay pantallas de esos documentos todavía: el texto es solo texto; anótalo como pendiente. Si se intenta crear la cuenta sin marcar alguna, esa casilla muestra su error ("Debes aceptar el Aviso de Privacidad para continuar" / "Debes aceptar los Términos de uso para continuar") y el foco/lector se mueven al primer error.
- **Botón primario** "Crear cuenta" en y=620, con el mismo estado de carga ("Creando tu cuenta"). Va **siempre habilitado** salvo durante el envío: la validación ocurre al enviar.
- **Enlace** "¿Ya tienes cuenta? Inicia sesión" (`EnlaceTexto`, centrado) en y≈700 → inicio de sesión.
- Éxito → `Rutas.inicio` (marcador de T-04).

## Validaciones (en una clase pura y probada, `lib/funciones/acceso/validadores.dart`)
- **Nombre:** no vacío tras recortar espacios, 2 a 60 caracteres. Mensaje: "Ingresa tu nombre".
- **Correo:** formato razonable (`algo@dominio.tld`, sin espacios), máx. 254. Mensaje: "Ingresa un correo válido".
- **Contraseña (registro):** mínimo 8 caracteres y al menos un número. Mensaje exacto: "Mínimo 8 caracteres, incluye un número". En el inicio de sesión solo se exige que no esté vacía.
- **Perfil** obligatorio; **ambas casillas** obligatorias.
- Se envía al repositorio el correo recortado; la contraseña **nunca** se imprime, registra ni guarda (ni en logs, ni en estado persistente, ni en mensajes de error). Los dos consentimientos viajan como dos booleanos distintos (`aceptaAvisoPrivacidad`, `aceptaTerminos`).

## Estado y navegación
- Proveedores de Riverpod por pantalla (estado del formulario y envío) que usan `repositorioAutenticacionProvider`; las pantallas no llaman al mock directamente. Un proveedor de sesión con el usuario actual (`Usuario?`) disponible para T-04.
- Rutas: reutiliza `Rutas.inicioSesion` y `Rutas.registro` (reemplaza el marcador de inicio de sesión; deja marcador solo para `Rutas.inicio`).
- Con "reducir animaciones", sin transiciones decorativas. Orden de foco por teclado en el orden visual de cada pantalla; Enter en el último campo envía el formulario.

## Pruebas
Validadores (casos válidos e inválidos, límites); `CasillaApp`, `ChipSeleccion`, `EnlaceTexto`, `BotonAtras` (claro/oscuro, semántica, foco, zona táctil ≥ 48); pantalla 05 (errores, carga, éxito y error del repositorio, navegación a registro, el enlace de contraseña); pantalla 06 (grupo de perfil sin selección inicial, errores por campo, **las dos casillas independientes y sin marcar**, éxito, regreso); que la contraseña no aparece en ningún texto semántico; texto al 200 % sin desbordes en 390×844 y 360×640, claro y oscuro. Agrega los componentes nuevos a la galería. `dart format`, `flutter analyze` y `flutter test` en verde.

## Archivos permitidos
`lib/funciones/acceso/**`, `lib/componentes/**`, `lib/core/**`, `lib/app/**`, `lib/datos/**` (solo si hace falta ajustar el mock o el proveedor de sesión), `lib/funciones/bienvenida/galeria_componentes.dart`, `test/**`, los nodos de código de `ai/grafo.md` y `ai/reporte.md`. **No tocar** `ai/siguiente.md` ni `ai/conocimiento/`. Sin dependencias nuevas.

## Criterios de aceptación
1. Pantallas 05 y 06 coinciden con las medidas, textos y colores de arriba, en claro y oscuro (verifica en Chrome a 390×844 y 360×640).
2. Validaciones y mensajes exactos; errores accesibles (anunciados, con foco al primer error).
3. Dos consentimientos separados, sin marcar y obligatorios; perfil obligatorio y sin selección inicial.
4. Contraseña tratada como dato sensible (oculta, sin registros). Sin hex fuera de `core/tema` ni textos sueltos.
5. Navegación: Splash → Onboarding → Inicio de sesión ⇄ Registro → marcador de Inicio.
6. CI en verde; commits sin prefijo y sin menciones a Claude.
7. `ai/grafo.md` actualizado (PANT-05, PANT-06, componentes, validadores, proveedores, pruebas, rutas) y `reporte.md` con ID **T-03**, rama, resumen, decisiones, pendientes (recuperación de contraseña, pantallas de Aviso y Términos), sección **"Grafo actualizado"** y dudas numeradas.
