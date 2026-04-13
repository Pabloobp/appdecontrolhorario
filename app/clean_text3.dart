@"
import "dart:io";

void main() {
  final file = File("lib/main.dart");
  String content = file.readAsStringSync();
  
  String r = String.fromCharCode(0xFFFD);
  
  content = content.replaceAll("Sesi${r}n", "Sesión");
  content = content.replaceAll("sesi${r}n", "sesión");
  content = content.replaceAll("electr${r}nico", "electrónico");
  content = content.replaceAll("r${r}pido", "rápido");
  content = content.replaceAll("inv${r}lido", "inválido");
  content = content.replaceAll("Contrase${r}a", "Contraseña");
  content = content.replaceAll("contrase${r}a", "contraseña");
  content = content.replaceAll("Funci${r}n", "Función");
  content = content.replaceAll("recuperaci${r}n", "recuperación");
  content = content.replaceAll("pr${r}xima", "próxima");
  content = content.replaceAll("versi${r}n", "versión");
  content = content.replaceAll("Versi${r}n", "Versión");
  content = content.replaceAll("${r}Olvidaste", "¿Olvidaste");
  content = content.replaceAll("Men$r", "Menú");
  content = content.replaceAll("Oc${r}ano", "Océano");
  content = content.replaceAll("A${r}adir", "Añadir");
  content = content.replaceAll("Gesti${r}n", "Gestión");
  content = content.replaceAll("b${r}squeda", "búsqueda");
  content = content.replaceAll("Reuni${r}n", "Reunión");
  content = content.replaceAll("Revisi${r}n", "Revisión");
  content = content.replaceAll("Ecol${r}gico", "Ecológico");
  content = content.replaceAll("Cl${r}sico", "Clásico");
  content = content.replaceAll("C${r}lido", "Cálido");
  content = content.replaceAll("pr${r}cticas", "prácticas");
  content = content.replaceAll("A${r}n", "Aún");

  file.writeAsStringSync(content);
  print("Fixed encoding issues 3");
}
"@
