import 'package:flutter/material.dart';
import 'package:glucy_app/doctor/caso_screen.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/doctor/doctor_tabbar.dart';

/// Lista completa de pacientes a cargo, con buscador y filtros rápidos.
class PacientesScreen extends StatefulWidget {
  const PacientesScreen({super.key});

  @override
  State<PacientesScreen> createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  String _query = '';
  String _filter = 'Todos';

  static const _filters = ['Todos', 'Fuera de rango', 'Sin registrar', 'Ajuste hoy'];

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = doctorCases.where((c) {
      final matchesQuery = q.isEmpty || c.name.toLowerCase().contains(q) || c.clinic.toLowerCase().contains(q);
      final matchesFilter = switch (_filter) {
        'Fuera de rango' => c.tag == 'crítico' || c.tag == 'alto',
        'Sin registrar' => c.tag == 'sin registrar',
        'Ajuste hoy' => c.note.contains('ajuste'),
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mis pacientes', style: TextStyle(fontFamily: 'Sora', fontSize: 21, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  const Text('48 activos · 6 requieren atención', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0x1A052E33)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0x6610262A)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _query = v),
                            decoration: const InputDecoration(hintText: 'Buscar por nombre o clínica…', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in _filters)
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(color: _filter == f ? DoctorColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
                            child: Text(f, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _filter == f ? Colors.white : DoctorColors.ink)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 9),
                itemBuilder: (context, i) {
                  final p = list[i];
                  final tint = tagTint(p.tag);
                  final fg = tagColor(p.tag);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CasoScreen(item: p))),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                            child: Text(p.initials, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DoctorColors.ink)),
                                Text(p.note, style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(p.value, style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
                              Text(p.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const DoctorTabBar(current: DoctorTab.pacientes),
          ],
        ),
      ),
    );
  }
}
