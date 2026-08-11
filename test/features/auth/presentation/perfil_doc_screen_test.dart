import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/doctor/perfil_doc_screen.dart';
import 'package:glucy_app/features/auth/data/auth_repository.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';

/// Fix 2 del review final: el boton "Cerrar sesión" del perfil del medico
/// tenia el mismo bug que el del paciente (`cuenta_screen_test.dart`):
/// navegaba a mano sin pasar por `SesionController.cerrarSesion()`.
class AuthRepositoryFalso implements AuthRepository {
  int cierres = 0;

  @override
  Future<Usuario> iniciarSesion() async => throw UnimplementedError();

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
        child: const MaterialApp(home: PerfilDocScreen()),
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
