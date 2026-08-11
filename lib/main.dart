import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/glucy_app.dart';
import 'app/theme/glucy_palette.dart';
import 'core/config/app_config.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/renovador_sesion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final AppConfig config;

  try {
    config = AppConfig.desdeMapa(dotenv.env);
  } on ConfigInvalida catch (e) {
    // Fallar aqui, con el motivo exacto, en vez de dar errores raros de red mas
    // adelante.
    runApp(_PantallaDeConfigRota(mensaje: e.mensaje));

    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        // Cierra el circulo: el interceptor ya puede renovar de verdad.
        renovadorProvider.overrideWith((ref) => ref.watch(renovadorRealProvider)),
      ],
      child: const GlucyApp(),
    ),
  );
}

class _PantallaDeConfigRota extends StatelessWidget {
  const _PantallaDeConfigRota({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: GlucyPalette.deep,
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Text(
              'La app no puede arrancar.\n\n$mensaje',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}
