import '../../core/textos/textos.dart';
import '../modelos/tarjeta.dart';
import '../repositorios/repositorio_tarjetas.dart';
import 'espera_simulada.dart';

/// Tarjetas simuladas con casos de ejemplo.
///
/// Los 5 sprints del módulo 1 (Protección de Datos, LFPDPPP) tienen tantas
/// tarjetas como su `numeroTarjetas` y su composición: `spr-1-3` (Aviso de
/// privacidad) 10 (6 normales, 3 con evidencia y 1 de justificación, con la
/// GPL-3.0 de Figma como tarjeta 5, el `registro_form.dart` de Figma 15 y 16b
/// como tarjeta 6 y el dilema de contraseñas de Figma 17 y 18 como tarjeta 10)
/// y los demás 8 (5, 2 y 1). Las tarjetas con evidencia y las de dilema no
/// llevan micro-pregunta: su bonus es la evidencia o la justificación.
/// `spr-2-1` solo tiene una tarjeta de ejemplo.
class MockTarjetas implements RepositorioTarjetas {
  MockTarjetas({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static const Map<String, List<Tarjeta>> tarjetasPorSprint = {
    'spr-1-1': [
      Tarjeta(
        id: 'tar-datos-01',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · DATOS PERSONALES',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'Guardamos el nombre y el correo de cada usuario. Como no son secretos, '
            '¿podemos usarlos como queramos sin seguir la ley de datos?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El nombre y el correo identifican a una persona: son datos personales y '
            'su tratamiento sigue la LFPDPPP, aunque no sean secretos.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 5, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'Son datos personales porque identifican a una persona',
            'Porque está prohibido guardar correos',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-datos-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 2 · DATOS ANÓNIMOS',
        personaje: 'Data Analyst',
        rol: 'Equipo de Datos',
        texto:
            'Queremos publicar en el blog cuántos usuarios tenemos por estado, solo '
            'con totales y sin ningún nombre. ¿Podemos?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Las cifras totales no permiten identificar a nadie, así que ya no son '
            'datos personales.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, velocidad: -5),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-datos-03',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 3 · DATOS SENSIBLES',
        personaje: 'Dev Backend',
        rol: 'Equipo de Backend',
        texto:
            'Marketing pidió guardar la religión de cada usuario para recomendarle '
            'contenido. ¿Lo agregamos al perfil con el aviso normal?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Las creencias religiosas son datos sensibles: piden consentimiento expreso '
            'y por escrito y una finalidad legítima. Es un caso para el área jurídica.',
        evidencia: EvidenciaTarjeta(
          archivo: 'perfil.dart',
          lineas: ['perfil: {', '  nombre, correo,', '  religion  // nuevo', '}'],
          lineasClave: [3],
          mensajeAcierto:
              'Marcaste el campo de religión: es un dato sensible. Ahora regresa a la tarjeta y '
              'dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 5, riesgoLegal: 20),
      ),
      Tarjeta(
        id: 'tar-datos-04',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 4 · DIRECCIÓN DE ENVÍO',
        personaje: 'Tech Lead',
        rol: 'Equipo de Móvil',
        texto:
            'Pedimos la dirección del cliente solo para enviarle su compra, y el aviso '
            'de privacidad lo dice. ¿Está bien?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Es un dato personal necesario para una finalidad informada en el aviso: '
            'cumple los principios de finalidad y proporcionalidad.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-datos-05',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 5 · REGISTROS DEL SISTEMA',
        personaje: 'QA',
        rol: 'Equipo de Calidad',
        texto:
            'Los registros de error guardan el nombre y el correo de quien falla al '
            'entrar, y el panel de registros es público. ¿Lo dejamos así?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Exponer datos personales en un panel público incumple el deber de '
            'seguridad y de confidencialidad.',
        evidencia: EvidenciaTarjeta(
          archivo: 'sesion.dart',
          lineas: [r'log.info("Login fallido: ${u.nombre} ${u.correo}");', '// panel: público'],
          lineasClave: [1, 2],
          mensajeAcierto:
              'Marcaste el registro que expone el nombre y el correo en un panel público. Ahora '
              'regresa a la tarjeta y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-datos-06',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 6 · PROPORCIONALIDAD',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'En nuestra app de recetas queremos pedir la CURP y el estado civil "por '
            'si algún día sirven". ¿Los agregamos al registro?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Solo se deben pedir los datos necesarios para la finalidad. La CURP y el '
            'estado civil no hacen falta para dar recetas.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'Pide más datos de los necesarios para la finalidad',
            'Porque la CURP solo la puede pedir el gobierno',
            'Porque el registro debe tener un solo campo',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-datos-07',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 7 · FOTO DE PERFIL',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Queremos usar las fotos de perfil de los usuarios en los anuncios de la '
            'app. ¿Podemos?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'La foto identifica a la persona. Usarla en anuncios es otra finalidad: '
            'solo vale si el usuario da su consentimiento para eso.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, reputacion: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -5),
      ),
      Tarjeta(
        id: 'tar-datos-08',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 8 · DILEMA CLAVE',
        personaje: 'CTO',
        rol: 'Dirección',
        texto:
            'Un hospital aliado nos ofrece los expedientes de sus pacientes para '
            'entrenar nuestro modelo de IA. ¿Los aceptamos?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Los datos de salud son sensibles y recibirlos de otra empresa es una '
            'transferencia: el área jurídica debe revisar el consentimiento y el '
            'contrato.',
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(presupuesto: 5, riesgoLegal: 25),
        justificacion: Justificacion(
          opciones: [
            'Porque los expedientes son de otra empresa y no los podemos usar.',
            'Son datos de salud (sensibles) que llegan por una transferencia: jurídico debe revisar el '
                'consentimiento y el contrato.',
            'Porque los modelos de IA no pueden usar datos reales.',
          ],
          indiceCorrecto: 1,
        ),
      ),
    ],
    'spr-1-2': [
      Tarjeta(
        id: 'tar-consen-01',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · ENTREGA DE PEDIDOS',
        personaje: 'Dev Backend',
        rol: 'Equipo de Backend',
        texto:
            'Usamos la dirección del cliente para entregarle el pedido que compró. '
            '¿Necesitamos pedirle un consentimiento aparte?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'No hace falta: los datos necesarios para cumplir la relación con el '
            'cliente (entregar su compra) son una excepción al consentimiento.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es legal?',
          opciones: [
            'Cumplir la relación con el cliente es una excepción al consentimiento',
            'Porque la dirección no es un dato personal',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-consen-02',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 2 · CONSENTIMIENTO NEGADO',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'El usuario no autorizó usar sus datos de salud, pero el código los usa '
            'igual para recomendar rutinas. ¿Lo publicamos así?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Los datos de salud son sensibles: sin consentimiento expreso no se pueden '
            'usar.',
        evidencia: EvidenciaTarjeta(
          archivo: 'rutinas.dart',
          lineas: [
            'if (perfil.salud != null) {',
            '  recomendar(perfil.salud);',
            '}',
            '// consentimientoSalud: false',
          ],
          lineasClave: [1, 2],
          mensajeAcierto:
              'Marcaste el uso de los datos de salud sin consentimiento. Ahora regresa a la tarjeta '
              'y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 5, riesgoLegal: 25),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-consen-03',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 3 · DIARIO DE ÁNIMO',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'La nueva función guarda cómo se siente el usuario cada día. ¿Basta con '
            'el aviso y que no se queje (consentimiento tácito)?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El estado de ánimo es un dato de salud, y los datos sensibles piden '
            'consentimiento expreso y por escrito; el tácito no basta.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'Los datos sensibles piden consentimiento expreso y por escrito',
            'Porque las apps no pueden guardar emociones',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-arco-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 4 · TRANSFERENCIAS',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Marketing quiere vender la base de correos de los clientes a una '
            'empresa aliada sin avisarles. ¿Es legal?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Transferir datos personales a terceros requiere informarlo en el '
            'aviso de privacidad y, en este caso, el consentimiento del titular.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(presupuesto: 10, riesgoLegal: 25),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-consen-04',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 5 · NUEVA FINALIDAD',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Queremos usar los correos para encuestas de satisfacción, algo que el '
            'aviso no menciona. ¿Podemos empezar ya?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Una finalidad nueva vale si se informa en el aviso y se obtiene el '
            'consentimiento del titular para ella.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, reputacion: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -5),
      ),
      Tarjeta(
        id: 'tar-consen-05',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 6 · REVOCACIÓN',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Este usuario revocó su consentimiento para promociones, pero sigue en la '
            'lista del boletín. ¿Le seguimos enviando porque ya había aceptado?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El titular puede revocar su consentimiento en cualquier momento; desde '
            'entonces ya no se pueden usar sus datos para esa finalidad.',
        evidencia: EvidenciaTarjeta(
          archivo: 'suscripciones.yaml',
          lineas: [
            'usuario: luis@correo.mx',
            'promociones: revocado (2 de marzo)',
            'boletin: activo',
          ],
          lineasClave: [3],
          mensajeAcierto:
              'Marcaste el boletín que sigue activo tras la revocación. Ahora regresa a la tarjeta '
              'y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-consen-06',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 7 · CONSENTIMIENTO EXPRESO',
        personaje: 'Dev Frontend',
        rol: 'Equipo de Web',
        texto:
            'Antes de guardar datos de salud mostramos el aviso y el usuario confirma '
            'un "Sí, autorizo" con su contraseña. ¿Cumple?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Es un consentimiento expreso y firmado con un medio de autenticación, '
            'como piden los datos sensibles.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, velocidad: -5),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-arco-01',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 8 · DILEMA CLAVE',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Un usuario pide que borren sus datos personales, pero tienen facturas '
            'fiscales recientes a su nombre. ¿Qué haces?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Se atiende la cancelación, pero se conservan bloqueados los datos que '
            'la ley fiscal obliga a guardar durante el plazo legal.',
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        justificacion: Justificacion(
          opciones: [
            'Se atiende la cancelación y se bloquean los datos que la ley fiscal obliga a conservar.',
            'Porque las facturas valen más que la privacidad del usuario.',
            'Porque los datos de clientes nunca se pueden borrar.',
          ],
          indiceCorrecto: 0,
        ),
      ),
    ],
    'spr-1-4': [
      Tarjeta(
        id: 'tar-derechos-01',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · ACCESO',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Una usuaria pide saber qué datos suyos tenemos. ¿Le pedimos que acredite '
            'su identidad antes de entregárselos?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Sí: para ejercer los derechos ARCO el titular debe acreditar su identidad, '
            'así los datos no terminan en manos de otra persona.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es legal?',
          opciones: [
            'El titular debe acreditar su identidad para ejercer sus derechos',
            'Porque así la solicitud tarda más',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-derechos-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 2 · COSTO',
        personaje: 'CEO',
        rol: 'Dirección',
        texto:
            'Atender solicitudes de acceso nos quita tiempo. ¿Cobramos una cuota por '
            'cada una?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Ejercer los derechos ARCO es gratuito; solo se pueden cobrar los gastos de '
            'envío o de reproducción de las copias.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(presupuesto: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: ['Ejercer los derechos ARCO es gratuito', 'Porque la cuota es muy baja'],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-derechos-03',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 3 · PLAZOS',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'Esta solicitud de acceso lleva semanas sin respuesta y ya venció el plazo '
            'legal. ¿La dejamos para después del lanzamiento?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Las solicitudes ARCO deben responderse dentro del plazo que marca la '
            'ley; dejarla sin respuesta incumple el derecho del titular.',
        evidencia: EvidenciaTarjeta(
          archivo: 'solicitudes_arco.txt',
          lineas: [
            'Solicitud de acceso',
            'Recibida: hace semanas',
            'Respuesta: —',
            'Plazo legal: vencido',
          ],
          lineasClave: [3, 4],
          mensajeAcierto:
              'Marcaste la solicitud sin respuesta con el plazo vencido. Ahora regresa a la tarjeta '
              'y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-derechos-04',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 4 · RECTIFICACIÓN',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Una usuaria pide corregir su apellido, que está mal escrito. ¿Lo '
            'corregimos y le confirmamos el cambio?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Es el derecho de rectificación: el titular puede pedir que se corrijan '
            'sus datos inexactos.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 10),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-derechos-05',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 5 · CANCELACIÓN',
        personaje: 'Dev Backend',
        rol: 'Equipo de Backend',
        texto:
            'Un usuario pide cancelar su cuenta, pero tiene un reembolso en trámite. '
            '¿Atendemos la cancelación?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Se atiende, pero los datos necesarios para terminar el reembolso se '
            'bloquean y se conservan hasta concluirlo; después se suprimen.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, reputacion: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -5),
      ),
      Tarjeta(
        id: 'tar-derechos-06',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 6 · BORRADO REAL',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'Para "cancelar" una cuenta solo ocultamos el perfil; los datos siguen '
            'guardados para siempre. ¿Con eso cumplimos?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Cancelar implica bloquear los datos y después suprimirlos. Ocultarlos y '
            'guardarlos sin límite no cumple el derecho de cancelación.',
        evidencia: EvidenciaTarjeta(
          archivo: 'cuentas.dart',
          lineas: [
            'cancelarCuenta(id) {',
            '  perfiles.ocultar(id);',
            '  // los datos se quedan',
            '}',
          ],
          lineasClave: [2, 3],
          mensajeAcierto:
              'Marcaste que solo se oculta el perfil y los datos se quedan. Ahora regresa a la '
              'tarjeta y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 5, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-derechos-07',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 7 · OPOSICIÓN',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Un usuario se opone a que usemos sus datos para publicidad. ¿Dejamos de '
            'enviarle anuncios y mantenemos su cuenta?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Es el derecho de oposición: se deja de usar sus datos para esa finalidad '
            'y el servicio sigue.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 10),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-derechos-08',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 8 · DILEMA CLAVE',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Una persona dice ser la abogada de un usuario y trae una carta simple '
            'para pedir todos sus datos. ¿Qué hacemos?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Un representante debe acreditar su representación. Revisar si el '
            'documento es válido es tarea del área jurídica.',
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 25),
        justificacion: Justificacion(
          opciones: [
            'Porque solo el titular puede pedir sus datos, nunca otra persona.',
            'Porque los abogados no pueden hacer solicitudes de acceso.',
            'Un representante debe acreditar su representación y validar el documento es tarea de '
                'jurídico.',
          ],
          indiceCorrecto: 2,
        ),
      ),
    ],
    'spr-1-5': [
      Tarjeta(
        id: 'tar-brecha-01',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · AVISAR O CALLAR',
        personaje: 'CEO',
        rol: 'Dirección',
        texto:
            'Alguien entró sin permiso a la base de usuarios y se llevó correos y '
            'teléfonos. ¿Lo mantenemos en secreto para no asustar a nadie?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Las vulneraciones que afectan de forma significativa a los titulares '
            'deben informárseles sin demora para que puedan protegerse.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 25),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'Hay que informar a los afectados para que puedan protegerse',
            'Porque los correos se pueden recuperar',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-brecha-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 2 · CONTENER',
        personaje: 'Tech Lead',
        rol: 'Equipo de Seguridad',
        texto:
            'Lo primero que proponemos es cerrar el acceso y cambiar todas las '
            'credenciales comprometidas. ¿Empezamos por ahí?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Contener la vulneración es parte del deber de seguridad: primero se '
            'detiene el daño y luego se informa.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(velocidad: -5, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-brecha-03',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 3 · EL AVISO',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto: 'Este es el correo que preparamos para los afectados. ¿Lo enviamos así?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Se puede enviar si agrega qué pasó, qué datos se afectaron, qué puede '
            'hacer el usuario y dónde pedir más información.',
        evidencia: EvidenciaTarjeta(
          archivo: 'aviso_incidente.txt',
          lineas: ['Asunto: Aviso', '', 'Hubo un incidente.', 'Saludos, el equipo.'],
          lineasClave: [3],
          mensajeAcierto:
              'Marcaste el aviso que no dice qué pasó ni qué puede hacer el usuario. Ahora regresa a '
              'la tarjeta y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -5),
      ),
      Tarjeta(
        id: 'tar-brecha-04',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 4 · CONTRASEÑAS',
        personaje: 'Dev Backend',
        rol: 'Equipo de Backend',
        texto:
            'Descubrimos que las contraseñas se guardan en texto plano. Cambiarlo '
            'retrasa el lanzamiento. ¿Seguimos así por ahora?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El responsable debe aplicar medidas de seguridad técnicas adecuadas. '
            'Guardar contraseñas sin cifrar deja expuestos a los usuarios.',
        evidencia: EvidenciaTarjeta(
          archivo: 'usuarios.dart',
          lineas: [
            'usuarios.guardar({',
            '  correo: u.correo,',
            '  contrasena: u.contrasena, // texto plano',
            '});',
          ],
          lineasClave: [3],
          mensajeAcierto:
              'Marcaste la contraseña guardada en texto plano. Ahora regresa a la tarjeta y '
              'dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(velocidad: -5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-brecha-05',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 5 · BITÁCORA',
        personaje: 'QA',
        rol: 'Equipo de Calidad',
        texto:
            'Proponemos registrar el incidente: cuándo pasó, qué datos se afectaron, '
            'la causa y lo que hicimos. ¿Lo documentamos?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'Documentar las vulneraciones y las medidas tomadas ayuda a demostrar el '
            'cumplimiento y a evitar que se repitan.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 10),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-brecha-06',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 6 · LA PRENSA',
        personaje: 'Marketing',
        rol: 'Comunicación',
        texto:
            'Un periodista pregunta por la fuga y el equipo quiere culpar al proveedor '
            'sin tener pruebas. ¿Qué hacemos con la respuesta?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Una declaración pública sobre una fuga y sobre un tercero tiene riesgos '
            'legales: debe revisarla el área jurídica.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
      ),
      Tarjeta(
        id: 'tar-brecha-07',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 7 · EL PROVEEDOR',
        personaje: 'CTO',
        rol: 'Dirección',
        texto:
            'La fuga ocurrió en nuestro proveedor de nube, que guarda los datos por '
            'encargo nuestro. ¿El problema es solo suyo?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El responsable sigue respondiendo por los datos aunque los trate un '
            'encargado; debe atender la vulneración y avisar a los afectados.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'El responsable responde por los datos aunque los trate un encargado',
            'Porque la nube no es segura',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-brecha-08',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 8 · DILEMA CLAVE',
        personaje: 'CEO',
        rol: 'Dirección',
        texto:
            'El atacante pide un rescate para no publicar los datos robados. ¿Pagamos '
            'y lo dejamos así?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Un rescate es una decisión con riesgos legales y de seguridad; debe '
            'llevarse al área jurídica y a las autoridades.',
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(presupuesto: -20, riesgoLegal: 25),
        justificacion: Justificacion(
          opciones: [
            'Pagar un rescate tiene riesgos legales y de seguridad: lo deciden jurídico y las '
                'autoridades.',
            'Porque el atacante podría pedir más dinero.',
            'Porque los datos robados ya no son personales.',
          ],
          indiceCorrecto: 0,
        ),
      ),
    ],
    'spr-1-3': [
      Tarjeta(
        id: 'tar-aviso-01',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 1 · AVISO DE PRIVACIDAD',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'El formulario de registro pide nombre, correo y fecha de nacimiento. '
            '¿Podemos lanzarlo el viernes sin mostrar ningún aviso de privacidad?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'La LFPDPPP obliga a poner el aviso de privacidad a disposición del '
            'titular antes de recabar sus datos.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'La LFPDPPP exige el aviso antes de recabar los datos',
            'Porque los formularios de registro son opcionales',
          ],
          indiceCorrecto: 0,
        ),
        explicacionFallo:
            'Recabar datos sin poner antes el aviso de privacidad a disposición del titular '
            'incumple la LFPDPPP, aunque el lanzamiento sea urgente.',
      ),
      Tarjeta(
        id: 'tar-aviso-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 2 · AVISO SIMPLIFICADO',
        personaje: 'Dev Frontend',
        rol: 'Equipo de Web',
        texto:
            'Pusimos un aviso simplificado en el registro con un enlace al aviso '
            'integral. ¿Cumple?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'El aviso simplificado es válido si informa lo esencial y remite al '
            'aviso integral.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, velocidad: -5),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-aviso-03',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 3 · FINALIDADES',
        personaje: 'Dev Backend',
        rol: 'Equipo de Backend',
        texto:
            'El aviso dice que usamos el correo solo para la cuenta, pero el código '
            'lo manda también a la lista de promociones. ¿Lo dejamos así?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Usar los datos para una finalidad que no está en el aviso incumple el '
            'principio de finalidad.',
        evidencia: EvidenciaTarjeta(
          archivo: 'registro.dart',
          lineas: ['onRegistro(u) {', '  crearCuenta(u);', '  listaPromos.agregar(u.correo);', '}'],
          lineasClave: [3],
          mensajeAcierto:
              'Marcaste el envío del correo a promociones, una finalidad que no está en el aviso. '
              'Ahora regresa a la tarjeta y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-aviso-04',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 4 · FINALIDADES SECUNDARIAS',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Queremos enviar promociones. ¿Basta con agregarlo al aviso y dar una '
            'casilla para que el usuario se niegue?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Las finalidades secundarias son válidas si están en el aviso y el '
            'titular puede negarse a ellas.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, reputacion: 5),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 15),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -5),
      ),
      Tarjeta(
        id: 'tar-gpl-01',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 5 · LICENCIAS OSS',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'Encontré una librería GPL-3.0 que resuelve el login. ¿La copio tal cual '
            'en nuestra app de código cerrado y la publicamos?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'La licencia GPL-3.0 es copyleft: si la integras, todo el producto derivado '
            'debe liberarse bajo la misma licencia. Responder bien el porqué demuestra que '
            'no adivinaste.',
        evidencia: EvidenciaTarjeta(
          archivo: 'pubspec.yaml',
          lineas: ['dependencies:', '  pdf_engine: ^2.1.0  # Licencia: GPL-3.0'],
          lineasClave: [2],
          mensajeAcierto:
              'Marcaste la dependencia con licencia GPL-3.0. Ahora regresa a la tarjeta y dicta tu '
              'veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 25),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        explicacionFallo:
            'Usar código GPL-3.0 dentro de software propietario sin liberar el código '
            'fuente infringe la licencia y la Ley Federal del Derecho de Autor. Busca una '
            'alternativa MIT o Apache 2.0.',
        explicacionParcial:
            'Escalar a jurídico no está mal, pero aquí no hacía falta: la GPL-3.0 es clara '
            'y no se puede usar en código cerrado. Consultar costó tiempo y dinero al '
            'equipo.',
      ),
      Tarjeta(
        id: 'tar-registro-01',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 6 · PROTECCIÓN DE DATOS',
        personaje: 'QA Tester',
        rol: 'Control de calidad',
        texto:
            'Revisé el formulario de registro antes del lanzamiento. Ya cumple con el aviso '
            'de privacidad, ¿lo publicamos así?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'El consentimiento debe ser libre e informado: una casilla pre-marcada no lo es, y '
            'el formulario no enlaza al aviso de privacidad.',
        evidencia: EvidenciaTarjeta(
          archivo: 'registro_form.dart',
          lineas: [
            'TextField(label: "Correo"),',
            'TextField(label: "CURP"),',
            'TextField(label: "Contraseña"),',
            'Checkbox(value: true, // pre-marcado',
            '  label: "Acepto compartir mis datos"),',
            '// sin enlace al aviso de privacidad',
            'ElevatedButton("Registrarme")',
          ],
          lineasClave: [4, 5, 6],
          mensajeAcierto:
              'Marcaste la casilla pre-marcada y el aviso de privacidad faltante. Ahora regresa a la '
              'tarjeta y dicta tu veredicto.',
          mensajeFallo:
              'Esa línea no es la que viola la ley. Ahora regresa a la tarjeta y dicta '
              'tu veredicto.',
        ),
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-aviso-07',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 7 · TRANSFERENCIAS',
        personaje: 'CTO',
        rol: 'Dirección',
        texto:
            'Guardamos los datos en un proveedor de nube que solo los procesa por '
            'nuestro encargo. ¿Hay que pedir consentimiento para eso?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'La remisión a un encargado que trata los datos por cuenta del '
            'responsable no requiere consentimiento.',
        impactoAcierto: ImpactoTarjeta(presupuesto: 5, velocidad: 5),
        impactoFallo: ImpactoTarjeta(presupuesto: -10, velocidad: -5),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
      ),
      Tarjeta(
        id: 'tar-aviso-06',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 8 · MENORES DE EDAD',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'Detectamos que algunos usuarios tienen 15 años. ¿Seguimos registrándolos '
            'igual que a los adultos?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'El tratamiento de datos de menores necesita el consentimiento de quien '
            'ejerce la patria potestad; conviene escalarlo.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -5),
        impactoFallo: ImpactoTarjeta(reputacion: -5, riesgoLegal: 20),
      ),
      Tarjeta(
        id: 'tar-aviso-09',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 9 · CAMBIOS AL AVISO',
        personaje: 'Product Owner',
        rol: 'Equipo de Producto',
        texto:
            'Cambiamos el aviso para agregar una finalidad nueva. ¿Lo publicamos '
            'sin avisar a los usuarios que ya están registrados?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Los cambios al aviso deben comunicarse a los titulares antes de '
            'aplicar la nueva finalidad.',
        impactoAcierto: ImpactoTarjeta(reputacion: 5, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(reputacion: -10, riesgoLegal: 20),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        microPregunta: MicroPregunta(
          enunciado: '¿por qué es ilegal?',
          opciones: [
            'Los cambios al aviso deben comunicarse antes de aplicarse',
            'Porque el aviso no se puede cambiar nunca',
          ],
          indiceCorrecto: 0,
        ),
      ),
      Tarjeta(
        id: 'tar-contrasenas-01',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 10 · DILEMA CLAVE',
        personaje: 'Cliente',
        rol: 'Inversionista ángel',
        texto:
            'El cliente nos pide guardar las contraseñas de los usuarios en texto plano "para '
            'soporte". ¿Aceptamos?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Las contraseñas son datos personales y el responsable debe protegerlas con medidas '
            'de seguridad: se guardan con hash, nunca en texto plano, aunque lo pida el cliente.',
        impactoAcierto: ImpactoTarjeta(reputacion: 10, riesgoLegal: -10),
        impactoFallo: ImpactoTarjeta(velocidad: 5, riesgoLegal: 25),
        impactoParcial: ImpactoTarjeta(presupuesto: -5, velocidad: -10),
        justificacion: Justificacion(
          opciones: [
            'Las contraseñas son datos personales y deben guardarse con hash (bcrypt), nunca en '
                'texto plano.',
            'Porque el cliente no firmó un contrato de confidencialidad.',
            'Solo sería ilegal si ocurre una filtración de datos.',
          ],
          indiceCorrecto: 0,
        ),
      ),
    ],
    'spr-2-1': [
      Tarjeta(
        id: 'tar-mit-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 5 · LICENCIA MIT',
        personaje: 'Tech Lead',
        rol: 'Equipo de Móvil',
        texto:
            'Usas una librería con licencia MIT en un producto comercial y '
            'conservas el aviso de copyright en los créditos. ¿Es legal?',
        respuestaCorrecta: Veredicto.legal,
        explicacion:
            'La licencia MIT permite el uso comercial siempre que se conserve '
            'el aviso de copyright y de licencia.',
      ),
    ],
  };

  @override
  Future<List<Tarjeta>> obtenerTarjetasDelSprint(String sprintId) async {
    await esperar(espera);
    final tarjetas = tarjetasPorSprint[sprintId];
    if (tarjetas == null) {
      throw StateError(Textos.errorSprintNoEncontrado);
    }
    return tarjetas;
  }
}
