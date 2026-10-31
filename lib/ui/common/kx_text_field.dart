import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Поле ввода: подпись сверху капсом, единица измерения справа.
/// По умолчанию числовое: цифровая клавиатура, пропускает только цифры, точку и запятую.
class KxTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? suffix;
  final String? errorText;
  final bool numeric;
  final bool integerOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const KxTextField({
    super.key,
    required this.label,
    this.controller,
    this.onChanged,
    this.suffix,
    this.errorText,
    this.numeric = true,
    this.integerOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    final style = numeric
        ? AppTextStyles.numeric.copyWith(color: c.textPrimary, fontSize: 18)
        : AppTextStyles.body.copyWith(color: c.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: c.textSecondary),
          ),
        ),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: style,
          cursorColor: c.textPrimary,
          textInputAction: textInputAction,
          keyboardType: numeric
              ? TextInputType.numberWithOptions(decimal: !integerOnly)
              : (keyboardType ?? TextInputType.text),
          inputFormatters: numeric
              ? [
                  FilteringTextInputFormatter.allow(
                    RegExp(integerOnly ? r'[0-9]' : r'[0-9.,]'),
                  ),
                ]
              : null,
          decoration: InputDecoration(
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      suffix!,
                      style: AppTextStyles.body.copyWith(color: c.textSecondary),
                    ),
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            error: errorText == null
                ? null
                : Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: c.textPrimary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          errorText!,
                          style: AppTextStyles.caption
                              .copyWith(color: c.textPrimary),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
