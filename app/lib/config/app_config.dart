import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class AppConfig {
  // Para dispositivos físicos Android/iOS, pon aquí la IP de tu PC y
  // deja las demás plataformas sin tocar.
  // Ejemplo: static const _physicalDeviceUrl = 'http://192.168.1.10:8000';
  // Deja vacío ('') para usar la detección automática de plataforma.
  static const String _physicalDeviceUrl = '';

  // URL base del backend, seleccionada automáticamente según la plataforma.
  static String get backendUrl {
    // Permite sobreescribir para dispositivos físicos cuando se configure.
    if (_physicalDeviceUrl.isNotEmpty) return _physicalDeviceUrl;

    // Web (Chrome, Edge, etc.)
    if (kIsWeb) return 'http://localhost:8000';

    switch (defaultTargetPlatform) {
      // Android emulator redirige 10.0.2.2 al localhost del PC anfitrión.
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';

      // iOS simulator y macOS usan localhost directamente.
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return 'http://localhost:8000';

      // Windows / Linux desktop también usan localhost.
      default:
        return 'http://localhost:8000';
    }
  }
}
