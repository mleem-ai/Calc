/// Разбор чисел из текстовых полей.
class NumberParser {
  /// Пробелы убираем, запятую меняем на точку. Пусто или мусор дают 0.
  static double parse(String s) {
    final cleaned = s.trim().replaceAll(' ', '').replaceAll(',', '.');
    final v = double.tryParse(cleaned);
    if (v == null || v.isNaN || v.isInfinite) return 0;
    return v;
  }

  /// Целое число не меньше [min].
  static int parseInt(String s, {int min = 1}) {
    final v = parse(s).floor();
    return v < min ? min : v;
  }
}
