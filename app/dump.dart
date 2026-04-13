import "dart:io";

void main() {
  final file = File("lib/main.dart");
  String t = file.readAsStringSync();
  
  // Dump out the exact sequence for "Inicia Sesi..."
  int idx = t.indexOf("Inicia Sesi");
  if (idx != -1) {
     print(t.substring(idx, idx + 15).codeUnits);
  }
}
