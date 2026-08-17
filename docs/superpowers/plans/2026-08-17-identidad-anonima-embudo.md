# Identidad anónima y embudo sin correo — plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** La app crea una identidad temporal al pulsar "Empezar", corre todo el embudo (perfil → filtro clínico → estudios → … → pre-diagnóstico) con ese Bearer y reclama la cuenta real en "Crear cuenta", sin pedir correo.

**Architecture:** Riverpod + go_router + Dio. `Usuario.esTemporal` distingue anónimo de real dentro del mismo `Sesion.autenticado`. `AuthRepository` gana `entrarComoAnonimo()` y `iniciarSesion(reclamar:)`; el router deja al temporal en rutas públicas; `evaluar` viaja con Bearer; `VinculadorPrecalificacion` y `leadEmail` desaparecen.

**Tech Stack:** Flutter, flutter_riverpod 3, go_router, dio + http_mock_adapter, freezed/json_serializable (build_runner), flutter_test.

**Spec:** `docs/superpowers/specs/2026-08-17-identidad-anonima-embudo-design.md`

## Global Constraints

- Idioma del código, comentarios, tests y commits: español sin tildes en identificadores (como el resto del repo). Copys de UI con tildes.
- Regenerar código de freezed/json con: `dart run build_runner build --delete-conflicting-outputs`.
- El repo **no** usa `dart format` a 80 columnas: no formatear archivos enteros; editar solo lo tocado.
- Después de cada tarea: `flutter analyze` sin errores nuevos y `flutter test` en verde antes de commitear.
- Commits: `feat:`/`fix:`/`refactor:`/`test:` en español, terminando con `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.
- Contrato backend (rama `feature/paciente-anonimo`): `POST /auth/anonimo` → 201 `{token, usuario}`; `POST /auth/auth0` con `Authorization: Bearer <anónimo>` reclama (200/409/401/422/403/503); `usuario.esTemporal` bool; `usuario.email` null cuando temporal.
- Cambios locales del usuario que **no** se tocan ni commitean: `lib/core/network/dio_client.dart` (PrettyDioLogger), `pubspec.yaml`/`pubspec.lock` (`pretty_dio_logger`), `devtools_options.yaml`. Los cambios ya hechos en `clinical_filter_widget.dart` y `filtro_clinico_controller.dart` (campo de correo fuera, `completo => todasRespondidas`) **sí** entran en la Task 5.

---

## Mapa de archivos

| Archivo | Responsabilidad | Tarea |
|---|---|---|
| `lib/core/error/fallo_api.dart` | + `FalloConflicto` (409) | 1 |
| `lib/core/network/traducir_fallo.dart` | 409 → `FalloConflicto` | 1 |
| `lib/features/auth/domain/usuario.dart` (+ `.freezed/.g`) | `email` nullable, `esTemporal` | 2 |
| `lib/features/auth/data/auth_api.dart` | `anonimo()`, `intercambiar(tokenAnonimo:)` | 3 |
| `lib/features/auth/data/auth_repository.dart` | `entrarComoAnonimo()`, `iniciarSesion(reclamar:)` | 4 |
| `lib/features/precalificacion/data/{precalificacion_api,precalificacion_repository,embudo_store}.dart` | sin `leadEmail`, `evaluar` con Bearer, sin `vincular` ni id guardado | 5 |
| `lib/features/precalificacion/data/vinculador_precalificacion.dart` | **borrar** | 5 |
| `lib/features/precalificacion/presentation/filtro_clinico_controller.dart` (+ `.freezed`) | sin `leadEmail`/`escribirCorreo`; `enviar` sin guardar id | 5 |
| `lib/features/auth/presentation/sesion_controller.dart` | `entrarComoAnonimo()`, `iniciarSesion(reclamar:)`, sin vinculador | 6 |
| `lib/app/router/{rutas,glucy_router}.dart` | `Rutas.perfil`, redirect del temporal | 7 |
| `lib/onboarding/questions_components/clinical_filter_widget.dart` | atrás → `Rutas.perfil` | 7 |
| `lib/onboarding/onboarding_screen.dart` | "Empezar" crea anónimo y va a `/tu-perfil` | 8 |
| `lib/profile/profile.dart` | PATCH `/perfil` y `context.go(Rutas.filtroClinico)` | 9 |
| `lib/onboarding/questions_components/crear_cuenta_screen.dart` | diálogo 409 → `reclamar: false` | 10 |
| `lib/doctor/doctor_login_screen.dart` | `reclamar: false` | 10 |
| `lib/onboarding/questions_components/estudios_screen.dart` | revertir parche "sin sesión" | 11 |

---

### Task 1: `FalloConflicto` para el 409

**Files:**
- Modify: `lib/core/error/fallo_api.dart`
- Modify: `lib/core/network/traducir_fallo.dart:36-52`
- Test: `test/core/network/traducir_fallo_test.dart`

**Interfaces:**
- Produces: `class FalloConflicto extends FalloApi { const FalloConflicto([String mensaje = 'Ese dato ya existe.']); }`

- [ ] **Step 1: Test que falla**

Añadir dentro de `group('traducirFallo', ...)` en `test/core/network/traducir_fallo_test.dart`, después del test `'404 es FalloNoEncontrado'`:

```dart
    test('409 es FalloConflicto y conserva el mensaje del backend', () {
      final fallo = traducirFallo(
        conRespuesta(409, cuerpo: {'message': 'Ya existe una cuenta con este correo. Inicia sesion con ella.'}),
      );

      expect(fallo, isA<FalloConflicto>());
      expect(fallo.mensaje, 'Ya existe una cuenta con este correo. Inicia sesion con ella.');
    });

    test('409 sin mensaje usa el texto por defecto', () {
      expect(traducirFallo(conRespuesta(409)).mensaje, 'Ese dato ya existe.');
    });
```

- [ ] **Step 2: Correr y ver rojo**

Run: `flutter test test/core/network/traducir_fallo_test.dart`
Expected: falla de compilación `Undefined name 'FalloConflicto'`.

- [ ] **Step 3: Implementar**

En `lib/core/error/fallo_api.dart`, después de `FalloValidacion`:

```dart
/// 409. En esta API: el correo o la identidad de Auth0 ya pertenece a otra
/// cuenta al reclamar una identidad anonima. La cuenta anonima no se toca.
class FalloConflicto extends FalloApi {
  const FalloConflicto([super.mensaje = 'Ese dato ya existe.']);
}
```

En `lib/core/network/traducir_fallo.dart`, dentro del `switch (respuesta.statusCode)`, entre `case 404` y `case 422`:

```dart
    case 409:
      return FalloConflicto(mensaje ?? 'Ese dato ya existe.');
```

- [ ] **Step 4: Verde**

Run: `flutter test test/core/network/traducir_fallo_test.dart`
Expected: todos pasan.

- [ ] **Step 5: Commit**

```bash
git add lib/core/error/fallo_api.dart lib/core/network/traducir_fallo.dart test/core/network/traducir_fallo_test.dart
git commit -m "feat: FalloConflicto para el 409 de la API" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 2: `Usuario` con `esTemporal` y correo opcional

**Files:**
- Modify: `lib/features/auth/domain/usuario.dart`
- Regenerate: `lib/features/auth/domain/usuario.freezed.dart`, `usuario.g.dart`
- Test: `test/features/auth/data/auth_api_test.dart` (grupo `UsuarioApi`)

