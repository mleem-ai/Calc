import 'package:flutter/material.dart';

import '../../../core/app_strings.dart';
import '../../../core/money_format.dart';
import '../../../domain/calc_result.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Карточка-«чек» с результатом: белая на тёмной теме, зубчатый нижний край.
/// При появлении выезжает снизу, суммы «прокручиваются» к новому значению.
class ResultCard extends StatefulWidget {
  final CalcResult result;
  const ResultCard({super.key, required this.result});

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  )..forward();

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  CalcResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _in, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(curve),
        child: _receipt(context),
      ),
    );
  }

  Widget _receipt(BuildContext context) {
    final c = context.kx;
    return ClipPath(
      clipper: _ZigZagClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: BoxDecoration(
          color: c.inverse,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.total.toUpperCase(),
              style: AppTextStyles.label.copyWith(color: c.onInverse),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _Rolling(
                  value: result.totalRub,
                  format: MoneyFormat.rub,
                  style: AppTextStyles.display.copyWith(color: c.onInverse),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _row(c, AppStrings.goods, result.goodsRub),
            _row(c, AppStrings.commission, result.commissionRub),
            _row(c, AppStrings.delivery, result.deliveryRub),
            _row(c, AppStrings.extra, result.extraRub),
            const SizedBox(height: 6),
            _row(c, AppStrings.perItem, result.perItemRub, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _row(KxColors c, String name, double value, {bool bold = false}) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            name,
            style: AppTextStyles.body
                .copyWith(color: c.onInverse, fontWeight: weight),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 2,
                child: CustomPaint(painter: _DotsPainter(c.onInverse)),
              ),
            ),
          ),
          _Rolling(
            value: value,
            format: MoneyFormat.number,
            style: AppTextStyles.numeric.copyWith(
              color: c.onInverse,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Число, которое плавно «докручивается» от прежнего значения к новому.
/// Первое значение показывается сразу, без анимации.
class _Rolling extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle style;
  const _Rolling(
      {required this.value, required this.format, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(format(v), maxLines: 1, style: style),
    );
  }
}

/// Пунктирная линия между названием и суммой.
class _DotsPainter extends CustomPainter {
  final Color color;
  _DotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.5);
    for (double x = 0; x < size.width; x += 5) {
      canvas.drawCircle(Offset(x, size.height / 2), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.color != color;
}

/// Нижний край как у кассового чека.
class _ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const tooth = 9.0;
    final n = (size.width / 16).floor().clamp(4, 80);
    final step = size.width / n;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - tooth);
    for (var i = n; i > 0; i--) {
      path
        ..lineTo(step * (i - 0.5), size.height)
        ..lineTo(step * (i - 1), size.height - tooth);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ZigZagClipper oldClipper) => false;
}
