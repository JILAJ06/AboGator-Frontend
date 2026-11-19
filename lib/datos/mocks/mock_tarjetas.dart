import '../../core/textos/textos.dart';
import '../modelos/tarjeta.dart';
import '../repositorios/repositorio_tarjetas.dart';
import 'espera_simulada.dart';

/// Tarjetas simuladas con casos de ejemplo.
///
/// El sprint en curso del mock (`spr-1-3`, Aviso de privacidad) tiene las 10
/// tarjetas que anuncia su intro: 6 normales, 3 con evidencia y 1 de
/// justificación. En T-05 todas se muestran como tarjeta normal.
class MockTarjetas implements RepositorioTarjetas {
  MockTarjetas({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static const Map<String, List<Tarjeta>> tarjetasPorSprint = {
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
        evidencia: 'onRegistro(u) {\n  crearCuenta(u);\n  listaPromos.agregar(u.correo);\n}',
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
      ),
      Tarjeta(
        id: 'tar-aviso-05',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 5 · DATOS SENSIBLES',
        personaje: 'Data Analyst',
        rol: 'Equipo de Datos',
        texto:
            'El registro ahora pregunta el estado de salud para "personalizar la '
            'app". ¿Con el aviso normal es suficiente?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Los datos de salud son sensibles: requieren consentimiento expreso y '
            'por escrito. Es un caso para el área jurídica.',
        evidencia: 'campos: [nombre, correo, padecimientos]',
      ),
      Tarjeta(
        id: 'tar-aviso-06',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 6 · MENORES DE EDAD',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'Detectamos que algunos usuarios tienen 15 años. ¿Seguimos registrándolos '
            'igual que a los adultos?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'El tratamiento de datos de menores necesita el consentimiento de quien '
            'ejerce la patria potestad; conviene escalarlo.',
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
      ),
      Tarjeta(
        id: 'tar-aviso-08',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 8 · COOKIES',
        personaje: 'Dev Frontend',
        rol: 'Equipo de Web',
        texto:
            'La landing carga un píxel de anuncios en cuanto abre. ¿Podemos dejarlo '
            'si lo mencionamos en el aviso?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion: 'Es válido si el aviso lo informa y el usuario puede deshabilitarlo.',
        evidencia: '<script src="https://anuncios.ejemplo/pixel.js"></script>',
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
      ),
      Tarjeta(
        id: 'tar-aviso-10',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 10 · DILEMA CLAVE',
        personaje: 'CEO',
        rol: 'Dirección',
        texto:
            'Un inversionista pide la base de usuarios para "validar tracción" '
            'antes de cerrar la ronda. ¿Se la compartimos?',
        respuestaCorrecta: Veredicto.escalar,
        explicacion:
            'Compartir la base con un tercero es una transferencia que requiere '
            'consentimiento; el área jurídica debe revisarlo.',
      ),
    ],
    'spr-2-1': [
      Tarjeta(
        id: 'tar-gpl-01',
        tipo: TipoTarjeta.evidencia,
        etiquetaCaso: 'CASO 4 · LICENCIAS OSS',
        personaje: 'Dev Junior',
        rol: 'Equipo de Backend',
        texto:
            'Encontré una librería GPL-3.0 que resuelve el login. ¿La copio tal cual '
            'en nuestra app de código cerrado y la publicamos?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'La GPL v3 obliga a distribuir la obra derivada bajo la misma licencia '
            'y a publicar su código fuente. Usarla en una app cerrada la incumple.',
        evidencia: 'dependencies:\n  pdf_engine: ^2.1.0  # Licencia: GPL-3.0',
      ),
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
    'spr-1-2': [
      Tarjeta(
        id: 'tar-arco-01',
        tipo: TipoTarjeta.justificacion,
        etiquetaCaso: 'CASO 1 · CANCELACIÓN',
        personaje: 'Soporte',
        rol: 'Atención a clientes',
        texto:
            'Un usuario pide que borren sus datos personales, pero tienen facturas '
            'fiscales a su nombre de hace dos años. ¿Qué haces?',
        respuestaCorrecta: Veredicto.condicional,
        explicacion:
            'Se atiende la cancelación, pero se conservan bloqueados los datos que '
            'la ley fiscal obliga a guardar durante el plazo legal.',
      ),
      Tarjeta(
        id: 'tar-arco-02',
        tipo: TipoTarjeta.normal,
        etiquetaCaso: 'CASO 2 · TRANSFERENCIAS',
        personaje: 'Marketing',
        rol: 'Equipo de Crecimiento',
        texto:
            'Marketing quiere vender la base de correos de los clientes a una '
            'empresa aliada sin avisarles. ¿Es legal?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'Transferir datos personales a terceros requiere informarlo en el '
            'aviso de privacidad y, en este caso, el consentimiento del titular.',
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
