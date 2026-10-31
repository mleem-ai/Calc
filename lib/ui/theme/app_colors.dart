import 'package:flutter/material.dart';

/// Цвета KITex: только чёрный, белый и серые.
@immutable
class KxColors extends ThemeExtension<KxColors> {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color inverse;
  final Color onInverse;

  const KxColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.inverse,
    required this.onInverse,
  });

  static const dark = KxColors(
    bg: Color(0xFF000000),
    surface: Color(0xFF0D0D0D),
    card: Color(0xFF161616),
    border: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9A9A9A),
    textDisabled: Color(0xFF5A5A5A),
    inverse: Color(0xFFFFFFFF),
    onInverse: Color(0xFF000000),
  );

  static const light = KxColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F5F5),
    card: Color(0xFFEDEDED),
    border: Color(0xFFD4D4D4),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF5C5C5C),
    textDisabled: Color(0xFFA3A3A3),
    inverse: Color(0xFF000000),
    onInverse: Color(0xFFFFFFFF),
  );

  @override
  KxColors copyWith({
    Color? bg,
    Color? surface,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? inverse,
    Color? onInverse,
  }) =>
      KxColors(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        card: card ?? this.card,
        border: border ?? this.border,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textDisabled: textDisabled ?? this.textDisabled,
        inverse: inverse ?? this.inverse,
        onInverse: onInverse ?? this.onInverse,
      );

  @override
  KxColors lerp(ThemeExtension<KxColors>? other, double t) {
    if (other is! KxColors) return this;
    return KxColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      onInverse: Color.lerp(onInverse, other.onInverse, t)!,
    );
  }
}

/// Короткий доступ к цветам: context.kx.bg
extension KxContext on BuildContext {
  KxColors get kx => Theme.of(this).extension<KxColors>()!;
}
