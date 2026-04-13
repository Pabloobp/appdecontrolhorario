# Control-Horario

Proyecto colaborativo para prácticas de 2º DAM orientado a un sistema de control horario.

Este repositorio ya está inicializado como proyecto Flutter para:
- Web
- Android

## Arquitectura

```
/backend          → API FastAPI (Python)
/Control-Horario-main/Control-Horario-main  → App Flutter
```

---

## 🚀 Instalación y puesta en marcha

### 1. Backend (FastAPI)

```bash
cd backend

# Crear entorno virtual
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Edita .env y rellena DATABASE_URL y SECRET_KEY

# Iniciar servidor
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> **Nota:** Necesitas una base de datos PostgreSQL. Puedes usar [Supabase](https://supabase.com) (plan gratuito) o PostgreSQL local.

La API queda disponible en `http://localhost:8000`.
La documentación interactiva en `http://localhost:8000/docs`.

### 2. Frontend (Flutter)

#### Configurar URL del backend

Edita `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Android emulator → 10.0.2.2:8000
  // iOS simulator / desktop → localhost:8000
  // Dispositivo físico en la misma red → IP de tu PC, p.ej. 192.168.1.100:8000
  static const String backendUrl = 'http://10.0.2.2:8000';
}
```

#### Instalar dependencias y ejecutar

```bash
cd "Control-Horario-main/Control-Horario-main"

flutter pub get
flutter run
```

---

## Endpoints del backend

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/register` | Crear nuevo usuario |
| POST | `/login` | Iniciar sesión → devuelve JWT |
| GET | `/me` | Datos del usuario autenticado |
| POST | `/fichar-entrada` | Registrar entrada |
| POST | `/fichar-salida` | Registrar salida |
| GET | `/ver-mi-historial` | Ver historial de fichajes |
| GET | `/descargar-excel` | Exportar a Excel |
| GET | `/descargar-pdf` | Exportar a PDF |

---

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
