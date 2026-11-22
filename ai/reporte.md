# Reporte
- **Tarea:** T-13b · Pantallas de cuenta, legal y notificaciones
- **Rama:** `13b-pantallas-cuenta-y-legal`
- **Estado:** terminada y subida. El Pull Request hacia `develop` lo abre el usuario; no hice merge.

## Entorno
- Flutter 3.50.0 (stable) · Dart 3.14.0 · Windows 11. **Sin dependencias nuevas.**
- Trabajé con las medidas de `siguiente.md`; no abrí Figma. Lo que no venía ahí está en "Decisiones propias" y en las dudas.

## Qué se hizo
### 1 · Recuperar contraseña (31 a 31e)
- **Rutas sin sesión:** `/recuperar`, `/recuperar/enviado`, `/recuperar/nueva?token=…`, `/recuperar/listo` y `/recuperar/caducado`. El enlace "¿Olvidaste tu contraseña?" del inicio de sesión (móvil y tablet) abre 31.
- **Repositorio:** `RepositorioAutenticacion` ganó `solicitarRecuperacion(correo)` y `restablecer(token, nueva)`, con `ExcepcionEnlaceCaducado`.
  - El mock responde igual aunque el correo no exista.
  - El token `caducado` lanza la excepción; cualquier otro vale.
  - "Abrir correo" va a `/recuperar/nueva?token=demo`, con la marca `// T-14`.
- **31:** atrás (48, en x 24); título en H1; Sarko sorprendido de 96 a la derecha; descripción, campo de correo y nota; "Enviar enlace", el fantasma "Volver a iniciar sesión" (48) y el pie "El enlace caduca en 30 minutos" abajo.
  - El correo usa el validador del Login. El error se anuncia (región en vivo del campo) y el foco va al campo.
- **31b:** ilustración de 260 (círculo `fondo/destacado` de 230, Sarko alegre de 150 e insignia de 64 `accionPrimaria` con `mail`), título, texto con el correo y "Abrir correo".
  - "Reenviar enlace en 0:45" deshabilitado, que a los 45 s pasa a "Reenviar enlace" (fantasma) y se anuncia **una sola vez**.
  - Al reenviar, se anuncia "Te enviamos otro enlace" y la cuenta vuelve a empezar.
  - Nota de spam.
- **31c:** cerrar (X); campos "Nueva contraseña", con la ayuda "Mínimo 8 caracteres, incluye un número", y "Confirmar contraseña", los dos con ojo; "Guardar contraseña".
  - Errores: regla incumplida (validador del Registro) y contraseñas que no coinciden. El foco va al primer campo con error.
- **31d / 31e:** la ilustración con check `accionPrimaria` (Sarko alegre) o alerta `accionAcento` (Sarko triste), título, texto y botones.
  - "Pedir un enlace nuevo" vuelve a 31 con el correo ya escrito: el correo vive en `recuperacionProvider`.
- **Tablet:** el panel de marca (o la franja, en vertical) con Sarko en la expresión de cada paso (`PanelMarca.pose`, nuevo) y el formulario en la columna de 470.

### 2 · Aviso de Privacidad y Términos de uso (32, 33)
- **Pantalla:** `PantallaLegal`, rutas `/legal/aviso` y `/legal/terminos`, sin sesión.
  - Atrás, título centrado de 18, la versión y las secciones en `FilaAcordeon`, con separación 10.
  - "Entendido" fijo abajo: regresa a quien la abrió.
- **Acordeón:** una sección abierta a la vez; al entrar, "¿Qué datos recopilamos?" en el Aviso y "Contenido educativo" en los Términos. Tocar la abierta la cierra.
  - Cerrada: 50 de alto, borde 1 `borde/default`.
  - Abierta: borde 2 `accionAcento`, chevron hacia abajo, título en negrita y el cuerpo.
  - Se lee como botón expandido o contraído ("…, sección 2 de 7"); el cuerpo se lee aparte. Enter o Espacio la abren.
  - 200 ms de animación (0 con "Reducir animaciones"). La lista se desplaza con texto al 200 %.