**Interfaces:**
- Produces: `Usuario({required int id, required String name, String? email, required Rol rol, bool esTemporal = false, ...})`. Todo el código que hoy hace `usuario.email` como `String` debe tolerar `null` (solo `cuenta_screen.dart:111` lo usa y ya hace `?? ''`).

- [ ] **Step 1: Test que falla**

En `test/features/auth/data/auth_api_test.dart`, dentro de `group('UsuarioApi', ...)`, añadir:

```dart
    test('actual() lee esTemporal y tolera email null (identidad anonima)', () async {
      adaptador.onGet(
        '/user',
        (servidor) => servidor.reply(200, {
          'id': 1,
          'name': 'Paciente',
          'email': null,
          'auth0Sub': null,
          'rol': 'paciente',
          'esTemporal': true,
        }),
      );

      final usuario = await UsuarioApi(dio).actual();

      expect(usuario.esTemporal, isTrue);
      expect(usuario.email, isNull);
    });

    test('actual() sin esTemporal en el JSON asume cuenta real', () async {
      adaptador.onGet('/user', (servidor) => servidor.reply(200, usuarioJson()));

      expect((await UsuarioApi(dio).actual()).esTemporal, isFalse);
    });
```

- [ ] **Step 2: Correr y ver rojo**

Run: `flutter test test/features/auth/data/auth_api_test.dart`
Expected: `The getter 'esTemporal' isn't defined` (compilación).

- [ ] **Step 3: Implementar**

En `lib/features/auth/domain/usuario.dart` cambiar la factory:

```dart
  const factory Usuario({
    required int id,
    required String name,
    // Null mientras la cuenta sea temporal (identidad anonima): Auth0 aporta
    // el correo al reclamarla.
    String? email,
    required Rol rol,
    // Identidad creada por POST /auth/anonimo, todavia sin reclamar. Los
    // JSON anteriores al contrato no lo traen: se asume cuenta real.
    @JsonKey(defaultValue: false) @Default(false) bool esTemporal,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? telefono,
    @JsonKey(name: 'email_verified_at') DateTime? emailVerificadoEn,
  }) = _Usuario;
```

Regenerar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verde + analyze**

Run: `flutter test test/features/auth && flutter analyze lib/features/auth lib/home/cuenta_screen.dart`
Expected: pasan; sin errores (el `usuario?.email ?? ''` de `cuenta_screen.dart` sigue válido).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/domain/usuario.dart lib/features/auth/domain/usuario.freezed.dart lib/features/auth/domain/usuario.g.dart test/features/auth/data/auth_api_test.dart
git commit -m "feat: Usuario con esTemporal y correo opcional para la identidad anonima" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 3: `AuthApi.anonimo()` e `intercambiar` con Bearer anónimo

**Files:**
- Modify: `lib/features/auth/data/auth_api.dart`
- Test: `test/features/auth/data/auth_api_test.dart`

**Interfaces:**
- Produces:
  - `Future<RespuestaSesion> anonimo({String dispositivo = 'api'})`
  - `Future<RespuestaSesion> intercambiar(String accessToken, {String dispositivo = 'api', String? tokenAnonimo})`

- [ ] **Step 1: Tests que fallan**

En `test/features/auth/data/auth_api_test.dart` añadir un grupo nuevo antes de `group('UsuarioApi', ...)`:

```dart
  group('AuthApi.anonimo', () {
    test('crea la identidad temporal y devuelve token y usuario', () async {
      adaptador.onPost(
        '/auth/anonimo',
        (servidor) => servidor.reply(201, {
          'token': '1|anon-abc',
          'usuario': {'id': 1, 'name': 'Paciente', 'email': null, 'rol': 'paciente', 'esTemporal': true},
        }),
        data: {'dispositivo': 'android-1'},
      );

      final respuesta = await AuthApi(dio).anonimo(dispositivo: 'android-1');

      expect(respuesta.token, '1|anon-abc');
      expect(respuesta.usuario.esTemporal, isTrue);
      expect(respuesta.usuario.email, isNull);
    });

    test('un 429 se propaga como FalloLimite', () async {
      adaptador.onPost(
        '/auth/anonimo',
        (servidor) => servidor.reply(429, {'message': 'Too Many Attempts.'}),
        data: {'dispositivo': 'api'},
      );

      await expectLater(AuthApi(dio).anonimo(), throwsA(isA<FalloLimite>()));
    });
  });

  group('AuthApi.intercambiar con identidad anonima', () {
    test('manda el Bearer anonimo cuando se le pasa', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(200, {'token': 'sanctum-real', 'usuario': usuarioJson()}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
        headers: {'Authorization': 'Bearer 1|anon-abc'},
      );

      final respuesta = await AuthApi(dio).intercambiar('auth0-abc', tokenAnonimo: '1|anon-abc');

      expect(respuesta.token, 'sanctum-real');
    });

    test('un 409 se propaga como FalloConflicto', () async {
      adaptador.onPost(
        '/auth/auth0',
        (servidor) => servidor.reply(409, {'message': 'Ya existe una cuenta con este correo. Inicia sesion con ella.'}),
        data: {'accessToken': 'auth0-abc', 'dispositivo': 'api'},
        headers: {'Authorization': 'Bearer 1|anon-abc'},
      );

      await expectLater(
        AuthApi(dio).intercambiar('auth0-abc', tokenAnonimo: '1|anon-abc'),
        throwsA(isA<FalloConflicto>()),
      );
    });
  });
```

Nota: `http_mock_adapter` compara `headers` de forma exacta cuando se pasan; si el matcher rechaza por cabeceras extra (`content-type`), usar `headers: {'Authorization': 'Bearer 1|anon-abc', 'content-type': 'application/json'}` — comprobar el error del primer run.

- [ ] **Step 2: Correr y ver rojo**

Run: `flutter test test/features/auth/data/auth_api_test.dart`
Expected: compilación falla por `anonimo` y `tokenAnonimo`.

- [ ] **Step 3: Implementar**

Reemplazar la clase en `lib/features/auth/data/auth_api.dart`:

```dart
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  /// Identidad temporal sin datos (`POST /auth/anonimo`). Con su token el
  /// paciente hace todo el embudo; en "Crear cuenta" se reclama con
  /// [intercambiar] pasando `tokenAnonimo`.
  Future<RespuestaSesion> anonimo({String dispositivo = 'api'}) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/auth/anonimo',
        data: {'dispositivo': dispositivo},
      );

      return RespuestaSesion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }

  /// Canjea el access token de Auth0 por un token de Sanctum. Si llega
  /// `tokenAnonimo`, va como Bearer y el backend convierte esa identidad en la
  /// cuenta real (mismo `usuario.id`). Se pone a mano y no por el
  /// `AuthInterceptor` porque este cliente es el publico: meterlo en la cola
  /// de renovacion crearia un ciclo (renovar llama a intercambiar).
  Future<RespuestaSesion> intercambiar(
    String accessToken, {
    String dispositivo = 'api',
    String? tokenAnonimo,
  }) async {
    try {
      final respuesta = await _dio.post<Map<String, dynamic>>(
        '/auth/auth0',
        data: {'accessToken': accessToken, 'dispositivo': dispositivo},
        options: tokenAnonimo == null
            ? null
            : Options(headers: {'Authorization': 'Bearer $tokenAnonimo'}),
      );

      return RespuestaSesion.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
    }
  }
}
```

