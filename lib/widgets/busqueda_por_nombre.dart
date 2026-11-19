/// Permite encontrar nombres con o sin tildes y sin distinguir mayúsculas.
String normalizarNombre(String texto) {
  const originales = 'áéíóúüñ';
  const reemplazos = 'aeiouun';
  var resultado = texto.trim().toLowerCase();
  for (var i = 0; i < originales.length; i++) {
    resultado = resultado.replaceAll(originales[i], reemplazos[i]);
  }
  return resultado.replaceAll(RegExp(r'\s+'), ' ');
}
