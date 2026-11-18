import '../../core/textos/textos.dart';
import '../modelos/tarjeta.dart';
import '../repositorios/repositorio_tarjetas.dart';
import 'espera_simulada.dart';

/// Tarjetas simuladas con casos de ejemplo.
class MockTarjetas implements RepositorioTarjetas {
  MockTarjetas({this.espera = esperaSimuladaPorDefecto});

  final Duration espera;

  static const Map<String, List<Tarjeta>> tarjetasPorSprint = {
    'spr-2-1': [
      Tarjeta(
        id: 'tar-gpl-01',
        tipo: TipoTarjeta.evidencia,
        texto:
            'Tu equipo integra una librería con licencia GPL v3 en la app móvil, '
            'que se distribuye con código cerrado. ¿Es legal?',
        respuestaCorrecta: Veredicto.ilegal,
        explicacion:
            'La GPL v3 obliga a distribuir la obra derivada bajo la misma licencia '
            'y a publicar su código fuente. Usarla en una app cerrada la incumple.',
        evidencia: 'dependencies:\n  pdf_engine: ^2.1.0  # Licencia: GPL-3.0',
      ),
      Tarjeta(
        id: 'tar-mit-02',
        tipo: TipoTarjeta.normal,
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
