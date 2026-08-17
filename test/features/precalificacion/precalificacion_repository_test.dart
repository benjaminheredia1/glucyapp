import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/core/network/error_interceptor.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_api.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adaptador;
  late PrecalificacionRepository repo;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    adaptador = DioAdapter(dio: dio);
    dio.interceptors.add(ErrorInterceptor());
    repo = PrecalificacionRepository(PrecalificacionApi(dio, dio));
  });

  test('preguntas() devuelve la lista ordenada del servidor', () async {
    adaptador.onGet('/precalificacion/preguntas', (servidor) => servidor.reply(200, [
          {'id': 1, 'codigo': 'q1', 'texto': '¿Tienes 18 años o más?', 'orden': 1, 'version': 1},
          {'id': 2, 'codigo': 'q2', 'texto': '¿Estás embarazada o en lactancia?', 'orden': 2, 'version': 1},
        ]));

    final preguntas = await repo.preguntas();

    expect(preguntas, hasLength(2));
    expect(preguntas.first.id, 1);
    expect(preguntas.first.codigo, 'q1');
    expect(preguntas.last.texto, contains('embarazada'));
  });

  test('preguntas() se cachea: la segunda llamada no vuelve a la red', () async {
    var llamadas = 0;
    adaptador.onGet('/precalificacion/preguntas', (servidor) {
      llamadas++;
      servidor.reply(200, [
        {'id': 1, 'codigo': 'q1', 'texto': 'Una', 'orden': 1, 'version': 1},
      ]);
    });

    await repo.preguntas();
    await repo.preguntas();

    expect(llamadas, 1);
  });

  test('evaluar() manda cada respuesta como si/no y devuelve el veredicto', () async {
    adaptador.onPost(
      '/precalificacion/evaluar',
      (servidor) => servidor.reply(201, {
        'id': 42,
        'resultado': 'no_apto',
        'motivo': 'embarazo o lactancia',
      }),
      data: {
        'respuestas': [
          {'preguntaId': 1, 'respuesta': 'si'},
          {'preguntaId': 2, 'respuesta': 'no'},
        ],
      },
    );

    final veredicto = await repo.evaluar({1: true, 2: false});

    expect(veredicto.id, 42);
    expect(veredicto.resultado, Resultado.noApto);
    expect(veredicto.motivo, 'embarazo o lactancia');
  });

  test('evaluar() viaja por el cliente autenticado (Bearer de la identidad anonima)', () async {
    // Dos Dio distintos: solo el autenticado tiene ruta registrada para
    // /evaluar. Si la peticion saliera por el publico, su adaptador (sin rutas)
    // la rechazaria y el test fallaria.
    final dioPublico = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    final dioAutenticado = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    DioAdapter(dio: dioPublico);
    final adaptadorAutenticado = DioAdapter(dio: dioAutenticado);
    dioAutenticado.interceptors.add(ErrorInterceptor());

    adaptadorAutenticado.onPost(
      '/precalificacion/evaluar',
      (servidor) => servidor.reply(201, {'id': 12, 'resultado': 'apto', 'motivo': null}),
      data: {
        'respuestas': [
          {'preguntaId': 1, 'respuesta': 'si'},
        ],
      },
    );

    final repoDoble = PrecalificacionRepository(PrecalificacionApi(dioPublico, dioAutenticado));

    final veredicto = await repoDoble.evaluar({1: true});

    expect(veredicto.resultado, Resultado.apto);
    expect(veredicto.motivo, isNull);
  });

  test('evaluar() propaga el 422 de respuestas incompletas', () async {
    adaptador.onPost(
      '/precalificacion/evaluar',
      (servidor) => servidor.reply(422, {
        'message': 'El filtro clinico exige responder las 9 preguntas activas.',
      }),
      data: {
        'respuestas': [
          {'preguntaId': 1, 'respuesta': 'si'},
        ],
      },
    );

    await expectLater(repo.evaluar({1: true}), throwsA(isA<FalloValidacion>()));
  });
}
