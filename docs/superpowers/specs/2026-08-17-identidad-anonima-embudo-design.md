# Identidad anónima y embudo sin correo — diseño (app)

Fecha: 2026-08-17. Backend: rama `feature/paciente-anonimo` de `glucyai` (contrato en su commit `c89c44f`).

## Objetivo

Seguir el flujo del prototipo (`Glucy AI (2) - Copy.html`, pantallas paciente 1–19) sin pedir correo en el filtro clínico:

```
splash → onboarding → tu perfil → filtro clínico → filtro 1 OK → estudios → subir / lab
       → procesando → elegibilidad → pre-diagnóstico → crear cuenta → checkout → … → inicio
```

Todo el embudo corre con una **identidad temporal** (`POST /auth/anonimo`) creada al pulsar
"Empezar" en onboarding. La cuenta real nace en "Crear cuenta" reclamando esa identidad
(`POST /auth/auth0` con el Bearer anónimo). Mismo `usuario.id`, mismos estudios.

## Decisiones

- **A. Cuándo crear el anónimo:** al pulsar "Empezar es gratis" en onboarding, no en el
  arranque. Evita cuentas basura de quien solo abre la app y de médicos que van al portal.
- **B. 401 "El token de la sesion no es valido." al reclamar:** borrar el token local y
  reintentar el login **sin** Bearer. El usuario termina con cuenta real; lo cargado como
  anónimo se perdió (el backend ya lo purgó) y se le avisa.
- **C. Cerrar sesión siendo temporal:** no hay pantalla que lo permita. Nada que añadir.
- **D. Médico:** `DoctorLoginScreen` siempre inicia sesión **sin** reclamar (`reclamar: false`).
- **E. `evaluar` viaja con Bearer** (por `dioProvider`) para que el backend ate la
  precalificación al paciente. Se elimina `leadEmail`, `VinculadorPrecalificacion` y el id de
  precalificación guardado en `EmbudoStore`. Se conserva `guardarProgreso` (retomar el filtro
  a medias).

## Componentes

### Dominio

- `Usuario`: `email` pasa a `String?`; nuevo `esTemporal` (`bool`, default `false`, `@JsonKey(defaultValue: false)`).
- `Sesion` no cambia de forma: temporal = `Sesion.autenticado(usuario)` con `usuario.esTemporal == true`.
- `FalloApi`: nuevo `FalloConflicto` (409). `traducirFallo` lo produce con el `message` del backend.

### Datos

- `AuthApi`
  - `anonimo({String dispositivo = 'api'})` → `POST /auth/anonimo` → `RespuestaSesion`.
  - `intercambiar(accessToken, {String dispositivo = 'api', String? tokenAnonimo})` →
    `POST /auth/auth0`; si `tokenAnonimo != null`, añade `Authorization: Bearer <tokenAnonimo>`
    a mano. Sigue en `dioPublico` (sin `AuthInterceptor`, para no entrar en la cola de
    renovación).
- `AuthRepository`
  - `entrarComoAnonimo()`: `anonimo()` → `store.guardar(token)` → `Usuario`.
  - `iniciarSesion({conexion, bool reclamar = true})`:
    1. `accessToken = gateway.iniciarSesion(conexion)`.
    2. `tokenAnonimo = reclamar ? await store.leer() : null` (vacío ⇒ null).
    3. `intercambiar(accessToken, tokenAnonimo: tokenAnonimo)`.
       - `FalloAuth` con `tokenAnonimo != null` (401 "token de la sesion no es valido") ⇒
         `store.borrar()` y reintentar **sin** Bearer una sola vez.
       - `FalloConflicto` (409) ⇒ propaga. El token anónimo se conserva.
       - Resto (`FalloValidacion` 422, `FalloAuth` 403 sin token anónimo, `FalloServidor` 503…) ⇒ propaga.
    4. `store.guardar(respuesta.token)` → `Usuario`.
  - `restaurarSesion()`: igual (GET `/user`; `FalloAuth` ⇒ borrar y `null`).
  - `cerrarSesion()`: igual; sigue limpiando `EmbudoStore`.
- `PrecalificacionRepository.evaluar(respuestas)`: sin `leadEmail`. `PrecalificacionApi.evaluar`
  usa `dioProvider` (con Bearer). `preguntas()` sigue en `dioPublico`. `vincular()` se elimina.
- `EmbudoStore`: se eliminan `guardarPrecalificacion`/`leerPrecalificacion`; `limpiar()` borra
  solo el progreso. `VinculadorPrecalificacion` y su provider se eliminan.

### Presentación

- `SesionController`
  - `entrarComoAnonimo()`: `AsyncLoading` → `AsyncData(autenticado(usuario))`; error ⇒ `AsyncError`.
  - `iniciarSesion({conexion, reclamar = true})`: pasa `reclamar`. Fuera la llamada al vinculador.
- Router (`glucy_router.dart`)
  - Nueva ruta pública `Rutas.perfil = '/tu-perfil'` → `Profile` (pantalla legacy adaptada).
  - `_destinoAutenticado(usuario, destino)`: si `usuario.esTemporal`:
    - destino público (`Rutas.publicas`) ⇒ `null` (splash ⇒ onboarding, como el no autenticado).
    - cualquier otro (inicio paciente, portal médico) ⇒ `Rutas.onboarding`.
    Cuenta real: como hoy.
