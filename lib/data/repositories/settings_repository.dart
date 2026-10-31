import 'package:flutter/foundation.dart';

import '../db/settings_dao.dart';
import '../models/app_settings.dart';

/// Настройки в памяти и в базе.
class SettingsRepository extends ChangeNotifier {
  final SettingsDao _dao;
  SettingsRepository(this._dao);

  AppSettings _current = AppSettings.defaults();

  /// Актуальные настройки, читаются синхронно.
  AppSettings get current => _current;

  Future<void> init() async {
    _current = AppSettings.fromMap(await _dao.getAll());
  }

  Future<void> update(AppSettings s) async {
    await _dao.setMany(s.toMap());
    _current = s;
    notifyListeners();
  }

  /// Точечное обновление без уведомления подписчиков.
  Future<void> setLastCategory(int? id) async {
    await _dao.set('last_category_id', id?.toString() ?? '');
    _current = _current.copyWith(
      lastCategoryId: id,
      clearLastCategory: id == null,
    );
  }
}
