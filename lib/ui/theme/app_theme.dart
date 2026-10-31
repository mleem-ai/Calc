import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Чёрно-белая тема KITex. Тёмная по умолчанию, светлая как инверсия.
class AppTheme {
  static ThemeData dark() => _build(KxColors.dark, Brightness.dark);
  static ThemeData light() => _build(KxColors.light, Brightness.light);

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData _build(KxColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.inverse,
      onPrimary: c.onInverse,
      secondary: c.inverse,
      onSecondary: c.onInverse,
      error: c.textPrimary,
      onError: c.bg,
      surface: c.bg,
      onSurface: c.textPrimary,
      outline: c.border,
      outlineVariant: c.border,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.card,
      surfaceContainerHighest: c.card,
      inverseSurface: c.inverse,
      onInverseSurface: c.onInverse,
    );

    final textTheme = TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: c.textPrimary),
      headlineMedium: AppTextStyles.headline.copyWith(color: c.textPrimary),
      titleMedium: AppTextStyles.title.copyWith(color: c.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: c.textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: c.textPrimary),
      bodySmall: AppTextStyles.caption.copyWith(color: c.textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: c.textPrimary),
      labelSmall: AppTextStyles.label.copyWith(color: c.textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: AppTextStyles.sans,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[c],
      splashFactory: NoSplash.splashFactory,
      iconTheme: IconThemeData(color: c.textPrimary),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title.copyWith(color: c.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(c.border),
        enabledBorder: _border(c.border),
        focusedBorder: _border(c.textPrimary, 1.5),
        errorBorder: _border(c.textPrimary, 2),
        focusedErrorBorder: _border(c.textPrimary, 2),
        suffixStyle: AppTextStyles.body.copyWith(color: c.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: c.textDisabled),
        errorStyle: AppTextStyles.caption.copyWith(color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.inverse,
        elevation: 0,
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? c.onInverse
                : c.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.label.copyWith(
            letterSpacing: 0.6,
            color: states.contains(WidgetState.selected)
                ? c.textPrimary
                : c.textSecondary,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverse,
        contentTextStyle: AppTextStyles.body.copyWith(color: c.onInverse),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.inverse
                : Colors.transparent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? c.onInverse
                : c.textPrimary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: c.border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          textStyle: WidgetStatePropertyAll(
            AppTextStyles.label.copyWith(letterSpacing: 0.6),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
