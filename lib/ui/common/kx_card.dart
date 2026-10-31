import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Контейнер с рамкой. При [inverted] наоборот: светлый фон, тёмный текст.
class KxCard extends StatelessWidget {
  final Widget child;
  final bool inverted;
  final EdgeInsetsGeometry padding;

  const KxCard({
    super.key,
    required this.child,
    this.inverted = false,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: inverted ? c.inverse : c.card,
        borderRadius: BorderRadius.circular(20),
        border: inverted ? null : Border.all(color: c.border),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: inverted ? c.onInverse : c.textPrimary),
        child: child,
      ),
    );
  }
}
