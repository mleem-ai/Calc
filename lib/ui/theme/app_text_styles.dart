import 'package:flutter/material.dart';

/// Стили текста без цвета. Цвет берётся из темы: .copyWith(color: ...)
class AppTextStyles {
  static const String sans = 'Inter';
  static const String mono = 'JetBrainsMono';

  /// Итого, крупные числа.
  static const TextStyle display = TextStyle(
    fontFamily: mono,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: sans,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Подписи полей. Текст пишем капсом: label.toUpperCase().
  static const TextStyle label = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  /// Значения в результате и истории.
  static const TextStyle numeric = TextStyle(
    fontFamily: mono,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
}
