import 'package:flutter/material.dart';

class ClinicalFilterScreen extends StatefulWidget {
  final VoidCallback onAdultConfirmed;

  const ClinicalFilterScreen({
    super.key,
    required this.onAdultConfirmed,
  });

  @override
  State<ClinicalFilterScreen> createState() => _ClinicalFilterScreenState();
}

class _ClinicalFilterScreenState extends State<ClinicalFilterScreen> {
  bool? _isAdult;

  static const Color _bgColor = Color(0xFF052E33);
  static const Color _neonGreen = Color(0xFF2EE6A8);
  static const Color _textColor = Color(0xFFFFFFFF);

  bool get _canContinue => _isAdult != null;

  void _handleSelection(bool isAdult) {
    setState(() => _isAdult = isAdult);
  }

  void _handleContinue() {
    if (_isAdult == true) {
      widget.onAdultConfirmed();
    } else if (_isAdult == false) {
      _showMinorBlockedDialog();
    }
  }

  void _showMinorBlockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _neonGreen, width: 1.5),
        ),
        title: const Text(
          'Acceso restringido',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Esta aplicación está diseñada para uso de personas mayores de 18 años. '
          'Si tienes dudas sobre tu salud, consulta con un profesional médico o con un adulto responsable.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildFilterCard(),
                const SizedBox(height: 32),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(
        painter: _GlucyLogoPainter(strokeColor: _neonGreen, nodeColor: _textColor),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: _neonGreen,
          width: 3.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.medical_information_outlined,
            color: Color(0xE6FFFFFF), // blanco 90% opacidad
            size: 48,
          ),
          const SizedBox(height: 24),
          const Text(
            '¿Tienes 18 años o más?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Necesitamos confirmar tu edad antes de continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _NeonButton(
                  text: 'Sí',
                  isSelected: _isAdult == true,
                  neonGreen: _neonGreen,
                  textColor: _textColor,
                  onPressed: () => _handleSelection(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _NeonButton(
                  text: 'No',
                  isSelected: _isAdult == false,
                  neonGreen: _neonGreen,
                  textColor: _textColor,
                  onPressed: () => _handleSelection(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _canContinue ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonGreen,
          disabledBackgroundColor: _neonGreen.withOpacity(0.25),
          foregroundColor: _bgColor,
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Continuar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color neonGreen;
  final Color textColor;
  final VoidCallback onPressed;

  const _NeonButton({
    required this.text,
    required this.isSelected,
    required this.neonGreen,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? neonGreen.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? neonGreen : textColor.withOpacity(0.3),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: neonGreen.withOpacity(0.2),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? neonGreen : textColor.withOpacity(0.8),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Recrea el ícono del SVG original: un contorno tipo "corazón/hoja" en verde
/// neón con tres nodos blancos conectados en su interior.
class _GlucyLogoPainter extends CustomPainter {
  final Color strokeColor;
  final Color nodeColor;

  _GlucyLogoPainter({required this.strokeColor, required this.nodeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double sx = size.width / 100;
    final double sy = size.height / 100;

    Offset p(double x, double y) => Offset(x * sx, y * sy);

    // Contorno principal (aprox. al path del SVG original)
    final outline = Path()
      ..moveTo(p(50, 10).dx, p(50, 10).dy)
      ..cubicTo(
        p(50, 10).dx, p(50, 10).dy,
        p(22, 44).dx, p(22, 44).dy,
        p(22, 63).dx, p(22, 63).dy,
      )
      ..arcToPoint(
        p(78, 63),
        radius: Radius.elliptical(28 * sx, 28 * sy),
        clockwise: false,
      )
      ..cubicTo(
        p(78, 44).dx, p(78, 44).dy,
        p(50, 10).dx, p(50, 10).dy,
        p(50, 10).dx, p(50, 10).dy,
      )
      ..close();

    final outlinePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * sx
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(outline, outlinePaint);

    // Líneas internas conectando los 3 nodos
    final innerLines = Path()
      ..moveTo(p(40, 58).dx, p(40, 58).dy)
      ..lineTo(p(60, 52).dx, p(60, 52).dy)
      ..lineTo(p(53, 72).dx, p(53, 72).dy)
      ..lineTo(p(40, 58).dx, p(40, 58).dy);

    final innerPaint = Paint()
      ..color = nodeColor.withOpacity(0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * sx;

    canvas.drawPath(innerLines, innerPaint);

    // Nodos (círculos blancos)
    final nodePaint = Paint()..color = nodeColor;
    canvas.drawCircle(p(40, 58), 4.5 * sx, nodePaint);
    canvas.drawCircle(p(60, 52), 4.5 * sx, nodePaint);
    canvas.drawCircle(p(53, 72), 4.5 * sx, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _GlucyLogoPainter oldDelegate) => false;
}