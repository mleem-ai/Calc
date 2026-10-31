import 'package:flutter/material.dart';

import 'calc_mark.dart';

/// Индикатор загрузки: маленький калькулятор покачивается, капельки прыгают.
/// [size] — высота в dp.
class CalcLoader extends StatefulWidget {
  final double size;
  const CalcLoader({super.key, this.size = 32});

  @override
  State<CalcLoader> createState() => _CalcLoaderState();
}

class _CalcLoaderState extends State<CalcLoader>
    with SingleTickerProviderStateMixin {
  static const double _seconds = 1.4; // ровно 2 цикла покачивания

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CalcMarkAnimated(
        height: widget.size,
        elapsed: _controller.value * _seconds,
      ),
    );
  }
}
