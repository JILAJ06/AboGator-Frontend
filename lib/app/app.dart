import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/tema/modo_tema.dart';
import '../core/tema/tema_app.dart';
import '../core/tema/tipografia.dart';
import '../core/textos/textos.dart';
import 'enrutador.dart';

/// Idioma único de la app: español de México.
const Locale localeApp = Locale('es', 'MX');

class AppAbogator extends ConsumerWidget {
  const AppAbogator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(modoTemaProvider);
    final fuente = ref.watch(resolutorFuenteProvider);
    final enrutador = ref.watch(enrutadorProvider);

    return MaterialApp.router(
      title: Textos.nombreApp,
      debugShowCheckedModeBanner: false,
      theme: crearTemaClaro(fuente),
      darkTheme: crearTemaOscuro(fuente),
      themeMode: modo,
      locale: localeApp,
      supportedLocales: const [localeApp],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: enrutador,
    );
  }
}
