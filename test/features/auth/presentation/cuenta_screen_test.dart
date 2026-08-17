import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/home/cuenta_screen.dart';

/// Fix 2 del review final: antes de este fix, "Cerrar sesión" navegaba a
/// mano con `Navigator.pushAndRemoveUntil` sin tocar `SesionController`, asi
/// que el token de Sanctum, las credenciales de Auth0 y `POST /auth/logout`
/// nunca se disparaban. Este doble cuenta las llamadas a `cerrarSesion()`
/// para probar que el boton de verdad llega hasta ahi.
class AuthRepositoryFalso implements AuthRepository {
  int cierres = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async => throw UnimplementedError();

  @override
  Future<Usuario> entrarComoAnonimo() async => throw UnimplementedError();

  @override
  Future<Usuario?> restaurarSesion() async => null;

  @override
  Future<void> cerrarSesion() async => cierres++;
}

void main() {
  testWidgets('el boton de cerrar sesion llama a SesionController.cerrarSesion', (tester) async {
    final repo = AuthRepositoryFalso();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: CuentaScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // El boton queda debajo del fold en el viewport de prueba: el
    // SingleChildScrollView de la pantalla no lo trae a la vista solo.
    final boton = find.byKey(const Key('boton-cerrar-sesion'));
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();

    expect(repo.cierres, 1);
  });
}
