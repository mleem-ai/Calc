import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/data/models/app_settings.dart';
import 'package:kitex_calc/data/models/calculation.dart';
import 'package:kitex_calc/data/models/category.dart';
import 'package:kitex_calc/domain/calc_input.dart';
import 'package:kitex_calc/domain/price_calculator.dart';

void main() {
  group('Category', () {
    test('toMap и fromMap возвращают то же самое', () {
      const c = Category(id: 1, name: 'Одежда', pricePerKg: 600, sortOrder: 2);
      final r = Category.fromMap(c.toMap());
      expect(r.id, 1);
      expect(r.name, 'Одежда');
      expect(r.pricePerKg, 600);
      expect(r.sortOrder, 2);
    });

    test('без id ключ id не попадает в map', () {
      const c = Category(name: 'Обувь', pricePerKg: 700);
      expect(c.toMap().containsKey('id'), false);
    });

    test('copyWith меняет только нужное', () {
      const c = Category(id: 1, name: 'A', pricePerKg: 100);
      final r = c.copyWith(pricePerKg: 200);
      expect(r.name, 'A');
      expect(r.pricePerKg, 200);
      expect(r.id, 1);
    });
  });

  group('Calculation', () {
    const input = CalcInput(
      priceCny: 120,
      qty: 2,
      weightKg: 0.8,
      rate: 13.12,
      commissionPct: 10,
      perKgRub: 600,
      extraRub: 0,
    );

    test('снимок расчёта сохраняется и читается без потерь', () {
      final result = PriceCalculator.calculate(input);
      final c = Calculation.fromInput(input, result,
          categoryId: 3, categoryName: 'Одежда', title: 'Куртка');
      final map = c.toMap()..['id'] = 5;
      final r = Calculation.fromMap(map);

      expect(r.id, 5);
      expect(r.title, 'Куртка');
      expect(r.categoryId, 3);
      expect(r.categoryName, 'Одежда');
      expect(r.totalRub, closeTo(4423.68, 0.001));
      expect(r.perItemRub, closeTo(2211.84, 0.001));
      expect(r.createdAt.isUtc, true);

      final back = r.toInput();
      expect(back.priceCny, 120);
      expect(back.qty, 2);
      expect(back.rate, 13.12);
    });

    test('displayTitle: название, если есть', () {
      final result = PriceCalculator.calculate(input);
      final c = Calculation.fromInput(input, result,
          categoryName: 'Одежда', title: 'Куртка');
      expect(c.displayTitle, 'Куртка');
    });

    test('displayTitle: дата, если названия нет', () {
      final result = PriceCalculator.calculate(input);
      final c = Calculation.fromInput(input, result, categoryName: 'Одежда');
      expect(RegExp(r'^\d{2}\.\d{2}, \d{2}:\d{2}$').hasMatch(c.displayTitle),
          true);
    });
  });

  group('AppSettings', () {
    test('пустая map даёт значения по умолчанию', () {
      final s = AppSettings.fromMap({});
      final d = AppSettings.defaults();
      expect(s.rateMode, d.rateMode);
      expect(s.manualRate, d.manualRate);
      expect(s.themeMode, ThemeMode.dark);
      expect(s.lastCategoryId, null);
    });

    test('toMap и fromMap возвращают то же самое', () {
      final s = AppSettings.defaults().copyWith(
        rateMode: RateMode.manual,
        manualRate: 13.5,
        themeMode: ThemeMode.light,
        lastCategoryId: 3,
      );
      final r = AppSettings.fromMap(s.toMap());
      expect(r.rateMode, RateMode.manual);
      expect(r.manualRate, 13.5);
      expect(r.themeMode, ThemeMode.light);
      expect(r.lastCategoryId, 3);
    });

    test('clearLastCategory обнуляет выбранную категорию', () {
      final s = AppSettings.defaults().copyWith(lastCategoryId: 3);
      expect(s.copyWith(clearLastCategory: true).lastCategoryId, null);
    });
  });
}