- [ ] **Step 4: Verde**

Run: `flutter test test/features/auth/data/auth_api_test.dart`
Expected: pasan. Si el matcher de cabeceras falla, ajustar el test según la nota del Step 1.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/auth_api.dart test/features/auth/data/auth_api_test.dart
git commit -m "feat: alta anonima y reclamo con Bearer en AuthApi" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 4: `AuthRepository.entrarComoAnonimo()` e `iniciarSesion(reclamar:)`

**Files:**
- Modify: `lib/features/auth/data/auth_repository.dart`
- Test: `test/features/auth/data/auth_repository_test.dart`

**Interfaces:**
- Consumes: `AuthApi.anonimo`, `AuthApi.intercambiar(tokenAnonimo:)`, `FalloConflicto`.
- Produces:
  - `Future<Usuario> entrarComoAnonimo()`
  - `Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true})`

- [ ] **Step 1: Tests que fallan**

En `test/features/auth/data/auth_repository_test.dart`:

1. Reemplazar `AuthApiFalsa` por:

```dart
class AuthApiFalsa implements AuthApi {
  AuthApiFalsa({this.token = 'sanctum-nuevo'});

  String token;
  Object? error;
  // Fallo solo en la primera llamada CON Bearer anonimo, para probar el
  // reintento sin Bearer.
  Object? errorConBearer;
  int llamadas = 0;
  int altasAnonimas = 0;
  String? ultimoAccessToken;
  String? ultimoTokenAnonimo;
  final List<String?> bearersEnviados = [];

  @override
  Future<RespuestaSesion> anonimo({String dispositivo = 'api'}) async {
    altasAnonimas++;
    if (error != null) throw error!;
    return RespuestaSesion(token: '1|anon', usuario: _anonimo);
  }

  @override
  Future<RespuestaSesion> intercambiar(
    String accessToken, {
    String dispositivo = 'api',
    String? tokenAnonimo,
  }) async {
    llamadas++;
    ultimoAccessToken = accessToken;
    ultimoTokenAnonimo = tokenAnonimo;
    bearersEnviados.add(tokenAnonimo);
    if (tokenAnonimo != null && errorConBearer != null) throw errorConBearer!;
    if (error != null) throw error!;
    return RespuestaSesion(token: token, usuario: _maria);
  }
}
```

y junto a `_maria` añadir:

```dart
const _anonimo = Usuario(id: 1, name: 'Paciente', email: null, rol: Rol.paciente, esTemporal: true);
```

2. Añadir grupos:

```dart
  group('entrarComoAnonimo', () {
    test('crea la identidad, guarda su token y devuelve el usuario temporal', () async {
      final usuario = await repo.entrarComoAnonimo();

      expect(usuario.esTemporal, isTrue);
      expect(authApi.altasAnonimas, 1);
      expect(await store.leer(), '1|anon');
    });

    test('si la API falla, no deja token guardado', () async {
      authApi.error = const FalloLimite(Duration(seconds: 30));

      await expectLater(repo.entrarComoAnonimo(), throwsA(isA<FalloLimite>()));
      expect(await store.leer(), isNull);
    });
  });

  group('iniciarSesion reclamando la identidad anonima', () {
    test('con token guardado lo manda como Bearer y lo sustituye por el real', () async {
      await store.guardar('1|anon');

      final usuario = await repo.iniciarSesion();

      expect(usuario, _maria);
      expect(authApi.ultimoTokenAnonimo, '1|anon');
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('sin token guardado no manda Bearer', () async {
      await repo.iniciarSesion();

      expect(authApi.ultimoTokenAnonimo, isNull);
    });

    test('reclamar: false nunca manda Bearer aunque haya token', () async {
      await store.guardar('1|anon');

      await repo.iniciarSesion(reclamar: false);

      expect(authApi.ultimoTokenAnonimo, isNull);
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('un 409 se propaga como FalloConflicto y conserva el token anonimo', () async {
      await store.guardar('1|anon');
      authApi.errorConBearer = const FalloConflicto('Ya existe una cuenta con este correo.');

      await expectLater(repo.iniciarSesion(), throwsA(isA<FalloConflicto>()));
      expect(await store.leer(), '1|anon');
      expect(authApi.llamadas, 1);
    });

    test('un 401 con Bearer anonimo borra el token y reintenta sin Bearer una vez', () async {
      await store.guardar('1|anon-muerto');
      authApi.errorConBearer = const FalloAuth('El token de la sesion no es valido.');

      final usuario = await repo.iniciarSesion();

      expect(usuario, _maria);
      expect(authApi.bearersEnviados, ['1|anon-muerto', null]);
      expect(await store.leer(), 'sanctum-nuevo');
    });

    test('un 401 sin Bearer anonimo (Auth0 invalido) se propaga sin reintentar', () async {
      authApi.error = const FalloAuth('Access token de Auth0 invalido.');

      await expectLater(repo.iniciarSesion(), throwsA(isA<FalloAuth>()));
      expect(authApi.llamadas, 1);
    });
  });
```

- [ ] **Step 2: Correr y ver rojo**

Run: `flutter test test/features/auth/data/auth_repository_test.dart`
Expected: compilación falla (`entrarComoAnonimo`, `reclamar`).

- [ ] **Step 3: Implementar**

En `lib/features/auth/data/auth_repository.dart` reemplazar `iniciarSesion` y añadir `entrarComoAnonimo`:

```dart
  /// Identidad temporal para correr el embudo sin cuenta. Su token es la
  /// unica credencial: se guarda donde el de la cuenta real.
  Future<Usuario> entrarComoAnonimo() async {
    final respuesta = await _authApi.anonimo();
    await _store.guardar(respuesta.token);

    return respuesta.usuario;
  }

  /// Con `reclamar` (por defecto) y un token guardado, ese token viaja como
  /// Bearer y el backend convierte la identidad anonima en la cuenta real.
  /// El portal medico llama con `reclamar: false`: un doctor nunca reclama.
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async {
    final accessToken = await _gateway.iniciarSesion(conexion: conexion);

    final guardado = reclamar ? await _store.leer() : null;
    final tokenAnonimo = (guardado == null || guardado.isEmpty) ? null : guardado;

    RespuestaSesion respuesta;

    try {
      respuesta = await _authApi.intercambiar(accessToken, tokenAnonimo: tokenAnonimo);
    } on FalloAuth {
      // 401 con Bearer anonimo: ese token ya no vale (purga o revocacion).
      // Se borra y se entra sin el; lo cargado como anonimo se perdio. Sin
      // Bearer, un 401 es el access token de Auth0 y se propaga tal cual.
      // 409 (FalloConflicto) y 422 no pasan por aqui: se propagan y el token
      // anonimo se conserva.
      if (tokenAnonimo == null) rethrow;

      await _store.borrar();
      respuesta = await _authApi.intercambiar(accessToken);
    }

    await _store.guardar(respuesta.token);

    return respuesta.usuario;
  }
```

Añadir el import `import 'dto/respuesta_sesion.dart';` si no está.

- [ ] **Step 4: Verde**

