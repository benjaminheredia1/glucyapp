import 'package:flutter/material.dart';

/// Paleta unica de Glucy AI.
///
/// La misma paleta esta hoy repetida en 37 archivos de `lib/`, con campos que
/// no siempre coinciden. Cada pantalla que se conecte a la API migra a esta
/// clase y borra su copia local; migrar las 37 de golpe abriria archivos que
/// nadie esta revisando.
abstract final class GlucyPalette {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const ink = Color(0xFF10262A);
  static const muted = Color(0x9910262A);
  static const cardBorder = Color(0x14052E33);
  static const track = Color(0xFFE1EDEA);

  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);

  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
  static const alert = Color(0xFFE8574B);
  static const alertBg = Color(0xFFFBE4E1);

  static ThemeData get tema => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
        fontFamily: 'Inter',
      );
}
