import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/data/db/app_database.dart';
import 'package:kitex_calc/data/db/calculation_dao.dart';
import 'package:kitex_calc/data/db/category_dao.dart';
import 'package:kitex_calc/data/db/rate_dao.dart';
import 'package:kitex_calc/data/db/settings_dao.dart';
import 'package:kitex_calc/data/models/app_settings.dart';
import 'package:kitex_calc/data/models/calculation.dart';
import 'package:kitex_calc/data/models/category.dart';
import 'package:kitex_calc/data/models/rate_info.dart';
import 'package:kitex_calc/data/remote/cbr_api.dart';
import 'package:kitex_calc/data/repositories/calculation_repository.dart';
import 'package:kitex_calc/data/repositories/category_repository.dart';
import 'package:kitex_calc/data/repositories/rate_repository.dart';
import 'package:kitex_calc/data/repositories/settings_repository.dart';
import 'package:kitex_calc/domain/calc_input.dart';
import 'package:kitex_calc/domain/price_calculator.dart';
import 'package:kitex_calc/ui/calc/calc_controller.dart';

// Подставные репозитории: база не открывается, всё в памяти.

class FakeSettingsRepo extends SettingsRepository {
  FakeSettingsRepo(this._s) : super(SettingsDao(AppDatabase()));
  AppSettings _s;

  @override
  AppSettings get current => _s;

  void change(AppSettings s) {
    _s = s;
    notifyListeners();
  }

  @override
  Future<void> setLastCategory(int? id) async {}
}

class FakeCategoryRepo extends CategoryRepository {
  FakeCategoryRepo(this.list) : super(CategoryDao(AppDatabase()));
  List<Category> list;

  @override
  List<Category> get items => list;

  @override
  Category? byId(int? id) {
    for (final c in list) {
      if (c.id == id) return c;
    }
    return null;
  }

  void change(List<Category> l) {
    list = l;
    notifyListeners();
  }
}

class FakeRateRepo extends RateRepository {
  FakeRateRepo() : super(RateDao(AppDatabase()), CbrApi());
  RateInfo _i = const RateInfo();

  @override
  RateInfo get info => _i;

  void setInfo(RateInfo i) {
    _i = i;
    notifyListeners();
  }

  @override
  Future<void> refreshIfStale() async {}
}

class FakeCalcRepo extends CalculationRepository {
  FakeCalcRepo() : super(CalculationDao(AppDatabase()));
  final saved = <Calculation>[];

  @override
  Future<Calculation> save(Calculation c) async {
    saved.add(c);
    return c.withId(saved.length);
  }
}

const cat1 = Category(id: 1, name: 'Одежда', pricePerKg: 600);
const cat2 = Category(id: 2, name: 'Электроника', pricePerKg: 900);

class Env {
  final FakeSettingsRepo settings;
  final FakeCategoryRepo cats;
  final FakeRateRepo rate;
  final FakeCalcRepo calcs;
  final CalcController ctl;
  Env(this.settings, this.cats, this.rate, this.calcs, this.ctl);
}

AppSettings manualSettings() => AppSettings.defaults()
    .copyWith(rateMode: RateMode.manual, manualRate: 13.12);

Env makeEnv({AppSettings? s}) {
  final settings = FakeSettingsRepo(s ?? manualSettings());
  final cats = FakeCategoryRepo([cat1, cat2]);
  final rate = FakeRateRepo();
  final calcs = FakeCalcRepo();
  final ctl = CalcController(
    settingsRepo: settings,
    categoryRepo: cats,
    calculationRepo: calcs,
    rateRepo: rate,
  )..init();
  addTearDown(ctl.dispose);
  return Env(settings, cats, rate, calcs, ctl);
}

