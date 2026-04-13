# Control Horario App

App de registro de fichajes de entrada y salida con autenticación JWT.

- **Backend:** Python FastAPI + SQLAlchemy + JWT + bcrypt
- **Frontend:** Flutter (Android, iOS, Web, Windows)

## Estructura

```
appdecontrolhorario/
├── backend/          ← Servidor FastAPI
│   ├── main.py
│   ├── database.py
│   ├── requirements.txt
│   └── .env.example
└── app/              ← Aplicación Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── gestion_page.dart
    │   ├── config/
    │   │   └── app_config.dart
    │   └── services/
    │       └── api_service.dart
    └── pubspec.yaml
```

---

## ⚡ Instalación rápida

### 1. Clonar el repositorio

```bash
git clone https://github.com/Pabloobp/appdecontrolhorario.git
cd appdecontrolhorario
```

---

### 2. Configurar y arrancar el Backend

```bash
cd backend

# Instalar dependencias
pip install -r requirements.txt

# Crear el archivo .env a partir del ejemplo
cp .env.example .env
```

Edita el archivo `.env` si quieres cambiar la base de datos u otros valores.
Por defecto usa **SQLite local** (`controlhorario.db`) — no necesitas instalar nada más.

```bash
# Arrancar el servidor
python -m uvicorn main:app --reload
```

El backend estará en: **http://127.0.0.1:8000**
Documentación Swagger: **http://127.0.0.1:8000/docs**

---

### 3. Configurar el Frontend (Flutter)

En **otra terminal**:

```bash
cd app

# Instalar paquetes
flutter pub get
```

La URL del backend se **detecta automáticamente** en `lib/config/app_config.dart` según la plataforma:

| Plataforma | URL usada automáticamente |
|---|---|
| Android emulator | `http://10.0.2.2:8000` ✅ |
| iOS simulator / Web / Desktop | `http://localhost:8000` ✅ |
| Dispositivo físico | Edita `app_config.dart` y pon `http://TU_IP_LOCAL:8000` |

```bash
# Ejecutar la app (elige dispositivo)
flutter run
```

---

## 🗄️ Base de datos

Por defecto, el backend usa **SQLite** (archivo `controlhorario.db` creado automáticamente).

Si quieres usar **PostgreSQL / Supabase**, edita el `.env`:

```env
DATABASE_URL=postgresql://usuario:contraseña@host:5432/nombre_db
```

---

## 📱 Funcionalidades

| Función | Backend | Flutter |
|---|---|---|
| Registro de usuario | `POST /register` | Página de registro |
| Login con JWT | `POST /login` | Página de login |
| Datos de perfil | `GET /me` | Página de perfil |
| Fichar entrada | `POST /fichar-entrada` | Botón "Entrada" |
| Fichar salida | `POST /fichar-salida` | Botón "Salida" |
| Ver historial | `GET /ver-mi-historial` | Página historial |
| Cerrar sesión | — | Botón logout |

---

## ✅ Requisitos

- Python 3.9+
- Flutter 3.x (`flutter --version` para verificar)
- Git
