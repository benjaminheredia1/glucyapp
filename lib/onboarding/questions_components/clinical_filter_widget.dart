import 'package:flutter/material.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorderDefault = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const cardBorderAlarm = Color(0x66E8574B); // rgba(232,87,75,0.4)
  static const ink = Color(0xFF10262A);
  static const muted = Color(0x9910262A); // rgba(16,38,42,0.6)
  static const alert = Color(0xFFE8574B);
  static const track = Color(0xFFE1EDEA);
  static const chipTealBg = Color(0xFFDEF3EC);
  static const chipTealFg = Color(0xFF0A7C86);
  static const siBorder = Color(0x4DE8574B); // rgba(232,87,75,0.3)
  static const noBorder = Color(0x4D0A7C86); // rgba(10,124,134,0.3)
}

/// Modelo de cada pregunta del filtro clínico
class ClinicalQuestion {
  final String id;
  final String text;
  final bool alarmIsSi; // true = la respuesta de alarma es "Sí", false = "No"
  final bool urgent; // si es true, detiene el flujo por urgencia (no solo "no apto")
  final String reason; // motivo mostrado en la pantalla de "no apto"

  const ClinicalQuestion({
    required this.id,
    required this.text,
    required this.alarmIsSi,
    required this.reason,
    this.urgent = false,
  });
}

class ClinicalFilterScreen extends StatefulWidget {
  /// Se llama cuando el usuario completa el filtro sin ninguna alarma.
  final VoidCallback onPassed;

  /// Se llama cuando responde una alarma marcada como urgente (síntomas agudos).
  final VoidCallback onUrgent;

  /// Se llama cuando responde una alarma que lo descalifica (no apto).
  /// Recibe el motivo (ClinicalQuestion.reason) de la pregunta de alarma.
  final ValueChanged<String> onNotEligible;

  const ClinicalFilterScreen({
    super.key,
    required this.onPassed,
    required this.onUrgent,
    required this.onNotEligible,
  });

  @override
  State<ClinicalFilterScreen> createState() => _ClinicalFilterScreenState();
}

class _ClinicalFilterScreenState extends State<ClinicalFilterScreen> {
  static const List<ClinicalQuestion> _questions = [
    ClinicalQuestion(
      id: 'q1',
      text: '¿Tienes 18 años o más?',
      alarmIsSi: false,
      reason: 'ser menor de 18 años',
    ),
    ClinicalQuestion(
      id: 'q2',
      text: '¿Estás embarazada o en lactancia?',
      alarmIsSi: true,
      reason: 'embarazo o lactancia',
    ),
    ClinicalQuestion(
      id: 'q3',
      text: '¿Diagnóstico previo de diabetes tipo 1 o uso de bomba de insulina?',
      alarmIsSi: true,
      reason: 'diabetes tipo 1 o bomba de insulina',
    ),
    ClinicalQuestion(
      id: 'q4',
      text: '¿Tienes ahora vómitos persistentes, dolor abdominal intenso, '
          'respiración rápida o confusión?',
      alarmIsSi: true,
      urgent: true,
      reason: 'síntomas de descompensación aguda',
    ),
    ClinicalQuestion(
      id: 'q5',
      text: '¿Diálisis o enfermedad renal avanzada?',
      alarmIsSi: true,
      reason: 'diálisis o enfermedad renal avanzada',
    ),
    ClinicalQuestion(
      id: 'q6',
      text: '¿Cirrosis o enfermedad hepática avanzada?',
      alarmIsSi: true,
      reason: 'cirrosis o enfermedad hepática avanzada',
    ),
    ClinicalQuestion(
      id: 'q7',
      text: '¿Cáncer en tratamiento activo o trasplante de órgano?',
      alarmIsSi: true,
      reason: 'cáncer en tratamiento activo o trasplante',
    ),
    ClinicalQuestion(
      id: 'q8',
      text: '¿Insuficiencia cardíaca severa o infarto en los últimos 6 meses?',
      alarmIsSi: true,
      reason: 'insuficiencia cardíaca severa o infarto reciente',
    ),
    ClinicalQuestion(
      id: 'q9',
      text: '¿Tomas corticoides de forma crónica?',
      alarmIsSi: true,
      reason: 'uso crónico de corticoides',
    ),
  ];

