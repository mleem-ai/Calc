import 'package:flutter/foundation.dart';

import '../../core/app_config.dart';
import '../db/rate_dao.dart';
import '../models/rate_info.dart';
import '../models/rate_snapshot.dart';
import '../remote/cbr_api.dart';

/// Курс юаня: кэш в базе и обновление из сети.
class RateRepository extends ChangeNotifier {
  final RateDao _dao;
  final CbrApi _api;
  RateRepository(this._dao, this._api);

  RateInfo _info = const RateInfo();
  bool _isRefreshing = false;

  RateInfo get info => _info;
  bool get isRefreshing => _isRefreshing;

  /// Подгружает последний сохранённый курс.
  Future<void> init() async {
    final s = await _dao.getLatest('CNY');
    if (s != null) {
      _info = RateInfo(
        cbrValue: s.value,
        sourceDate: s.sourceDate,
        fetchedAt: s.fetchedAt,
        fromCache: true,
      );
    }
    notifyListeners();
  }

  /// Запрос в ЦБ. При ошибке остаётся старый курс, в info.error текст.
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      final r = await _api.fetchCnyRate();
      final snap = RateSnapshot(
        value: r.valuePerOne,
        sourceDate: r.date,
        fetchedAt: DateTime.now().toUtc(),
      );
      _info = RateInfo(
        cbrValue: snap.value,
        sourceDate: snap.sourceDate,
        fetchedAt: snap.fetchedAt,
        fromCache: false,
      );
      try {
        await _dao.insert(snap);
        await _dao.trim(AppConfig.rateSnapshotsKeep);
      } catch (_) {
        // курс уже получен и показан, сбой записи в кэш не критичен
      }
    } on RateFetchException catch (e) {
      _info = _info.withError(e.message);
    } catch (e) {
      _info = _info.withError(e.toString());
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Обновляет только если курса нет или он старше 12 часов.
  Future<void> refreshIfStale() async {
    if (_info.isStale(AppConfig.rateTtl)) {
      await refresh();
    }
  }
}
