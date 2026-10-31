import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:kitex_calc/core/app_config.dart';
import 'package:kitex_calc/data/db/app_database.dart';
import 'package:kitex_calc/data/db/calculation_dao.dart';
import 'package:kitex_calc/data/db/category_dao.dart';
import 'package:kitex_calc/data/db/rate_dao.dart';
import 'package:kitex_calc/data/db/settings_dao.dart';
import 'package:kitex_calc/data/models/app_settings.dart';
import 'package:kitex_calc/data/models/calculation.dart';
import 'package:kitex_calc/data/models/category.dart';
import 'package:kitex_calc/data/models/rate_snapshot.dart';
import 'package:kitex_calc/data/repositories/category_repository.dart';
import 'package:kitex_calc/data/repositories/settings_repository.dart';

Calculation calc(int minute, {int? categoryId, String name = 'Одежда'}) =>
    Calculation(
      createdAt: DateTime.utc(2026, 1, 1, 12, minute),
      priceCny: 120,
      qty: 2,
      weightKg: 0.8,
      categoryId: categoryId,
      categoryName: name,
      rate: 13.12,
      commissionPct: 10,
      perKgRub: 600,
      extraRub: 0,
      totalRub: 4423.68,
      perItemRub: 2211.84,
    );

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabase db;

  setUp(() {
    // новая пустая база в памяти для каждого теста
    db = AppDatabase(path: inMemoryDatabasePath);
  });

  tearDown(() async => db.close());

  group('схема и стартовые данные', () {
    test('создаются 5 категорий с ценами из конфига', () async {
      final cats = await CategoryDao(db).getAll();
      expect(cats.map((c) => c.name).toList(),
          AppConfig.defaultCategories.keys.toList());
      expect(cats.first.pricePerKg, 600);
    });

    test('настройки по умолчанию записаны, профиль компании пустой', () async {
      final map = await SettingsDao(db).getAll();
      final s = AppSettings.fromMap(map);
      expect(s.rateMode, RateMode.auto);
      expect(s.markupPct, AppConfig.defaultMarkupPct);
      expect(s.companyName, '');
      expect(s.companyContact, '');
    });
  });

  group('CategoryDao', () {
    test('имена категорий уникальны', () async {
      final dao = CategoryDao(db);
      expect(
        () => dao.insert(const Category(name: 'Одежда', pricePerKg: 1)),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('отрицательная цена за кг отклоняется', () async {
      final dao = CategoryDao(db);
      expect(
        () => dao.insert(const Category(name: 'Минус', pricePerKg: -5)),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('вставка, правка и удаление', () async {
      final dao = CategoryDao(db);
      final id = await dao.insert(
          const Category(name: 'Игрушки', pricePerKg: 500, sortOrder: 9));
      final c = (await dao.getById(id))!;
      expect(c.pricePerKg, 500);
      await dao.update(c.copyWith(pricePerKg: 550));
      expect((await dao.getById(id))!.pricePerKg, 550);
      await dao.delete(id);
      expect(await dao.getById(id), isNull);
    });
  });

  group('CalculationDao', () {
    test('сохранённый расчёт читается без потерь', () async {
      final dao = CalculationDao(db);
      final id = await dao.insert(calc(0));
      final c = (await dao.getById(id))!;
      expect(c.priceCny, 120);
      expect(c.qty, 2);
      expect(c.totalRub, closeTo(4423.68, 0.0001));
      expect(c.createdAt.isUtc, true);
    });

    test('новые расчёты идут первыми', () async {
      final dao = CalculationDao(db);
      await dao.insert(calc(1));
      await dao.insert(calc(5));
      await dao.insert(calc(3));
      final all = await dao.getAll();
      expect(all.map((c) => c.createdAt.minute).toList(), [5, 3, 1]);
    });

    test('удаление категории не удаляет расчёты, category_id становится NULL',
        () async {
      final cats = CategoryDao(db);
      final dao = CalculationDao(db);
      final catId = (await cats.getAll()).first.id!;
      final id = await dao.insert(calc(0, categoryId: catId));
      await cats.delete(catId);
      final c = (await dao.getById(id))!;
      expect(c.categoryId, isNull);
      expect(c.categoryName, 'Одежда');
    });

    test('trimToLimit оставляет самые свежие', () async {
      final dao = CalculationDao(db);
      for (var i = 0; i < 6; i++) {
        await dao.insert(calc(i));
      }
      await dao.trimToLimit(3);
      expect(await dao.count(), 3);
      final left = await dao.getAll();
      expect(left.map((c) => c.createdAt.minute).toList(), [5, 4, 3]);
    });

    test('deleteAll очищает историю', () async {
      final dao = CalculationDao(db);
      await dao.insert(calc(0));
      await dao.insert(calc(1));
      await dao.deleteAll();
      expect(await dao.count(), 0);
    });
  });

  group('RateDao', () {
    test('getLatest возвращает самый свежий курс', () async {
      final dao = RateDao(db);
      await dao.insert(RateSnapshot(
          value: 12.9, fetchedAt: DateTime.utc(2026, 1, 1, 10)));
      await dao.insert(RateSnapshot(
          value: 13.1, fetchedAt: DateTime.utc(2026, 1, 2, 10)));
      expect((await dao.getLatest('CNY'))!.value, 13.1);
    });

    test('trim хранит только последние N снимков', () async {
      final dao = RateDao(db);
      for (var i = 1; i <= 5; i++) {
        await dao.insert(RateSnapshot(
            value: 10 + i.toDouble(), fetchedAt: DateTime.utc(2026, 1, i)));
      }
      await dao.trim(2);
      expect((await dao.getLatest('CNY'))!.value, 15);
    });
  });

  group('репозитории поверх настоящей базы', () {
    test('профиль компании сохраняется и читается заново', () async {
      final repo = SettingsRepository(SettingsDao(db));
      await repo.init();
      await repo.update(repo.current
          .copyWith(companyName: 'KITex', companyContact: '@KITex_Mickey'));

      final again = SettingsRepository(SettingsDao(db));
      await again.init();
      expect(again.current.companyName, 'KITex');
      expect(again.current.companyContact, '@KITex_Mickey');
    });

    test('CategoryRepository не даёт удалить последнюю категорию', () async {
      final repo = CategoryRepository(CategoryDao(db));
      await repo.load();
      while (repo.items.length > 1) {
        await repo.remove(repo.items.first.id!);
      }
      expect(() => repo.remove(repo.items.first.id!),
          throwsA(isA<CategoryException>()));
    });

    test('CategoryRepository отклоняет дубль названия', () async {
      final repo = CategoryRepository(CategoryDao(db));
      await repo.load();
      expect(() => repo.add('одежда', 100),
          throwsA(isA<CategoryException>()));
    });

    test('resetToDefaults возвращает 5 стартовых категорий', () async {
      final repo = CategoryRepository(CategoryDao(db));
      await repo.load();
      await repo.add('Свои', 100);
      await repo.resetToDefaults();
      expect(repo.items.length, AppConfig.defaultCategories.length);
    });
  });
}
