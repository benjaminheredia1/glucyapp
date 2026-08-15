import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/onboarding/questions_components/crear_cuenta_screen.dart';

const _maria = Usuario(id: 7, name: 'Maria', email: 'maria@ejemplo.com', rol: Rol.paciente);

class AuthRepositoryFalso implements AuthRepository {
  Object? errorAlIniciar;
  int intentos = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion}) async {
    intentos++;
    // Un retraso real (no solo microtasks) para que el estado de carga sea
    // observable: `tester.tap` agota la cola de microtasks antes de volver,
    // asi que un Future que resuelve sin espera real nunca deja ver el
    // AsyncLoading intermedio. `tester.pump()` sin duracion no avanza el
    // reloj falso, asi que este timer no dispara todavia.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return _maria;
  }

  @override
  Future<Usuario?> restaurarSesion() async => null;

  @override
  Future<void> cerrarSesion() async {}
}

Future<void> montar(WidgetTester tester, AuthRepositoryFalso repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: CrearCuentaScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el boton de acceso llama a iniciarSesion', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(repo.intentos, 1);
  });

  testWidgets('el boton de Apple esta deshabilitado', (tester) async {
    await montar(tester, AuthRepositoryFalso());

    final boton = tester.widget<OutlinedButton>(find.byKey(const Key('boton-apple')));

    expect(boton.onPressed, isNull);
  });

  testWidgets('un fallo del servidor se muestra en pantalla', (tester) async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = const FalloServidor('El servidor tuvo un problema.');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mensaje-error')), findsOneWidget);
    expect(find.text('El servidor tuvo un problema.'), findsOneWidget);

    // Un error no debe dejar el boton bloqueado: el usuario tiene que poder
    // reintentar sin recargar la pantalla.
    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder')));
    expect(boton.onPressed, isNotNull);
  });

  testWidgets('un fallo de validacion muestra el mensaje del campo, no el generico', (tester) async {
    final repo = AuthRepositoryFalso()
      ..errorAlIniciar = const FalloValidacion(
        'Los datos enviados no son validos.',
        {
          'email': ['El correo ya esta registrado.'],
        },
      );
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mensaje-error')), findsOneWidget);
    expect(find.text('El correo ya esta registrado.'), findsOneWidget);
    // Si MensajeError cayera al caso generico en vez de listar `errores`,
    // veriamos este mensaje en su lugar.
    expect(find.text('Los datos enviados no son validos.'), findsNothing);
  });

  testWidgets('un 503 explica que el proveedor no responde', (tester) async {
    final repo = AuthRepositoryFalso()
      ..errorAlIniciar = const FalloServidor('El proveedor de identidad no esta disponible.');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(find.text('El proveedor de identidad no esta disponible.'), findsOneWidget);
  });

  testWidgets('mientras carga, el boton no admite otro toque', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pump(); // en AsyncLoading, sin resolver todavia

    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder')));
    expect(boton.onPressed, isNull);

    await tester.pumpAndSettle();
  });

  testWidgets('sin error no se pinta el mensaje', (tester) async {
    await montar(tester, AuthRepositoryFalso());

    expect(find.byKey(const Key('mensaje-error')), findsNothing);
  });

  testWidgets('un fallo que no es FalloApi tambien se muestra, no queda en silencio', (tester) async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = StateError('token corrupto en el almacen seguro');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(find.textContaining('token corrupto en el almacen seguro'), findsOneWidget);

    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder')));
    expect(boton.onPressed, isNotNull);
  });
}
