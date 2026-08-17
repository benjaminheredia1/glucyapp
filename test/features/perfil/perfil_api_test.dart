import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';

void main() {
  group('PerfilPaciente.fromJson', () {
    test('lee pesoKg cuando llega como string decimal (MySQL) o como numero', () {
      // El backend serializa el decimal(5,2) de MySQL como "50.00".
      expect(PerfilPaciente.fromJson({'id': 5, 'pesoKg': '50.00'}).pesoKg, 50.0);
      expect(PerfilPaciente.fromJson({'id': 5, 'pesoKg': 74}).pesoKg, 74.0);
      expect(PerfilPaciente.fromJson({'id': 5, 'pesoKg': 74.5}).pesoKg, 74.5);
      expect(PerfilPaciente.fromJson({'id': 5, 'pesoKg': null}).pesoKg, isNull);
    });

    test('lee tallaCm como entero o como string', () {
      expect(PerfilPaciente.fromJson({'id': 5, 'tallaCm': 178}).tallaCm, 178);
      expect(PerfilPaciente.fromJson({'id': 5, 'tallaCm': '178'}).tallaCm, 178);
    });

    test('un pesoKg basura no revienta: queda null', () {
      expect(PerfilPaciente.fromJson({'id': 5, 'pesoKg': 'abc'}).pesoKg, isNull);
    });
  });
}
