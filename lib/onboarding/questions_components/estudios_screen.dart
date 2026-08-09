import 'package:flutter/material.dart';
import 'package:glucy_app/onboarding/questions_components/lab_domicilio_screen.dart';
import 'package:glucy_app/onboarding/questions_components/procesando_screen.dart';
import 'package:glucy_app/onboarding/questions_components/subir_estudio_screen.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const dashedBorder = Color(0xFFDDE8E7);
  static const ink = Color(0xFF10262A);
  static const muted = Color(0xFF5E7377);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
  static const track = Color(0xFFE1EDEA);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
  static const alert = Color(0xFFE8574B);
  static const alertBg = Color(0xFFFBE4E1);
}

enum StudyStatus { done, pending, rejected }

/// Estudio de laboratorio requerido antes del análisis clínico.
class StudyItem {
  final int n;
  final String name;
  final String subtitle; // qué mide, mostrado en "Subir estudio"
  final String banner; // por qué importa, mostrado en "Subir estudio"
  final StudyStatus status;
  final String detail;

  const StudyItem({
    required this.n,
    required this.name,
    required this.subtitle,
    required this.banner,
    required this.status,
    this.detail = '',
  });

  StudyItem markDone(String detail) => StudyItem(
        n: n,
        name: name,
        subtitle: subtitle,
        banner: banner,
        status: StudyStatus.done,
        detail: detail,
      );
}

class _BulkFile {
  final String name;
  final String meta;
  const _BulkFile(this.name, this.meta);
}

/// Lista de estudios requeridos antes de pasar al análisis clínico
/// (filtro 2). Cada estudio pendiente o rechazado se sube individualmente
/// o se agenda una toma de muestra a domicilio.
class EstudiosScreen extends StatefulWidget {
  const EstudiosScreen({super.key});

  @override
  State<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  List<StudyItem> _studies = const [
    StudyItem(
      n: 1,
      name: 'Glucemia en ayunas',
      subtitle: 'Nivel de glucosa en sangre tras 8 horas sin comer',
      banner: 'Es la base para medir tu control glucémico actual.',
      status: StudyStatus.done,
      detail: '158 mg/dL',
    ),
    StudyItem(
      n: 2,
      name: 'Hemoglobina glicosilada (HbA1c)',
      subtitle: 'Promedio de tu glucosa en los últimos 3 meses',
      banner: 'Confirma el diagnóstico y qué tan descompensada está tu diabetes.',
      status: StudyStatus.done,
      detail: '7.4 %',
    ),
    StudyItem(
      n: 3,
      name: 'Creatinina',
      subtitle: 'Función renal, con tasa de filtrado glomerular (TFG)',
      banner: 'Decide si la metformina es segura para tus riñones y en qué dosis.',
      status: StudyStatus.done,
      detail: 'TFG 92',
    ),
    StudyItem(
      n: 4,
      name: 'Péptido C',
      subtitle: 'Cuánta insulina produce todavía tu propio páncreas',
      banner: 'Descarta diabetes tipo 1 o LADA antes de indicar tratamiento.',
      status: StudyStatus.done,
      detail: 'Normal',
    ),
    StudyItem(
      n: 5,
      name: 'Perfil lipídico',
      subtitle: 'Colesterol total, HDL, LDL y triglicéridos',
      banner: 'Define tu riesgo cardiovascular: es parte inseparable del tratamiento de la diabetes tipo 2.',
      status: StudyStatus.pending,
    ),
    StudyItem(
      n: 6,
      name: 'Transaminasas (ALT/AST)',
      subtitle: 'Función hepática',
      banner: 'Verifica que tu hígado tolere bien la medicación oral.',
      status: StudyStatus.rejected,
      detail: 'falta la fecha',
    ),
  ];

  final List<_BulkFile> _bulkFiles = [];

  static const _bulkPool = [
    _BulkFile('laboratorio-central.pdf', '3 estudios detectados'),
    _BulkFile('perfil-lipidico.jpg', '1 estudio detectado'),
    _BulkFile('transaminasas.pdf', '1 estudio detectado'),
  ];

  int get _done => _studies.where((s) => s.status == StudyStatus.done).length;
  int get _total => _studies.length;
  bool get _allDone => _done == _total;

