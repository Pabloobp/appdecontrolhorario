import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('lib/main.dart');
  String content = file.readAsStringSync(encoding: utf8);
  
  Map<String, String> replacements = {
    'rï¿½pido': 'rápido',
    'Sesiï¿½n': 'Sesión',
    'sesiï¿½n': 'sesión',
    'electrï¿½nico': 'electrónico',
    'invï¿½lido': 'inválido',
    'Contraseï¿½a': 'Contraseña',
    'contraseï¿½a': 'contraseña',
    'Funciï¿½n': 'Función',
    'recuperaciï¿½n': 'recuperación',
    'prï¿½xima': 'próxima',
    'versiï¿½n': 'versión',
    'Versiï¿½n': 'Versión',
    'ï¿½Olvidaste': '¿Olvidaste',
    'Menï¿½': 'Menú',
    'Ocï¿½ano': 'Océano',
    'Aï¿½adir': 'Añadir',
    'Gestiï¿½n': 'Gestión',
    'bï¿½squeda': 'búsqueda',
    'Reuniï¿½n': 'Reunión',
    'Revisiï¿½n': 'Revisión',
    'Ecolï¿½gico': 'Ecológico',
    'Clï¿½sico': 'Clásico',
    'Cï¿½lido': 'Cálido',
    'prï¿½cticas': 'prácticas',
    'Aï¿½n': 'Aún',
  };

  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  file.writeAsStringSync(content, encoding: utf8);
  print('Fixed encoding issues');
}
