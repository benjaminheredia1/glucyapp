import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/features/mediciones/medicion_api.dart';
import 'package:glucy_app/features/mediciones/mediciones_provider.dart';

Medicion _m(int id, double valor, DateTime cuando) =>
    Medicion(id: id, valor: valor, momento: 'ayunas', medidoEn: cuando);

class MedicionApiFalsa implements MedicionApi {
  MedicionApiFalsa(this.devueltas);

  List<Medicion> devueltas;
  int llamadas = 0;

  @override
  Future<List<Medicion>> recientes({int cantidad = 7}) async {
    llamadas++;
    return devueltas;
  }

  @override
  Future<Medicion> registrar({required double valor, required String momento, String? nota}) =>
      throw UnimplementedError();
}

void main() {
  group('Medicion.fromJson', () {
    test('lee valor como numero o como string decimal (MySQL)', () {
      final base = {'id': 3, 'momento': 'ayunas', 'medidoEn': '2026-08-17T22:08:17.000000Z'};

      expect(Medicion.fromJson({...base, 'valor': 108}).valor, 108.0);
      expect(Medicion.fromJson({...base, 'valor': '108.00'}).valor, 108.0);
    });
  });

  group('medicionesProvider', () {
    test('devuelve las mediciones de la mas antigua a la mas reciente', () async {
      final hoy = DateTime(2026, 8, 17, 8);
      final api = MedicionApiFalsa([
        _m(3, 124, hoy),
        _m(2, 132, hoy.subtract(const Duration(days: 1))),
        _m(1, 138, hoy.subtract(const Duration(days: 2))),
      ]);
      final c = ProviderContainer(overrides: [medicionApiProvider.overrideWithValue(api)]);
      addTearDown(c.dispose);

      final lista = await c.read(medicionesProvider.future);

      expect(lista.map((m) => m.id), [1, 2, 3]);
    });
  });

  group('MedicionesResumen', () {
    final hoy = DateTime(2026, 8, 17, 8);
    final lista = [
      _m(1, 150, hoy.subtract(const Duration(days: 40))),
      _m(2, 130, hoy.subtract(const Duration(days: 2))),
      _m(3, 110, hoy.subtract(const Duration(days: 1))),
      _m(4, 126, hoy),
    ];

    test('promedio y porcentaje en rango (<= 130)', () {
      expect(lista.promedio, closeTo(129, 0.01));
      expect(lista.porcentajeEnRango, 75);
    });

    test('sin datos, promedio y porcentaje son null', () {
      expect(<Medicion>[].promedio, isNull);
      expect(<Medicion>[].porcentajeEnRango, isNull);
    });

    test('ultimosDias filtra por fecha', () {
      expect(lista.ultimosDias(7, ahora: hoy).map((m) => m.id), [2, 3, 4]);
      expect(lista.ultimosDias(90, ahora: hoy).length, 4);
    });
  });
}
