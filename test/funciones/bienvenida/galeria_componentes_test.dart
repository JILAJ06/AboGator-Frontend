import 'package:abogator/app/app.dart';
import 'package:abogator/app/enrutador.dart';
import 'package:abogator/app/rutas.dart';
import 'package:abogator/componentes/acciones_veredicto.dart';
import 'package:abogator/componentes/aviso_conexion.dart';
import 'package:abogator/componentes/aviso_informativo.dart';
import 'package:abogator/componentes/barra_comodines.dart';
import 'package:abogator/componentes/barra_progreso.dart';
import 'package:abogator/componentes/boton_app.dart';
import 'package:abogator/componentes/boton_veredicto.dart';
import 'package:abogator/componentes/campo_texto_app.dart';
import 'package:abogator/componentes/chip_hud.dart';
import 'package:abogator/componentes/confeti_sprint.dart';
import 'package:abogator/componentes/corazon_vida.dart';
import 'package:abogator/componentes/cuenta_regresiva_vida.dart';
import 'package:abogator/componentes/encabezado_modulo.dart';
import 'package:abogator/componentes/estadisticas_sprint.dart';
import 'package:abogator/componentes/estrellas_sprint.dart';
import 'package:abogator/componentes/etiqueta_quiebra.dart';
import 'package:abogator/componentes/fila_acordeon.dart';
import 'package:abogator/componentes/fila_apelacion.dart';
import 'package:abogator/componentes/fila_detalle_sprint.dart';
import 'package:abogator/componentes/globo_sprint_actual.dart';
import 'package:abogator/componentes/hoja_lateral.dart';
import 'package:abogator/componentes/ilustracion_insignia.dart';
import 'package:abogator/componentes/impacto_startup.dart';
import 'package:abogator/componentes/indicador_pendientes.dart';
import 'package:abogator/componentes/indicadores_startup.dart';
import 'package:abogator/componentes/interruptor_conexion_debug.dart';
import 'package:abogator/componentes/logo_app.dart';
import 'package:abogator/componentes/navegacion_inferior_app.dart';
import 'package:abogator/componentes/nodo_sprint.dart';
import 'package:abogator/componentes/notificacion_apelacion.dart';
import 'package:abogator/componentes/opcion_justificacion.dart';
import 'package:abogator/componentes/paginador_puntos.dart';
import 'package:abogator/componentes/panel_evidencia.dart';
import 'package:abogator/componentes/panel_justificacion.dart';
import 'package:abogator/componentes/panel_lateral_juego.dart';
import 'package:abogator/componentes/panel_veredicto.dart';
import 'package:abogator/componentes/piezas_ajustes.dart';
import 'package:abogator/componentes/piezas_apelacion.dart';
import 'package:abogator/componentes/piezas_jefe.dart';
import 'package:abogator/componentes/piezas_perfil.dart';
import 'package:abogator/componentes/piezas_resultado.dart';
import 'package:abogator/componentes/piezas_tienda.dart';
import 'package:abogator/componentes/riel_navegacion.dart';
import 'package:abogator/componentes/sarko_imagen.dart';
import 'package:abogator/componentes/sello_veredicto.dart';
import 'package:abogator/componentes/snippet_codigo.dart';
import 'package:abogator/componentes/tarjeta_buzon_inicio.dart';
import 'package:abogator/componentes/tarjeta_caso.dart';
import 'package:abogator/componentes/tarjeta_consejo_sarko.dart';
import 'package:abogator/componentes/tarjeta_semana.dart';
import 'package:abogator/core/tema/tokens_color.dart';
import 'package:abogator/core/textos/textos.dart';
import 'package:abogator/datos/modelos/tarjeta.dart';
import 'package:abogator/funciones/bienvenida/galeria_componentes.dart';
import 'package:abogator/funciones/notificaciones/selector_hora.dart';
import 'package:abogator/funciones/vidas/pantalla_sin_vidas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Pantalla alta para que la galería entera quede construida.
Future<void> montarGaleria(WidgetTester tester) async {
  await abrirGaleria(tester);
  await agrandar(tester, const Size(390, 36000));
}

