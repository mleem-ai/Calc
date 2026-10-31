import 'package:flutter/material.dart';

import 'calc_mark.dart';

/// Оставлен для совместимости со старыми экранами: теперь везде калькулятор.
enum KitexLogoVariant { mark, full }

/// Знак приложения: калькулятор с капельками. [size] — высота в dp.
class KitexLogo extends StatelessWidget {
  final KitexLogoVariant variant;
  final double size;

  const KitexLogo({
    super.key,
    this.variant = KitexLogoVariant.mark,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) => CalcMark(height: size);
}
