import 'package:flutter/material.dart' show ThemeMode;

import '../../core/app_config.dart';

enum RateMode { manual, auto }

/// Все настройки одним объектом.
class AppSettings {
  final RateMode rateMode;
  final double manualRate;
  final double markupPct;
  final double defaultCommissionPct;
  final ThemeMode themeMode;
  final int? lastCategoryId;

  /// Профиль компании: попадает в текст «Поделиться».
  final String companyName;
  final String companyContact;

  const AppSettings({
    required this.rateMode,
    required this.manualRate,
    required this.markupPct,
    required this.defaultCommissionPct,
    required this.themeMode,
    this.lastCategoryId,
    this.companyName = '',
    this.companyContact = '',
  });

  factory AppSettings.defaults() => const AppSettings(
        rateMode: RateMode.auto,
        manualRate: AppConfig.defaultManualRate,
        markupPct: AppConfig.defaultMarkupPct,
        defaultCommissionPct: AppConfig.defaultCommissionPct,
        themeMode: ThemeMode.dark,
        lastCategoryId: null,
      );

  AppSettings copyWith({
    RateMode? rateMode,
    double? manualRate,
    double? markupPct,
    double? defaultCommissionPct,
    ThemeMode? themeMode,
    int? lastCategoryId,
    String? companyName,
    String? companyContact,
    bool clearLastCategory = false,
  }) =>
      AppSettings(
        rateMode: rateMode ?? this.rateMode,
        manualRate: manualRate ?? this.manualRate,
        markupPct: markupPct ?? this.markupPct,
        defaultCommissionPct:
            defaultCommissionPct ?? this.defaultCommissionPct,
        themeMode: themeMode ?? this.themeMode,
        lastCategoryId:
            clearLastCategory ? null : (lastCategoryId ?? this.lastCategoryId),
        companyName: companyName ?? this.companyName,
        companyContact: companyContact ?? this.companyContact,
      );

  /// Собирает объект из пар ключ-значение таблицы settings.
  /// Чего не хватает или что битое, берётся из значений по умолчанию.
  static AppSettings fromMap(Map<String, String> m) {
    final d = AppSettings.defaults();
    return AppSettings(
      rateMode: m['rate_mode'] == 'manual' ? RateMode.manual : RateMode.auto,
      manualRate: double.tryParse(m['manual_rate'] ?? '') ?? d.manualRate,
      markupPct: double.tryParse(m['markup_pct'] ?? '') ?? d.markupPct,
      defaultCommissionPct:
          double.tryParse(m['default_commission_pct'] ?? '') ??
              d.defaultCommissionPct,
      themeMode: _themeFrom(m['theme_mode']) ?? d.themeMode,
      lastCategoryId: int.tryParse(m['last_category_id'] ?? ''),
      companyName: m['company_name'] ?? '',
      companyContact: m['company_contact'] ?? '',
    );
  }

  Map<String, String> toMap() => {
        'rate_mode': rateMode.name,
        'manual_rate': manualRate.toString(),
        'markup_pct': markupPct.toString(),
        'default_commission_pct': defaultCommissionPct.toString(),
        'theme_mode': themeMode.name,
        'last_category_id': lastCategoryId?.toString() ?? '',
        'company_name': companyName,
        'company_contact': companyContact,
      };

  static ThemeMode? _themeFrom(String? s) {
    switch (s) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }
}
