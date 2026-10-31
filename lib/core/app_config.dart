/// Ссылка на сообщество KITex для блока в настройках.
class KitexLink {
  final String title;
  final String url;
  const KitexLink(this.title, this.url);
}

/// Все константы приложения в одном месте.
class AppConfig {
  static const String appName = 'KITex Calc';
  static const String appVersion = 'KITex Calc v1.0.0';
  static const String dbName = 'kitex_calc.db';
  static const int dbVersion = 1;

  static const String cbrUrl = 'https://www.cbr-xml-daily.ru/daily_json.js';
  static const Duration httpTimeout = Duration(seconds: 8);
  static const Duration rateTtl = Duration(hours: 12);

  static const int rateSnapshotsKeep = 30;
  static const int historyLimit = 100;

  static const double defaultManualRate = 12.5;
  static const double defaultMarkupPct = 5.0;
  static const double defaultCommissionPct = 10.0;

  /// Стартовые категории и цена доставки за кг (примеры, меняются в настройках).
  static const Map<String, double> defaultCategories = {
    'Одежда': 600,
    'Обувь': 700,
    'Электроника': 900,
    'Аксессуары': 700,
    'Другое': 650,
  };

  static const String shareFooter = 'Рассчитано в KITex Calc';
  static const String shareSeparator = '➖➖➖➖➖';

  /// Сообщества KITex. Впиши реальные ссылки на 4 сообщества, например:
  /// KitexLink('KITex | Товары из Китая', 'https://t.me/ИМЯ_СООБЩЕСТВА'),
  /// KitexLink('KITex Новости', 'https://t.me/ИМЯ_СООБЩЕСТВА'),
  /// KitexLink('KITex Ассортимент', 'https://t.me/ИМЯ_СООБЩЕСТВА'),
  /// KitexLink('KITex Цены', 'https://t.me/ИМЯ_СООБЩЕСТВА'),
  /// KitexLink('Написать Майку', 'https://t.me/KITex_Mickey'),
  static const List<KitexLink> kitexLinks = [];
}