Run: `flutter test test/features/auth/data/auth_repository_test.dart`
Expected: pasan (los tests viejos de `iniciarSesion` siguen válidos: sin token guardado no hay Bearer).

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/auth_repository.dart test/features/auth/data/auth_repository_test.dart
git commit -m "feat: AuthRepository entra como anonimo y reclama la cuenta al iniciar sesion" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 5: Precalificación sin `leadEmail`, `evaluar` con Bearer, fuera el vinculador

**Files:**
- Modify: `lib/features/precalificacion/data/precalificacion_api.dart`
- Modify: `lib/features/precalificacion/data/precalificacion_repository.dart`
- Modify: `lib/features/precalificacion/data/embudo_store.dart`
- Delete: `lib/features/precalificacion/data/vinculador_precalificacion.dart`
- Modify: `lib/features/precalificacion/presentation/filtro_clinico_controller.dart` (+ regen `.freezed.dart`)
- Modify: `lib/onboarding/questions_components/clinical_filter_widget.dart` (ya sin campo; solo asegurar que no referencia `escribirCorreo`)
- Test: `test/features/precalificacion/precalificacion_repository_test.dart`, `test/features/precalificacion/filtro_clinico_controller_test.dart`, `test/features/precalificacion/embudo_store_test.dart`
- Delete: `test/features/precalificacion/vinculador_precalificacion_test.dart`
- Modify (dobles): `test/features/auth/data/auth_repository_test.dart` (`EmbudoStoreFalso`), `test/features/auth/presentation/sesion_controller_test.dart` (quitar vinculador — se hace en Task 6), `test/app/router/glucy_router_test.dart` (`EmbudoStoreFalso`, `PrecalificacionRepositoryFalso.evaluar`)

**Interfaces:**
- Produces:
  - `PrecalificacionApi(Dio publico, Dio autenticado)`: `preguntas()` por público, `evaluar(cuerpo)` por autenticado. Sin `vincular`.
  - `PrecalificacionRepository.evaluar(Map<int,bool> respuestas)` (sin `leadEmail`).
  - `EmbudoStore { guardarProgreso, leerProgreso, limpiar }` (sin `guardarPrecalificacion`/`leerPrecalificacion`).
  - `EstadoFiltro({preguntas, respuestas, errorEnvio})`, `completo => todasRespondidas`. `FiltroClinicoController` sin `escribirCorreo`.

- [ ] **Step 1: Tests que fallan**

`test/features/precalificacion/precalificacion_repository_test.dart`:
- En el test `'evaluar() manda cada respuesta como si/no y devuelve el veredicto'` quitar `'leadEmail': 'maria@ejemplo.com',` del `data:` esperado y `leadEmail: 'maria@ejemplo.com',` de la llamada.
- Borrar los tests `'evaluar() omite leadEmail cuando no hay correo'` y `'vincular() llama a la ruta del id'`.
- Añadir:

```dart
  test('evaluar() viaja por el cliente autenticado (Bearer de la identidad anonima)', () async {
    // El repo se construye con dos Dio: publico y autenticado. Aqui el
    // autenticado es el unico que tiene ruta registrada para /evaluar; si la
    // peticion saliera por el publico, el adaptador la rechazaria.
    final dioPublico = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    final dioAutenticado = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api'));
    final adaptadorAutenticado = DioAdapter(dio: dioAutenticado);
    DioAdapter(dio: dioPublico);
    dioAutenticado.interceptors.add(ErrorInterceptor());

    adaptadorAutenticado.onPost(
      '/precalificacion/evaluar',
      (servidor) => servidor.reply(201, {'id': 12, 'resultado': 'apto', 'motivo': null}),
      data: {
        'respuestas': [
          {'preguntaId': 1, 'respuesta': 'si'},
        ],
      },
    );

    final repo = PrecalificacionRepository(PrecalificacionApi(dioPublico, dioAutenticado));

    final veredicto = await repo.evaluar({1: true});

    expect(veredicto.resultado, Resultado.apto);
  });
```

(Revisar cómo el `setUp` de ese archivo construye `PrecalificacionApi`; si ya usa dos Dio con dos adaptadores, mover el registro de `/evaluar` al adaptador autenticado en los tests existentes en vez de duplicar Dio.)

`test/features/precalificacion/filtro_clinico_controller_test.dart`:
- En los dobles `PrecalificacionRepositoryFalso`/equivalentes (líneas ~71 y ~90) cambiar la firma a `Future<Veredicto> evaluar(Map<int, bool> respuestas)`.
- Quitar todas las llamadas `notifier.escribirCorreo(...)`.
- Borrar `'el estado no esta completo sin un correo valido, aunque este todo respondido'`, `'enviar() con exito guarda el id del veredicto para vincularlo despues'`, `'un fallo al guardar el id localmente no marca error ni bloquea el envio'`.
- Añadir:

```dart
  test('el estado esta completo en cuanto estan todas respondidas: no hay correo', () async {
    // (usar el mismo montaje que 'el estado no esta completo hasta responderlas todas',
    // responder todas y comprobar)
    expect(estado.completo, isTrue);
  });
```

  concretando el montaje con los helpers reales del archivo (misma forma que el test vecino).

- En los dobles de `EmbudoStore` de ese archivo, de `auth_repository_test.dart` y de `glucy_router_test.dart`: borrar `guardarPrecalificacion`/`leerPrecalificacion`.
- `test/features/precalificacion/embudo_store_test.dart`: si tiene tests de `guardarPrecalificacion`/`leerPrecalificacion`, borrarlos; añadir:

```dart
  test('limpiar() borra el progreso', () async {
    await store.guardarProgreso({1: true});
    await store.limpiar();
    expect(await store.leerProgreso(), isEmpty);
  });
```

  (usar la variable `store` real del archivo).
- Borrar `test/features/precalificacion/vinculador_precalificacion_test.dart`.

- [ ] **Step 2: Correr y ver rojo**

Run: `flutter test test/features/precalificacion`
Expected: fallos de compilación (firmas).

- [ ] **Step 3: Implementar**

`lib/features/precalificacion/data/precalificacion_api.dart`:

```dart
/// Dos clientes: `preguntas` es publica y no lleva Bearer; `evaluar` tambien
/// es publica pero viaja por el autenticado para que, con la identidad
/// anonima, el backend ate la precalificacion al paciente de la sesion.
class PrecalificacionApi {
  const PrecalificacionApi(this._publico, this._autenticado);

  final Dio _publico;
  final Dio _autenticado;

  Future<List<PreguntaFiltro>> preguntas() async { /* igual que hoy, por _publico */ }

  Future<Veredicto> evaluar(Map<String, dynamic> cuerpo) async {
    try {
      final respuesta = await _autenticado.post<Map<String, dynamic>>(
        '/precalificacion/evaluar',
        data: cuerpo,
      );

      return Veredicto.fromJson(respuesta.data!);
    } on DioException catch (e) {
      throw _fallo(e);
    }
  }

  FalloApi _fallo(DioException e) =>
      e.error is FalloApi ? e.error as FalloApi : const FalloDesconocido();
}
```

(Borrar `vincular`.)

`precalificacion_repository.dart`:

```dart
  Future<Veredicto> evaluar(Map<int, bool> respuestas) {
    return _api.evaluar({
      'respuestas': [
        for (final entrada in respuestas.entries)
          {'preguntaId': entrada.key, 'respuesta': entrada.value ? 'si' : 'no'},
      ],
    });
  }
```

