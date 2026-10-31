import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/domain/calc_input.dart';
import 'package:kitex_calc/domain/price_calculator.dart';

CalcInput input({
  double price = 120,
  int qty = 2,
  double weight = 0.8,
  double rate = 13.12,
  double commission = 10,
  double perKg = 600,
  double extra = 0,
}) =>
    CalcInput(
      priceCny: price,
      qty: qty,
      weightKg: weight,
      rate: rate,
      commissionPct: commission,
      perKgRub: perKg,
      extraRub: extra,
    );

void main() {
  test('обычный случай', () {
    final r = PriceCalculator.calculate(input());
    expect(r.goodsRub, closeTo(3148.80, 0.001));
    expect(r.commissionRub, closeTo(314.88, 0.001));
    expect(r.deliveryRub, closeTo(960.00, 0.001));
    expect(r.totalRub, closeTo(4423.68, 0.001));
    expect(r.perItemRub, closeTo(2211.84, 0.001));
  });

  test('всё по нулям', () {
    final r = PriceCalculator.calculate(
        input(price: 0, weight: 0, extra: 0));
    expect(r.totalRub, 0);
    expect(r.perItemRub, 0);
  });

  test('количество 0 считается как 1', () {
    final r = PriceCalculator.calculate(input(qty: 0));
    expect(r.goodsRub, closeTo(120 * 13.12, 0.001));
  });

  test('доп. расходы входят в итог', () {
    final r = PriceCalculator.calculate(input(extra: 500));
    expect(r.totalRub, closeTo(4923.68, 0.001));
  });

  test('большие числа не ломают расчёт', () {
    final r = PriceCalculator.calculate(input(price: 1e9, qty: 1000));
    expect(r.totalRub.isFinite, true);
  });

  test('курс с наценкой', () {
    expect(PriceCalculator.effectiveRate(10, 5), closeTo(10.5, 0.0001));
  });
}
