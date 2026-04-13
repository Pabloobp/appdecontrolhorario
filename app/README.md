# Control-Horario

Proyecto colaborativo para prácticas de 2º DAM orientado a un sistema de control horario.

Este repositorio ya está inicializado como proyecto Flutter para:
- Web
- Android

## Preparación de entorno Flutter (Linux)

Este repositorio incluye un script para preparar el entorno local de Flutter sin `snap`.

### 1) Ejecutar bootstrap

```bash
bash scripts/setup_flutter_linux.sh
```

El script:
- clona Flutter estable en `~/development/flutter` (si no existe),
- configura `PATH` de Flutter en `~/.bashrc`,
- configura Chromium para Flutter Web (si está instalado),
- instala Java 17 local en `~/development/jdks/jdk-17`,
- instala Android SDK (cmdline-tools, platform-tools y build-tools requeridos),
- acepta licencias de Android SDK,
- ejecuta `flutter doctor` de verificación.

### 2) Recargar shell

```bash
source ~/.bashrc
```

### 3) Verificar Flutter

```bash
flutter --version
flutter doctor -v
```

### 4) Ejecutar la app

Web (Chromium):

```bash
export CHROME_EXECUTABLE=/usr/bin/chromium
flutter run -d chrome
```

Android (emulador o móvil):

```bash
flutter devices
flutter run -d <device_id>
```

### 5) Validaciones recomendadas

```bash
flutter analyze
flutter test
```

## VS Code

Se recomiendan automáticamente las extensiones:
- `Dart-Code.dart-code`
- `Dart-Code.flutter`

## Próximo paso de equipo

Cuando tengáis la base funcionando, podéis crear los 3 forks (una por empresa) partiendo de esta plantilla común.
