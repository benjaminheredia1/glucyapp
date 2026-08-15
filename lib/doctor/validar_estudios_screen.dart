import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/doctor/doctor_data.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bandeja de validación del doctor: estudios subidos por sus pacientes que
/// esperan veredicto. Abre el documento con un enlace firmado temporal y
/// firma aprobado o rechazado (con motivo) contra la API.
class ValidarEstudiosScreen extends ConsumerStatefulWidget {
  const ValidarEstudiosScreen({super.key});

  @override
  ConsumerState<ValidarEstudiosScreen> createState() => _ValidarEstudiosScreenState();
}

class _ValidarEstudiosScreenState extends ConsumerState<ValidarEstudiosScreen> {
  List<EstudioMedico> _estudios = const [];
  bool _cargando = true;
  String? _error;
  int? _procesando; // id del estudio con una accion en vuelo

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
      final estudios = await ref.read(estudioApiProvider).porValidar();

      if (!mounted) return;

      setState(() {
        _estudios = estudios;
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

  Future<void> _verDocumento(EstudioMedico estudio) async {
    final archivoId = estudio.archivoId;

    if (archivoId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Este estudio no tiene documento adjunto.')));

      return;
    }

    try {
      final url = await ref.read(estudioApiProvider).enlaceArchivo(archivoId);

      // El enlace firmado es la credencial: se abre fuera, sin el Bearer.
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo abrir el documento: ${fallo.mensaje}')));
    }
  }

  Future<void> _firmar(EstudioMedico estudio, {required bool aprobar, String? motivo}) async {
    setState(() => _procesando = estudio.id);

    try {
      await ref.read(estudioApiProvider).validar(id: estudio.id, aprobar: aprobar, motivo: motivo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(aprobar
            ? '${estudio.tipoEstudio?.nombre ?? 'Estudio'} aprobado'
            : '${estudio.tipoEstudio?.nombre ?? 'Estudio'} rechazado; el paciente puede volver a subirlo'),
      ));

      await _cargar();
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo firmar: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _procesando = null);
    }
  }

  Future<void> _rechazar(EstudioMedico estudio) async {
    final controlador = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Rechazar ${estudio.tipoEstudio?.nombre ?? 'estudio'}',
            style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLength: 255,
          decoration: const InputDecoration(
            labelText: 'Motivo (lo verá el paciente)',
            hintText: 'Ej: no se ve la fecha del resultado',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(contexto).pop(), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DoctorColors.alert),
            onPressed: () {
              final texto = controlador.text.trim();

              if (texto.isNotEmpty) Navigator.of(contexto).pop(texto);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (motivo != null) await _firmar(estudio, aprobar: false, motivo: motivo);
  }

  String _fecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: DoctorColors.cardBorder)),
                      child: const Icon(Icons.arrow_back_ios_new, size: 13, color: DoctorColors.primary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Estudios por validar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: DoctorColors.primary))
                  : _error != null
                      ? _vistaError()
                      : _estudios.isEmpty
                          ? _vistaVacia()
                          : RefreshIndicator(
                              color: DoctorColors.primary,
                              onRefresh: _cargar,
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                                itemCount: _estudios.length,
                                separatorBuilder: (context, indice) => const SizedBox(height: 10),
                                itemBuilder: (_, indice) => _tarjeta(_estudios[indice]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No se pudo cargar la bandeja: $_error',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0x9910262A))),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _vistaVacia() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 40, color: DoctorColors.primary),
            SizedBox(height: 10),
            Text('Sin estudios pendientes. Cuando un paciente suba un resultado, aparece aquí.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: Color(0x9910262A))),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(EstudioMedico estudio) {
    final ocupado = _procesando == estudio.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: DoctorColors.cardBorder), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(estudio.tipoEstudio?.nombre ?? 'Estudio',
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 13.5, fontWeight: FontWeight.w700, color: DoctorColors.deep)),
                    const SizedBox(height: 2),
                    Text(
                      '${estudio.pacienteNombre ?? 'Paciente'} · ${_fecha(estudio.fecha)}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0x8C10262A)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: DoctorColors.warnBg, borderRadius: BorderRadius.circular(999)),
                child: const Text('Por validar',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: DoctorColors.warn)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ocupado ? null : () => _verDocumento(estudio),
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('Ver documento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DoctorColors.primary,
                    side: const BorderSide(color: Color(0x4D0A7C86)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: ocupado ? null : () => _firmar(estudio, aprobar: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: DoctorColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: ocupado
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Aprobar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: ocupado ? null : () => _rechazar(estudio),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DoctorColors.alert,
                    side: const BorderSide(color: Color(0x66E8574B)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Rechazar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