- **Contenido:** `lib/core/textos/textos_legales.dart` (`SeccionLegal`, `DocumentoLegal`), marcado `// BORRADOR legal: revisar antes de publicar` (también en `textos.dart`).
  - Escribí los cuerpos que faltaban en 2 o 3 frases: en el Aviso, la LFPDPPP, los ARCO y el correo de contacto del equipo del proyecto.
- **Tablet:** columna de lectura de 640 centrada, sin riel.
- **Accesos:**
  - Registro: enlaces "Leer el Aviso de Privacidad" y "Leer los Términos de uso" bajo las casillas; se abren con push, así no se pierde lo escrito.
  - Perfil: la fila "Aviso de Privacidad" y la nueva "Términos de uso".
  - Ajustes: sección nueva "Legal" con las dos.

### 3 · Notificaciones de racha (34, 34c, 34b)
- **34** (ruta `/ajustes/notificaciones`, con sesión): atrás, título "Protege tu racha" con Sarko alegre de 96, descripción y la tarjeta de tres filas.
  - Las filas tienen interruptor de 52 × 32 (`InterruptorApp(grande: true)`).
  - **Recordatorio diario:** tocar la fila abre el selector; su interruptor es un control aparte (`InterruptorTocable`).
  - Nota, "Activar notificaciones" y "Ahora no".
  - Cada interruptor se guarda al instante. Los dos botones guardan `activadas` (sí o no) y `decidido`, y cierran. `// T-14: permiso del sistema`.
- **34c:** en móvil, hoja inferior con radio superior 28, agarre de 40 × 5, relleno 24, `sombraGlobo` (la "Elevada") y velo al 40 %. En tablet, diálogo centrado de 440 como máximo.
  - Título H3, leyenda y tres ruedas: hora 1–12, minutos de 5 en 5 y a. m./p. m. La fila elegida mide 48, sobre `fondo/superficie-alt` con radio 14; las vecinas al 45 %.
  - "Guardar" y "Cancelar". Esc cancela.
  - Al cerrar, el foco vuelve a la fila (`devolverFoco`). Al guardar se anuncia "Recordatorio a las 8:10 p. m." y se enciende el recordatorio.
  - Las ruedas son ajustables para el lector (valor, aumentar y disminuir) y con ↑ ↓ del teclado.
  - Con "Botones en lugar de deslizar", cada rueda lleva + arriba y − abajo (48 × 48).
  - Está aislado en `lib/funciones/notificaciones/selector_hora.dart`, para poder quitarlo.
- **34b:** `NotificacionSistema`, la notificación de 21b generalizada. En la galería, "Tu racha de 7 días está en riesgo" y "Perdiste tu racha de 7 días".
- **Estado:** `ajustesNotificacionesProvider`. `RepositorioAjustes` ganó `cargarNotificaciones` y `guardarNotificaciones` (claves `notif_*` en la misma tabla de SQLite o memoria; los valores inválidos toman su valor por defecto).
- **Accesos:**
  - Tras el **primer registro exitoso** se abre 34 una vez (si aún no se decidió) y al cerrar va al Inicio.
  - Ajustes: sección "Notificaciones".
  - Perfil: la fila "Notificaciones de racha".

### Galería
Sección "Cuenta, legal y notificaciones":
- las tres ilustraciones (31b, 31d, 31e);
- el acordeón cerrado y abierto;
- los interruptores grandes y el tocable;
- las dos notificaciones de 34b;
- el selector de hora con y sin + y −.

