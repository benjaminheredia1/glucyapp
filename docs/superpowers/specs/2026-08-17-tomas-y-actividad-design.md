# Tomas de medicación y actividad — diseño (app)

Fecha: 2026-08-17. Backend: `glucyai` rama `feature/tomas-diarias`, contrato en `docs/api/tomas-y-actividad-app.md`.

## Objetivo

Que "Mi plan → Medicamentos" muestre las tomas reales del día, que "Marcar" las registre en el servidor y que la pestaña "Actividad" sea el historial real (tomas marcadas + mediciones). Y que un doctor pueda asignar medicamentos con horarios desde la app, porque nada más los crea.

## Decisiones

- **A.** El paciente pide `GET /tomas?dia=<hoy local>&zona=<zona del teléfono>&orden=programadaEn&direccion=asc`. La zona sale de `DateTime.now().timeZoneName` **no** (abreviatura, p. ej. "BOT"); se usa el offset local: el backend acepta IANA, así que la app manda un IANA fijo desde config: `AppConfig.zonaHoraria` leído de `.env` `ZONA_HORARIA` (default `America/La_Paz`). Se documenta en `.env.example`.
- **B.** "Actividad" deja de ser actividad física: es el historial (`GET /actividad`), agrupado por día en hora local.
- **C.** Doctor: nueva pantalla "Asignar medicación" desde el panel (`DashScreen`), junto a "Estudios por validar": elige paciente (`GET /pacientes`), medicamento (`GET /medicamentos`), dosis, frecuencia (texto), horarios (chips de hora, 1–6, selector de hora), fecha de inicio (hoy) → `POST /paciente-medicamentos`. La maqueta "Editar plan → Firma" del caso se queda como está.
- **D.** Estado compartido con Riverpod: `tomasDeHoyProvider` (FutureProvider.autoDispose), `actividadProvider` (FutureProvider.autoDispose). Marcar una toma y registrar glucosa invalidan ambos.

## Componentes

- `lib/features/medicacion/medicacion_api.dart`: modelos `TomaDelDia {id, programadaEn (local), tomadaEn?, estado, medicamento, dosis}`, `EntradaActividad` (sealed: `ActividadToma`, `ActividadMedicion`), `MedicamentoCatalogo {id, nombre, concentracion?}`, `PacienteResumen {id, nombre}`; `MedicacionApi { tomasDeHoy(dia, zona), marcar(id, {tomada}), actividad({porPagina}), medicamentos(), pacientes(), asignar({pacienteId, medicamentoId, dosis, frecuencia, horarios, fechaInicio}) }`. Todo por `dioProvider`.
- `lib/features/medicacion/medicacion_providers.dart`: `tomasDeHoyProvider`, `actividadProvider`.
- `AppConfig.zonaHoraria` (+ `.env`, `.env.example`).
- `lib/home/plan_screen.dart`: `ConsumerStatefulWidget`; pestaña Medicamentos = tomas del día (loading/error/vacío "Tu médico aún no cargó tu plan de medicación"); "Marcar" → `marcar` → invalidar; "Tomada ✓" si `tomada`; contador `tomadas de total`. Pestaña Actividad = lista agrupada por día ("Hoy", "Ayer", `dd/MM`) con icono por tipo.
- `RegistrarScreen`: además invalida `actividadProvider`.
- `lib/doctor/asignar_medicacion_screen.dart` + entrada en `DashScreen`.
- Tests: `medicacion_api_test` (parseo `paciente_medicamento` snake_case, hora local, actividad), `plan_screen_test` (lista tomas, marcar llama a la API con el id y refresca, vacío, actividad agrupada), `asignar_medicacion_screen_test` (envía el POST con horarios).

## Fuera de alcance

- Recordatorios/notificaciones. Editar/retirar medicamentos ya asignados (solo alta). Pantalla de caso del doctor (maqueta).
