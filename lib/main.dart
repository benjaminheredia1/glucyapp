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

  final AppConfig config;

  try {
    // dotenv.load tiene que fallar tambien aqui dentro: si se queda fuera del
    // try, un .env que falta -- el fallo de configuracion mas probable ahora
    // mismo, con el tenant de Auth0 todavia sin dar de alta -- tira la app
    // antes de que _PantallaDeConfigRota llegue a explicar nada.
    await dotenv.load(fileName: '.env');
    config = AppConfig.desdeMapa(dotenv.env);
  } on ConfigInvalida catch (e) {
    // Fallar aqui, con el motivo exacto, en vez de dar errores raros de red mas
    // adelante.
    runApp(_PantallaDeConfigRota(mensaje: e.mensaje));

    return;
  } on FileNotFoundError {
    // FileNotFoundError y EmptyEnvFileError son Error, no Exception: asi
    // modela flutter_dotenv un fallo de configuracion recuperable, no un bug
    // de programacion, y por eso vale la pena capturarlas aqui igual que
    // ConfigInvalida.
    runApp(
      const _PantallaDeConfigRota(
        mensaje: 'Falta el archivo .env. Copia .env.example y rellenalo.',
      ),
    );

    return;
  } on EmptyEnvFileError {
    runApp(
      const _PantallaDeConfigRota(
        mensaje: 'El archivo .env esta vacio. Copia .env.example y rellenalo.',
      ),
    );

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
