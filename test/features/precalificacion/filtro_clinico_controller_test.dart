import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/precalificacion/data/precalificacion_repository.dart';
import 'package:glucy_app/features/precalificacion/domain/pregunta_filtro.dart';
import 'package:glucy_app/features/precalificacion/domain/veredicto.dart';
import 'package:glucy_app/features/precalificacion/presentation/filtro_clinico_controller.dart';

const _preguntas = [
  PreguntaFiltro(id: 1, codigo: 'q1', texto: 'Una', orden: 1, version: 1),
  PreguntaFiltro(id: 2, codigo: 'q2', texto: 'Dos', orden: 2, version: 1),
];

class RepoFalso implements PrecalificacionRepository {
  RepoFalso({this.veredicto = const Veredicto(id: 1, resultado: Resultado.apto)});

  Veredicto veredicto;
  Object? errorAlEvaluar;
  Map<int, bool>? enviadas;
  int vinculadas = 0;

  @override
  Future<List<PreguntaFiltro>> preguntas() async => _preguntas;

  @override
  Future<Veredicto> evaluar(Map<int, bool> respuestas, {String? leadEmail}) async {
    enviadas = respuestas;
    if (errorAlEvaluar != null) throw errorAlEvaluar!;

    return veredicto;
  }

  @override
  Future<void> vincular(int precalificacionId) async => vinculadas++;
}

ProviderContainer contenedor(RepoFalso repo) {
  final c = ProviderContainer(
    overrides: [precalificacionRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);

  return c;
}

void main() {
  test('carga las preguntas del servidor', () async {
    final c = contenedor(RepoFalso());

    final estado = await c.read(filtroClinicoControllerProvider.future);

    expect(estado.preguntas, hasLength(2));
    expect(estado.respuestas, isEmpty);
    expect(estado.completo, isFalse);
  });

  test('el estado no esta completo hasta responderlas todas', () async {
    final c = contenedor(RepoFalso());
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    expect(c.read(filtroClinicoControllerProvider).value!.completo, isFalse);

    notifier.responder(2, false);
    expect(c.read(filtroClinicoControllerProvider).value!.completo, isTrue);
  });

  test('responder dos veces la misma pregunta sustituye la respuesta', () async {
    final c = contenedor(RepoFalso());
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(1, false);

    expect(c.read(filtroClinicoControllerProvider).value!.respuestas[1], isFalse);
  });

  test('enviar() manda todas las respuestas y devuelve el veredicto', () async {
    final repo = RepoFalso(veredicto: const Veredicto(id: 9, resultado: Resultado.urgente, motivo: 'sintomas'));
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, false);

    final veredicto = await notifier.enviar();

    expect(repo.enviadas, {1: true, 2: false});
    expect(veredicto!.resultado, Resultado.urgente);
    expect(veredicto.motivo, 'sintomas');
  });

  test('enviar() sin responderlas todas no llama al servidor', () async {
    final repo = RepoFalso();
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);

    expect(await notifier.enviar(), isNull);
    expect(repo.enviadas, isNull);
  });

  test('un fallo al evaluar deja el estado en error y devuelve null', () async {
    final repo = RepoFalso()..errorAlEvaluar = const FalloRed();
    final c = contenedor(repo);
    await c.read(filtroClinicoControllerProvider.future);
    final notifier = c.read(filtroClinicoControllerProvider.notifier);

    notifier.responder(1, true);
    notifier.responder(2, true);

    expect(await notifier.enviar(), isNull);
    expect(c.read(filtroClinicoControllerProvider).hasError, isTrue);
  });
}
