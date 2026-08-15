import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/domain/sesion.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/auth/presentation/sesion_controller.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
  static const warnBg = Color(0xFFFBEEDA);
}

class _Pref {
  final String title;
  final String sub;
  bool on;
  _Pref(this.title, this.sub, this.on);
}

/// Datos personales y preferencias de notificación de la cuenta. Nombre,
/// teléfono y los datos clínicos persisten en `PATCH /perfil`.
class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  final _talla = TextEditingController();
  final _peso = TextEditingController();

  DateTime? _nacimiento;
  String? _sexo; // 'femenino' | 'masculino', valores del backend
  bool _cargando = true;
  bool _guardando = false;

  final List<_Pref> _prefs = [
    _Pref('Recordatorios de medicación', 'Aviso 10 min antes de cada toma', true),
    _Pref('Avisos de validación médica', 'Cuando tu médica firma un ajuste', true),
    _Pref('Novedades de Glucy AI', 'Contenido educativo y mejoras', false),
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    // La sesion ya trae nombre y telefono; los clinicos llegan con /user.
    final usuario = switch (ref.read(sesionControllerProvider).value) {
      SesionAutenticado(:final usuario) => usuario,
      _ => null,
    };

    _nombre.text = usuario?.name ?? '';
    _apellido.text = usuario?.apellidoPaterno ?? '';
    _telefono.text = usuario?.telefono ?? '';

    try {
      final perfil = await ref.read(perfilApiProvider).obtener();
      final paciente = perfil.paciente;

      if (!mounted || paciente == null) return;

      setState(() {
        _nacimiento = paciente.fechaNacimiento;
        _sexo = paciente.sexo == 'femenino' || paciente.sexo == 'masculino' ? paciente.sexo : null;
        _talla.text = paciente.tallaCm?.toString() ?? '';
        _peso.text = paciente.pesoKg == null
            ? ''
            : paciente.pesoKg!.toStringAsFixed(paciente.pesoKg! % 1 == 0 ? 0 : 1);
      });
    } on FalloApi {
      // Sin red se edita igual con lo que la sesion ya sabe.
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _apellido, _telefono, _talla, _peso]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirNacimiento() async {
    final hoy = DateTime.now();
    final elegido = await showDatePicker(
      context: context,
      initialDate: _nacimiento ?? DateTime(hoy.year - 30),
      firstDate: DateTime(hoy.year - 120),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
      builder: (context, hijo) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: GlucyColors.primary)),
        child: hijo!,
      ),
    );

    if (elegido != null) setState(() => _nacimiento = elegido);
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('El nombre no puede quedar vacío.')));

      return;
    }

    setState(() => _guardando = true);

    try {
      final perfil = await ref.read(perfilApiProvider).actualizar(
            name: _nombre.text.trim(),
            apellidoPaterno: _apellido.text.trim(),
            telefono: _telefono.text.trim(),
            fechaNacimiento: _nacimiento,
            sexo: _sexo,
            tallaCm: int.tryParse(_talla.text),
            pesoKg: double.tryParse(_peso.text),
          );

      ref.read(sesionControllerProvider.notifier).fijarUsuario(perfil.usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil guardado')));
      Navigator.of(context).pop();
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String get _nacimientoTexto => _nacimiento == null
      ? ''
      : '${_nacimiento!.day.toString().padLeft(2, '0')}/${_nacimiento!.month.toString().padLeft(2, '0')}/${_nacimiento!.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
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
                    child: Text('Editar perfil',
                        textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 19, fontWeight: FontWeight.w700, color: GlucyColors.deep)),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: GlucyColors.primary))
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: GlucyColors.tealBg, shape: BoxShape.circle),
                          child: Text(
                            switch (ref.watch(sesionControllerProvider).value) {
                              SesionAutenticado(:final usuario) => usuario.iniciales,
                              _ => '?',
                            },
                            style: const TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: GlucyColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _field('Nombre', _nombre)),
                              const SizedBox(width: 12),
                              Expanded(child: _field('Apellido', _apellido)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _field('Teléfono móvil', _telefono, keyboard: TextInputType.phone),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _campoNacimiento()),
                              const SizedBox(width: 12),
                              Expanded(child: _campoSexo()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _field('Talla (cm)', _talla,
                                    keyboard: TextInputType.number,
                                    formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field('Peso (kg)', _peso,
                                    keyboard: const TextInputType.numberWithOptions(decimal: true),
                                    formatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,2}$'))]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PREFERENCIAS', style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0x6B10262A), letterSpacing: 0.7)),
                          const SizedBox(height: 10),
                          for (final p in _prefs) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: GlucyColors.ink)),
                                      Text(p.sub, style: const TextStyle(fontSize: 11, color: Color(0x8010262A))),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: p.on,
                                  activeTrackColor: GlucyColors.primary,
                                  onChanged: (v) => setState(() => p.on = v),
                                ),
                              ],
                            ),
                            if (p != _prefs.last) const SizedBox(height: 4),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(color: GlucyColors.warnBg, borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFB97417)),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text('Peso y talla afectan tu plan. Al guardarlos, tu médica revisa el cambio en la próxima validación.',
                                style: TextStyle(fontSize: 11.5, height: 1.5, color: Color(0xFF8A5510))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: GlucyColors.cardBorder))),
              child: ElevatedButton(
                onPressed: _cargando || _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar cambios', style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoNacimiento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nacimiento', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
        const SizedBox(height: 5),
        InkWell(
          onTap: _elegirNacimiento,
          borderRadius: BorderRadius.circular(9),
          child: InputDecorator(
            decoration: _decoracion(hintText: 'Elegir fecha'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nacimientoTexto.isEmpty ? 'Elegir fecha' : _nacimientoTexto,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: _nacimientoTexto.isEmpty ? const Color(0x7310262A) : GlucyColors.ink),
                ),
                const Icon(Icons.calendar_today_outlined, size: 15, color: GlucyColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoSexo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sexo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          initialValue: _sexo,
          decoration: _decoracion(),
          hint: const Text('Elegir', style: TextStyle(fontSize: 13.5, color: Color(0x7310262A))),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: GlucyColors.ink),
          items: const [
            DropdownMenuItem(value: 'femenino', child: Text('Mujer')),
            DropdownMenuItem(value: 'masculino', child: Text('Hombre')),
          ],
          onChanged: (v) => setState(() => _sexo = v),
        ),
      ],
    );
  }

  InputDecoration _decoracion({String? hintText}) => InputDecoration(
        filled: true,
        fillColor: GlucyColors.bg,
        isDense: true,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0x17052E33))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0x17052E33))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: GlucyColors.primary, width: 1.5)),
      );

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0x8010262A))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: GlucyColors.ink),
          decoration: _decoracion(),
        ),
      ],
    );
  }
}
