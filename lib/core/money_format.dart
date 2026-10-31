/// Форматирование чисел для экрана. Округление только здесь, внутри считаем точно.
class MoneyFormat {
  static const String _nbsp = ' ';

  /// 4423.68 → «4 423,68». Пробел между разрядами неразрывный.
  static String number(double v, {int decimals = 2}) {
    if (v.isNaN || v.isInfinite) v = 0;
    final fixed = v.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = parts[0]
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => _nbsp);
    final frac = parts.length > 1 ? ',${parts[1]}' : '';
    final negative = v < 0 && double.parse(fixed) != 0;
    return '${negative ? '-' : ''}$grouped$frac';
  }

  static String rub(double v) => '${number(v)} ₽';

  static String cny(double v) =>
      '${number(v, decimals: v == v.roundToDouble() ? 0 : 2)} ¥';

  /// Число для поля ввода: без разрядов, запятая, лишние нули убраны.
  /// 13.12 → «13,12», 12.0 → «12», 11.796225 → «11,7962».
  static String input(double v, {int maxDecimals = 4}) {
    if (v.isNaN || v.isInfinite) return '0';
    var s = v.toStringAsFixed(maxDecimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s.replaceAll('.', ',');
  }

  /// «21.10, 11:25» в местном времени.
  static String dateTime(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(l.day)}.${two(l.month)}, ${two(l.hour)}:${two(l.minute)}';
  }
}
