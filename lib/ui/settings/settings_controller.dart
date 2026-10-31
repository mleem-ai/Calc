import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/app_strings.dart';
import '../../core/number_parser.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/category.dart';
import '../../data/models/rate_info.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/rate_repository.dart';
import '../../data/repositories/settings_repository.dart';

/// Состояние экрана настроек.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required this.settingsRepo,
    required this.categoryRepo,
    required this.rateRepo,
  }) {
    settingsRepo.addListener(_relay);
    categoryRepo.addListener(_relay);
    rateRepo.addListener(_relay);
  }

  final SettingsRepository settingsRepo;
  final CategoryRepository categoryRepo;
  final RateRepository rateRepo;

  /// Ошибки проверки полей по имени: manualRate, markup, commission.
  final Map<String, String> errors = {};

  AppSettings get settings => settingsRepo.current;
  List<Category> get categories => categoryRepo.items;
  RateInfo get rateInfo => rateRepo.info;
  bool get isRefreshing => rateRepo.isRefreshing;

  void _relay() => notifyListeners();

  @override
  void dispose() {
    settingsRepo.removeListener(_relay);
    categoryRepo.removeListener(_relay);
    rateRepo.removeListener(_relay);
    super.dispose();
  }

  Future<void> setRateMode(RateMode m) async {
    await settingsRepo.update(settings.copyWith(rateMode: m));
    if (m == RateMode.auto) await rateRepo.refreshIfStale();
  }

  Future<void> setManualRate(String s) async {
    final v = NumberParser.parse(s);
    if (v <= 0) return _fail('manualRate', AppStrings.errPositive);
    errors.remove('manualRate');
    await settingsRepo.update(settings.copyWith(manualRate: v));
  }

  Future<void> setMarkup(String s) async {
    final v = NumberParser.parse(s);
    if (v < 0 || v > 100) return _fail('markup', AppStrings.errPercent);
    errors.remove('markup');
    await settingsRepo.update(settings.copyWith(markupPct: v));
  }

  Future<void> setDefaultCommission(String s) async {
    final v = NumberParser.parse(s);
    if (v < 0 || v > 100) return _fail('commission', AppStrings.errPercent);
    errors.remove('commission');
    await settingsRepo.update(settings.copyWith(defaultCommissionPct: v));
  }

  Future<void> setCompanyName(String s) =>
      settingsRepo.update(settings.copyWith(companyName: s.trim()));

  Future<void> setCompanyContact(String s) =>
      settingsRepo.update(settings.copyWith(companyContact: s.trim()));

  Future<void> setTheme(ThemeMode m) =>
      settingsRepo.update(settings.copyWith(themeMode: m));

  Future<void> refreshRate() => rateRepo.refresh();

  // Категории. Методы возвращают текст ошибки или null, если всё хорошо.

  Future<String?> addCategory(String name, String price) =>
      _guard(() => categoryRepo.add(name, NumberParser.parse(price)));

  Future<String?> updateCategory(Category c, String name, String price) =>
      _guard(() => categoryRepo.update(
          c.copyWith(name: name, pricePerKg: NumberParser.parse(price))));

  Future<String?> deleteCategory(int id) =>
      _guard(() => categoryRepo.remove(id));

  Future<void> resetCategories() => categoryRepo.resetToDefaults();

  void _fail(String key, String message) {
    errors[key] = message;
    notifyListeners();
  }

  Future<String?> _guard(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on CategoryException catch (e) {
      return e.message;
    } catch (_) {
      return AppStrings.errGeneric;
    }
  }
}