(Borrar `vincular`.)

`embudo_store.dart`: borrar `guardarPrecalificacion`, `leerPrecalificacion`, `_clavePrecalificacion` de interfaz e implementación; `limpiar()` queda:

```dart
  @override
  Future<void> limpiar() => _almacen.delete(key: _claveProgreso);
```

Actualizar el doc-comment de la clase: sigue existiendo para retomar el filtro a medias.

Borrar `lib/features/precalificacion/data/vinculador_precalificacion.dart`.

`filtro_clinico_controller.dart`:
- Quitar `String? leadEmail,` de la factory, `correoValido` (y el comentario del correo), `escribirCorreo`.
- `completo => todasRespondidas;`
- En `enviar()`: `evaluar(actual.respuestas)` y quitar el bloque `guardarPrecalificacion(...)` con su comentario.
- Regenerar freezed: `dart run build_runner build --delete-conflicting-outputs`.

`clinical_filter_widget.dart`: comprobar con `grep -n "escribirCorreo\|leadEmail" lib/onboarding/questions_components/clinical_filter_widget.dart` que no queda nada.

`sesion_controller.dart`: **todavía** referencia `vinculadorPrecalificacionProvider`; para que compile en esta tarea, borrar el import y el bloque `try { await ref.read(vinculadorPrecalificacionProvider).vincularPendiente(); } catch (_) {}` (Task 6 termina el controller). Y en `test/features/auth/presentation/sesion_controller_test.dart` borrar el import del vinculador, las clases `_RepoInerte`, `_StoreInerte`, `_vinculadorInerte`, `VinculadorPrecalificacionQueFalla`, el override en `contenedor(...)` y el test `'un fallo inesperado al vincular la precalificacion no tumba la sesion'`.

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test`
Expected: sin errores; toda la suite en verde (incluido router y sesion controller).

- [ ] **Step 5: Commit**

```bash
git add -A lib/features/precalificacion lib/features/auth/presentation/sesion_controller.dart lib/onboarding/questions_components/clinical_filter_widget.dart test/features/precalificacion test/features/auth test/app/router
git commit -m "refactor: precalificacion sin correo; evaluar con Bearer; fuera el vinculador" -m "El backend ata la precalificacion al paciente de la sesion (identidad anonima), asi que leadEmail y el vinculo por correo sobran." -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 6: `SesionController.entrarComoAnonimo()` y `reclamar`

**Files:**
- Modify: `lib/features/auth/presentation/sesion_controller.dart`
- Test: `test/features/auth/presentation/sesion_controller_test.dart`

**Interfaces:**
- Consumes: `AuthRepository.entrarComoAnonimo()`, `iniciarSesion({conexion, reclamar})`.
- Produces: `SesionController.entrarComoAnonimo()`, `iniciarSesion({String? conexion, bool reclamar = true})`.

- [ ] **Step 1: Tests que fallan**

En `test/features/auth/presentation/sesion_controller_test.dart`, actualizar `AuthRepositoryFalso`:

```dart
class AuthRepositoryFalso implements AuthRepository {
  AuthRepositoryFalso({this.almacenada, this.alIniciar = _maria, this.errorAlIniciar, this.errorAnonimo});

  Usuario? almacenada;
  Usuario alIniciar;
  Object? errorAlIniciar;
  Object? errorAnonimo;
  bool? ultimoReclamar;
  int altasAnonimas = 0;

  @override
  Future<Usuario> iniciarSesion({String? conexion, bool reclamar = true}) async {
    ultimoReclamar = reclamar;
    if (errorAlIniciar != null) throw errorAlIniciar!;
    return alIniciar;
  }

  @override
  Future<Usuario> entrarComoAnonimo() async {
    altasAnonimas++;
    if (errorAnonimo != null) throw errorAnonimo!;
    return _anonimo;
  }

  @override
  Future<Usuario?> restaurarSesion() async => almacenada;

  @override
  Future<void> cerrarSesion() async {}
}
```

(adaptar nombres a los que ya usa el archivo; añadir `const _anonimo = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);`). Añadir tests:

```dart
  test('entrarComoAnonimo pasa a autenticado temporal', () async {
    final c = contenedor(AuthRepositoryFalso());
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).entrarComoAnonimo();

    final sesion = c.read(sesionControllerProvider).value;
    expect(sesion, isA<SesionAutenticado>());
    expect((sesion as SesionAutenticado).usuario.esTemporal, isTrue);
  });

  test('un fallo al entrar como anonimo deja el estado en error', () async {
    final c = contenedor(AuthRepositoryFalso(errorAnonimo: const FalloLimite(Duration(seconds: 30))));
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).entrarComoAnonimo();

    expect(c.read(sesionControllerProvider).hasError, isTrue);
  });

  test('iniciarSesion reclama por defecto y respeta reclamar: false', () async {
    final repo = AuthRepositoryFalso();
    final c = contenedor(repo);
    await c.read(sesionControllerProvider.future);

    await c.read(sesionControllerProvider.notifier).iniciarSesion();
    expect(repo.ultimoReclamar, isTrue);

    await c.read(sesionControllerProvider.notifier).iniciarSesion(reclamar: false);
    expect(repo.ultimoReclamar, isFalse);
  });
```

También actualizar los `AuthRepositoryFalso`/`AuthRepositoryDinamica`/`AuthRepositoryQueNuncaResuelveAlIniciar` de `test/app/router/glucy_router_test.dart`, `crear_cuenta_screen_test.dart`, `doctor_login_screen_test.dart`, `cuenta_screen_test.dart`, `perfil_doc_screen_test.dart` y `test/onboarding/questions_components/estudios_screen_test.dart` (si aún existe) para que implementen `iniciarSesion({String? conexion, bool reclamar = true})` y `entrarComoAnonimo()` (basta `async => throw UnimplementedError()` donde no se use).

- [ ] **Step 2: Rojo**

Run: `flutter test test/features/auth/presentation/sesion_controller_test.dart`
Expected: compilación falla.

- [ ] **Step 3: Implementar**

En `sesion_controller.dart`:

```dart
  /// Identidad temporal para el embudo. Falla ⇒ `AsyncError` (la pantalla lo
  /// pinta con MensajeError y deja reintentar).
  Future<void> entrarComoAnonimo() async {
    state = const AsyncLoading();
    try {
      final usuario = await ref.read(authRepositoryProvider).entrarComoAnonimo();
      state = AsyncData(Sesion.autenticado(usuario));
    } catch (e, pila) {
      state = AsyncError(e, pila);
    }
  }

  Future<void> iniciarSesion({String? conexion, bool reclamar = true}) async {
    state = const AsyncLoading();
    try {
      final usuario = await ref
          .read(authRepositoryProvider)
          .iniciarSesion(conexion: conexion, reclamar: reclamar);
      state = AsyncData(Sesion.autenticado(usuario));
    } on Auth0Cancelado {
      state = const AsyncData(Sesion.noAutenticado());
    } catch (e, pila) {
      state = AsyncError(e, pila);
    }
  }
```

Cuidado con `Auth0Cancelado` en `iniciarSesion` cuando había sesión temporal: volver a `noAutenticado()` haría perder la sesión anónima en el estado (aunque el token siga guardado). Mejor: conservar el valor anterior si existía:

