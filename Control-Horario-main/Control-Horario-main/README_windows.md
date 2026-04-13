# Guía rápida para clonar y configurar el proyecto en Windows

## 1. Clonar la rama UI_Luis_01

Abre una terminal (CMD, PowerShell o Git Bash) y ejecuta:

```
git clone https://github.com/luisluiswii/Control-Horario.git
cd Control-Horario
git checkout UI_Luis_01
```

## 2. Instalar Flutter y dependencias
- Descarga Flutter SDK para Windows: https://docs.flutter.dev/get-started/install/windows
- Extrae y añade la ruta de Flutter al PATH.
- Instala Android Studio (incluye SDK y emulador) o solo el SDK si prefieres.

## 3. Instalar dependencias del proyecto
```
flutter pub get
```

## 4. Validar entorno
```
flutter doctor
```

## 5. Ejecutar la app
- Para web:
```
flutter run -d chrome
```
- Para Android (emulador o dispositivo):
```
flutter run -d <device_id>
```

## 6. Ejecutar tests
```
flutter test
```

## 7. Notas
- El script `scripts/setup_flutter_linux.sh` es solo para Linux, ignóralo en Windows.
- Si tienes problemas con el emulador, usa un dispositivo físico o revisa la configuración de AVD.

---

Puedes añadir aquí tus notas/contexto de Windows para que te ayude a adaptar el proyecto.
