import 'package:flutter/material.dart';

import '../../../core/app_strings.dart';
import '../../../core/money_format.dart';
import '../../../data/models/calculation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Строка списка истории.
class HistoryTile extends StatelessWidget {
  final Calculation item;
  final VoidCallback onTap;
  const HistoryTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    final hasTitle = (item.title ?? '').trim().isNotEmpty;
    final parts = <String>[
      if (item.categoryName.isNotEmpty) item.categoryName,
      '${item.qty} ${AppStrings.pcs}',
      if (hasTitle) MoneyFormat.dateTime(item.createdAt),
    ];

    return Material(
      color: c.bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption
                          .copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormat.rub(item.totalRub),
                    style: AppTextStyles.numeric.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.perItem.toLowerCase()} ${MoneyFormat.number(item.perItemRub, decimals: 0)}',
                    style: AppTextStyles.caption
                        .copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
