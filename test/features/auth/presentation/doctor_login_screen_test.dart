import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/doctor/doctor_login_screen.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';

const _doctor = Usuario(id: 3, name: 'Dr. Medina', email: 'medina@clinica.com', rol: Rol.doctor);

class AuthRepositoryFalso implements AuthRepository {
  Object? errorAlIniciar;
  int intentos = 0;
  bool? ultimoReclamar;
  final List<bool> reclamos = [];

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async {
    intentos++;
    ultimoReclamar = reclamar;
    reclamos.add(reclamar);
    // Un retraso real (no solo microtasks) para que el estado de carga sea
    // observable: `tester.tap` agota la cola de microtasks antes de volver,
    // asi que un Future que resuelve sin espera real nunca deja ver el
    // AsyncLoading intermedio. `tester.pump()` sin duracion no avanza el
    // reloj falso, asi que este timer no dispara todavia.
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return _doctor;
  }

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

  @override
  Future<Usuario?> restaurarSesion() async => null;

  @override
  Future<void> cerrarSesion() async {}
}

Future<void> montar(WidgetTester tester, AuthRepositoryFalso repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: DoctorLoginScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el acceso medico usa el mismo Universal Login', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico')));
    await tester.pumpAndSettle();

    expect(repo.intentos, 1);
  });

  testWidgets('el acceso medico nunca reclama la identidad anonima', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico')));
    await tester.pumpAndSettle();

    expect(repo.ultimoReclamar, isFalse);
  });

  testWidgets('no pide contrasena en la propia app', (tester) async {
    await montar(tester, AuthRepositoryFalso());

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Contraseña'), findsNothing);
  });

  testWidgets('un fallo se muestra en pantalla', (tester) async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = const FalloRed('No hay conexion con el servidor.');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mensaje-error')), findsOneWidget);
    expect(find.text('No hay conexion con el servidor.'), findsOneWidget);

    // Un error no debe dejar el boton bloqueado: el usuario tiene que poder
    // reintentar sin recargar la pantalla.
    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder-medico')));
    expect(boton.onPressed, isNotNull);
  });

  testWidgets('mientras carga, el boton no admite otro toque', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico')));
    await tester.pump(); // en AsyncLoading, sin resolver todavia

    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder-medico')));
    expect(boton.onPressed, isNull);

    await tester.pumpAndSettle();
  });

  testWidgets('un fallo que no es FalloApi tambien se muestra, no queda en silencio', (tester) async {
    final repo = AuthRepositoryFalso()..errorAlIniciar = StateError('token corrupto en el almacen seguro');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico')));
    await tester.pumpAndSettle();

    expect(find.textContaining('token corrupto en el almacen seguro'), findsOneWidget);

    final boton = tester.widget<FilledButton>(find.byKey(const Key('boton-acceder-medico')));
    expect(boton.onPressed, isNotNull);
  });
}
