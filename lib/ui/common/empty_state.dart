import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'kitex_logo.dart';

/// Пустой экран: кит и подпись.
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KitexLogo(size: 96),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: c.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
