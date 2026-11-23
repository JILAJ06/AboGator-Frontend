import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Tamaño de pantalla y escala del texto de un caso de «sin desbordes».
typedef CasoDesborde = (Size tamano, double escala);

/// Las 6 combinaciones del móvil: 390×844, 360×640 y 320×640, a 1.0 y 2.0.
const casosMovil = <CasoDesborde>[
  (Size(390, 844), 1.0),
  (Size(390, 844), 2.0),
  (Size(360, 640), 1.0),
  (Size(360, 640), 2.0),
  (Size(320, 640), 1.0),
  (Size(320, 640), 2.0),
];

/// [casosMovil] sin 360×640 a 1.0.
const casosMovilCinco = <CasoDesborde>[
  (Size(390, 844), 1.0),
  (Size(390, 844), 2.0),
  (Size(360, 640), 2.0),
  (Size(320, 640), 1.0),
  (Size(320, 640), 2.0),
];

/// Solo los casos con texto grande o la pantalla más angosta.
const casosTextoGrande = <CasoDesborde>[
  (Size(390, 844), 2.0),
  (Size(360, 640), 2.0),
  (Size(320, 640), 1.0),
  (Size(320, 640), 2.0),
];

/// Fija la escala del texto (y, si se da, el brillo del sistema) de la prueba
/// y los restaura al terminar.
void fijarTextoYBrillo(WidgetTester tester, double escala, [Brightness? brillo]) {
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  if (brillo != null) tester.platformDispatcher.platformBrightnessTestValue = brillo;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (brillo != null) addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
}

/// Registra una prueba por caso de [casos] (y por brillo, con [ambosBrillos])
/// que fija la escala del texto y el brillo y luego corre [cuerpo]. Con
/// [grupo] las agrupa; con `grupo: null` las deja en el grupo actual.
///
/// Nombre: `'$prefijo390×844 ${texto}2.0x'`, más ` dark` o ` light` con
/// [ambosBrillos].
void probarSinDesbordes(
  Future<void> Function(WidgetTester tester, Size tamano, double escala) cuerpo, {
  String? grupo = 'sin desbordes',
  List<CasoDesborde> casos = casosMovil,
  bool ambosBrillos = false,
  String prefijo = '',
  String texto = '',
}) {
  void registrar() {
    for (final (tamano, escala) in casos) {
      for (final brillo in ambosBrillos ? Brightness.values : const [null]) {
        final medida = '${tamano.width.toInt()}×${tamano.height.toInt()}';
        final sufijo = brillo == null ? '' : ' ${brillo.name}';
        testWidgets('$prefijo$medida $texto${escala}x$sufijo', (tester) async {
          fijarTextoYBrillo(tester, escala, brillo);
          await cuerpo(tester, tamano, escala);
        });
      }
    }
  }

  if (grupo == null) {
    registrar();
  } else {
    group(grupo, registrar);
  }
}
