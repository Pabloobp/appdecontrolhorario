/// Configuración de la URL del backend.
/// Cambia [backendUrl] a la dirección donde corre tu servidor FastAPI.
class AppConfig {
  /// URL base del backend FastAPI.
  /// Ejemplos:
  ///   - Local Android emulator: "http://10.0.2.2:8000"
  ///   - Local iOS simulator / desktop: "http://localhost:8000"
  ///   - Producción: "https://tu-dominio.com"
  static const String backendUrl = 'http://10.0.2.2:8000';
}