## Componentes compartidos (para la T-15)
- `InsigniaCircular` e `IlustracionInsignia` (`lib/componentes/ilustracion_insignia.dart`): en 31b, 31d y 31e, y en la galería.
- `FilaAcordeon` (`lib/componentes/fila_acordeon.dart`): las 15 secciones de 32 y 33.
- `InterruptorApp(grande:)` e `InterruptorTocable` (`piezas_ajustes.dart`): en 34 y en la galería.
- `NotificacionSistema` (`notificacion_apelacion.dart`): en 21b y 34b.
- `RuedaSelector` (en `selector_hora.dart`): una sola rueda reutilizable; si la T-15 la necesita en otro lugar, se puede pasar a `lib/componentes/`.
- `PanelMarca` y `DisposicionAccesoTablet` aceptan `pose`.

## Decisiones propias
- **Recuperación en tablet:** como Sarko ya está en el panel de marca, la columna no repite la ilustración de 260; muestra solo la insignia, de 96.
- **31d y 31e sin botón atrás:** el flujo terminó; sus botones llevan a 31 o al inicio de sesión.
- **Pie abajo sin medidas intrínsecas:** el marco de la recuperación y la pantalla 34 usan una columna con alto mínimo y `spaceBetween`. `IntrinsicHeight` y `SliverFillRemaining` fallan con `FilaAjuste`, que usa `LayoutBuilder`.
- **Recordatorio:** elegir una hora enciende el recordatorio.
- **Ruedas:** hora y minutos son cíclicas (de 12 se pasa a 1); en las ruedas, ↑ aumenta y ↓ disminuye.
- **Íconos en las filas de 34:** `flame`, `gavel` y `clock`, para seguir el patrón de `FilaAjuste` (ver D5).
- **Ruta de 34 de primer nivel** (`DEC-NOTIF-RUTA`). Primero la colgué de `/perfil/ajustes`, pero abrirla directo (como hace el registro) construía Perfil y Ajustes debajo, y el foco podía quedar en una página fuera de pantalla: Tab fallaba. Lo encontró la prueba de foco visible.
- **`PantallaPendiente`** ya no la usa ninguna ruta; la marqué `obsoleto` y no la borré.
- **"Aviso de Privacidad"** con P mayúscula también en el Perfil, igual que el título de la pantalla.

## Accesibilidad
- **Auditoría:** 13 escenas nuevas en `test/auditoria/auditoria_cuenta_test.dart` (31, 31 con error, 31b, 31c, 31c con errores, 31d, 31e, 32, 32 con otra sección abierta, 33, 34, 34c y 34c con "Solo botones").
  - Cada una en 4 tamaños × claro y oscuro × 100, 160 y 200 % = **312 combinaciones**, todas en verde.
  - Se verifica: sin desbordes, zona táctil Android e iOS, etiquetas y contraste de texto.
- **Foco visible en cada parada de Tab:** se sumaron 31, 31c, 32 y 34, en móvil y tablet.
- **Foco y anuncios:** foco inicial en el título; errores anunciados y foco al primer campo con error; anuncio único del reenvío; foco de regreso del selector; anuncio de la hora guardada; Esc cierra el selector.

## Verificación
- `dart format`: sin cambios pendientes.
- `flutter analyze`: `No issues found!`
- `flutter test`: **3019 pruebas** (antes de T-13b, 2650):
```
+3019: All tests passed!
```
- **Pruebas nuevas (369):** recuperación 14, legal 11, notificaciones 14, componentes 8, auditoría 312, foco visible 8 y 2 del Perfil (la fila de Términos).
- **Pruebas existentes que ajusté** (por el cambio pedido, sin cambiar su tamaño de pantalla):
  - **Inicio de sesión:** el enlace ahora abre 31 en lugar del aviso "pronto".
  - **Registro:** el éxito abre 34 y "Ahora no" lleva al Inicio.
  - **Perfil:** cinco filas, que abren 34, 32 y 33 en lugar de los marcadores.
  - **Ajustes:** diez filas.
  - **Galería:** cuentas de la sección nueva.
  - **Clases falsas de los repositorios:** implementan los métodos nuevos.

