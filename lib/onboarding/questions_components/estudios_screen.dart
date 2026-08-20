import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/estudios/estudio_api.dart';
import 'package:glucy_app/onboarding/questions_components/lab_domicilio_screen.dart';
import 'package:glucy_app/onboarding/questions_components/procesando_screen.dart';

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

/// Estado visible de cada tipo de estudio, derivado del ultimo intento.
enum _Estado { sinSubir, enRevision, aprobado, rechazado }

class _Fila {
  const _Fila({required this.tipo, this.estudio});

  final TipoEstudio tipo;
  final EstudioMedico? estudio;

  _Estado get estado => switch (estudio?.estado) {
        null => _Estado.sinSubir,
        'aprobado' => _Estado.aprobado,
        'rechazado' => _Estado.rechazado,
        // 'pendiente' y 'en_revision': ya subido, espera veredicto del doctor.
        _ => _Estado.enRevision,
      };
}

/// Archivo elegido por el paciente. Record propio y no `PlatformFile` porque
/// esa clase es `abstract base` (no se puede doblar en tests).
typedef ArchivoElegido = ({String nombre, String ruta});

typedef SelectorDeArchivo = Future<ArchivoElegido?> Function();

/// Estudios del paciente contra la API: lista el paquete requerido
/// (`/tipo-estudios`), muestra el veredicto de cada carga y sube el
/// documento (`/archivos/subir` + `/estudios-medicos`). La aprobación la
/// firma un doctor desde su portal; aquí solo se ve el estado.
class EstudiosScreen extends ConsumerStatefulWidget {
  const EstudiosScreen({super.key, this.elegirArchivo});

  /// Inyectable para test; por defecto abre el selector de archivos.
  final SelectorDeArchivo? elegirArchivo;

  @override
  ConsumerState<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends ConsumerState<EstudiosScreen> {
  List<_Fila> _filas = const [];
  bool _cargando = true;
  String? _error;
  int? _subiendoTipoId;
  bool _subiendoTodo = false;

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
      final api = ref.read(estudioApiProvider);
      final tipos = await api.tipos();
      final estudios = await api.propios();

      // El ultimo intento por tipo decide el estado (la lista llega en orden
      // descendente de creacion, el primero que aparece es el mas reciente).
      final ultimoPorTipo = <int, EstudioMedico>{};

      for (final estudio in estudios) {
        final tipoId = estudio.tipoEstudioId ?? estudio.tipoEstudio?.id;

        if (tipoId != null && !ultimoPorTipo.containsKey(tipoId)) {
          ultimoPorTipo[tipoId] = estudio;
        }
      }

      if (!mounted) return;

      setState(() {
        _filas = [for (final tipo in tipos) _Fila(tipo: tipo, estudio: ultimoPorTipo[tipo.id])];
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

  int get _completos => _filas.where((f) => f.estado == _Estado.aprobado).length;
  int get _subidos => _filas.where((f) => f.estado != _Estado.sinSubir).length;
  int get _total => _filas.length;
  bool get _todosAprobados => _total > 0 && _completos == _total;

  Future<ArchivoElegido?> _elegirArchivo(String titulo) async {
    if (widget.elegirArchivo != null) return widget.elegirArchivo!();

    final archivo = await FilePicker.pickFile(
      dialogTitle: titulo,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (archivo == null || archivo.path == null) return null;

    return (nombre: archivo.name, ruta: archivo.path!);
  }

  Future<void> _subir(_Fila fila) async {
    if (fila.estado == _Estado.aprobado || fila.estado == _Estado.enRevision) return;

    final archivo = await _elegirArchivo('Elegir resultado (foto o PDF)');

    if (archivo == null || !mounted) return;

    setState(() => _subiendoTipoId = fila.tipo.id);

    try {
      await ref.read(estudioApiProvider).subir(
            tipoEstudioId: fila.tipo.id,
            rutaArchivo: archivo.ruta,
            nombreArchivo: archivo.nombre,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${fila.tipo.nombre} subido. Queda en revisión médica.')),
      );

      await _cargar();
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo subir: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _subiendoTipoId = null);
    }
  }

  /// Filas que la carga conjunta tiene que cubrir: sin subir o rechazadas.
  List<_Fila> get _faltantes =>
      [for (final f in _filas) if (f.estado == _Estado.sinSubir || f.estado == _Estado.rechazado) f];

  /// Un solo archivo (la hoja completa del laboratorio) que se registra como
  /// estudio de cada tipo que falte: todos quedan "Subido · en revisión" y el
  /// doctor valida tipo por tipo sobre el mismo documento.
  Future<void> _subirTodo() async {
    final faltantes = _faltantes;

    if (faltantes.isEmpty || _subiendoTodo) return;

    final archivo = await _elegirArchivo('Elegir el archivo con todos los resultados');

    if (archivo == null || !mounted) return;

    setState(() => _subiendoTodo = true);

    try {
      final api = ref.read(estudioApiProvider);
      final archivoId = await api.subirArchivo(rutaArchivo: archivo.ruta, nombreArchivo: archivo.nombre);

      for (final fila in faltantes) {
        await api.registrar(
          tipoEstudioId: fila.tipo.id,
          archivoId: archivoId,
          descripcion: 'Carga conjunta: ${archivo.nombre}',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${archivo.nombre} subido: ${faltantes.length} estudios quedan en revisión médica.'),
      ));

      await _cargar();
    } on FalloApi catch (fallo) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo subir: ${fallo.mensaje}')));
    } finally {
      if (mounted) setState(() => _subiendoTodo = false);
    }
  }

  void _enviarAAnalisis() {
    if (!_todosAprobados) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProcesandoScreen()));
  }