```dart
    } on Auth0Cancelado {
      state = AsyncData(state.value ?? const Sesion.noAutenticado());
    }
```

Nota: al poner `state = const AsyncLoading()` se pierde `state.value`; guardar `final anterior = state.value;` antes y usar `anterior`.

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test`
Expected: verde completo.

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/presentation/sesion_controller.dart test
git commit -m "feat: SesionController entra como anonimo y reclama al iniciar sesion" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 7: Router — `Rutas.perfil` y el temporal se queda en el embudo

**Files:**
- Modify: `lib/app/router/rutas.dart`
- Modify: `lib/app/router/glucy_router.dart`
- Modify: `lib/onboarding/questions_components/clinical_filter_widget.dart:147-150` (atrás → `Rutas.perfil`)
- Test: `test/app/router/glucy_router_test.dart`

**Interfaces:**
- Produces: `Rutas.perfil = '/tu-perfil'` (en `Rutas.publicas`); GoRoute que construye `const Profile()`; `_destinoAutenticado(Usuario usuario, String destino)`.

- [ ] **Step 1: Tests que fallan**

En `test/app/router/glucy_router_test.dart` añadir `const _anonima = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);` y tests:

```dart
  testWidgets('una identidad temporal aterriza en onboarding, no en inicio', (tester) async {
    final router = await montar(tester, _anonima);
    expect(rutaActual(router), Rutas.onboarding);
  });

  testWidgets('una identidad temporal que va a inicio vuelve a onboarding', (tester) async {
    final router = await montar(tester, _anonima);
    router.go(Rutas.inicioPaciente);
    await tester.pumpAndSettle();
    expect(rutaActual(router), Rutas.onboarding);
  });

  testWidgets('una identidad temporal puede entrar a tu perfil, filtro clinico y crear cuenta', (tester) async {
    final router = await montar(tester, _anonima);
    for (final ruta in [Rutas.perfil, Rutas.filtroClinico, Rutas.crearCuenta]) {
      router.go(ruta);
      await tester.pumpAndSettle();
      expect(rutaActual(router), ruta);
    }
  });

  testWidgets('sin sesion, tu perfil es alcanzable (ruta publica)', (tester) async {
    final router = await montar(tester, null);
    router.go(Rutas.perfil);
    await tester.pumpAndSettle();
    expect(rutaActual(router), Rutas.perfil);
  });
```

Si `Profile` no monta en test por dependencias (fuentes/pickers), el test de rutas solo comprueba `rutaActual`, que no requiere render completo; si aun así revienta, envolver `Profile` en la ruta con `const Profile()` y ajustar el test tras ver el error real.

- [ ] **Step 2: Rojo**

Run: `flutter test test/app/router/glucy_router_test.dart`
Expected: `Rutas.perfil` no existe.

- [ ] **Step 3: Implementar**

`rutas.dart`: añadir `static const perfil = '/tu-perfil';` y meterlo en `publicas` (después de `onboarding`).

`glucy_router.dart`:
- `import '../../profile/profile.dart';`
- Ruta: `GoRoute(path: Rutas.perfil, builder: (_, __) => const Profile()),` junto a la de onboarding.
- Cambiar la llamada `_destinoAutenticado(usuario.rol, destino)` por `_destinoAutenticado(usuario, destino)` y la función:

```dart
String? _destinoAutenticado(Usuario usuario, String destino) {
  // Identidad temporal (POST /auth/anonimo): vive en el embudo, que son las
  // rutas publicas. Inicio y portal medico son de cuenta real.
  if (usuario.esTemporal) {
    if (Rutas.publicas.contains(destino)) {
      return destino == Rutas.splash ? Rutas.onboarding : null;
    }
    return Rutas.onboarding;
  }

  final inicio = usuario.rol == Rol.paciente ? Rutas.inicioPaciente : Rutas.inicioMedico;
  // ... resto igual que hoy, usando usuario.rol
}
```

Añadir `import '../../features/auth/domain/usuario.dart';`.

`clinical_filter_widget.dart:150`: `onTap: () => context.canPop() ? context.pop() : context.go(Rutas.perfil),` y ajustar el comentario (el atrás vuelve a "Tu perfil", pantalla anterior del prototipo).

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test test/app/router`
Expected: verde.

- [ ] **Step 5: Commit**

```bash
git add lib/app/router lib/onboarding/questions_components/clinical_filter_widget.dart test/app/router/glucy_router_test.dart
git commit -m "feat: ruta /tu-perfil y la identidad temporal se queda en el embudo" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 8: Onboarding "Empezar" crea la identidad anónima y va a Tu perfil

**Files:**
- Modify: `lib/onboarding/onboarding_screen.dart` (`OnboardingScreen` pasa a `ConsumerWidget`; `_empezar`; botón)
- Test: `test/app/router/glucy_router_test.dart` (nuevo test end-to-end por router)

**Interfaces:**
- Consumes: `sesionControllerProvider`, `SesionController.entrarComoAnonimo()`, `Rutas.perfil`, `MensajeError`.

- [ ] **Step 1: Test que falla**

En `test/app/router/glucy_router_test.dart` (el `AuthRepositoryFalso` ya implementa `entrarComoAnonimo()` desde Task 6; hacer que devuelva `_anonima` y cuente llamadas):

```dart
  testWidgets('Empezar sin sesion crea la identidad anonima y va a tu perfil', (tester) async {
    final repo = AuthRepositoryFalso(null); // ajustar al constructor real del archivo
    final router = await montarCon(tester, repo);   // helper que acepte el repo; si no existe, crearlo copiando `montar`
    expect(rutaActual(router), Rutas.onboarding);

    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(repo.altasAnonimas, 1);
    expect(rutaActual(router), Rutas.perfil);
  });

  testWidgets('Empezar con sesion temporal ya creada va directo a tu perfil', (tester) async {
    final repo = AuthRepositoryFalso(_anonima);
    final router = await montarCon(tester, repo);

    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(repo.altasAnonimas, 0);
    expect(rutaActual(router), Rutas.perfil);
  });

  testWidgets('si crear la identidad falla, onboarding muestra el error y no navega', (tester) async {
    final repo = AuthRepositoryFalso(null)..errorAnonimo = const FalloLimite(Duration(seconds: 30));
    final router = await montarCon(tester, repo);

    await tester.tap(find.text('Empezar es gratis'));
    await tester.pumpAndSettle();

    expect(rutaActual(router), Rutas.onboarding);
    expect(find.byType(MensajeError), findsOneWidget);
  });
```

Puede que el botón quede fuera del viewport 800x600 y `tap` avise "not hit-testable": usar `await tester.ensureVisible(find.text('Empezar es gratis'))` antes del tap o `tester.view.physicalSize = const Size(800, 1400)` con `addTearDown(tester.view.reset)`.

- [ ] **Step 2: Rojo**

Run: `flutter test test/app/router/glucy_router_test.dart --plain-name "Empezar"`
Expected: `altasAnonimas` es 0 y la ruta es `/filtro-clinico`.

- [ ] **Step 3: Implementar**

En `onboarding_screen.dart`:
- Imports: `flutter_riverpod`, `../features/auth/domain/sesion.dart`, `../features/auth/presentation/sesion_controller.dart`, `../core/error/fallo_api.dart`, `../shared/widgets/mensaje_error.dart`.
- `class OnboardingScreen extends ConsumerWidget` con `build(BuildContext context, WidgetRef ref)`.
- Reemplazar `_empezar`:

```dart
  Future<void> _empezar(BuildContext context, WidgetRef ref) async {
    final sesion = ref.read(sesionControllerProvider).value;

    // Ya hay identidad (temporal o real): al perfil sin pedir otra.
    if (sesion is! SesionAutenticado) {
      await ref.read(sesionControllerProvider.notifier).entrarComoAnonimo();
      if (!context.mounted) return;
      if (ref.read(sesionControllerProvider).hasError) return;
    }

    context.go(Rutas.perfil);
  }