## Grafo actualizado
- **`en curso`:**
  - datos: REPO-AUTH, MOCK-AUTH, REPO-AJUSTES, LOCAL-AJUSTES, MOCK-AJUSTES;
  - app y textos: TEXTOS, RUTAS, ENRUTADOR;
  - componentes: PANEL-MARCA, COMP-NOTIFICACION, COMP-PIEZAS-AJUSTES;
  - pantallas: CODIGO-PANT-05, 06, 25 y 26, PANT-GALERIA;
  - pruebas: TEST-GALERIA, TEST-AUDITORIA, TEST-ACCESO, TEST-PERFIL y TEST-AJUSTES.
- **Nuevos:**
  - datos y textos: MODELO-NOTIF, TEXTOS-LEGALES;
  - recuperación: EST-RECUPERACION, MARCO-RECUPERACION, CODIGO-PANT-31;
  - legal: CODIGO-PANT-32;
  - notificaciones: EST-NOTIFICACIONES, CODIGO-PANT-34, SELECTOR-HORA;
  - componentes: COMP-ILUSTRACION-INSIGNIA, COMP-FILA-ACORDEON;
  - pruebas: TEST-RECUPERACION, TEST-LEGAL, TEST-NOTIFICACIONES, TEST-COMP-CUENTA;
  - decisiones: DEC-NOTIF-RUTA, DEC-LEGAL-PUSH.
- **Obsoleto:** PANT-PENDIENTE (sin uso).
- Faltan las filas de pantalla PANT-31 a PANT-34, que son de Claude Chat (D7).
- Línea nueva en el registro de cambios.

## Para la T-14 (lo que depende del servidor)
- **Correo y enlace:** el enlace profundo del correo (`/recuperar/nueva?token=…`) y "Abrir correo", que hoy navega con el token `demo`.
- **Token:** la caducidad real (30 minutos) y el uso único; hoy solo `caducado` falla.
- **Reenvío:** con límite real por servidor; hoy solo hay la cuenta de 45 s en el cliente.
- **Sesiones:** el cierre de las sesiones en otros dispositivos al cambiar la contraseña (hoy solo se dice en el texto).
- **Notificaciones:** el permiso del sistema y el alta del dispositivo al "Activar"; el envío real (racha en riesgo, días 3, 7 y 14 y el tope de 2 al día); la hora del recordatorio, que guarda el cliente pero debe programar el servidor (con la zona horaria).
- **Legal:** la versión y la fecha vigentes del Aviso y los Términos, y el registro de qué versión aceptó cada usuario.

## Dudas
- **D1.** Tras el primer registro abro 34 (una vez) y luego el Inicio. ¿Prefieres otro orden, por ejemplo, ofrecerlas después del primer sprint?
- **D2.** La ruta de 34 es `/ajustes/notificaciones` de primer nivel (no hija de `/perfil/ajustes`) por el problema de foco descrito arriba. ¿Bien?
- **D3.** El Registro no tenía enlaces a los documentos (solo las casillas). Agregué "Leer el Aviso de Privacidad" y "Leer los Términos de uso" bajo las casillas. ¿Así, o prefieres que la palabra dentro de cada casilla sea el enlace?
- **D4.** En tablet no tenía medidas de T34, así que usé la columna de 470 centrada, sin riel; para 32 y 33 usé la de 640, como pediste. ¿Coincide con Figma?
- **D5.** Puse íconos en las filas de 34 (`flame`, `gavel`, `clock`) como en Ajustes. Si en Figma no llevan, se quitan con un parámetro.
- **D6.** "Ahora no" guarda `activadas = false`, pero conserva los interruptores tal como quedaron, y cada interruptor se guarda al tocarlo. ¿Bien, o "Ahora no" debería apagarlos todos?
- **D7.** Faltan las filas PANT-31 a PANT-34 en el grafo (son tuyas). Además, `PantallaPendiente` quedó sin uso: ¿la borramos en la T-15?
- **D8.** Los textos legales son un borrador mío para validar con el docente; el correo de contacto aparece como "el correo del equipo del proyecto". ¿Tienes la dirección real?
