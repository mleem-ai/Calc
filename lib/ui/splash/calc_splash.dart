import 'package:flutter/material.dart';

import '../common/calc_mark.dart';
import '../theme/app_text_styles.dart';

/// Заставка при запуске: калькулятор резво покачивается, капельки выпрыгивают.
/// Системная заставка Android показывает тот же калькулятор неподвижно,
/// поэтому переход получается плавным.
class CalcSplash extends StatefulWidget {
  final VoidCallback onDone;
  const CalcSplash({super.key, required this.onDone});

  @override
  State<CalcSplash> createState() => _CalcSplashState();
}

class _CalcSplashState extends State<CalcSplash>
    with SingleTickerProviderStateMixin {
  static const double _seconds = 2.1; // ровно 3 цикла покачивания
  static const double _height = 140;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  );

  bool _started = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller.duration = const Duration(milliseconds: 600);
    }
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _envelope(double t) {
    final fadeIn = Curves.easeOut.transform((t / 0.1).clamp(0.0, 1.0));
    final fadeOut =
        1 - Curves.easeIn.transform(((t - 0.8) / 0.2).clamp(0.0, 1.0));
    return fadeIn * fadeOut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final caption =
              Curves.easeOut.transform(((t - 0.15) / 0.3).clamp(0.0, 1.0));
          return Stack(
            children: [
              Center(
                child: _reduceMotion
                    ? const CalcMark(height: _height, color: Colors.white)
                    : CalcMarkAnimated(
                        height: _height,
                        elapsed: t * _seconds,
                        envelope: _envelope(t),
                        color: Colors.white,
                      ),
              ),
              Align(
                alignment: const Alignment(0, 0.42),
                child: Opacity(
                  opacity: caption,
                  child: Text(
                    'KITEX CALC',
                    style: AppTextStyles.label.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
