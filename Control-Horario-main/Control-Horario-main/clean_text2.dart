import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('lib/main.dart');
  String content = file.readAsStringSync();
  
  String rep = String.fromCharCode(0xFFFD);
  
  Map<String, String> replacements = {
    'Sesi\n': 'Sesión',
    'sesi\n': 'sesión',
    'electr\nico': 'electrónico',
    'rpido': 'rápido',
    'invlido': 'inválido',
    'Contrasea': 'Contraseña',
    'contrasea': 'contraseña',
    'Funci\n': 'Función',
    'recuperaci\n': 'recuperación',
    'pr\xima': 'próxima',
    'versi\n': 'versión',
    'Versi\n': 'Versión',
    'Olvidaste': '¿Olvidaste',
    'Men\': 'Menú',
    'Ocano': 'Océano',
    'Aadir': 'Añadir',
    'Gesti\n': 'Gestión',
    'bsqueda': 'búsqueda',
    'Reuni\n': 'Reunión',
    'Revisi\n': 'Revisión',
    'Ecolgico': 'Ecológico',
    'Clsico': 'Clásico',
    'Clido': 'Cálido',
    'prcticas': 'prácticas',
    'A\n': 'Aún',
  };

  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  file.writeAsStringSync(content);
  print('Fixed encoding issues 2');
}
