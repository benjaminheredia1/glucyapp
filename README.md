# glucy_app

App de Glucy AI. El arranque, la configuracion y los requisitos estan en el
[README de la raiz](../README.md).

## Estructura

- `lib/app/` — tema, router y widget raiz.
- `lib/core/` — configuracion, red, errores y almacenamiento seguro.
- `lib/features/` — una carpeta por feature (`auth`, `precalificacion`), con
  `data`, `domain` y `presentation`.
- `lib/shared/` — widgets reutilizables entre features, como `MensajeError`.
- `lib/onboarding/`, `lib/home/`, `lib/doctor/`, `lib/profile/`, `lib/warning/`
  — pantallas heredadas de antes de esta migracion. Conectarlas a la API no
  implica moverlas a `features/`: `crear_cuenta_screen.dart` y
  `clinical_filter_widget.dart` (en `onboarding/questions_components/`) y
  `doctor_login_screen.dart` (en `doctor/`) ya consumen `features/auth` y
  `features/precalificacion` sin haber cambiado de carpeta. El resto de estas
  carpetas sigue pendiente de conectarse.

Tras tocar una clase con `@freezed` o `@JsonSerializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```