  Future<void> _abrirEstudio(StudyItem s) async {
    if (s.status == StudyStatus.done) return;
    final detail = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => SubirEstudioScreen(study: s)),
    );
    if (detail == null) return;
    setState(() {
      _studies = _studies.map((x) => x.n == s.n ? x.markDone(detail) : x).toList();
    });
  }

  void _uploadBulk() {
    if (_bulkFiles.length >= _bulkPool.length) return;
    final pendientes = _studies.where((s) => s.status != StudyStatus.done);
    if (pendientes.isEmpty) return;
    setState(() {
      _bulkFiles.add(_bulkPool[_bulkFiles.length]);
      final next = pendientes.first;
      _studies = _studies.map((x) => x.n == next.n ? x.markDone('del archivo') : x).toList();
    });
  }

  void _enviarAAnalisis() {
    if (!_allDone) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProcesandoScreen()));
  }

  ({Color tint, Color fg, IconData icon, String label}) _statusMeta(StudyStatus st) {
    switch (st) {
      case StudyStatus.done:
        return (tint: GlucyColors.tealBg, fg: GlucyColors.primary, icon: Icons.check_circle_outline, label: 'Completado');
      case StudyStatus.pending:
        return (tint: GlucyColors.warnBg, fg: GlucyColors.warn, icon: Icons.schedule_outlined, label: 'Pendiente de subir');
      case StudyStatus.rejected:
        return (tint: GlucyColors.alertBg, fg: GlucyColors.alert, icon: Icons.error_outline, label: 'Rechazado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estudios requeridos',
                      style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  SizedBox(height: 3),
                  Text('Estudios de bajo costo, disponibles en cualquier laboratorio.',
                      style: TextStyle(fontSize: 12.5, color: Color(0x8C10262A))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  _progresoCard(),
                  const SizedBox(height: 12),
                  for (final s in _studies) ...[
                    _studyRow(s),
                    const SizedBox(height: 10),
                  ],
                  _bulkCard(),
                  const SizedBox(height: 10),
                  _labRow(),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: GlucyColors.cardBorder)),
              ),
              child: ElevatedButton(
                onPressed: _allDone ? _enviarAAnalisis : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _allDone ? GlucyColors.primary : GlucyColors.primary.withValues(alpha: 0.35),
                  disabledBackgroundColor: GlucyColors.primary.withValues(alpha: 0.35),
                  foregroundColor: GlucyColors.bg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _allDone ? 'Enviar a análisis clínico' : 'Completa los estudios para continuar',
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progresoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paquete mínimo obligatorio', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xB310262A))),
              Text('$_done de $_total subidos', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xB310262A))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _total == 0 ? 0 : _done / _total,
              minHeight: 8,
              backgroundColor: GlucyColors.track,
              valueColor: const AlwaysStoppedAnimation(GlucyColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studyRow(StudyItem s) {
    final meta = _statusMeta(s.status);
    final statusText = s.detail.isEmpty ? meta.label : '${meta.label} · ${s.detail}';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _abrirEstudio(s),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(9)),
              child: Icon(meta.icon, size: 18, color: meta.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${s.n}. ${s.name}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: GlucyColors.ink)),
                  Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: meta.fg)),
                ],
              ),
            ),
            if (s.status != StudyStatus.done)
              const Icon(Icons.chevron_right, size: 18, color: Color(0x47101E22)),
          ],
        ),
      ),
    );
  }

  Widget _bulkCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.dashedBorder), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Carga global de documentos', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
          const SizedBox(height: 4),
          const Text(
            'Si tienes todos tus resultados en un archivo, súbelos de una vez: aceptamos foto o PDF y los repartimos entre los estudios.',
            style: TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.muted),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _uploadBulk,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x660A7C86), style: BorderStyle.solid, width: 1.5),
              ),
              child: const Column(
                children: [
                  Icon(Icons.upload_file_outlined, size: 24, color: GlucyColors.primary),
                  SizedBox(height: 8),
                  Text('Subir documento o PDF', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                  SizedBox(height: 2),
                  Text('Hasta 3 archivos · JPG, PNG o PDF', style: TextStyle(fontSize: 11, color: GlucyColors.muted)),
                ],
              ),
            ),
          ),
          for (final f in _bulkFiles) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFEAF4F2), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: GlucyColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                        Text(f.meta, style: const TextStyle(fontSize: 10.5, color: GlucyColors.muted)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFCFE9E4), borderRadius: BorderRadius.circular(999)),
                    child: const Text('Leído', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: GlucyColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _labRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LabDomicilioScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.home_outlined, size: 18, color: GlucyColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Que un laboratorio venga a ti', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                  Text('Toma de muestra a domicilio · desde 12 USD', style: TextStyle(fontSize: 11.5, color: GlucyColors.tealText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
