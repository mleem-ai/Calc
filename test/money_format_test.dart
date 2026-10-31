import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/core/money_format.dart';

void main() {
  const nb = ' ';

  test('number: разряды и запятая', () {
    expect(MoneyFormat.number(4423.68), '4${nb}423,68');
    expect(MoneyFormat.number(1234567.891), '1${nb}234${nb}567,89');
    expect(MoneyFormat.number(0), '0,00');
    expect(MoneyFormat.number(-5.5), '-5,50');
    expect(MoneyFormat.number(999.999), '1${nb}000,00');
  });

  test('number: мусор не ломает', () {
    expect(MoneyFormat.number(double.nan), '0,00');
    expect(MoneyFormat.number(double.infinity), '0,00');
  });

  test('rub и cny', () {
    expect(MoneyFormat.rub(2211.84), '2${nb}211,84 ₽');
    expect(MoneyFormat.cny(120), '120 ¥');
    expect(MoneyFormat.cny(12.5), '12,50 ¥');
  });

  test('input: для полей ввода', () {
    expect(MoneyFormat.input(13.12), '13,12');
    expect(MoneyFormat.input(12), '12');
    expect(MoneyFormat.input(11.796225), '11,7962');
    expect(MoneyFormat.input(0), '0');
    expect(MoneyFormat.input(0.5), '0,5');
    expect(MoneyFormat.input(600), '600');
  });

  test('input и NumberParser согласованы', () {
    // то, что показали в поле, разбирается обратно в то же число
    const v = 11.7962;
    expect(double.parse(MoneyFormat.input(v).replaceAll(',', '.')), v);
  });
}
