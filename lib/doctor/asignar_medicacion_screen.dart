import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/features/medicacion/medicacion_api.dart';
import 'package:glucy_app/shared/widgets/mensaje_error.dart';

typedef SelectorDeHora = Future<TimeOfDay?> Function(BuildContext context);

/// Alta de medicacion con horarios (`POST /paciente-medicamentos`). Con los
/// horarios el backend genera las tomas de cada dia que el paciente ve en
/// "Mi plan". Es hoy la unica via para que existan tomas.
class AsignarMedicacionScreen extends ConsumerStatefulWidget {
  const AsignarMedicacionScreen({super.key, this.seleccionarHora});

  /// Inyectable para test; por defecto abre el TimePicker de Material.
  final SelectorDeHora? seleccionarHora;

  @override
  ConsumerState<AsignarMedicacionScreen> createState() => _AsignarMedicacionScreenState();
}

class _AsignarMedicacionScreenState extends ConsumerState<AsignarMedicacionScreen> {
  List<PacienteResumen> _pacientes = const [];
  List<MedicamentoCatalogo> _medicamentos = const [];
  bool _cargando = true;
  Object? _errorCarga;

  int? _pacienteId;
  int? _medicamentoId;
  final _dosis = TextEditingController();
  final _frecuencia = TextEditingController();
  final _indicaciones = TextEditingController();
  final List<TimeOfDay> _horarios = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _dosis.dispose();
    _frecuencia.dispose();
    _indicaciones.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final api = ref.read(medicacionApiProvider);
      final resultados = await Future.wait([api.pacientes(), api.medicamentos()]);

      if (!mounted) return;
      setState(() {
        _pacientes = resultados[0] as List<PacienteResumen>;
        _medicamentos = resultados[1] as List<MedicamentoCatalogo>;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = e;
        _cargando = false;
      });
    }
  }

  static String _hhmm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _agregarHorario() async {
    if (_horarios.length >= 6) return;

    final elegir = widget.seleccionarHora ??
        (ctx) => showTimePicker(context: ctx, initialTime: const TimeOfDay(hour: 8, minute: 0));
    final hora = await elegir(context);

    if (hora == null || !mounted) return;
    if (_horarios.any((h) => h.hour == hora.hour && h.minute == hora.minute)) return;

    setState(() {
      _horarios
        ..add(hora)
        ..sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    });
  }

  bool get _valido =>
      _pacienteId != null && _medicamentoId != null && _dosis.text.trim().isNotEmpty && _frecuencia.text.trim().isNotEmpty && _horarios.isNotEmpty;

  Future<void> _asignar() async {
    if (!_valido || _enviando) return;

    setState(() => _enviando = true);

    try {
      await ref.read(medicacionApiProvider).asignar(
            pacienteId: _pacienteId!,
            medicamentoId: _medicamentoId!,
            dosis: _dosis.text.trim(),
            frecuencia: _frecuencia.text.trim(),
            horarios: [for (final h in _horarios) _hhmm(h)],
            fechaInicio: DateTime.now(),
            indicaciones: _indicaciones.text.trim().isEmpty ? null : _indicaciones.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicación asignada. El paciente verá sus tomas desde hoy.')));
      Navigator.of(context).pop();
    } on FalloApi catch (fallo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo asignar: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: DoctorColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: DoctorColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Asignar medicación', style: TextStyle(fontFamily: 'Sora', fontSize: 18, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _errorCarga != null
                      ? _errorVista()
                      : _formulario(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorVista() {
    final e = _errorCarga!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (e is FalloApi) MensajeError(e) else Text('$e'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
        ],
      ),
    );
  }

  InputDecoration _decoracion(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DoctorColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: DoctorColors.cardBorder)),
      );

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            key: const Key('campo-paciente'),
            initialValue: _pacienteId,
            isExpanded: true,
            decoration: _decoracion('Paciente'),
            items: [for (final p in _pacientes) DropdownMenuItem(value: p.id, child: Text(p.nombre))],
            onChanged: (v) => setState(() => _pacienteId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: const Key('campo-medicamento'),
            initialValue: _medicamentoId,
            isExpanded: true,
            decoration: _decoracion('Medicamento'),
            items: [for (final m in _medicamentos) DropdownMenuItem(value: m.id, child: Text(m.etiqueta))],
            onChanged: (v) => setState(() => _medicamentoId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-dosis'),
            controller: _dosis,
            onChanged: (_) => setState(() {}),
            decoration: _decoracion('Dosis por toma', hint: 'Ej: 1 comprimido · 22 U'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-frecuencia'),
            controller: _frecuencia,
            onChanged: (_) => setState(() {}),
            decoration: _decoracion('Frecuencia (texto para el paciente)', hint: 'Ej: 2 veces al día, con las comidas'),
          ),
          const SizedBox(height: 16),
          const Text('Horarios de toma', style: TextStyle(fontFamily: 'Sora', fontSize: 12.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
          const SizedBox(height: 4),
          const Text('Con estos horarios se generan las tomas de cada día en la app del paciente (máx. 6).',
              style: TextStyle(fontSize: 11.5, color: Color(0x8C10262A))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in _horarios)
                InputChip(
                  label: Text(_hhmm(h)),
                  onDeleted: () => setState(() => _horarios.remove(h)),
                  backgroundColor: DoctorColors.tealBg,
                  labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DoctorColors.primary),
                ),
              ActionChip(
                key: const Key('horario-agregar'),
                avatar: const Icon(Icons.add, size: 16, color: DoctorColors.primary),
                label: const Text('Agregar hora'),
                onPressed: _horarios.length >= 6 ? null : _agregarHorario,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _indicaciones,
            maxLines: 2,
            decoration: _decoracion('Indicaciones (opcional)', hint: 'Ej: Después de las comidas'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            key: const Key('boton-asignar'),
            onPressed: _valido && !_enviando ? _asignar : null,
            style: FilledButton.styleFrom(
              backgroundColor: DoctorColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _enviando
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Asignar', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
