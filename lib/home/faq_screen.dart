import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/ayuda/ayuda_api.dart';
import 'package:glucy_app/home/articulo_ayuda_screen.dart';
import 'package:glucy_app/home/patient_tabbar.dart';
import 'package:glucy_app/home/soporte_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const muted = Color(0xFF5E7377);
}

/// Centro de ayuda contra `/articulos-ayuda`: buscador y filtro por las
/// categorías que el equipo publicó en el panel.
class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String _query = '';
  String _cat = 'Todo';

  List<ArticuloAyuda> _articulos = const [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final articulos = await ref.read(ayudaApiProvider).articulos();

      if (!mounted) return;

      setState(() {
        _articulos = articulos;
        _cargando = false;
      });
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      setState(() {
        _error = fallo.mensaje;
        _cargando = false;
      });
    }
  }

  List<String> get _cats => ['Todo', ...{for (final a in _articulos) a.categoria}];

  List<ArticuloAyuda> get _filtrados {
    final q = _query.toLowerCase();

    return [
      for (final a in _articulos)
        if ((_cat == 'Todo' || a.categoria == _cat) &&
            (q.isEmpty || a.titulo.toLowerCase().contains(q) || a.cuerpo.toLowerCase().contains(q)))
          a,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ayuda', style: TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  const Text('Resuelve en segundos, sin esperar a nadie', style: TextStyle(fontSize: 12, color: Color(0x8010262A))),
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
                            decoration: const InputDecoration(hintText: 'Buscar en la ayuda…', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  if (_cats.length > 1)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in _cats)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setState(() => _cat = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(color: _cat == c ? GlucyColors.primary : Colors.white, borderRadius: BorderRadius.circular(999)),
                              child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _cat == c ? Colors.white : GlucyColors.ink)),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: GlucyColors.primary))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      children: [
                        if (_error != null) ...[
                          Text('No se pudo cargar la ayuda: $_error',
                              style: const TextStyle(fontSize: 12.5, color: GlucyColors.muted)),
                          const SizedBox(height: 8),
                          OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
                          const SizedBox(height: 10),
                        ] else if (_articulos.isEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Aún no hay artículos publicados. Escríbenos y te respondemos directo.',
                                textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: GlucyColors.muted)),
                          ),
                        ] else ...[
                          const Text('ARTÍCULOS', style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.6)),
                          const SizedBox(height: 8),
                          if (_filtrados.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text('Sin resultados para “$_query”.',
                                  textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: GlucyColors.muted)),
                            ),
                          for (final articulo in _filtrados) ...[
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ArticuloAyudaScreen(articulo: articulo)),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(articulo.titulo,
                                          style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500, color: GlucyColors.ink)),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: Color(0x4D10262A)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SoporteScreen())),
                          style: OutlinedButton.styleFrom(foregroundColor: GlucyColors.primary, side: const BorderSide(color: Color(0x4D0A7C86)), padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: const Text('No encontré mi respuesta', style: TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
            ),
            const PatientTabBar(current: PatientTab.faq),
          ],
        ),
      ),
    );
  }
}
