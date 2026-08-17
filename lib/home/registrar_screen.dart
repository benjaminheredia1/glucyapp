import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/mediciones/medicion_api.dart';
import 'package:glucy_app/features/medicacion/medicacion_providers.dart';
import 'package:glucy_app/features/mediciones/mediciones_provider.dart';
import 'package:glucy_app/home/reg_ok_screen.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const warn = Color(0xFFB97417);
}

/// Registro diario de glucosa: teclado numérico propio (para replicar el
/// diseño) + selector de momento de medición. Persiste en `POST /mediciones`;
/// el backend asigna el ciclo activo y dispara las alertas.
class RegistrarScreen extends ConsumerStatefulWidget {
  const RegistrarScreen({super.key});

  @override
  ConsumerState<RegistrarScreen> createState() => _RegistrarScreenState();
}

class _RegistrarScreenState extends ConsumerState<RegistrarScreen> {
  String _entry = '';
  String _moment = 'ayunas';
  bool _guardando = false;

  // Etiqueta visible → valor del enum `momento` del backend.
  static const _moments = [
    ('ayunas', 'En ayunas'),
    ('preprandial', 'Antes de comer'),
    ('postprandial', '2 h después'),
  ];

  int get _entryNum => int.tryParse(_entry) ?? 0;
  bool get _inRange => _entryNum > 0 && _entryNum <= 130;

  /// El backend acepta 10–900 mg/dL; por debajo de 10 es un error de tipeo.
  bool get _valida => _entryNum >= 10 && _entryNum <= 900;

  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        _entry = _entry.isEmpty ? _entry : _entry.substring(0, _entry.length - 1);
      } else if (key != '.') {
        _entry = (_entry + key).length <= 3 ? _entry + key : _entry;
      }
    });
  }

  Future<void> _guardar() async {
    if (!_valida || _guardando) return;

    setState(() => _guardando = true);

    try {
      final medicion = await ref.read(medicionApiProvider).registrar(
            valor: _entryNum.toDouble(),
            momento: _moment,
          );

      // Inicio y Progreso pintan `medicionesProvider`: sin esto, la grafica
      // seguiria mostrando lo de antes al volver.
      ref.invalidate(medicionesProvider);
      ref.invalidate(actividadProvider);

      if (!mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RegOkScreen(
          glucoseEntry: _entry,
          momento: _moments.firstWhere((m) => m.$1 == _moment).$2,
          medidoEn: medicion.medidoEn,
        ),
      ));
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: GlucyColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: GlucyColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Registrar glucosa',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Una medición al día es suficiente: elige el momento y comparamos siempre con el mismo tipo de medición.',
                style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0x9910262A)),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 44, fontWeight: FontWeight.w700, color: GlucyColors.deep),
                        children: [
                          TextSpan(text: _entry.isEmpty ? '—' : _entry),
                          const TextSpan(text: ' mg/dL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0x7310262A))),
                        ],
                      ),
                    ),
                    Text(
                      _inRange ? 'En rango · objetivo ≤ 130 mg/dL' : 'Sobre el objetivo de 130 mg/dL',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _inRange ? GlucyColors.primary : GlucyColors.warn),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('¿CUÁNDO TE MEDISTE? (OBLIGATORIO)',
                  style: TextStyle(fontFamily: 'Sora', fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0x8C10262A), letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final m in _moments)
                    InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => setState(() => _moment = m.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: _moment == m.$1 ? GlucyColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: _moment == m.$1 ? GlucyColors.primary : GlucyColors.cardBorder),
                        ),
                        child: Text(m.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _moment == m.$1 ? Colors.white : GlucyColors.ink)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.7,
                children: [
                  for (final k in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '⌫'])
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _tap(k),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
                        child: Text(k, style: const TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w600, color: GlucyColors.deep)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _valida && !_guardando ? _guardar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  disabledBackgroundColor: GlucyColors.primary.withValues(alpha: 0.35),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar medición', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
