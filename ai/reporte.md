# Reporte

- **Tarea:** T-03 · Acceso: Inicio de sesión y Registro
- **Rama:** `03-acceso`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11.
- Revisé en Chrome (web en modo debug):
  - Inicio de sesión: en claro a 390×844, vacío y con errores; en oscuro a 360×640.
  - Registro: en claro a 390×844, vacío y con todos los errores; en oscuro a 360×640.

## Qué se hizo
1. **Componentes nuevos** en `lib/componentes/`, con pruebas y en la galería:
   - `AccionEnfocable`: base común de los controles propios. Se activa con toque, Enter o Espacio, muestra el anillo de foco solo con teclado y deja la semántica a cargo de quien lo usa.
   - `CasillaApp`: cuadro de 22 con radio 6 y texto Leyenda a 10.
     - Marcada: `accion/primaria` con un check de 14.
     - Sin marcar: `fondo/superficie` con borde 1.5 `borde/control`.
     - Toda la fila es táctil (≥ 48). Se anuncia como casilla marcada o sin marcar, y su error se anuncia.
   - `ChipSeleccion`: píldora con relleno 12×10 y texto Etiqueta, con los colores de seleccionado y no seleccionado de la especificación.
     - Su zona táctil mide ≥ 48 sin cambiar el aspecto.
     - Se anuncia como opción seleccionada de un grupo exclusivo, por ejemplo "Perfil Desarrollador, 2 de 3", **sin emoji**.
   - `EnlaceTexto`: Cuerpo/Énfasis en `texto/acento`, zona ≥ 48, semántica de enlace.
   - `BotonAtras`: cuadro de 48 con radio 12, `fondo/superficie`, borde 1 e ícono back de 20, etiqueta "Atrás".
2. **Componentes ajustados:**
   - `BotonApp` ganó `cargando` y `textoCargando`. Mientras carga no responde y muestra un indicador de progreso en lugar del texto. Su semántica pasa a deshabilitada, en región viva, con el texto de carga ("Iniciando sesión" / "Creando tu cuenta").
   - `CampoTextoApp` ganó `alEnviar` (Enter o "Listo" en el teclado) y `pistasAutocompletado`. Por defecto, el correo ahora usa las pistas email y username.
3. **Validadores** (`lib/funciones/acceso/validadores.dart`): una clase pura con los mensajes exactos de la tarea.
   - Nombre: 2 a 60 caracteres tras recortar espacios.
   - Correo: formato `algo@dominio.tld` sin espacios, máximo 254.
   - Contraseña: en el inicio de sesión solo se exige que no esté vacía; en el registro, al menos 8 caracteres con un número.
   - Perfil y las dos casillas son obligatorios.
   - Ningún mensaje incluye la contraseña.
4. **Estado (Riverpod):**
   - `inicioSesionProvider` y `registroProvider` se liberan al salir de la pantalla (`autoDispose`).
   - Guardan errores, el estado de envío y, en el registro, el perfil y las casillas. **Nunca guardan la contraseña**: la pantalla la pasa solo al enviar.
   - Devuelven el primer campo con error para mover el foco.
   - `sesionProvider` (`Usuario?`) queda listo para T-04.
   - Las pantallas usan `repositorioAutenticacionProvider`; nunca llaman al mock directamente.
   - Se envía el correo (y el nombre) recortado. Los consentimientos viajan como dos booleanos distintos.
5. **Pantalla 05 · Inicio de sesión:**
   - Logo horizontal a color de 306.9×74.4 (en oscuro cambia solo a la versión negativa).
   - Título en dos líneas y subtítulo fijo, con Sarko de 96×120 decorativo a la derecha.
   - Campos de correo y contraseña (oculta, con botón para mostrarla). Enter en la contraseña envía el formulario.
   - "¿Olvidaste tu contraseña?" muestra un aviso breve no bloqueante (ver Pendientes).
   - Botón "Iniciar sesión" con estado de carga, separador "o", "Crear una cuenta" (va al registro) y la nota de seguridad.
   - Errores por campo al enviar, que se limpian al editar. El error del repositorio aparece arriba del botón, con ícono en `estado/ilegal`, y se anuncia.
   - Al iniciar sesión va a `Rutas.inicio`, que es un marcador ("Inicio · llega en T-04").
6. **Pantalla 06 · Registro:**
   - Botón atrás que regresa al inicio de sesión, título y subtítulo.
   - Tres chips de perfil **sin selección inicial**.
   - Campos de nombre, correo y contraseña, que empiezan **vacíos**.
   - **Dos casillas independientes y sin marcar.**
   - "Crear cuenta" está siempre habilitado salvo durante el envío; la validación ocurre al enviar.
   - Debajo, el enlace "¿Ya tienes cuenta? Inicia sesión".
   - Al enviar con errores se muestran todos y el **foco va al primero en orden visual** (perfil, nombre, correo, contraseña, Aviso, Términos). Los errores se anuncian como región viva.
7. **Rutas:** `inicioSesion` y `registro` ya son pantallas reales. Solo `inicio` queda como marcador. El flujo completo es Splash → Onboarding → Inicio de sesión ⇄ Registro → marcador del Inicio.

## Resultados
`dart format --set-exit-if-changed lib test`: sin cambios.

