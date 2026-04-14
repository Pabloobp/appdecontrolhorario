# Control Horario App

App de registro de fichajes de entrada y salida con Supabase como backend.

- **Backend:** Supabase (PostgreSQL + Auth + REST API)
- **Frontend:** Flutter (Android, iOS, Web, Windows)

## Estructura

```
appdecontrolhorario/
├── supabase/
│   └── schema.sql         ← Script SQL para crear tablas + RLS
├── backend/               ← Servidor FastAPI (legacy, no requerido)
│   ├── main.py
│   ├── database.py
│   ├── requirements.txt
│   └── .env.example
└── app/                   ← Aplicación Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── gestion_page.dart
    │   ├── cambio_turno_page.dart
    │   ├── config/
    │   │   └── app_config.dart       ← URL y key de Supabase
    │   └── services/
    │       ├── api_service.dart      ← (legacy)
    │       └── supabase_service.dart ← Servicio Supabase
    └── pubspec.yaml
```

---

## 🗄️ 1. Configurar Supabase (Base de Datos)

1. Ve a [https://supabase.com](https://supabase.com) → tu proyecto
2. Abre el **SQL Editor** (menú lateral izquierdo)
3. Copia y pega el contenido de `supabase/schema.sql`
4. Haz clic en **RUN** para crear todas las tablas y políticas RLS

Esto creará las tablas:
- `usuarios` — perfiles de empleados (se crea automáticamente al registrarse)
- `horarios` — horario semanal por empleado
- `marcajes` — registro diario de entrada/salida
- `cambios_turno` — solicitudes de cambio de turno

---

## ⚡ 2. Configurar el Frontend (Flutter)

```bash
cd app

# Instalar paquetes
flutter pub get
```

Las credenciales de Supabase ya están en `lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'https://htmumknfebjqjvjwcvug.supabase.co';
static const String supabaseAnonKey = 'sb_publishable_07XgshcqADVom9neTKotTA_4bnCRtR1';
```

```bash
# Ejecutar la app (elige dispositivo)
flutter run

# Para web
flutter run -d chrome
```

---

## 📱 Funcionalidades

| Función | Descripción |
|---|---|
| Login / Registro | Autenticación con Supabase Auth (email + contraseña) |
| Dashboard | Ver estado de jornada, tiempo acumulado |
| Check-in | Fichar entrada (se guarda en Supabase) |
| Check-out | Fichar salida (se guarda en Supabase) |
| Historial | Ver marcajes del mes actual |
| Cambio de turno | Solicitar/aceptar/rechazar cambios con otros empleados |
| Perfil | Ver datos del usuario y cerrar sesión |
| Temas | 7 temas de color disponibles |

---

## 🔐 Seguridad (RLS)

- Cada empleado solo puede ver y modificar sus propios datos
- Los admins pueden ver datos de todos los empleados
- Row Level Security habilitado en todas las tablas
- Supabase Auth gestiona tokens y sesiones

---

## ✅ Requisitos

- Flutter 3.x (`flutter --version` para verificar)
- Git
- Cuenta en [Supabase](https://supabase.com) (ya configurada)
