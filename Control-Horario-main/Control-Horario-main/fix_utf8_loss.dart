import 'dart:io';

void main() {
  final file = File('lib/main.dart');
  String content = file.readAsStringSync();

  final map = {
    'Sesiï¿½n': 'Sesión',
    'sesiï¿½n': 'sesión',
    'electrï¿½nico': 'electrónico',
    'Contraseï¿½a': 'Contraseña',
    'contraseï¿½a': 'contraseña',
    'ï¿½Olvidaste': '¿Olvidaste',
    'rï¿½pido': 'rápido',
    'invï¿½lido': 'inválido',
    'Funciï¿½n': 'Función',
    'recuperaciï¿½n': 'recuperación',
    'prï¿½xima': 'próxima',
    'versiï¿½n': 'versión',
    'Versiï¿½n': 'Versión',
    'biometrï¿½a': 'biometría',
    'Menï¿½': 'Menú',
    'Ocï¿½ano': 'Océano',
    'bï¿½squeda': 'búsqueda',
    'Reuniï¿½n': 'Reunión',
    'Revisiï¿½n': 'Revisión',
    'Ecolï¿½gico': 'Ecológico',
    'Clï¿½sico': 'Clásico',
    'Cï¿½lido': 'Cálido',
    'prï¿½cticas': 'prácticas',
    'Aï¿½n': 'Aún',
    'Dï¿½a': 'Día',
    'dï¿½a': 'día',
    'Aï¿½adir': 'Añadir',
    'Gestiï¿½n': 'Gestión',
    'Aï¿½o': 'Año',
    'aï¿½o': 'año',
    'Miï¿½': 'Mié',
  };

  map.forEach((bad, good) {
    content = content.replaceAll(bad, good);
  });
  
  file.writeAsStringSync(content);
  print('main.dart repaired');

  final file2 = File('lib/gestion_page.dart');
  if (file2.existsSync()) {
    String content2 = file2.readAsStringSync();
    map.forEach((bad, good) {
      content2 = content2.replaceAll(bad, good);
    });
    // Add any specific to gestion_page
    content2 = content2.replaceAll('Lucï¿½a', 'Lucía');
    content2 = content2.replaceAll('Gestiï¿½n', 'Gestión');
    content2 = content2.replaceAll('Miï¿½', 'Mié');
    file2.writeAsStringSync(content2);
    print('gestion_page.dart repaired');
  }
}