`flutter analyze`:
```
No issues found!
```
`flutter test` (186 pruebas):
```
+186: All tests passed!
```
- `test/funciones/acceso/validadores_test.dart`: casos válidos e inválidos y los límites (2 y 60 caracteres de nombre, 254 de correo, 8 de contraseña con número).
- `test/componentes/acceso_componentes_test.dart`: los 4 componentes en claro y oscuro, solo colores del tema, semántica (casilla, opción seleccionada, enlace, "Atrás"), zonas ≥ 48, anillo de foco con Tab y activación con Enter o Espacio. También el botón en carga.
- `test/funciones/acceso/inicio_sesion_test.dart`:
  - Medidas del logo y tipos de teclado y autocompletado.
  - Errores al enviar vacío, con foco en el correo; error de correo inválido que se limpia al editar.
  - Durante la carga: progreso, anuncio "Iniciando sesión" y un segundo toque que no reenvía. Al terminar, éxito con sesión iniciada.
  - Error del repositorio anunciado y ubicado arriba del botón.
  - Enter envía, "Crear una cuenta" lleva al registro y el enlace muestra el aviso.
  - Orden de foco correcto y contraseña fuera de la semántica.
  - Texto al 200 % sin desbordes en 390×844 y 360×640, en claro y oscuro.
- `test/funciones/acceso/registro_test.dart`:
  - Al abrir no hay perfil elegido, las casillas están sin marcar y los campos vacíos.
  - Los perfiles se anuncian sin emoji y la selección es única.
  - Con todo vacío aparecen los 6 errores y el foco va al perfil.
  - **Las casillas son independientes:** con una marcada, el error y el foco van a la otra, en los dos sentidos.
  - La contraseña sin número muestra el mensaje exacto.
  - En el éxito se envían los datos recortados y los dos booleanos por separado.
  - El botón atrás y el enlace regresan al inicio de sesión.
  - La contraseña no aparece en la semántica, y no hay desbordes con texto al 200 % en los dos tamaños y modos.
- Revisé con `git grep` que no haya hex fuera de `lib/core/tema/` ni `print` o `debugPrint` en `lib/`.

## Pendientes
- **Recuperación de contraseña:** no existe la pantalla. "¿Olvidaste tu contraseña?" muestra un aviso breve: "La recuperación de contraseña estará disponible pronto".
- **Pantallas del Aviso de Privacidad y los Términos de uso:** no existen. Los textos de las casillas no son enlaces.
- **Inicio (07):** sigue siendo un marcador hasta T-04.

## Decisiones
- **Botón en carga:** conserva los colores de su tipo en lugar del gris de deshabilitado, para que no parezca un error. Aun así no responde y se anuncia como deshabilitado.
- **`AccionEnfocable`:** los 4 componentes nuevos comparten la misma lógica de foco, teclado y toque. No migré los componentes de T-01 y T-02 para no salirme del alcance.
- **Autocompletado:** el correo usa email y username en el inicio de sesión, y solo email en el registro. La contraseña usa `password` en el inicio de sesión y `newPassword` en el registro, para que el gestor de contraseñas proponga una nueva.
- **Posiciones del inicio de sesión:** el enlace de contraseña ocupa una zona de 48, así que el hueco antes del botón es de 8 (no 20) para mantener el botón cerca de y=560. En el navegador todo queda 48 dp más arriba, porque no hay barra de estado; en un teléfono `SafeArea` lo baja a y≈96.
- **Posiciones del registro:**
  - El botón atrás se corre 4 dp a la izquierda para quedar en x=20, con el resto del contenido en x=24.
  - El error "Elige tu perfil" va debajo de los chips.
  - Cada casilla ocupa 48 de alto, porque la fila entera es táctil, así que quedan a 48 entre sí en lugar de los 36 de Figma (ver D1).
- **Texto de ayuda de la contraseña en el registro:** no lleva, porque el diseño no lo pide. El correo y el nombre usan los textos de ayuda que ya existían ("tu@correo.com" y "¿Cómo te llamas?").
- **El mock no cambió:** inicia sesión con cualquier correo y contraseña no vacíos. El error del repositorio se prueba con un repositorio falso en las pruebas.

## Grafo actualizado
Toqué la sección 4 (Código), las filas PANT-05 y PANT-06 (sección 5) para anotar la ruta del código, la línea "Última actualización" y el registro de cambios. Comprobé con `ls` que todas las rutas de la sección 4 existen.
- **Cambiados (`en curso`):** ENRUTADOR, RUTAS, PANT-PENDIENTE (ahora solo el Inicio), TEXTOS, COMP-BOTON (carga), COMP-CAMPO (Enter y autocompletado), PANT-GALERIA, FUNC, TEST-COMP, TEST-GALERIA y TEST-BIENVENIDA.
- **Nuevos:**
  - Componentes: COMP-ACCION, COMP-CASILLA, COMP-CHIP-SEL, COMP-ENLACE y COMP-ATRAS.
  - Lógica de acceso: VALIDADORES, SESION, EST-INICIO-SESION, EST-REGISTRO y AVISO-ERROR.
  - Pantallas y pruebas: CODIGO-PANT-05, CODIGO-PANT-06 y TEST-ACCESO.
  - Decisión: DEC-CARGA.
- **Obsoletos:** ninguno.

## Dudas
- **D1 · Separación de las casillas.** En Figma están a 36 de distancia (y=548 y y=584), pero cada fila táctil debe medir ≥ 48. Las dejé a 48, unos 12 dp más que en el diseño. ¿Se acepta, o se reduce la zona táctil solapándolas?
- **D2 · Chips de perfil en 360 de ancho.** En 360×640, "⚖️ Legal" baja a una segunda fila. En 390 caben los tres en una. ¿Se acepta el salto, o se reduce el relleno en pantallas angostas?
- **D3 · Mock de autenticación.** ¿Conviene que el mock rechace alguna credencial concreta (por ejemplo, una contraseña "incorrecta") para poder demostrar el error del repositorio en la app, y no solo en las pruebas?
- **D4 · "Bienvenido de vuelta".** Es el texto del diseño, pero está en masculino. ¿Se prefiere una forma neutra como "Te damos la bienvenida de vuelta"? No lo cambié.
