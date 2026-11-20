import 'dart:async';

import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/datos/mocks/mock_apelaciones.dart';
import 'package:abogator/datos/mocks/mock_progreso.dart';
import 'package:abogator/datos/mocks/mock_tarjetas.dart';
import 'package:abogator/datos/mocks/mock_tienda.dart';
import 'package:abogator/datos/mocks/mock_vidas.dart';
import 'package:abogator/datos/mocks/onboarding_en_memoria.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/datos/modelos/usuario.dart';
import 'package:abogator/datos/repositorios/proveedores_repositorios.dart';
import 'package:abogator/datos/repositorios/repositorio_tarjetas.dart';
import 'package:abogator/funciones/acceso/sesion.dart';
import 'package:abogator/funciones/juego/estado_juego.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const ana = Usuario(
  id: 'u-ana',
  nombre: 'Ana López',
  correo: 'ana@startup.mx',
  perfil: PerfilUsuario.desarrollador,
  nivel: 4,
  xp: 0,
  racha: 7,
);

/// Sprint del mock con 10 tarjetas.
const sprintMock = 'spr-1-3';

class TarjetasFalsas implements RepositorioTarjetas {
  TarjetasFalsas(this.porSprint);

  final Map<String, List<Tarjeta>> porSprint;
  bool fallar = false;
  Completer<void>? bloqueo;
  int llamadas = 0;

  @override
  Future<List<Tarjeta>> obtenerTarjetasDelSprint(String sprintId) async {
    llamadas++;
    await bloqueo?.future;
    if (fallar) throw Exception('sin red');
    final lista = porSprint[sprintId];
    if (lista == null) throw StateError('no existe');
    return lista;
  }
}

/// Monta la app con sesión y abre [ruta] (el juego del sprint 3 del módulo 1
/// por defecto). Con [desdeIntro] abre primero la intro y entra con push.
Future<TarjetasFalsas> abrirJuego(
  WidgetTester tester, {
  String sprintId = sprintMock,
  String? ruta,
  Size tamano = const Size(390, 844),
  int vidas = 5,
  Map<String, List<Tarjeta>>? tarjetas,
  bool esperar = true,
  bool desdeIntro = false,
  bool conSesion = true,
  void Function(TarjetasFalsas)? antes,
  MockTienda? tienda,
}) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final repo = TarjetasFalsas(tarjetas ?? MockTarjetas.tarjetasPorSprint);
  antes?.call(repo);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositorioProgresoProvider.overrideWithValue(MockProgreso(espera: Duration.zero)),
        repositorioTiendaProvider.overrideWithValue(tienda ?? MockTienda(espera: Duration.zero)),
        repositorioVidasProvider.overrideWithValue(
          MockVidas(espera: Duration.zero, cantidad: vidas),
        ),
        repositorioTarjetasProvider.overrideWithValue(repo),
        repositorioApelacionesProvider.overrideWithValue(MockApelaciones(espera: Duration.zero)),
        repositorioOnboardingProvider.overrideWithValue(OnboardingEnMemoria(vistoAlInicio: true)),
      ],
      child: const AppAbogator(),
    ),
  );
  final contenedor = ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));
  if (conSesion) contenedor.read(sesionProvider.notifier).iniciar(ana);
  final enrutador = contenedor.read(enrutadorProvider);
  if (desdeIntro) {
    enrutador.go(Rutas.introSprintDe('mod-1', sprintId));
    await tester.pumpAndSettle();
    unawaited(enrutador.push(Rutas.juegoDe(sprintId)));
  } else {
    enrutador.go(ruta ?? Rutas.juegoDe(sprintId));
  }
  if (esperar) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
  return repo;
}

ProviderContainer contenedorDe(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(AppAbogator)));

String rutaActual(WidgetTester tester) =>
    contenedorDe(tester).read(enrutadorProvider).state.uri.path;

EstadoJuego estadoJuego(WidgetTester tester, [String sprintId = sprintMock]) =>
    contenedorDe(tester).read(juegoProvider(sprintId));

Finder get tarjeta => find.byKey(const ValueKey('gesto-tarjeta'));

/// Texto del caso de la tarjeta que se ve.
String textoActual(WidgetTester tester) =>
    tester.widget<TarjetaCaso>(find.byType(TarjetaCaso)).texto;

/// Botón "Salir" del diálogo de confirmación.
Finder get salirDelDialogo =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text('Salir'));

/// Si el elemento [contexto] contiene un widget de tipo [T].
bool contiene<T extends Widget>(BuildContext? contexto) {
  if (contexto == null) return false;
  var encontrado = false;
  void visitar(Element e) {
    if (encontrado) return;
    if (e.widget is T) {
      encontrado = true;
      return;
    }
    e.visitChildElements(visitar);
  }

  (contexto as Element).visitChildElements(visitar);
  return encontrado;
}

/// Cierra el panel de veredicto abierto: si hay micro-pregunta, primero
/// "Saltar bonus"; luego el botón del panel ("Continuar" o "Entendido").
Future<void> cerrarPanel(WidgetTester tester, {bool settle = true}) async {
  for (var i = 0; i < 3; i++) {
    final boton = find.descendant(of: find.byType(PanelVeredicto), matching: find.byType(BotonApp));
    if (boton.evaluate().isEmpty) return;
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
  }
}
