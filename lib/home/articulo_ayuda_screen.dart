import 'package:flutter/material.dart';
import 'package:glucy_app/features/ayuda/ayuda_api.dart';

class GlucyColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const tealBg = Color(0xFFDEF3EC);
}

/// Articulo del centro de ayuda tal como lo publico el equipo en glucyai.
class ArticuloAyudaScreen extends StatelessWidget {
  const ArticuloAyudaScreen({super.key, required this.articulo});

  final ArticuloAyuda articulo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlucyColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: GlucyColors.tealBg, borderRadius: BorderRadius.circular(999)),
                    child: Text(articulo.categoria,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GlucyColors.primary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(articulo.titulo,
                        style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, color: GlucyColors.deep)),
                    const SizedBox(height: 12),
                    Text(articulo.cuerpo,
                        style: const TextStyle(fontSize: 13.5, height: 1.65, color: GlucyColors.ink)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
