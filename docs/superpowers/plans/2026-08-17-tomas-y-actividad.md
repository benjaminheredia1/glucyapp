# Tomas de medicación y actividad — plan (app)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mi plan → Medicamentos lista y marca las tomas reales del día; Actividad es el historial real; el doctor asigna medicación con horarios desde la app.

**Architecture:** `MedicacionApi` (Dio autenticado) + dos `FutureProvider.autoDispose` (`tomasDeHoyProvider`, `actividadProvider`); pantallas Riverpod que invalidan al escribir. Zona horaria IANA en `AppConfig.zonaHoraria` (`.env ZONA_HORARIA`, default `America/La_Paz`).

**Tech Stack:** Flutter, flutter_riverpod 3, dio + http_mock_adapter, flutter_test.

**Spec:** `docs/superpowers/specs/2026-08-17-tomas-y-actividad-design.md`

## Global Constraints

- Mismas del plan anterior (español sin tildes en identificadores, no `dart format` global, `flutter analyze` + `flutter test` en verde por tarea, commits con `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`).
- No tocar los cambios locales del usuario (`dio_client.dart`, `pubspec.*`, `devtools_options.yaml`).

---

### Task 1: `AppConfig.zonaHoraria`
- Test (`app_config_test`): sin `ZONA_HORARIA` → `America/La_Paz`; con `ZONA_HORARIA=Europe/Madrid` → ese valor.
- Impl: campo `zonaHoraria` (`String`), `desdeMapa` lee `env['ZONA_HORARIA']` (vacío ⇒ default). Actualizar `.env.example` y `.env` (comentario). Actualizar todos los `AppConfig(` de tests si construyen a mano.
- Commit `feat: zona horaria IANA en AppConfig`.

### Task 2: `MedicacionApi` + providers
- Files: `lib/features/medicacion/medicacion_api.dart`, `lib/features/medicacion/medicacion_providers.dart`, `test/features/medicacion/medicacion_api_test.dart`.
- Tests con `DioAdapter`: `tomasDeHoy` manda `dia`, `zona`, `orden=programadaEn`, `direccion=asc` y parsea `paciente_medicamento.medicamento.nombre`, `dosis`, `programadaEn` a local; `marcar(id, tomada: true)` hace `POST /tomas/{id}/marcar {estado: tomada}`; `actividad()` parsea `tipo` toma/medicion en `EntradaActividad`; `medicamentos()`/`pacientes()` leen `data[]` (paciente: `usuario.name` + `apellidoPaterno`); `asignar(...)` manda `horarios` y `fechaInicio` `Y-m-d`.
- Providers: `tomasDeHoyProvider` usa `DateTime.now()` local (`Y-m-d`) y `ref.watch(appConfigProvider).zonaHoraria`; `actividadProvider` (`porPagina: 50`).
- Commit `feat: MedicacionApi y providers de tomas y actividad`.

### Task 3: `PlanScreen` real (Medicamentos + Actividad)
- Test `test/home/plan_screen_test.dart` con `MedicacionApiFalsa` y `appConfigProvider` sobrescrito: lista tomas (nombre, dosis, hora HH:mm local), contador "Tomas de hoy: 1 de 2", tap "Marcar" llama `marcar(id, tomada: true)` y la lista se refresca (fake cambia estado); vacío → texto "Tu médico aún no cargó tu plan de medicación"; pestaña Actividad muestra "Hoy"/"Ayer" y entradas de ambos tipos.
- Impl: `ConsumerStatefulWidget`; `_medsList` con `ref.watch(tomasDeHoyProvider).when(...)`; `_actividad` con `ref.watch(actividadProvider).when(...)`, agrupación por día local. `RegistrarScreen` invalida también `actividadProvider`.
- Commit `feat: Mi plan lista y marca las tomas reales; Actividad es el historial`.

### Task 4: doctor "Asignar medicación"
- Files: `lib/doctor/asignar_medicacion_screen.dart`, entrada en `DashScreen`, `test/doctor/asignar_medicacion_screen_test.dart`.
- Test: carga pacientes y medicamentos del fake; elegir paciente y medicamento, dosis "1 comprimido", añadir horarios 08:00 y 20:00 (chips con `Key('horario-agregar')` que en test añade una hora fija; el selector real usa `showTimePicker`), tap "Asignar" → `asignar(...)` con `horarios ['08:00','20:00']`, snackbar de éxito y `pop`.
- Impl: `DropdownButtonFormField` paciente/medicamento, `TextField` dosis (`Key('campo-dosis')`), frecuencia (`Key('campo-frecuencia')`), chips de horarios con botón "+ hora" (`showTimePicker`; en test se inyecta `Future<TimeOfDay?> Function(BuildContext)? seleccionarHora`), botón `Key('boton-asignar')`.
- Commit `feat: el doctor asigna medicacion con horarios desde el panel`.

### Task 5: cierre
- `flutter analyze` + `flutter test`; probar en el teléfono: doctor asigna → paciente ve tomas → marca → Actividad. Commit si hay ajustes; merge a `main` y push si el usuario lo pide.