```

- En el botón: leer `final sesion = ref.watch(sesionControllerProvider); final cargando = sesion.isLoading; final fallo = sesion.error;` al inicio de `build`. `onPressed: cargando ? null : () => _empezar(context, ref)`; el `child` muestra `CircularProgressIndicator` de 18px blanco cuando `cargando` (mismo patrón que `crear_cuenta_screen.dart:97-104`). Encima del botón, si `fallo != null`: `if (fallo is FalloApi) MensajeError(fallo) else Text('$fallo')` + `SizedBox(height: 10)`.

Nota: la sesión en `AsyncError` tras un fallo de `entrarComoAnonimo` hace que el redirect del router use `sesion.value ?? noAutenticado` (ya lo hace): sigue en onboarding. Correcto.

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test`
Expected: verde.

- [ ] **Step 5: Commit**

```bash
git add lib/onboarding/onboarding_screen.dart test/app/router/glucy_router_test.dart
git commit -m "feat: Empezar crea la identidad anonima y lleva a Tu perfil" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 9: "Tu perfil" guarda por `PATCH /perfil` y sigue al filtro clínico

**Files:**
- Modify: `lib/profile/profile.dart` (`Profile` → `ConsumerStatefulWidget`; `_bottomCta`; imports)
- Create: `test/profile/profile_test.dart`

**Interfaces:**
- Consumes: `perfilApiProvider` / `PerfilApi.actualizar({name, apellidoPaterno, telefono, fechaNacimiento, sexo, pesoKg, tallaCm})`, `Rutas.filtroClinico`.
- Produces: la pantalla `Profile` navega con `context.go(Rutas.filtroClinico)` tras guardar.

- [ ] **Step 1: Test que falla**

`test/profile/profile_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glucy_app/app/router/rutas.dart';
import 'package:glucy_app/core/error/fallo_api.dart';
import 'package:glucy_app/features/auth/domain/rol.dart';
import 'package:glucy_app/features/auth/domain/usuario.dart';
import 'package:glucy_app/features/perfil/perfil_api.dart';
import 'package:glucy_app/profile/profile.dart';
import 'package:go_router/go_router.dart';

const _anonima = Usuario(id: 1, name: 'Paciente', rol: Rol.paciente, esTemporal: true);

class PerfilApiFalsa implements PerfilApi {
  Object? error;
  Map<String, Object?>? ultimoPatch;

  @override
  Future<Perfil> obtener() async => const Perfil(usuario: _anonima);

  @override
  Future<Perfil> actualizar({
    String? name,
    String? apellidoPaterno,
    String? telefono,
    DateTime? fechaNacimiento,
    String? sexo,
    double? pesoKg,
    int? tallaCm,
  }) async {
    ultimoPatch = {
      'name': name,
      'apellidoPaterno': apellidoPaterno,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'sexo': sexo,
      'pesoKg': pesoKg,
      'tallaCm': tallaCm,
    };
    if (error != null) throw error!;
    return const Perfil(usuario: _anonima);
  }
}

