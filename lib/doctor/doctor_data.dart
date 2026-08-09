import 'package:flutter/material.dart';

/// Colores del diseño Glucy AI, portal médico.
class DoctorColors {
  static const deep = Color(0xFF052E33);
  static const primary = Color(0xFF0A7C86);
  static const accent = Color(0xFF2EE6A8);
  static const bg = Color(0xFFF4FAF9);
  static const cardBorder = Color(0x14052E33); // rgba(5,46,51,0.08)
  static const ink = Color(0xFF10262A);
  static const warn = Color(0xFFB97417);
  static const warnBg = Color(0xFFFBEEDA);
  static const alert = Color(0xFFE8574B);
  static const alertBg = Color(0xFFFBE4E1);
  static const tealBg = Color(0xFFDEF3EC);
  static const tealText = Color(0xFF0A5A62);
}

enum Urgency { urgente, pendiente, estable }

class CaseItem {
  final int id;
  final String name;
  final int age;
  final Urgency urgency;
  final String kind;
  final String task;
  final String clinic;
  final String value;
  final String tag; // crítico | alto | sin registrar | en meta
  final String note;
  const CaseItem(this.id, this.name, this.age, this.urgency, this.kind, this.task, this.clinic, this.value, this.tag, this.note);

  String get initials => name.split(' ').map((w) => w[0]).take(2).join();
}

class UrgencyMeta {
  final String label;
  final Color tint;
  final Color fg;
  const UrgencyMeta(this.label, this.tint, this.fg);
}

UrgencyMeta urgencyMeta(Urgency u) {
  switch (u) {
    case Urgency.urgente:
      return const UrgencyMeta('Urgente', DoctorColors.alertBg, DoctorColors.alert);
    case Urgency.pendiente:
      return const UrgencyMeta('Pendiente', DoctorColors.warnBg, DoctorColors.warn);
    case Urgency.estable:
      return const UrgencyMeta('Estable', DoctorColors.tealBg, DoctorColors.primary);
  }
}

Color tagColor(String tag) {
  if (tag == 'crítico') return DoctorColors.alert;
  if (tag == 'alto' || tag == 'sin registrar') return DoctorColors.warn;
  return DoctorColors.primary;
}

Color tagTint(String tag) {
  if (tag == 'crítico') return DoctorColors.alertBg;
  if (tag == 'alto' || tag == 'sin registrar') return DoctorColors.warnBg;
  return DoctorColors.tealBg;
}

/// Casos de la bandeja del médico (misma cartera reusada en Pacientes,
/// Alertas y el detalle de cada caso).
const List<CaseItem> doctorCases = [
  CaseItem(1, 'María Torres', 58, Urgency.urgente, 'Ingreso nuevo · semáforo verde', 'Validar ingreso y firmar plan inicial', 'Clínica San Rafael', '268', 'crítico', 'DM2 · ajuste hoy'),
  CaseItem(2, 'Ana Ibarra', 29, Urgency.urgente, 'Ajuste de ciclo', 'TFG límite: revisar dosis de metformina', 'Salud Integral Norte', '192', 'alto', 'DM2 · TFG límite'),
  CaseItem(3, 'Jorge Aguilar', 45, Urgency.pendiente, 'Ingreso nuevo · semáforo amarillo', 'HbA1c 9.8: definir esquema inicial', 'Centro Médico Andes', '—', 'sin registrar', 'DM2 · sin registrar 3 días'),
  CaseItem(4, 'Lucía Fernández', 34, Urgency.pendiente, 'Revisión de 15 días', 'Revalidar plan y metas', 'Clínica Vitalia', '128', 'en meta', 'DM2 · revisión hoy'),
  CaseItem(5, 'Carlos Medina', 62, Urgency.estable, 'Ajuste de ciclo', 'Confirmar titulación de insulina', 'Clínica San Rafael', '121', 'en meta', 'DM2 · estable'),
  CaseItem(6, 'Roberto Sánchez', 51, Urgency.estable, 'Revisión de 15 días', 'Sin cambios sugeridos', 'Centro Médico Andes', '134', 'en meta', 'DM2 · estable'),
];

CaseItem caseById(int id) => doctorCases.firstWhere((c) => c.id == id, orElse: () => doctorCases.first);

class AlertItem {
  final int id;
  final String tab; // criticas | resueltas
  final IconData icon;
  final String title;
  final String who;
  final String time;
  final String detail;
  const AlertItem(this.id, this.tab, this.icon, this.title, this.who, this.time, this.detail);
}

const List<AlertItem> doctorAlerts = [
  AlertItem(1, 'criticas', Icons.error_outline, 'Glucosa 268 mg/dL', 'María Torres, 58 · Clínica San Rafael', 'hace 12 min',
      'Reporta sed intensa. Sin vómitos ni confusión. Última toma de metformina: 13:00.'),
  AlertItem(2, 'criticas', Icons.error_outline, 'TFG 54 mL/min', 'Ana Ibarra, 29 · Salud Integral Norte', 'hace 2 h',
      'Función renal en descenso: revisar dosis de metformina antes del próximo ciclo.'),
  AlertItem(3, 'criticas', Icons.schedule, 'Sin registrar 3 días', 'Jorge Aguilar, 45 · Centro Médico Andes', 'hace 1 día',
      'No registró mediciones desde el lunes. El ciclo de ajuste está detenido.'),
  AlertItem(5, 'resueltas', Icons.check_circle_outline, 'Glucosa 245 mg/dL', 'Carlos Medina, 62 · Clínica San Rafael', 'ayer',
      'Resuelto: ajuste de insulina aplicado y valores normalizados.'),
];
