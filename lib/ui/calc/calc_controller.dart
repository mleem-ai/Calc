import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/app_config.dart';
import '../../core/app_strings.dart';
import '../../core/money_format.dart';
import '../../core/number_parser.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/calculation.dart';
import '../../data/models/category.dart';
import '../../data/models/rate_info.dart';
import '../../data/repositories/calculation_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/rate_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/calc_input.dart';
import '../../domain/calc_result.dart';
import '../../domain/price_calculator.dart';

/// Состояние и логика главного экрана.
class CalcController extends ChangeNotifier {
  CalcController({
    required this.settingsRepo,
    required this.categoryRepo,
    required this.calculationRepo,
    required this.rateRepo,
  });

  final SettingsRepository settingsRepo;
  final CategoryRepository categoryRepo;
  final CalculationRepository calculationRepo;
  final RateRepository rateRepo;

  double priceCny = 0;
  int qty = 1;
  double weightKg = 0;
  double rate = 0;
  double commissionPct = 0;
  double perKgRub = 0;
  double extraRub = 0;
  Category? category;

  /// Если пользователь правил поле сам, автоматика его не перезаписывает.
  bool rateEditedManually = false;
  bool perKgEditedManually = false;
  bool commissionEditedManually = false;

  CalcResult result = const CalcResult(
    goodsRub: 0,
    commissionRub: 0,
    deliveryRub: 0,
    extraRub: 0,
    totalRub: 0,
    perItemRub: 0,
  );

  /// Растёт, когда поля на экране нужно перезаписать программно.
  int syncTick = 0;

  List<Category> get categories => categoryRepo.items;
  RateInfo get rateInfo => rateRepo.info;
  bool get isRefreshingRate => rateRepo.isRefreshing;
  bool get isAutoRate => settingsRepo.current.rateMode == RateMode.auto;

  void init() {
    final s = settingsRepo.current;
    category = categoryRepo.byId(s.lastCategoryId) ?? _firstCategory();
    perKgRub = category?.pricePerKg ?? 0;
    commissionPct = s.defaultCommissionPct;
    rate = _resolveRate();

    settingsRepo.addListener(_onDepsChanged);
    categoryRepo.addListener(_onDepsChanged);
    rateRepo.addListener(_onDepsChanged);

    _recalculate(sync: true);
    if (s.rateMode == RateMode.auto) {
      unawaited(rateRepo.refreshIfStale());
    }
  }

  @override
  void dispose() {
    settingsRepo.removeListener(_onDepsChanged);
    categoryRepo.removeListener(_onDepsChanged);
    rateRepo.removeListener(_onDepsChanged);
    super.dispose();
  }

  // ---------- ввод ----------

  void setPrice(String s) {
    priceCny = NumberParser.parse(s);
    _recalculate();
  }

  void setQty(String s) {
    qty = NumberParser.parseInt(s);
    _recalculate();
  }

  void setWeight(String s) {
    weightKg = NumberParser.parse(s);
    _recalculate();
  }

  void setRate(String s) {
    rate = NumberParser.parse(s);
    rateEditedManually = true;
    _recalculate();
  }

  void setCommission(String s) {
    commissionPct = NumberParser.parse(s);
    commissionEditedManually = true;
    _recalculate();
  }

  void setPerKg(String s) {
    perKgRub = NumberParser.parse(s);
    perKgEditedManually = true;
    _recalculate();
  }

  void setExtra(String s) {
    extraRub = NumberParser.parse(s);
    _recalculate();
  }

  /// Выбор категории подставляет её цену доставки за кг.
  void selectCategory(Category c) {
    category = c;
    perKgEditedManually = false;
    perKgRub = c.pricePerKg;
    unawaited(settingsRepo.setLastCategory(c.id));
    _recalculate(sync: true);
  }

  void resetRateToDefault() {
    rateEditedManually = false;
    rate = _resolveRate();
    _recalculate(sync: true);
  }

  /// Очищает цену и вес, остальное возвращает к значениям по умолчанию.
  void resetInputs() {
    priceCny = 0;
    weightKg = 0;
    qty = 1;
    extraRub = 0;
    rateEditedManually = false;
    perKgEditedManually = false;
    commissionEditedManually = false;
    rate = _resolveRate();
    commissionPct = settingsRepo.current.defaultCommissionPct;
    perKgRub = category?.pricePerKg ?? 0;
    _recalculate(sync: true);
  }

