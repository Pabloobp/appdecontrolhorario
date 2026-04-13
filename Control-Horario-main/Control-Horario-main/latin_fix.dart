import "dart:io";
import "dart:convert";

void main() {
  final file = File("lib/main.dart");
  List<int> bytes = file.readAsBytesSync();
  String content = utf8.decode(bytes, allowMalformed: true);
  
  // Custom manual replace for cases that we know are broken strings
  // We can just use the literal bytes that we see in the IDE.
  final fixes = {
    "SesiÃ³n": "Sesión",
    "sesiÃ³n": "sesión",
    "electrÃ³nico": "electrónico",
    "rÃ¡pido": "rápido",
    "invÃ¡lido": "inválido",
    "ContraseÃ±a": "Contraseña",
    "contraseÃ±a": "contraseña",
    "FunciÃ³n": "Función",
    "recuperaciÃ³n": "recuperación",
    "prÃ³xima": "próxima",
    "versiÃ³n": "versión",
    "VersiÃ³n": "Versión",
    "Ã‚Â¿Olvidaste": "¿Olvidaste",
    "MenÃº": "Menú",
    "OcÃ©ano": "Océano",
    "AÃ±adir": "Añadir",
    "GestiÃ³n": "Gestión",
    "bÃºsqueda": "búsqueda",
    "ReuniÃ³n": "Reunión",
    "RevisiÃ³n": "Revisión",
    "EcolÃ³gico": "Ecológico",
    "ClÃ¡sico": "Clásico",
    "CÃ¡lido": "Cálido",
    "prÃ¡cticas": "prácticas",
    "AÃºn": "Aún",
    "biometrÃƒÂa": "biometría",
  };

  fixes.forEach((malformed, corrected) {
    content = content.replaceAll(malformed, corrected);
  });

  file.writeAsStringSync(content);
  print("Fixes applied successfully to main.");
}