/// Agranda la superficie después de navegar (la transición de página no
/// puede rasterizar superficies tan altas).
Future<void> agrandar(WidgetTester tester, Size tamano) async {
  await tester.binding.setSurfaceSize(tamano);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpAndSettle();
}

/// Monta la app (que arranca en el Splash) y navega a la galería.
Future<void> abrirGaleria(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: AppAbogator()));
  ProviderScope.containerOf(tester.element(find.byType(AppAbogator)))
      .read(enrutadorProvider)
      .go(Rutas.galeria);
  await tester.pumpAndSettle();
}

TokensColor tokensActuales(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(GaleriaComponentes))).extension<TokensColor>()!;

void main() {
  testWidgets('la app abre en la galería con todos los componentes', (tester) async {
    await montarGaleria(tester);
    expect(find.text(Textos.galeriaTitulo), findsOneWidget);
    expect(find.byType(BotonApp), findsNWidgets(26)); // 8 + globo + 5 paneles + 3 visores + panel 18 + Abogado + 2 del Buzón (20) + Buzón del Inicio de tablet + 4 de los selectores de hora (T-13b)
    expect(find.byType(RielNavegacion), findsOneWidget);
    expect(find.byType(TarjetaSemana), findsNWidgets(2));
    expect(find.byType(TarjetaBuzonInicio), findsNWidgets(2));
    expect(find.byType(TarjetaConsejoSarko), findsNWidgets(2)); // Inicio y Tienda (T-12b)
    expect(find.byType(TarjetaProgresoModulos), findsOneWidget);
    expect(find.byType(VistaPreviaTexto), findsOneWidget);
    expect(find.byType(BotonVeredicto), findsNWidgets(12)); // 8 + los de las acciones
    expect(find.byType(CampoTextoApp), findsNWidgets(4));
    expect(find.byType(ChipHud), findsNWidgets(8)); // 5 + 2 encabezados + barra de juego
    expect(find.byType(FilaVidas), findsNWidgets(3));
    // + la de "Tu Startup" del juego en tablet (T-12c).
    expect(find.byType(IndicadoresStartup), findsNWidgets(2));
    expect(find.byType(TarjetaTuStartup), findsOneWidget);
    expect(find.byType(TarjetaContextoSprint), findsOneWidget);
    expect(find.byType(TarjetaAtajos), findsOneWidget);
    expect(find.byType(HojaLateral), findsOneWidget);
    expect(find.byType(ImpactoStartup), findsNWidgets(6)); // 1 + 5 paneles
    expect(find.byType(BarraProgreso), findsNWidgets(6)); // 4 + barras de juego y juicio
    expect(find.byType(InsigniaVida), findsNWidgets(5)); // 4 + barra del juicio
    expect(find.byType(AvisoFallo), findsOneWidget);
    expect(find.byType(FilaRepaso), findsNWidgets(2));
    expect(find.byType(TarjetaArticulo), findsNWidgets(4));
    expect(find.byType(PildoraSaldo), findsOneWidget);
    expect(find.byType(MedallaInsignia), findsNWidgets(2));
    expect(find.byType(FilaMenu), findsNWidgets(2));
    expect(find.byType(BarraDelJefe), findsNWidgets(2)); // + la de TarjetaJefe (T-12d)
    expect(find.byType(TemporizadorCrisis), findsNWidgets(2));
    expect(find.byType(ChipGolpe), findsNWidgets(2));
    expect(find.byType(PanelContraargumento), findsOneWidget);
    expect(find.byType(TarjetaCertificado), findsOneWidget);
    expect(find.byType(EsqueletoCertificado), findsOneWidget);
    expect(find.byType(FilaResumenExamen), findsOneWidget);
    expect(find.byType(TrofeoCertificado), findsOneWidget);
    expect(find.byType(PaginadorPuntos), findsOneWidget);
    expect(find.byType(SarkoImagen), findsNWidgets(14)); // 5 + 5 paneles + 3 ilustraciones y la de T34 (T-13b)
    expect(
      find.byType(LogoApp),
      findsNWidgets(26),
    ); // + isotipo del riel + 2 notificaciones de racha (T-13b)
    expect(find.byType(NavegacionInferiorApp), findsOneWidget);
    expect(find.byType(EncabezadoModulo), findsNWidgets(2));
    // Fin de sprint (19 y 19b).
    expect(find.byType(ConfetiSprint), findsNWidgets(2));
    expect(find.byType(EstrellasSprint), findsNWidgets(3));
    expect(find.byType(EstadisticasSprint), findsOneWidget);
    expect(find.byType(AvisoInformativo), findsNWidgets(2));
    expect(find.byType(EtiquetaQuiebra), findsNWidgets(2));
    expect(find.byType(NodoSprint), findsNWidgets(6)); // + el nodo seleccionado de tablet (T-12b)
    expect(
      tester.widgetList<NodoSprint>(find.byType(NodoSprint)).map((n) => n.tipo).toSet(),
      TipoNodoSprint.values.toSet(),
    );
    expect(find.byType(GloboSprintActual), findsOneWidget);
    expect(find.byType(FilaDetalleSprint), findsNWidgets(3));
    expect(find.byType(TarjetaCaso), findsNWidgets(4));
    expect(
      tester.widgetList<TarjetaCaso>(find.byType(TarjetaCaso)).map((t) => t.tipo).toSet(),
      TipoTarjeta.values.toSet(),
    );
    expect(find.byType(SnippetCodigo), findsNWidgets(5)); // 2 sueltos + 3 visores
    expect(find.byType(PanelEvidencia), findsNWidgets(3));
    expect(find.byType(PanelJustificacion), findsOneWidget);
    expect(find.byType(SelloVeredicto), findsNWidgets(4));
    expect(find.byType(AccionesVeredicto), findsOneWidget);
    expect(find.byType(BarraComodines), findsNWidgets(3));
    expect(find.byType(CuentaRegresivaVida), findsOneWidget);
    expect(find.byType(SugerenciaBuzon), findsNWidgets(2));
    expect(find.byType(AvisoConexion), findsNWidgets(2));
    expect(find.byType(IndicadorPendientes), findsNWidgets(2));
    expect(find.byType(InterruptorConexionDebug), findsOneWidget);
    expect(find.byType(TarjetaRecompensaBuzon), findsNWidgets(3));
    expect(find.byType(FilaApelacion), findsNWidgets(5)); // + la seleccionada (T-12d)
    expect(find.byType(TarjetaJefe), findsOneWidget);
    expect(find.byType(NotificacionApelacion), findsNWidgets(2));
    // T-13b: 21b (2) + 34b (2) comparten la notificación del sistema.
    expect(find.byType(NotificacionSistema), findsNWidgets(4));
    expect(find.byType(IlustracionInsignia), findsNWidgets(3));
    expect(find.byType(FilaAcordeon), findsNWidgets(2));
    expect(find.byType(InterruptorTocable), findsOneWidget);
    expect(find.byType(SelectorHora), findsNWidgets(2));
    expect(
      tester.widgetList<PanelVeredicto>(find.byType(PanelVeredicto)).map((p) => p.tipo),
      TipoPanelVeredicto.values,
    );
    // 2 de la micro-pregunta, 3 sueltas en modo selección y 3 del panel 18.
    expect(find.byType(OpcionJustificacion), findsNWidgets(10));
    expect(tester.takeException(), isNull);
  });

  testWidgets('el interruptor alterna entre claro y oscuro', (tester) async {
    await montarGaleria(tester);
    expect(tokensActuales(tester).fondoApp, TokensColor.claro.fondoApp);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(tokensActuales(tester).fondoApp, TokensColor.oscuro.fondoApp);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la navegación inferior cambia de pestaña', (tester) async {
    await montarGaleria(tester);
    await tester.tap(
      find.descendant(of: find.byType(NavegacionInferiorApp), matching: find.text('Perfil')),
    );
    await tester.pump();
    expect(
      tester.widget<NavegacionInferiorApp>(find.byType(NavegacionInferiorApp)).actual,
      PestanaApp.perfil,
    );
  });

  for (final brillo in Brightness.values) {
    testWidgets('con texto al 200 % no hay desbordes (${brillo.name})', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      tester.platformDispatcher.platformBrightnessTestValue = brillo;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await abrirGaleria(tester);
      await agrandar(tester, const Size(390, 22000));
      expect(tester.takeException(), isNull);
    });
  }
}
