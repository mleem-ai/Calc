import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/core/number_parser.dart';

void main() {
  test('точка и запятая', () {
    expect(NumberParser.parse('12,5'), 12.5);
    expect(NumberParser.parse('12.5'), 12.5);
  });

  test('пробелы', () {
    expect(NumberParser.parse(' 1 200 '), 1200);
  });

  test('пусто и буквы дают 0', () {
    expect(NumberParser.parse(''), 0);
    expect(NumberParser.parse('abc'), 0);
  });

  test('целое не меньше минимума', () {
    expect(NumberParser.parseInt('0'), 1);
    expect(NumberParser.parseInt('3'), 3);
  });
}
