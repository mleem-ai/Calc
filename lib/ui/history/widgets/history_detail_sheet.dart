import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_strings.dart';
import '../../../core/money_format.dart';
import '../../../data/models/calculation.dart';
import '../../common/kx_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Плавающее окно снизу с деталями расчёта из истории.
/// Закрывается с результатом true, если нажали «Вставить в калькулятор».
class HistoryDetailSheet extends StatelessWidget {
  final Calculation item;
  const HistoryDetailSheet({super.key, required this.item});

  static Future<bool?> show(BuildContext context, Calculation item) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => HistoryDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    final goods = item.priceCny * item.qty * item.rate;
    final commission = goods * item.commissionPct / 100;
    final delivery = item.weightKg * item.qty * item.perKgRub;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: k.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: k.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: k.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(color: k.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              MoneyFormat.dateTime(item.createdAt),
              style: AppTextStyles.caption.copyWith(color: k.textSecondary),
            ),
            const SizedBox(height: 16),
            _section(k, AppStrings.detailsInput),
            _row(k, AppStrings.fieldPrice,
                '${MoneyFormat.cny(item.priceCny)} × ${item.qty} ${AppStrings.pcs}'),
            if (item.weightKg > 0)
              _row(k, AppStrings.detailsWeight,
                  '${MoneyFormat.input(item.weightKg)} кг'),
            if (item.categoryName.isNotEmpty)
              _row(k, AppStrings.fieldCategory, item.categoryName),
            _row(k, AppStrings.fieldRate, MoneyFormat.input(item.rate)),
            _row(k, AppStrings.fieldCommission,
                '${MoneyFormat.input(item.commissionPct, maxDecimals: 2)}%'),
            _row(k, AppStrings.detailsPerKg,
                '${MoneyFormat.input(item.perKgRub, maxDecimals: 2)} ₽'),
            const SizedBox(height: 12),
            _section(k, AppStrings.detailsResult),
            _row(k, AppStrings.goods, MoneyFormat.rub(goods)),
            _row(k, AppStrings.commission, MoneyFormat.rub(commission)),
            _row(k, AppStrings.delivery, MoneyFormat.rub(delivery)),
            if (item.extraRub > 0)
              _row(k, AppStrings.extra, MoneyFormat.rub(item.extraRub)),
            const SizedBox(height: 4),
            _row(k, AppStrings.total, MoneyFormat.rub(item.totalRub),
                bold: true),
            _row(k, AppStrings.perItem, MoneyFormat.rub(item.perItemRub),
                bold: true),
            const SizedBox(height: 20),
            KxButton.primary(
              label: AppStrings.pasteToCalc,
              icon: Icons.south_west,
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(KxColors k, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: k.textSecondary),
        ),
      );

  Widget _row(KxColors k, String name, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.body.copyWith(
              color: bold ? k.textPrimary : k.textSecondary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.numeric.copyWith(
                color: k.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