  // null = sin responder, true = "Sí", false = "No"
  final Map<String, bool?> _answers = {};

  int get _answeredCount => _answers.values.where((v) => v != null).length;
  int get _total => _questions.length;
  double get _pct => _total == 0 ? 0 : _answeredCount / _total;
  bool get _allAnswered => _answeredCount == _total;

  /// Primera pregunta cuya respuesta coincide con su valor de alarma
  ClinicalQuestion? get _alarmQuestion {
    for (final q in _questions) {
      final ans = _answers[q.id];
      if (ans != null && ans == q.alarmIsSi) return q;
    }
    return null;
  }

  void _responder(String id, bool valor) {
    setState(() => _answers[id] = valor);
  }

  void _submit() {
    if (!_allAnswered) return;
    final alarm = _alarmQuestion;
    if (alarm == null) {
      widget.onPassed();
    } else if (alarm.urgent) {
      widget.onUrgent();
    } else {
      widget.onNotEligible(alarm.reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                itemCount: _questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _questionCard(_questions[index]),
              ),
            ),
            _bottomCta(),
          ],
        ),
      ),
    );
  }

  // ---------- Header: volver, título, pills, descripción y barra de progreso ----------
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: GlucyColors.cardBorderDefault),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
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
                    color: GlucyColors.deep,
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
            style: TextStyle(fontSize: 12.5, height: 1.5, color: GlucyColors.muted),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta $_answeredCount de $_total',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.muted),
              ),
              const Text(
                'Semáforo clínico',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GlucyColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _pct,
              minHeight: 6,
              backgroundColor: GlucyColors.track,
              valueColor: const AlwaysStoppedAnimation(GlucyColors.primary),
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
        color: filled ? GlucyColors.chipTealBg : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : Border.all(color: GlucyColors.cardBorderDefault),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? GlucyColors.chipTealFg : GlucyColors.muted,
        ),
      ),
    );
  }

  // ---------- Tarjeta de cada pregunta ----------
  Widget _questionCard(ClinicalQuestion q) {
    final ans = _answers[q.id];
    final isAlarm = ans != null && ans == q.alarmIsSi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAlarm ? GlucyColors.cardBorderAlarm : GlucyColors.cardBorderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.text,
            style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500, color: GlucyColors.ink),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(child: _respuestaBoton(q, valor: true, seleccionado: ans == true, label: 'Sí')),
              const SizedBox(width: 8),
              Expanded(child: _respuestaBoton(q, valor: false, seleccionado: ans == false, label: 'No')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _respuestaBoton(
    ClinicalQuestion q, {
    required bool valor,
    required bool seleccionado,
    required String label,
  }) {
    // Si esta opción coincide con la alarma de la pregunta, se pinta de rojo
    // al seleccionarla; si no, se pinta con el teal principal.
    final esAlarma = valor == q.alarmIsSi;
    final bgSeleccionado = esAlarma ? GlucyColors.alert : GlucyColors.primary;
    final borderColor = valor ? GlucyColors.siBorder : GlucyColors.noBorder;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => _responder(q.id, valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? bgSeleccionado : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: seleccionado ? Colors.white : GlucyColors.ink,
          ),
        ),
      ),
    );
  }

  // ---------- Botón inferior fijo ----------
  Widget _bottomCta() {
    final label = _allAnswered ? 'Ver mi resultado' : 'Responde las $_total preguntas';
    final bg = _allAnswered ? GlucyColors.primary : GlucyColors.primary.withOpacity(0.35);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GlucyColors.cardBorderDefault)),
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: GlucyColors.bg,
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
}