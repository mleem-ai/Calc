import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Кнопка KITex. primary: белая заливка. outline: белая обводка.
/// Внутри Row оборачивай в Expanded.
class KxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool _outline;

  const KxButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  }) : _outline = false;

  const KxButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  }) : _outline = true;

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final textStyle = AppTextStyles.title.copyWith(
      fontSize: 15,
      letterSpacing: 0.8,
    );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label.toUpperCase(), maxLines: 1),
          ),
        ),
      ],
    );

    return SizedBox(
      height: 56,
      child: _outline
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.textPrimary,
                disabledForegroundColor: c.textDisabled,
                side: BorderSide(
                  color: onPressed == null ? c.border : c.textPrimary,
                  width: 1.5,
                ),
                shape: shape,
                textStyle: textStyle,
                minimumSize: const Size(64, 56),
              ),
              child: content,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: c.inverse,
                foregroundColor: c.onInverse,
                disabledBackgroundColor: c.card,
                disabledForegroundColor: c.textDisabled,
                shape: shape,
                textStyle: textStyle,
                minimumSize: const Size(64, 56),
              ),
              child: content,
            ),
    );
  }
}
