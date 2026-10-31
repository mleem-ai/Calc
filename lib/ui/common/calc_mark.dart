import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Высота / ширина картинок калькулятора (все слои одного размера).
const double kCalcAspect = 1.589;

/// Точки, от которых «вылетают» капельки (в долях картинки, от -1 до 1).
const Alignment _pivotLeft = Alignment(-0.086, -0.692);
const Alignment _pivotRight = Alignment(0.02, -0.69);

const String _bodyAsset = 'assets/brand/calc_body.png';
const String _dropLeftAsset = 'assets/brand/calc_drop_l.png';
const String _dropRightAsset = 'assets/brand/calc_drop_r.png';
const String _markAsset = 'assets/brand/calc_mark.png';

Widget _layer(String path, double width, double height, Color color) {
  return Image.asset(
    path,
    width: width,
    height: height,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
    color: color,
    colorBlendMode: BlendMode.srcIn,
  );
}

/// Калькулятор с капельками, статичный. Цвет по умолчанию берётся из темы.
class CalcMark extends StatelessWidget {
  final double height;
  final Color? color;
  const CalcMark({super.key, this.height = 32, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.kx.textPrimary;
    final width = height / kCalcAspect;
    return Semantics(
      label: 'KITex Calc',
      child: _layer(_markAsset, width, height, c),
    );
  }
}

/// Калькулятор, который покачивается из стороны в сторону,
/// а капельки по очереди выпрыгивают из него.
/// [elapsed] — время в секундах. [envelope] от 0 до 1 плавно включает
/// и выключает покачивание (на старте и в конце заставки).
class CalcMarkAnimated extends StatelessWidget {
  final double height;
  final double elapsed;
  final double envelope;
  final Color? color;

  static const double wobblePeriod = 0.7;
  static const double dropPeriod = 0.7;

  const CalcMarkAnimated({
    super.key,
    required this.height,
    required this.elapsed,
    this.envelope = 1,
    this.color,
  });

  Widget _drop({
    required Widget child,
    required Alignment pivot,
    required double rawPhase,
    required double side,
    required double width,
  }) {
    final p = rawPhase - rawPhase.floorToDouble();
    final up = Curves.easeOut.transform(p);
    final grow = Curves.easeOutBack.transform((p / 0.3).clamp(0.0, 1.0));
    final scale = 0.15 + 0.85 * grow;
    final fade = p < 0.6 ? 1.0 : (1.0 - (p - 0.6) / 0.4).clamp(0.0, 1.0);
    return Opacity(
      opacity: fade,
      child: Transform.translate(
        offset: Offset(side * up * width * 0.28, -up * height * 0.16),
        child: Transform.rotate(
          angle: side * 0.5 * up,
          alignment: pivot,
          child: Transform.scale(
            scale: scale,
            alignment: pivot,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.kx.textPrimary;
    final width = height / kCalcAspect;
    final angle =
        math.sin(elapsed / wobblePeriod * 2 * math.pi) * 0.14 * envelope;
    final phase = elapsed / dropPeriod;
    return SizedBox(
      width: width,
      height: height,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.bottomCenter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _layer(_bodyAsset, width, height, c),
            _drop(
              child: _layer(_dropLeftAsset, width, height, c),
              pivot: _pivotLeft,
              rawPhase: phase,
              side: -1,
              width: width,
            ),
            _drop(
              child: _layer(_dropRightAsset, width, height, c),
              pivot: _pivotRight,
              rawPhase: phase + 0.5,
              side: 1,
              width: width,
            ),
          ],
        ),
      ),
    );
  }
}