  ({Color tint, Color fg, IconData icon, String label}) _meta(_Estado estado) {
    switch (estado) {
      case _Estado.aprobado:
        return (tint: GlucyColors.tealBg, fg: GlucyColors.primary, icon: Icons.check_circle_outline, label: 'Aprobado');
      case _Estado.enRevision:
        return (tint: GlucyColors.track, fg: GlucyColors.tealText, icon: Icons.hourglass_top_outlined, label: 'Subido · en revisión médica');
      case _Estado.sinSubir:
        return (tint: GlucyColors.warnBg, fg: GlucyColors.warn, icon: Icons.schedule_outlined, label: 'Pendiente de subir');
      case _Estado.rechazado:
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
                  Text('Sube foto o PDF de cada resultado; tu médica los valida uno a uno.',
                      style: TextStyle(fontSize: 12.5, color: Color(0x8C10262A))),
                ],
              ),
            ),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: GlucyColors.primary))
                  : _error != null
                      ? _errorVista()
                      : RefreshIndicator(
                          color: GlucyColors.primary,
                          onRefresh: _cargar,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                            children: [
                              _progresoCard(),
                              const SizedBox(height: 12),
                              for (final fila in _filas) ...[
                                _filaEstudio(fila),
                                const SizedBox(height: 10),
                              ],
                              _labRow(),
                              if (_faltantes.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _subirTodoCard(),
                              ],
                            ],
                          ),
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
                onPressed: _todosAprobados ? _enviarAAnalisis : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlucyColors.primary,
                  disabledBackgroundColor: GlucyColors.primary.withValues(alpha: 0.35),
                  foregroundColor: GlucyColors.bg,
                  disabledForegroundColor: GlucyColors.bg,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _todosAprobados
                      ? 'Enviar a análisis clínico'
                      : _subidos < _total
                          ? 'Sube los estudios para continuar'
                          : 'Esperando validación médica',
                  style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorVista() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No se pudieron cargar los estudios: $_error',
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: GlucyColors.muted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
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
              Text('$_completos de $_total aprobados', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xB310262A))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _total == 0 ? 0 : _completos / _total,
              minHeight: 8,
              backgroundColor: GlucyColors.track,
              valueColor: const AlwaysStoppedAnimation(GlucyColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEstudio(_Fila fila) {
    final meta = _meta(fila.estado);
    final motivo = fila.estudio?.motivoRechazo;
    final subiendo = _subiendoTipoId == fila.tipo.id;
    final estadoTexto = fila.estado == _Estado.rechazado && motivo != null && motivo.isNotEmpty
        ? '${meta.label} · $motivo'
        : meta.label;
    final accionable = fila.estado == _Estado.sinSubir || fila.estado == _Estado.rechazado;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: subiendo ? null : () => _subir(fila),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: GlucyColors.cardBorder), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(9)),
              child: subiendo
                  ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2, color: GlucyColors.primary))
                  : Icon(meta.icon, size: 18, color: meta.fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fila.tipo.nombre, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: GlucyColors.ink)),
                  Text(subiendo ? 'Subiendo…' : estadoTexto, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: meta.fg)),
                ],
              ),
            ),
            if (accionable && !subiendo)
              const Icon(Icons.upload_file_outlined, size: 18, color: GlucyColors.primary),
          ],
        ),
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

  Widget _subirTodoCard() {
    final faltan = _faltantes.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GlucyColors.dashedBorder, width: 1.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Tienes todo en un solo archivo?',
            style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: GlucyColors.deep),
          ),
          const SizedBox(height: 4),
          Text(
            'Sube la hoja completa del laboratorio una sola vez y quedará registrada para '
            '${faltan == 1 ? 'el estudio que falta' : 'los $faltan estudios que faltan'}.',
            style: const TextStyle(fontSize: 11.5, height: 1.5, color: GlucyColors.muted),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('boton-subir-todo'),
              onPressed: _subiendoTodo ? null : _subirTodo,
              style: OutlinedButton.styleFrom(
                foregroundColor: GlucyColors.primary,
                side: const BorderSide(color: Color(0x4D0A7C86)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: _subiendoTodo
                  ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file_outlined, size: 17),
              label: const Text(
                'Subir un archivo con todo',
                style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
