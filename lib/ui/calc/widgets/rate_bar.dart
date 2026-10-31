import 'package:flutter/material.dart';

import '../../../core/app_strings.dart';
import '../../common/calc_loader.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Строка под результатом: откуда курс, сброс ручного курса, обновление.
class RateBar extends StatelessWidget {
  final String caption;
  final bool isLoading;
  final bool canReset;
  final bool showRefresh;
  final VoidCallback onRefresh;
  final VoidCallback onReset;

  const RateBar({
    super.key,
    required this.caption,
    required this.isLoading,
    required this.canReset,
    required this.showRefresh,
    required this.onRefresh,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    return Row(
      children: [
        Expanded(
          child: Text(
            caption,
            style: AppTextStyles.caption.copyWith(color: c.textSecondary),
          ),
        ),
        if (canReset)
          TextButton(
            onPressed: onReset,
            child: Text(
              AppStrings.rateReset.toUpperCase(),
              style: AppTextStyles.label.copyWith(color: c.textPrimary),
            ),
          ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CalcLoader(size: 28),
          )
        else if (showRefresh)
          IconButton(
            tooltip: AppStrings.rateRefresh,
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
      ],
    );
  }
}