void main() {
  test('начальные значения берутся из настроек и первой категории', () {
    final e = makeEnv();
    expect(e.ctl.rate, 13.12);
    expect(e.ctl.commissionPct, 10);
    expect(e.ctl.perKgRub, 600);
    expect(e.ctl.category?.id, 1);
    expect(e.ctl.qty, 1);
    expect(e.ctl.result.totalRub, 0);
  });

  test('ввод пересчитывает результат, запятая и точка равны', () {
    final e = makeEnv();
    e.ctl.setPrice('120');
    e.ctl.setQty('2');
    e.ctl.setWeight('0,8');
    expect(e.ctl.result.goodsRub, closeTo(3148.80, 0.001));
    expect(e.ctl.result.totalRub, closeTo(4423.68, 0.001));
    expect(e.ctl.result.perItemRub, closeTo(2211.84, 0.001));
  });

  test('пустое количество считается как 1', () {
    final e = makeEnv();
    e.ctl.setQty('');
    expect(e.ctl.qty, 1);
  });

  test('выбор категории ставит цену доставки и сбрасывает ручную правку', () {
    final e = makeEnv();
    e.ctl.selectCategory(cat2);
    expect(e.ctl.perKgRub, 900);
    e.ctl.setPerKg('1000');
    expect(e.ctl.perKgEditedManually, true);
    e.ctl.selectCategory(cat1);
    expect(e.ctl.perKgRub, 600);
    expect(e.ctl.perKgEditedManually, false);
  });

  test('авто-курс: ЦБ плюс наценка, ручная правка не перезаписывается', () {
    final e = makeEnv(
      s: AppSettings.defaults().copyWith(rateMode: RateMode.auto, markupPct: 5),
    );
    // курса ЦБ ещё нет, берётся ручной
    expect(e.ctl.rate, AppSettings.defaults().manualRate);

    e.rate.setInfo(RateInfo(cbrValue: 10, fetchedAt: DateTime.now().toUtc()));
    expect(e.ctl.rate, closeTo(10.5, 0.0001));

    e.rate.setInfo(RateInfo(cbrValue: 20, fetchedAt: DateTime.now().toUtc()));
    expect(e.ctl.rate, closeTo(21.0, 0.0001));

    e.ctl.setRate('15');
    expect(e.ctl.rateEditedManually, true);
    e.rate.setInfo(RateInfo(cbrValue: 30, fetchedAt: DateTime.now().toUtc()));
    expect(e.ctl.rate, 15);

    e.ctl.resetRateToDefault();
    expect(e.ctl.rate, closeTo(31.5, 0.0001));
    expect(e.ctl.rateEditedManually, false);
  });

  test('комиссия по умолчанию меняется, пока её не правили руками', () {
    final e = makeEnv();
    e.settings.change(manualSettings().copyWith(defaultCommissionPct: 7));
    expect(e.ctl.commissionPct, 7);

    e.ctl.setCommission('3');
    e.settings.change(manualSettings().copyWith(defaultCommissionPct: 8));
    expect(e.ctl.commissionPct, 3);
  });

  test('удалённая категория заменяется первой из оставшихся', () {
    final e = makeEnv();
    e.cats.change([cat2]);
    expect(e.ctl.category?.id, 2);
    expect(e.ctl.perKgRub, 900);
  });

  test('правка цены категории в настройках подтягивается в калькулятор', () {
    final e = makeEnv();
    e.cats.change([cat1.copyWith(pricePerKg: 650), cat2]);
    expect(e.ctl.perKgRub, 650);
  });

  test('открытие расчёта из истории подставляет значения и блокирует автоматику',
      () {
    const input = CalcInput(
      priceCny: 120,
      qty: 2,
      weightKg: 0.8,
      rate: 13.12,
      commissionPct: 10,
      perKgRub: 600,
      extraRub: 0,
    );
    final saved = Calculation.fromInput(
      input,
      PriceCalculator.calculate(input),
      categoryId: 1,
      categoryName: 'Одежда',
    );

    final e = makeEnv();
    final tickBefore = e.ctl.syncTick;
    e.ctl.loadFrom(saved);
    expect(e.ctl.priceCny, 120);
    expect(e.ctl.qty, 2);
    expect(e.ctl.rate, 13.12);
    expect(e.ctl.rateEditedManually, true);
    expect(e.ctl.syncTick, greaterThan(tickBefore));
    expect(e.ctl.result.totalRub, closeTo(4423.68, 0.001));
  });

  test('сохранение кладёт расчёт в историю, текст для шаринга содержит итог',
      () async {
    final e = makeEnv();
    e.ctl.setPrice('120');
    e.ctl.setQty('2');
    e.ctl.setWeight('0.8');
    final id = await e.ctl.saveCurrent(title: 'Куртка');
    expect(id, 1);
    final saved = e.calcs.saved.single;
    expect(saved.title, 'Куртка');
    expect(saved.categoryName, 'Одежда');
    expect(saved.totalRub, closeTo(4423.68, 0.001));

    final text = e.ctl.shareText();
    expect(text.contains('4 423,68 ₽'), true);
    expect(text.contains('Рассчитано в KITex Calc'), true);
  });

  test('сброс очищает цену и вес и возвращает значения по умолчанию', () {
    final e = makeEnv();
    e.ctl.setPrice('120');
    e.ctl.setWeight('1');
    e.ctl.setRate('99');
    e.ctl.setPerKg('1');
    e.ctl.resetInputs();
    expect(e.ctl.priceCny, 0);
    expect(e.ctl.weightKg, 0);
    expect(e.ctl.rate, 13.12);
    expect(e.ctl.perKgRub, 600);
    expect(e.ctl.rateEditedManually, false);
    expect(e.ctl.perKgEditedManually, false);
  });
}
