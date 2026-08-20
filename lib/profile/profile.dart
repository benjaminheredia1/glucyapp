import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';
import 'package:go_router/go_router.dart';

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
  static const alert = Color(0xFFE8574B);
}

/// "Tu perfil" (pantalla 3 del prototipo): entre onboarding y el filtro
/// clinico. Guarda lo que el backend acepta por `PATCH /perfil` con el Bearer
/// de la identidad temporal y sigue al filtro. Anos con diabetes y
/// antecedentes se quedan en pantalla: el contrato del PATCH no los tiene.
class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  bool _guardando = false;
  String? _error;
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  double _imc = 0.0;

  static List<String> opciones = ['Masculino', 'Femenino', 'Otro'];

  // Controllers para peso/talla, necesarios para calcular el IMC en vivo
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _anosDiabetesController = TextEditingController();

  // Medicación actual: nombre + cantidad en texto libre, se agrega por
  // diálogo y viaja completa en el PATCH.
  final List<MedicamentoActual> _medicamentos = [];

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
    _telefonoController.dispose();
    _anosDiabetesController.dispose();
    super.dispose();
  }

  /// Devuelve el primer problema encontrado, o `null` si todo esta bien. El
  /// PATCH del backend es parcial y aceptaria campos vacios: la obligacion de
  /// llenarlos es de esta pantalla, antes de seguir al filtro clinico.
  String? _validar({
    required String nombre,
    required String telefono,
    required double? peso,
    required int? talla,
  }) {
    if (nombre.isEmpty) return 'Escribe tu nombre completo.';
    if (telefono.isEmpty) return 'Escribe tu teléfono móvil.';
    if (telefono.length < 7) return 'El teléfono debe tener al menos 7 dígitos.';
    if (_fechaNacimiento == null) return 'Selecciona tu fecha de nacimiento.';
    if (_sexoSeleccionado == null) return 'Selecciona tu sexo.';
    if (talla == null) return 'Escribe tu talla en centímetros.';
    if (talla < 80 || talla > 250) return 'La talla debe estar entre 80 y 250 cm.';
    if (peso == null) return 'Escribe tu peso en kilogramos.';
    if (peso < 20 || peso > 300) return 'El peso debe estar entre 20 y 300 kg.';

    return null;
  }

  Future<void> _continuar() async {
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final talla = int.tryParse(_tallaController.text);
    // El backend espera minusculas: femenino / masculino / otro.
    final sexo = _sexoSeleccionado?.toLowerCase();

    final problema = _validar(nombre: nombre, telefono: telefono, peso: peso, talla: talla);

    if (problema != null) {
      setState(() => _error = problema);

      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      // Solo viajan los campos con valor (PATCH parcial). La medicación se
      // omite si no se agregó ninguna: el backend no toca lo que no viaja.
      await ref.read(perfilApiProvider).actualizar(
            name: nombre.isEmpty ? null : nombre,
            telefono: telefono.isEmpty ? null : telefono,
            fechaNacimiento: _fechaNacimiento,
            sexo: sexo,
            pesoKg: peso,
            tallaCm: talla,
            medicacionActual: _medicamentos.isEmpty ? null : _medicamentos,
          );

      if (!mounted) return;
      context.go(Rutas.filtroClinico);
    } on FalloApi catch (fallo) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo guardar tu perfil: ${fallo.mensaje}');
    } catch (e) {
      // Un fallo que no es de la API (parsear una respuesta rara, por
      // ejemplo) tampoco puede dejar la pantalla colgada sin explicacion.
      if (!mounted) return;
      setState(() => _error = 'No se pudo guardar tu perfil: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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
            key: const Key('campo-nombre'),
            controller: _nombreController,
            decoration: _fieldDecoration('Nombre completo', hint: 'Ej: María Torres'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-telefono'),
            controller: _telefonoController,
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
                  key: const Key('campo-talla'),
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
                  key: const Key('campo-peso'),
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
      key: const Key('campo-sexo'),
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
              for (var i = 0; i < _medicamentos.length; i++) _chipMedicacion(i),
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

  Widget _chipMedicacion(int indice) {
    final medicamento = _medicamentos[indice];
    final cantidad = medicamento.cantidad;
    final etiqueta =
        cantidad == null || cantidad.isEmpty ? medicamento.nombre : '${medicamento.nombre} · $cantidad';

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 7, 6, 7),
      decoration: BoxDecoration(
        color: GlucyColors.chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GlucyColors.primary),
          ),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => setState(() => _medicamentos.removeAt(indice)),
            child: const Icon(Icons.close, size: 14, color: GlucyColors.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _agregarMedicamento() async {
    final agregado = await showDialog<MedicamentoActual>(
      context: context,
      builder: (_) => _DialogoMedicamento(decoracion: _fieldDecoration),
    );

    if (agregado != null && mounted) {
      setState(() => _medicamentos.add(agregado));
    }
  }

  Widget _chipAgregar() {
    return InkWell(
      key: const Key('chip-agregar-medicamento'),
      borderRadius: BorderRadius.circular(999),
      onTap: _agregarMedicamento,
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

  // ---------- Botón inferior fijo ----------
  Widget _bottomCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GlucyColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12.5, color: GlucyColors.alert),
              ),
            ),
          ElevatedButton(
            onPressed: _guardando ? null : _continuar,
            style: ElevatedButton.styleFrom(
              backgroundColor: GlucyColors.primary,
              foregroundColor: GlucyColors.bg,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _guardando
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Continuar al filtro clínico',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo "Agregar medicamento" (nombre + cantidad). Widget propio, y no un
/// builder inline, para que los TextEditingController vivan y mueran con el
/// diálogo: disposearlos en el caller rompe la animación de cierre, que
/// todavía los referencia.
class _DialogoMedicamento extends StatefulWidget {
  const _DialogoMedicamento({required this.decoracion});

  final InputDecoration Function(String label, {String? hint}) decoracion;

  @override
  State<_DialogoMedicamento> createState() => _DialogoMedicamentoState();
}

class _DialogoMedicamentoState extends State<_DialogoMedicamento> {
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) return;

    final cantidad = _cantidadController.text.trim();
    Navigator.of(context).pop((nombre: nombre, cantidad: cantidad.isEmpty ? null : cantidad));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Agregar medicamento',
        style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: GlucyColors.deep),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('campo-medicamento-nombre'),
            controller: _nombreController,
            autofocus: true,
            decoration: widget.decoracion('Nombre', hint: 'Ej: Metformina'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('campo-medicamento-cantidad'),
            controller: _cantidadController,
            decoration: widget.decoracion('Cantidad', hint: 'Ej: 850 mg'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          key: const Key('boton-guardar-medicamento'),
          onPressed: _guardar,
          child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}