  /// Открывает сохранённый расчёт из истории.
  void loadFrom(Calculation c) {
    priceCny = c.priceCny;
    qty = c.qty < 1 ? 1 : c.qty;
    weightKg = c.weightKg;
    rate = c.rate;
    commissionPct = c.commissionPct;
    perKgRub = c.perKgRub;
    extraRub = c.extraRub;
    category = categoryRepo.byId(c.categoryId) ?? category ?? _firstCategory();
    rateEditedManually = true;
    perKgEditedManually = true;
    commissionEditedManually = true;
    _recalculate(sync: true);
  }

  Future<void> refreshRate() => rateRepo.refresh();

  // ---------- сохранение и шаринг ----------

  CalcInput _input() => CalcInput(
        priceCny: priceCny,
        qty: qty,
        weightKg: weightKg,
        rate: rate,
        commissionPct: commissionPct,
        perKgRub: perKgRub,
        extraRub: extraRub,
      );

  /// Сохраняет текущий расчёт в историю. Возвращает id записи.
  Future<int> saveCurrent({String? title}) async {
    final cat = category;
    final calc = Calculation.fromInput(
      _input(),
      result,
      categoryId: cat?.id,
      categoryName: cat?.name ?? '',
      title: title,
    );
    final saved = await calculationRepo.save(calc);
    return saved.id ?? 0;
  }

  /// Текст для «Поделиться».
  String shareText() {
    final r = result;
    final cat = category?.name;
    final b = StringBuffer()
      ..writeln(_shareTitle)
      ..writeln(
          '${MoneyFormat.cny(priceCny)} × $qty ${AppStrings.pcs}${cat == null || cat.isEmpty ? '' : ', $cat'}')
      ..writeln('${AppStrings.fieldRate}: ${MoneyFormat.input(rate)}')
      ..writeln()
      ..writeln('${AppStrings.goods}: ${MoneyFormat.rub(r.goodsRub)}')
      ..writeln(
          '${AppStrings.commission} (${MoneyFormat.input(commissionPct, maxDecimals: 2)}%): ${MoneyFormat.rub(r.commissionRub)}')
      ..writeln('${AppStrings.delivery}: ${MoneyFormat.rub(r.deliveryRub)}');
    if (r.extraRub > 0) {
      b.writeln('${AppStrings.extra}: ${MoneyFormat.rub(r.extraRub)}');
    }
    b
      ..writeln()
      ..writeln('${AppStrings.total}: ${MoneyFormat.rub(r.totalRub)}')
      ..writeln('${AppStrings.perItem}: ${MoneyFormat.rub(r.perItemRub)}')
      ..writeln();
    final contact = settingsRepo.current.companyContact;
    if (contact.isNotEmpty) b.writeln(contact);
    b
      ..writeln(AppConfig.shareSeparator)
      ..write(AppConfig.shareFooter);
    return b.toString();
  }

  /// Заголовок для «Поделиться»: название компании или название приложения.
  String get _shareTitle {
    final n = settingsRepo.current.companyName;
    return n.isEmpty ? AppConfig.appName : n;
  }

  /// Подпись под результатом: откуда курс и на какое время.
  String get rateCaption {
    final s = settingsRepo.current;
    final info = rateRepo.info;
    if (rateEditedManually) return AppStrings.rateEdited;
    if (s.rateMode == RateMode.manual) return AppStrings.rateManual;
    if (!info.hasValue) return AppStrings.rateUnavailable;
    final at = info.fetchedAt;
    final when = at == null ? '' : ' на ${MoneyFormat.dateTime(at)}';
    final markup = MoneyFormat.input(s.markupPct, maxDecimals: 1);
    final base = '${AppStrings.cbrRate}$when · +$markup%';
    return info.error != null ? '$base · ${AppStrings.rateNotUpdated}' : base;
  }

  // ---------- внутреннее ----------

  Category? _firstCategory() {
    final items = categoryRepo.items;
    return items.isEmpty ? null : items.first;
  }

  double _round4(double v) => (v * 10000).round() / 10000;

  double _resolveRate() {
    final s = settingsRepo.current;
    final info = rateRepo.info;
    if (s.rateMode == RateMode.auto && info.hasValue) {
      return _round4(
          PriceCalculator.effectiveRate(info.cbrValue!, s.markupPct));
    }
    return s.manualRate;
  }

  void _onDepsChanged() {
    final fresh = categoryRepo.byId(category?.id) ?? _firstCategory();
    category = fresh;
    if (fresh != null && !perKgEditedManually) perKgRub = fresh.pricePerKg;
    if (!rateEditedManually) rate = _resolveRate();
    if (!commissionEditedManually) {
      commissionPct = settingsRepo.current.defaultCommissionPct;
    }
    _recalculate(sync: true);
  }

  void _recalculate({bool sync = false}) {
    result = PriceCalculator.calculate(_input());
    if (sync) syncTick++;
    notifyListeners();
  }
}
