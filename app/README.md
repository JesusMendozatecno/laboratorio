# Laboratorio de Programación — App Flutter

Aplicación multiplataforma (Android, iOS, Web, Windows) para la gestión del
laboratorio, migrada desde el sistema PHP/MySQL original. Usa **Firebase Auth +
Cloud Firestore** como backend y **Provider** para el manejo de estado.

## Estado actual

✅ **Proyecto Firebase conectado:** `laboratorio-unefa`
- Apps registradas: Web, Windows y Android (`com.unefa.laboratorio.laboratorio_app`).
- Credenciales generadas en `lib/services/firebase_options.dart`
  (Android además tiene `google-services.json` + plugin).
- Base de datos **Cloud Firestore** creada (modo nativo, plan gratuito).
- Reglas de seguridad desplegadas (`firestore.rules`) e índices.

✅ **Autenticación lista:** proveedor **Correo electrónico/Contraseña** habilitado
  (verificado con registro de prueba). Solo falta probar la app en ejecución.

## Estructura del proyecto

```
lib/
├── main.dart                     # Arranque: inicializa Firebase
├── app.dart                      # MaterialApp, providers y AuthGate
├── core/
│   ├── constants/app_constants.dart   # Colecciones, roles, colores, textos
│   ├── theme/app_theme.dart           # Tema claro/oscuro (Material 3)
│   ├── utils/validators.dart          # Validadores de formularios
│   └── widgets/                       # Botones, campos y tarjetas reutilizables
├── models/app_user.dart          # Modelo de usuario
├── providers/
│   ├── auth_provider.dart        # Sesión (login/registro/logout)
│   ├── security_provider.dart    # Bloqueo con huella/PIN e inactividad
│   └── theme_provider.dart       # Modo claro/oscuro
├── services/
│   ├── firebase_options.dart     # Credenciales Firebase por plataforma
│   ├── auth_service.dart         # Envoltorio de Firebase Auth
│   └── firestore_service.dart    # Envoltorio de Cloud Firestore
└── features/
    ├── auth/                     # Login y registro
    ├── security/                 # Bloqueo e inactividad (SecurityGate)
    ├── home/                     # Página pública con normas del laboratorio
    └── dashboard/                # Paneles por rol (docente/encargado/estudiante)
```

## Cómo ejecutar

```bash
flutter pub get
flutter run -d chrome       # Web (lista hoy, sin toolchains extra)
flutter run -d windows      # requiere Visual Studio (workload C++)
flutter run -d android      # requiere Android Studio / SDK
```

> En este equipo, el único dispositivo disponible ahora mismo es Chrome
> (Web). Windows necesita Visual Studio instalado; Android, el Android SDK.

## Usar la app en un teléfono Android

1. **Instala Android Studio** (una sola vez): https://developer.android.com/studio
   Al abrirlo, el asistente instala el **Android SDK** (incluye Platform-Tools).
   Verifica con `flutter doctor` que aparezca `[√] Android toolchain`.
2. **Activa la depuración USB** en el teléfono:
   Ajustes → Información del teléfono → toca 7 veces *Número de compilación*;
   luego en *Opciones de desarrollador* activa **Depuración por USB**.
3. **Conecta el teléfono** por USB y acepta el permiso de depuración.
4. **Ejecuta:** `flutter run` (instala y abre la app en el teléfono).

### Generar un APK para instalar sin cable

```bash
# APK de depuración (pruebas rápidas)
flutter build apk --debug

# APK de release optimizado + ofuscado (recomendado para repartir)
flutter build apk --release --obfuscate --split-debug-info=build/symbols
```

El archivo queda en `build\app\outputs\flutter-apk\app-release.apk`; cópialo al
teléfono y ábrelo para instalar (activa "Instalar apps de origen desconocido").
Guarda la carpeta `build/symbols` para poder leer reportes de errores.

### Descargar el APK sin compilar en tu equipo

El repositorio incluye una **GitHub Action** (`build-apk.yml`) que compila el
APK en la nube:

1. **GitHub → Actions → "Build Android APK" → *Run workflow*.** Cuando termine,
   baja el artefacto `laboratorio-apk` (contiene `app-release.apk`).
2. O crea una etiqueta y se publica una **Release** con el APK adjunto
   (enlace permanente de descarga):
   ```bash
   git tag v1.0.0 && git push origin v1.0.0
   ```

## Seguridad

- **Bloqueo con huella/PIN** (`local_auth`): se activa en *Configuración →
  Seguridad*. Pide la huella o el PIN del dispositivo al abrir la app y al
  volver del segundo plano. En Web aparece deshabilitado.
- **Cierre por inactividad:** la sesión se cierra automáticamente tras el tiempo
  configurado (por defecto 15 min; se puede poner en *Nunca*).
- **Reglas de Firestore endurecidas:** nadie puede cambiar su propio rol, solo
  el encargado administra usuarios y catálogos, y se valida la forma de los
  perfiles.
- **Optimización del APK:** R8/ProGuard activado en release
  (`android/app/proguard-rules.pro`) y build ofuscado con `--obfuscate`.

## Colecciones de Firestore

| Colección    | Descripción                                  |
| ------------ | -------------------------------------------- |
| `usuarios`   | Perfil: nombre, apellido, cédula, correo, tipo |
| `clases`     | Registro de clases                           |
| `reportes`   | Reportes de problemas                        |
| `equipos`    | Equipos del laboratorio                      |
| `asignaciones` | Equipos asignados a estudiantes             |
| `practicas`  | Prácticas de programación (lenguaje, IDE)    |
| `profesores` | Profesores (panel encargado)                 |
| `institutos` | Institutos (panel encargado)                 |

## Notas sobre la migración del sistema PHP

- **Autenticación:** el sistema web usaba cédula + contraseña con hash MD5.
  Firebase Auth gestiona sus propios hashes (no se pueden importar MD5
  directamente). Los usuarios deben **registrarse de nuevo** en la app. El
  login acepta **correo o cédula** para mantener la costumbre de ingresar con
  cédula.
- **Roles:** el panel se muestra según `tipo` (`estudiante`, `docente`,
  `encargado`).
- **Backend PHP (XAMPP):** queda obsoleto salvo que quieras conservarlo para
  tareas administrativas. La app no llama a `db/*.php`.
