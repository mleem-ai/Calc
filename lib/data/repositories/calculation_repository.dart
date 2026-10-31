import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../db/calculation_dao.dart';
import '../models/calculation.dart';

/// Сохранённые расчёты.
class CalculationRepository extends ChangeNotifier {
  final CalculationDao _dao;
  CalculationRepository(this._dao);

  /// Новые сверху, не больше лимита истории.
  Future<List<Calculation>> getAll() =>
      _dao.getAll(limit: AppConfig.historyLimit);

  /// Сохраняет и возвращает запись уже с id.
  Future<Calculation> save(Calculation c) async {
    final id = await _dao.insert(c);
    await _dao.trimToLimit(AppConfig.historyLimit);
    notifyListeners();
    return c.withId(id);
  }

  Future<void> delete(int id) async {
    await _dao.delete(id);
    notifyListeners();
  }

  /// Возвращает удалённую запись (кнопка «Отменить»).
  Future<void> restore(Calculation c) async {
    await _dao.insert(c);
    await _dao.trimToLimit(AppConfig.historyLimit);
    notifyListeners();
  }

  Future<void> clear() async {
    await _dao.deleteAll();
    notifyListeners();
  }
}
