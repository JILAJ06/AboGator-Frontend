// BORRADOR legal: revisar antes de publicar.
//
// Los textos del Aviso de Privacidad y de los Términos de uso (pantallas 32 y
// 33, T-13b) son un borrador para el proyecto escolar: los valida el equipo
// con su docente. No son asesoría legal.

/// Una sección del Aviso de Privacidad o de los Términos de uso.
class SeccionLegal {
  const SeccionLegal(this.titulo, this.cuerpo);

  final String titulo;
  final String cuerpo;
}

/// Documento legal con sus secciones y la que se abre por defecto.
class DocumentoLegal {
  const DocumentoLegal({
    required this.titulo,
    required this.secciones,
    required this.abiertaPorDefecto,
  });

  final String titulo;
  final List<SeccionLegal> secciones;

  /// Índice de la sección abierta al entrar.
  final int abiertaPorDefecto;
}

abstract final class TextosLegales {
  /// BORRADOR legal: revisar antes de publicar.
  static const DocumentoLegal avisoPrivacidad = DocumentoLegal(
    titulo: 'Aviso de Privacidad',
    abiertaPorDefecto: 1,
    secciones: [
      SeccionLegal(
        '¿Quién es responsable?',
        'El equipo del proyecto AboGator es responsable del tratamiento de tus datos '
            'personales, conforme a la Ley Federal de Protección de Datos Personales en Posesión '
            'de los Particulares (LFPDPPP). Puedes escribirnos al correo de contacto del equipo '
            'del proyecto para cualquier duda sobre este aviso.',
      ),
      SeccionLegal(
        '¿Qué datos recopilamos?',
        'Datos de cuenta: nombre, correo electrónico y perfil (estudiante, desarrollador o '
            'legal). Datos de uso: tus respuestas, progreso, vidas, monedas y racha. Datos del '
            'dispositivo: tipo de dispositivo y tus preferencias de accesibilidad. No recopilamos '
            'datos personales sensibles.',
      ),
      SeccionLegal(
        '¿Para qué los usamos?',
        'Usamos tus datos para crear y mantener tu cuenta, guardar tu progreso y adaptar los '
            'casos a tu perfil. También los usamos para enviarte los avisos que actives, como los '
            'de racha o los juicios de apelación. No los usamos para publicidad.',
      ),
      SeccionLegal(
        'Tus derechos ARCO',
        'Tienes derecho a acceder a tus datos, rectificarlos si son inexactos, cancelarlos '
            'cuando ya no sean necesarios y oponerte a su uso para fines específicos. Para '
            'ejercerlos, escríbenos al correo del equipo del proyecto; te responderemos en un '
            'plazo máximo de 20 días hábiles.',
      ),
      SeccionLegal(
        'Transferencias de datos',
        'No vendemos ni compartimos tus datos con terceros. Solo los compartimos con los '
            'proveedores que alojan el servicio, que están obligados a protegerlos, o cuando una '
            'autoridad competente lo solicite conforme a la ley.',
      ),
      SeccionLegal(
        'Conservación y seguridad',
        'Guardamos tus datos mientras tu cuenta esté activa y los eliminamos cuando la '
            'cancelas. Protegemos la información con conexiones cifradas y acceso restringido; '
            'las contraseñas nunca se guardan en texto plano.',
      ),
      SeccionLegal(
        'Cambios a este aviso',
        'Si cambiamos este aviso, te lo diremos dentro de la app antes de que el cambio entre '
            'en vigor. La versión vigente y su fecha aparecen siempre al inicio de esta pantalla.',
      ),
    ],
  );

  /// BORRADOR legal: revisar antes de publicar.
  static const DocumentoLegal terminos = DocumentoLegal(
    titulo: 'Términos de uso',
    abiertaPorDefecto: 3,
    secciones: [
      SeccionLegal(
        'Aceptación de los términos',
        'Al crear una cuenta o usar AboGator aceptas estos términos. Si no estás de acuerdo con '
            'ellos, no uses la app.',
      ),
      SeccionLegal(
        'Tu cuenta',
        'Eres responsable de la información de tu cuenta y de mantener segura tu contraseña. '
            'Avísanos si crees que alguien más entró a tu cuenta.',
      ),
      SeccionLegal(
        'Uso permitido',
        'Usa la app solo para aprender. No intentes alterar el juego, acceder a cuentas ajenas '
            'ni copiar el contenido para venderlo.',
      ),
      SeccionLegal(
        'Contenido educativo',
        'AboGator es una herramienta educativa. Los casos y veredictos sirven para aprender y no '
            'sustituyen la asesoría de un abogado. Revisa siempre la normativa vigente de tu país '
            'antes de aplicarla en un proyecto real.',
      ),
      SeccionLegal(
        'Vidas, monedas y compras',
        'Las vidas, monedas y comodines solo existen dentro del juego: no tienen valor en dinero '
            'ni se pueden cambiar por él. Se ganan jugando y pueden ajustarse si detectamos un '
            'error.',
      ),
      SeccionLegal(
        'Propiedad intelectual',
        'Los casos, ilustraciones, la mascota Sarko y el resto del contenido pertenecen al '
            'equipo del proyecto. Puedes usarlos para tu aprendizaje personal, pero no '
            'republicarlos sin permiso.',
      ),
      SeccionLegal(
        'Suspensión de la cuenta',
        'Podemos suspender una cuenta que incumpla estos términos. Antes de hacerlo, te '
            'avisaremos por correo y podrás explicarnos lo que pasó.',
      ),
      SeccionLegal(
        'Cambios a los términos',
        'Si cambiamos estos términos, te avisaremos dentro de la app. Seguir usándola después '
            'del aviso significa que aceptas la nueva versión.',
      ),
    ],
  );
}
