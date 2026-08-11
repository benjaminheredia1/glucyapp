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

  @override
  Future<Usuario> iniciarSesion() async {
    intentos++;
    if (errorAlIniciar != null) throw errorAlIniciar!;

    return _doctor;
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

    expect(find.text('No hay conexion con el servidor.'), findsOneWidget);
  });
}
