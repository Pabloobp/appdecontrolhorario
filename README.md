# Control de Horario — App

Aplicación de control horario con backend FastAPI y frontend Flutter.

## Estructura del proyecto

```
appdecontrolhorario/
├── backend/          # API REST en Python/FastAPI
│   ├── main.py
│   ├── database.py
│   ├── requirements.txt
│   └── .env.example
└── app/              # App Flutter (Android, iOS, Web, Windows)
    ├── lib/
    │   ├── main.dart
    │   └── gestion_page.dart
    ├── pubspec.yaml
    ├── android/
    ├── web/
    └── windows/
```

---

## Requisitos previos

- Python 3.10+
- Flutter SDK 3.x ([instalar Flutter](https://flutter.dev/docs/get-started/install))
- Una base de datos PostgreSQL (puedes usar [Supabase](https://supabase.com) gratis)

---

## 1. Configurar y arrancar el Backend

```bash
cd backend

# Crear entorno virtual e instalar dependencias
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Edita .env y pon tu DATABASE_URL real

# Arrancar el servidor
uvicorn main:app --reload
```

La API estará disponible en **http://localhost:8000**  
Documentación interactiva en **http://localhost:8000/docs**

---

## 2. Configurar y ejecutar la App Flutter

```bash
cd app

# Instalar dependencias
flutter pub get

# Ejecutar en el dispositivo/emulador conectado
flutter run

# Ejecutar en Chrome (web)
flutter run -d chrome

# Compilar para Windows
flutter build windows
```

> **Nota:** Para conectar la app al backend local, edita la URL base en `app/lib/main.dart` (busca `localhost:8000`).

---

## Endpoints principales del Backend

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/login` | Autenticar usuario, devuelve token |
| POST | `/fichar-entrada` | Registrar entrada (requiere token) |
| POST | `/fichar-salida` | Registrar salida (requiere token) |
| GET | `/ver-mi-historial` | Ver todos mis fichajes (requiere token) |
| GET | `/descargar-excel` | Exportar historial a Excel (requiere token) |
| GET | `/descargar-pdf` | Exportar historial a PDF (requiere token) |

---

## Solución de problemas

**Error: rutas demasiado largas en Windows**  
Activa las rutas largas en Windows ejecutando como administrador:  
```
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
```

**Error: DATABASE_URL no configurada**  
Asegúrate de copiar `.env.example` a `.env` y rellenar la cadena de conexión.