- `OnboardingScreen` (`_empezar`): si la sesión ya es autenticada (temporal o real) ⇒
  `context.go(Rutas.perfil)`; si no ⇒ `entrarComoAnonimo()` con spinner en el botón; al
  resolver ⇒ `context.go(Rutas.perfil)`; en error ⇒ `MensajeError` + botón reintentar.
- `Profile` ("Tu perfil"): "Continuar al filtro clínico" ⇒ `PerfilApi.actualizar(name,
  fechaNacimiento, sexo (minúsculas: femenino/masculino/otro), pesoKg, tallaCm)` ⇒
  `context.go(Rutas.filtroClinico)`. Años con diabetes y antecedentes se quedan locales (el
  contrato del PATCH no los acepta). Fallo ⇒ snackbar/`MensajeError`, se queda en la pantalla.
- `ClinicalFilterScreen`: sin campo de correo (ya quitado). `EstadoFiltro` sin `leadEmail`,
  `completo => todasRespondidas`. Botón "atrás" ⇒ `Rutas.perfil`.
- `EstudiosScreen`: revertir el parche "sin sesión no pide propios": con Bearer anónimo
  `propios()` funciona. Se elimina `test/onboarding/questions_components/estudios_screen_test.dart`.
- `CrearCuentaScreen`: `iniciarSesion()` reclama. Ante `FalloConflicto`: diálogo
  "Ya existe una cuenta con este correo. ¿Iniciar sesión con ella? Lo que cargaste como
  invitado no se transfiere." → Sí ⇒ `iniciarSesion(reclamar: false)`. Ante `FalloValidacion`
  (correo sin verificar) ⇒ `MensajeError` como hoy.
- `DoctorLoginScreen`: `iniciarSesion(reclamar: false)`.
- `CuentaScreen`: `usuario.email ?? ''` ya tolera null.

## Flujo de sesión

| Estado | Rutas permitidas | Redirección |
|---|---|---|
| no autenticado | públicas | otras ⇒ `/login`; splash ⇒ `/onboarding` |
| autenticado temporal | públicas (embudo, crear cuenta, login, portal médico login) | inicio/portal ⇒ `/onboarding`; splash ⇒ `/onboarding` |
| autenticado paciente | como hoy | públicas ⇒ `/inicio` |
| autenticado doctor/admin | como hoy | públicas ⇒ `/portal-medico` |

Arranque: token guardado ⇒ `GET /user` ⇒ `esTemporal` decide. 401 ⇒ borrar ⇒ no autenticado
(al pulsar Empezar se crea otro anónimo). El embudo local (`guardarProgreso`) sobrevive.

## Errores

- `POST /auth/anonimo` 429 ⇒ `FalloLimite` ⇒ mensaje "Inténtalo en X s" en onboarding.
- Cualquier 401 en ruta autenticada con token anónimo: el `AuthInterceptor` intenta renovar
  por Auth0, `accessTokenVigente()` devuelve `null`, borra el token y propaga `FalloAuth`. La
  pantalla muestra el error; en el siguiente arranque `restaurarSesion()` ya no encuentra
  token y el flujo vuelve a onboarding. No se añade recuperación automática en caliente.

## Tests

- `traducir_fallo_test`: 409 ⇒ `FalloConflicto` con mensaje.
- `auth_api_test`: `anonimo()` (201 → token+usuario, `esTemporal`), `intercambiar` con y sin Bearer.
- `auth_repository_test`: `entrarComoAnonimo` guarda token; `iniciarSesion` reclama con token
  guardado; 401 con token anónimo ⇒ borra y reintenta sin Bearer; 409 ⇒ propaga
  `FalloConflicto` y conserva token; `reclamar: false` nunca manda Bearer.
- `sesion_controller_test`: `entrarComoAnonimo` ⇒ autenticado temporal; `iniciarSesion` ya no
  llama al vinculador (se borra ese test).
- `glucy_router_test`: temporal en `/inicio` ⇒ `/onboarding`; temporal puede ir a
  `/tu-perfil`, `/filtro-clinico`, `/crear-cuenta`; onboarding "Empezar" crea anónimo y va a
  `/tu-perfil`.
- `filtro_clinico_controller_test`: `completo` sin correo; `enviar` no manda `leadEmail`.
- `precalificacion_repository_test`: body sin `leadEmail`.
- `crear_cuenta_screen_test`: 409 muestra el diálogo y "Iniciar sesión" reintenta con `reclamar: false`.
- `doctor_login_screen_test`: llama con `reclamar: false`.
- `profile` (nuevo `tu_perfil_screen_test`): "Continuar" hace PATCH con los campos y navega.
- Se eliminan `vinculador_precalificacion_test` y `estudios_screen_test`.

## Fuera de alcance

- Pantallas 9–13 y 15–19 más allá de que ya funcionen con Bearer anónimo.
- Purga a 30 días (el 401 en `restaurarSesion` ya la cubre).
- Logger Pretty y Chucker (cambios locales del usuario, no se tocan).
