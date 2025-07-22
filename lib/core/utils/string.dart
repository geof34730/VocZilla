String GetValidName(String? input) {
  const fallback = '?';
  if (input == null || input.trim().isEmpty) return fallback;
  final clean = input.trim().replaceAll(RegExp(r'[^\w\s]'), '');
  return clean.isEmpty ? fallback : clean;
}