Future<GoRouter> montar(WidgetTester tester, PerfilApiFalsa api) async {
  final router = GoRouter(
    initialLocation: Rutas.perfil,
    routes: [
      GoRoute(path: Rutas.perfil, builder: (_, __) => const Profile()),
      GoRoute(path: Rutas.filtroClinico, builder: (_, __) => const Scaffold(body: Text('FILTRO'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [perfilApiProvider.overrideWithValue(api)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();

  return router;
}

void main() {
  setUp(() {
    // La pantalla es alta: que quepa el boton inferior.
  });

  testWidgets('Continuar manda el PATCH con nombre, sexo, peso y talla y va al filtro', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final api = PerfilApiFalsa();
    final router = await montar(tester, api);

    await tester.enterText(find.byKey(const Key('campo-nombre')), 'María Torres');
    await tester.enterText(find.byKey(const Key('campo-peso')), '74');
    await tester.enterText(find.byKey(const Key('campo-talla')), '162');
    await tester.tap(find.byKey(const Key('sexo-femenino')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar al filtro clínico'));
    await tester.pumpAndSettle();

    expect(api.ultimoPatch?['name'], 'María Torres');
    expect(api.ultimoPatch?['sexo'], 'femenino');
    expect(api.ultimoPatch?['pesoKg'], 74.0);
    expect(api.ultimoPatch?['tallaCm'], 162);
    expect(router.routerDelegate.currentConfiguration.uri.path, Rutas.filtroClinico);
  });

  testWidgets('si el PATCH falla se queda en la pantalla y muestra el error', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final api = PerfilApiFalsa()..error = const FalloServidor();
    final router = await montar(tester, api);

    await tester.tap(find.text('Continuar al filtro clínico'));
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, Rutas.perfil);
    expect(find.textContaining('El servidor tuvo un problema.'), findsOneWidget);
  });
}
```

Requiere `Key`s en los campos: revisar `profile.dart` y poner `key: const Key('campo-nombre')` en el `TextField` del nombre, `campo-peso`, `campo-talla`, y `Key('sexo-femenino')`/`sexo-masculino`/`sexo-otro` en el selector de sexo. Si el selector de sexo es un `DropdownButton`, sustituir el tap por: `await tester.tap(find.byKey(const Key('campo-sexo'))); await tester.pumpAndSettle(); await tester.tap(find.text('Femenino').last); await tester.pumpAndSettle();` y adaptar la key.

- [ ] **Step 2: Rojo**

Run: `flutter test test/profile/profile_test.dart`
Expected: falla (keys no existen / no hay PATCH / no navega).

- [ ] **Step 3: Implementar**

En `profile.dart`:
- Imports: `flutter_riverpod`, `go_router`, `../app/router/rutas.dart`, `../core/error/fallo_api.dart`, `../features/perfil/perfil_api.dart`. Quitar los imports de `veredicto.dart`, `clinical_filter_widget.dart`, `filtro1_screen.dart`, `no_apto_screen.dart`, `warning.dart` si dejan de usarse (el `_noAptoRecap` puede borrarse; ya no se usa).
- `class Profile extends ConsumerStatefulWidget` + `ConsumerState<Profile> createState()`; `_ProfileState extends ConsumerState<Profile>`.
- Estado nuevo: `bool _guardando = false; String? _error;`
- Método:

```dart
  Future<void> _continuar() async {
    setState(() { _guardando = true; _error = null; });

    final nombre = _nombreController.text.trim();
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final talla = int.tryParse(_tallaController.text);
    // El backend espera minusculas: femenino / masculino / otro.
    final sexo = _sexoSeleccionado?.toLowerCase();

    try {
      await ref.read(perfilApiProvider).actualizar(
            name: nombre.isEmpty ? null : nombre,
            fechaNacimiento: _fechaNacimiento,
            sexo: sexo,
            pesoKg: peso,
            tallaCm: talla,
          );

      if (!mounted) return;
      context.go(Rutas.filtroClinico);
    } on FalloApi catch (fallo) {
      if (!mounted) return;
      setState(() => _error = fallo.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
```

- `_bottomCta()`: `onPressed: _guardando ? null : _continuar`; encima del botón, `if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('No se pudo guardar tu perfil: $_error', style: const TextStyle(color: GlucyColors.alert /* o Colors.red si no existe */)))`; el `child` del botón muestra spinner de 18px cuando `_guardando`.
- Poner las `Key`s del Step 1 en los campos.

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test test/profile test/app/router`
Expected: verde.

- [ ] **Step 5: Commit**

```bash
git add lib/profile/profile.dart test/profile/profile_test.dart
git commit -m "feat: Tu perfil guarda por PATCH /perfil y sigue al filtro clinico" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 10: Crear cuenta reclama (diálogo 409) y el portal médico no reclama

**Files:**
- Modify: `lib/onboarding/questions_components/crear_cuenta_screen.dart`
- Modify: `lib/doctor/doctor_login_screen.dart:92`
- Test: `test/features/auth/presentation/crear_cuenta_screen_test.dart`, `test/features/auth/presentation/doctor_login_screen_test.dart`

**Interfaces:**
- Consumes: `SesionController.iniciarSesion({conexion, reclamar})`, `FalloConflicto`.

- [ ] **Step 1: Tests que fallan**

`crear_cuenta_screen_test.dart`: `AuthRepositoryFalso.iniciarSesion` pasa a `({String? conexion, bool reclamar = true})` y guarda `ultimoReclamar` y una lista `reclamos`. Añadir:

```dart
  testWidgets('el boton de acceso reclama la identidad anonima', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(repo.ultimoReclamar, isTrue);
  });

  testWidgets('un 409 abre el dialogo y "Iniciar sesion" reintenta sin reclamar', (tester) async {
    final repo = AuthRepositoryFalso()
      ..errorAlIniciar = const FalloConflicto('Ya existe una cuenta con este correo. Inicia sesion con ella.');
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dialogo-cuenta-existente')), findsOneWidget);
    expect(find.textContaining('no se transfiere'), findsOneWidget);

    repo.errorAlIniciar = null;
    await tester.tap(find.byKey(const Key('boton-entrar-sin-reclamar')));
    await tester.pumpAndSettle();

    expect(repo.reclamos, [true, false]);
    expect(find.byKey(const Key('dialogo-cuenta-existente')), findsNothing);
  });
```

`doctor_login_screen_test.dart`: en `AuthRepositoryFalso` misma firma; añadir:

```dart
  testWidgets('el acceso medico nunca reclama la identidad anonima', (tester) async {
    final repo = AuthRepositoryFalso();
    await montar(tester, repo);

    await tester.tap(find.byKey(const Key('boton-acceder-medico'))); // usar la key real del boton
    await tester.pumpAndSettle();

    expect(repo.ultimoReclamar, isFalse);
  });
```

(Comprobar la key real del botón en `doctor_login_screen.dart` y en su test existente.)

- [ ] **Step 2: Rojo**

Run: `flutter test test/features/auth/presentation`
Expected: fallan los nuevos.

- [ ] **Step 3: Implementar**

`crear_cuenta_screen.dart`:
- Pasar `CrearCuentaScreen` a `ConsumerWidget` con `ref.listen` en `build`:

```dart
    ref.listen<AsyncValue<Sesion>>(sesionControllerProvider, (anterior, actual) {
      final fallo = actual.error;
      if (fallo is FalloConflicto && !actual.isLoading) {
        _dialogoCuentaExistente(context, ref, fallo);
      }
    });
```

- Método:

```dart
  Future<void> _dialogoCuentaExistente(BuildContext context, WidgetRef ref, FalloConflicto fallo) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('dialogo-cuenta-existente'),
        title: const Text('Ya existe una cuenta con este correo'),
        content: const Text(
          '¿Quieres iniciar sesión con ella? Lo que cargaste como invitado no se transfiere a esa cuenta.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Usar otro correo')),
          FilledButton(
            key: const Key('boton-entrar-sin-reclamar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(sesionControllerProvider.notifier).iniciarSesion(reclamar: false);
            },
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }
```

- En la zona de error, no pintar `MensajeError` para `FalloConflicto` (lo cubre el diálogo): `if (fallo != null && fallo is! FalloConflicto) ...`.

`doctor_login_screen.dart:92`: `.iniciarSesion(reclamar: false)` con comentario `// Un doctor nunca reclama una identidad anonima de paciente.`

- [ ] **Step 4: Verde**

Run: `flutter analyze && flutter test`
Expected: verde.

- [ ] **Step 5: Commit**

```bash
git add lib/onboarding/questions_components/crear_cuenta_screen.dart lib/doctor/doctor_login_screen.dart test/features/auth/presentation
git commit -m "feat: crear cuenta reclama la identidad anonima; 409 ofrece entrar sin reclamar" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

### Task 11: Revertir el parche de EstudiosScreen y cierre

**Files:**
- Modify: `lib/onboarding/questions_components/estudios_screen.dart` (volver a `final estudios = await api.propios();`, quitar imports de sesión)
- Delete: `test/onboarding/questions_components/estudios_screen_test.dart`

- [ ] **Step 1: Revertir**

```bash
git checkout -- lib/onboarding/questions_components/estudios_screen.dart
git rm -q --cached test/onboarding/questions_components/estudios_screen_test.dart 2>/dev/null; rm -f test/onboarding/questions_components/estudios_screen_test.dart
```

(`git checkout --` funciona porque ese archivo no tiene commits nuevos en este plan; si en el paso 6 se tocó su doble, borrar el archivo de test es suficiente.)

- [ ] **Step 2: Suite completa**

Run: `flutter analyze && flutter test`
Expected: sin errores; verde. Confirmar que `git status` solo deja fuera los cambios locales del usuario (`dio_client.dart`, `pubspec.*`, `devtools_options.yaml`).

- [ ] **Step 3: Prueba manual en el teléfono** (con `adb reverse tcp:8000 tcp:8000` y backend en `feature/paciente-anonimo`)

1. Onboarding → "Empezar es gratis" → log muestra `POST /auth/anonimo` 201 → pantalla Tu perfil.
2. Rellenar y "Continuar al filtro clínico" → `PATCH /perfil` 200 → filtro.
3. Responder → "Ver mi resultado" → `POST /precalificacion/evaluar` 201 con `pacienteId` no nulo → Filtro 1 OK → Estudios (`GET /estudios-medicos` 200).
4. Llegar a Crear cuenta → Google → `POST /auth/auth0` con `Authorization` → 200 con mismo `usuario.id`, `esTemporal: false` → `/inicio`.

- [ ] **Step 4: Commit**

```bash
git add lib/onboarding/questions_components/estudios_screen.dart
git rm -q test/onboarding/questions_components/estudios_screen_test.dart 2>/dev/null || true
git commit -m "refactor: EstudiosScreen vuelve a pedir los propios siempre (hay Bearer anonimo)" -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

(Si `estudios_screen.dart` no cambió respecto a HEAD tras el `checkout`, no hay nada que commitear más allá de borrar el test.)
