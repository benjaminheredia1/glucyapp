import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:glucy_app/onboarding/questions_components/clinical_filter_widget.dart';
import 'package:glucy_app/onboarding/questions_components/filtro1_screen.dart';
import 'package:glucy_app/onboarding/questions_components/no_apto_screen.dart';
import 'package:glucy_app/warning/warning.dart';

/// Colores del diseño Glucy AI
class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const fieldBorder = Color(0x12052E33); // rgba(5,46,51,0.07)
  static const ink = Color(0xFF10262A);
  static const mutedLabel = Color(0x8010262A); // rgba(16,38,42,0.5)
  static const dotInactive = Color(0xFFD5E7E4);
  static const imcCardBg = Color(0xFFDEF3EC);
  static const imcText = Color(0xFF0A5A62);
  static const chipBg = Color(0xFFDEF3EC);
  static const chipDashedBorder = Color(0x590A7C86); // rgba(10,124,134,0.35)
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  double _imc = 0.0;

  static List<String> opciones = ['Masculino', 'Femenino', 'Otro'];

  // Controllers para peso/talla, necesarios para calcular el IMC en vivo
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _anosDiabetesController = TextEditingController();

  // Antecedentes familiares (chips seleccionables, como en el diseño)
  final Map<String, bool> _famChips = {
    'diabetes': false,
    'hta': false,
    'cardio': false,
  };
  final Map<String, String> _famLabels = {
    'diabetes': 'Diabetes',
    'hta': 'Hipertensión',
    'cardio': 'Cardiopatía',
  };

  @override
  void dispose() {
    _pesoController.dispose();
    _tallaController.dispose();
    _nombreController.dispose();
    _anosDiabetesController.dispose();
    super.dispose();
  }

  int? get _edad {
    final nac = _fechaNacimiento;
    if (nac == null) return null;
    final hoy = DateTime.now();
    var edad = hoy.year - nac.year;
    if (hoy.month < nac.month || (hoy.month == nac.month && hoy.day < nac.day)) edad--;
    return edad;
  }

  void _calcularImc(double weight, double height) {
    if (height <= 0) {
      return;
    }
    double imc = weight / ((height / 100) * (height / 100));
    setState(() {
      _imc = imc;
    });
  }

  void _onPesoTallaChanged() {
    final peso = double.tryParse(_pesoController.text) ?? 0;
    final talla = double.tryParse(_tallaController.text) ?? 0;
    _calcularImc(peso, talla);
  }

  String get _categoriaImc {
    if (_imc == 0) return '—';
    if (_imc < 18.5) return 'Bajo peso';
    if (_imc < 25) return 'Normal';
    if (_imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  void _abrirDataPicker() {
    DatePicker.showDatePicker(
      context,
      minTime: DateTime(1920),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        setState(() => _fechaNacimiento = date);
      },
      currentTime: DateTime(2000, 1, 1),
      locale: LocaleType.es,
    );
  }

  // ---------- Estilo reutilizable de los inputs (mismo look que el HTML) ----------
  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: GlucyColors.bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: GlucyColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: GlucyColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: GlucyColors.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 11, color: GlucyColors.mutedLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _camposCard(),
                    const SizedBox(height: 12),
                    _imcCard(),
                    const SizedBox(height: 12),
                    _sectionTitle('Contexto clínico'),
                    const SizedBox(height: 8),
                    _contextoClinicoCard(),
                  ],
                ),
              ),
            ),
            _bottomCta(),
          ],
        ),
      ),
    );
  }

  // ---------- Header: título + paso + puntos de progreso ----------
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tu perfil',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: GlucyColors.deep,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Paso 1 de 3 · 2 min aprox.',
                  style: TextStyle(fontSize: 12, color: Color(0x8010262A)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _dot(active: true),
              const SizedBox(width: 4),
              _dot(active: false),
              const SizedBox(width: 4),
              _dot(active: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      width: 22,
      height: 4,
      decoration: BoxDecoration(
        color: active ? GlucyColors.primary : GlucyColors.dotInactive,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  // ---------- Tarjeta blanca con los campos del formulario ----------
  Widget _camposCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nombreController,
            decoration: _fieldDecoration('Nombre completo', hint: 'Ej: María Torres'),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _fieldDecoration('Teléfono móvil', hint: 'Ej: 123-456-7890'),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _nacimientoField()),
              const SizedBox(width: 12),
              Expanded(child: _sexoField()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _tallaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _onPesoTallaChanged(),
                  decoration: _fieldDecoration('Talla (cm)', hint: 'Ej: 170'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _pesoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _onPesoTallaChanged(),
                  decoration: _fieldDecoration('Peso (kg)', hint: 'Ej: 70'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _anosDiabetesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _fieldDecoration('Años con diabetes', hint: 'Ej: 5'),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()), // celda vacía, como en el grid del HTML
            ],
          ),
        ],
      ),
    );
  }

  // "Nacimiento" usa un InputDecorator en vez de TextField, ya que abre el
  // date picker en lugar del teclado (misma lógica que ya tenías).
  Widget _nacimientoField() {
    final texto = _fechaNacimiento != null
        ? _fechaNacimiento.toString().split(' ')[0]
        : 'Seleccionar fecha';
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: _abrirDataPicker,
      child: InputDecorator(
        decoration: _fieldDecoration('Nacimiento'),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 13.5, color: GlucyColors.ink),
        ),
      ),
    );
  }

  Widget _sexoField() {
    return DropdownButtonFormField<String>(
      value: _sexoSeleccionado,
      isExpanded: true,
      decoration: _fieldDecoration('Sexo'),
      hint: const Text('Seleccionar', style: TextStyle(fontSize: 13.5)),
      items: opciones
          .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13.5))))
          .toList(),
      onChanged: (nuevoValor) {
        setState(() => _sexoSeleccionado = nuevoValor);
      },
    );
  }

  // ---------- Tarjeta verde con el IMC ----------
  Widget _imcCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GlucyColors.imcCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IMC estimado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: GlucyColors.imcText,
                ),
              ),
              Text(
                _categoriaImc,
                style: TextStyle(fontSize: 11.5, color: GlucyColors.imcText.withOpacity(0.7)),
              ),
            ],
          ),
          Text(
            _imc.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: GlucyColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Sora',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0x6B10262A), // rgba(16,38,42,0.42)
        letterSpacing: 0.8,
      ),
    );
  }

  // ---------- Tarjeta blanca con medicación y antecedentes familiares ----------
  Widget _contextoClinicoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicación actual',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.mutedLabel),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _chipMedicacion('Metformina 850 mg'),
              _chipAgregar(),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Antecedentes familiares',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.mutedLabel),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _famChips.keys.map((key) => _chipAntecedente(key)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chipMedicacion(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: GlucyColors.chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary),
      ),
    );
  }

  Widget _chipAgregar() {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        // TODO: abrir selector para agregar medicación
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: GlucyColors.chipDashedBorder, style: BorderStyle.solid),
        ),
        child: const Text(
          '+ Agregar',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary),
        ),
      ),
    );
  }

  Widget _chipAntecedente(String key) {
    final activo = _famChips[key] ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => setState(() => _famChips[key] = !activo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? GlucyColors.chipBg : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: activo ? const Color(0x660A7C86) : const Color(0x1F052E33),
          ),
        ),
        child: Text(
          _famLabels[key]!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: activo ? GlucyColors.primary : GlucyColors.ink,
          ),
        ),
      ),
    );
  }

  List<NoAptoRecapItem> _noAptoRecap() {
    final nombre = _nombreController.text.trim();
    final edad = _edad;
    final perfil = [
      if (nombre.isNotEmpty) nombre,
      if (edad != null) '$edad años',
    ].join(' · ');
    final anos = _anosDiabetesController.text.trim();
    return [
      NoAptoRecapItem('Perfil', perfil.isEmpty ? '—' : perfil),
      NoAptoRecapItem('IMC estimado', _imc == 0 ? '—' : '${_imc.toStringAsFixed(1)} · $_categoriaImc'),
      NoAptoRecapItem('Años con diabetes', anos.isEmpty ? '—' : anos),
      const NoAptoRecapItem('Filtro clínico', '9 de 9 respondidas'),
    ];
  }

  // ---------- Botón inferior fijo ----------
  Widget _bottomCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GlucyColors.cardBorder)),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClinicalFilterScreen(
                onPassed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Filtro1Screen()),
                ),
                onUrgent: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UrgencyScreen()),
                ),
                onNotEligible: (reason) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoAptoScreen(
                      reason: reason,
                      recap: [..._noAptoRecap(), NoAptoRecapItem('Respuesta de alarma', reason)],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: GlucyColors.primary,
          foregroundColor: GlucyColors.bg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Continuar al filtro clínico',
          style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}