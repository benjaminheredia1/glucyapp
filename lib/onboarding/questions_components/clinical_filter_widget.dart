import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/rutas.dart';
import '../../app/theme/glucy_palette.dart';
import '../../core/error/fallo_api.dart';
import '../../features/precalificacion/domain/veredicto.dart';
import '../../features/precalificacion/presentation/filtro_clinico_controller.dart';
import '../../shared/widgets/mensaje_error.dart';

/// Filtro clinico. Las preguntas y el veredicto vienen del backend: aqui no
/// hay ninguna regla clinica, a proposito. `GET /precalificacion/preguntas` no
/// entrega la respuesta de alarma, asi que el cliente no podria calcularlo
/// aunque quisiera.
class ClinicalFilterScreen extends ConsumerWidget {
  const ClinicalFilterScreen({super.key, required this.onVeredicto});

  /// Se invoca con el veredicto que devolvio el servidor.
  final ValueChanged<Veredicto> onVeredicto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(filtroClinicoControllerProvider);

    return Scaffold(
      backgroundColor: GlucyPalette.bg,
      body: SafeArea(
        child: estado.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _errorConReintento(context, ref, e),
          data: (filtro) => _contenido(context, ref, filtro),
        ),
      ),
    );
  }

  Widget _errorConReintento(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (e is FalloApi) MensajeError(e) else Text('$e'),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('boton-reintentar-filtro'),
              onPressed: () => ref.invalidate(filtroClinicoControllerProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, WidgetRef ref, EstadoFiltro filtro) {
    final notifier = ref.read(filtroClinicoControllerProvider.notifier);

    // Un solo cierre para el CTA y para "Reintentar envio": reintentar un
    // envio fallido es, literalmente, volver a llamar a enviar().
    Future<void> enviarYNavegar() async {
      final veredicto = await notifier.enviar();

      if (veredicto != null) onVeredicto(veredicto);
    }

    return Column(
      children: [
        _header(context, respondidas: filtro.respondidas, total: filtro.preguntas.length),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            itemCount: filtro.preguntas.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final pregunta = filtro.preguntas[i];

              return _questionCard(
                texto: pregunta.texto,
                respuesta: filtro.respuestas[pregunta.id],
                onResponder: (si) => notifier.responder(pregunta.id, si),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextFormField(
            key: const Key('campo-correo-filtro'),
            initialValue: filtro.leadEmail,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: notifier.escribirCorreo,
            decoration: InputDecoration(
              labelText: 'Tu correo',
              helperText: 'Para guardar tu resultado y recuperarlo al crear la cuenta.',
              helperMaxLines: 2,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (filtro.errorEnvio case final error?)
          _bannerEnvio(error, onReintentar: enviarYNavegar),
        _bottomCta(habilitado: filtro.completo, onEnviar: enviarYNavegar),
      ],
    );
  }
}

// ---------- Aviso de un envio fallido: no reemplaza el cuestionario ----------
//
// A diferencia de `_errorConReintento` (que es para un fallo al CARGAR las
// preguntas, donde no hay nada que conservar), este aviso vive junto a las
// respuestas ya dadas. Reintentar llama a `enviar()` de nuevo, no invalida el
// provider: invalidar volveria a pedir las preguntas con `respuestas: {}`.
Widget _bannerEnvio(Object error, {required Future<void> Function() onReintentar}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: Column(
      children: [
        if (error is FalloApi) MensajeError(error) else Text('$error'),
        const SizedBox(height: 8),
        TextButton(
          key: const Key('boton-reintentar-envio'),
          onPressed: () => onReintentar(),
          child: const Text('Reintentar envio'),
        ),
      ],
    ),
  );
}

// ---------- Header: volver, título, pills, descripción y barra de progreso ----------
Widget _header(BuildContext context, {required int respondidas, required int total}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              // `context.go(Rutas.filtroClinico)` desde OnboardingScreen deja
              // esta pantalla como unica en el stack: `pop()` a secas
              // lanzaria `GoError('There is nothing to pop')`.
              onTap: () => context.canPop() ? context.pop() : context.go(Rutas.onboarding),
              borderRadius: BorderRadius.circular(32),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: GlucyPalette.cardBorder),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyPalette.primary),
              ),
            ),
            const Expanded(
              child: Text(
                'Filtro clínico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: GlucyPalette.deep,
                ),
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _pill('Filtro 1 de 2 · sin estudios', filled: true),
            _pill('3 min', filled: false),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Una sola respuesta de alarma detiene el proceso antes de pedirte un solo estudio.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: GlucyPalette.muted),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta $respondidas de $total',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyPalette.muted),
            ),
            const Text(
              'Semáforo clínico',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyPalette.muted),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : respondidas / total,
            minHeight: 6,
            backgroundColor: GlucyPalette.track,
            valueColor: const AlwaysStoppedAnimation(GlucyPalette.primary),
          ),
        ),
      ],
    ),
  );
}

Widget _pill(String text, {required bool filled}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: filled ? GlucyPalette.tealBg : Colors.white,
      borderRadius: BorderRadius.circular(999),
      border: filled ? null : Border.all(color: GlucyPalette.cardBorder),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: filled ? GlucyPalette.primary : GlucyPalette.muted,
      ),
    ),
  );
}

// ---------- Tarjeta de cada pregunta ----------
//
// Ya no se pinta la respuesta de alarma en rojo: esa informacion no llega del
// backend (a proposito, vease `PreguntaFiltro`), asi que el cliente no puede
// distinguir cual respuesta es la de riesgo para cada pregunta.
Widget _questionCard({
  required String texto,
  required bool? respuesta,
  required ValueChanged<bool> onResponder,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: GlucyPalette.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texto,
          style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500, color: GlucyPalette.ink),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _respuestaBoton(
                seleccionado: respuesta == true,
                label: 'Sí',
                onTap: () => onResponder(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _respuestaBoton(
                seleccionado: respuesta == false,
                label: 'No',
                onTap: () => onResponder(false),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _respuestaBoton({
  required bool seleccionado,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(9),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: seleccionado ? GlucyPalette.primary : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: GlucyPalette.cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: seleccionado ? Colors.white : GlucyPalette.ink,
        ),
      ),
    ),
  );
}

// ---------- Botón inferior fijo ----------
Widget _bottomCta({required bool habilitado, required Future<void> Function() onEnviar}) {
  final label = habilitado ? 'Ver mi resultado' : 'Responde todas las preguntas';
  final bg = habilitado ? GlucyPalette.primary : GlucyPalette.primary.withValues(alpha: 0.35);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: GlucyPalette.cardBorder)),
    ),
    child: ElevatedButton(
      onPressed: habilitado ? () => onEnviar() : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: GlucyPalette.bg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
