import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/tema/modo_tema.dart';
import '../core/tema/tema_app.dart';
import '../core/textos/textos.dart';
import '../funciones/ajustes/estado_ajustes.dart';
import '../funciones/ajustes/logica_ajustes.dart';
import 'enrutador.dart';

/// Idioma único de la app: español de México.
const Locale localeApp = Locale('es', 'MX');

class AppAbogator extends ConsumerWidget {
  const AppAbogator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(modoTemaProvider);
    final ajustes = ref.watch(ajustesProvider);
    final enrutador = ref.watch(enrutadorProvider);

    return MaterialApp.router(
      title: Textos.nombreApp,
      debugShowCheckedModeBanner: false,
      theme: crearTemaClaro(),
      darkTheme: crearTemaOscuro(),
      themeMode: modo,
      locale: localeApp,
      supportedLocales: const [localeApp],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: enrutador,
      // Tamaño de texto y "reducir animaciones" de los ajustes (pantalla 26):
      // aquí llegan también a diálogos y paneles.
      builder: (context, hijo) => MediaQuery(
        data: LogicaAjustes.aplicar(MediaQuery.of(context), ajustes),
        child: hijo ?? const SizedBox.shrink(),
      ),
    );
  }
}
