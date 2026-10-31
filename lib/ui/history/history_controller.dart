import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../data/models/calculation.dart';
import '../../data/repositories/calculation_repository.dart';

/// Состояние экрана истории.
class HistoryController extends ChangeNotifier {
  HistoryController(this._repo);

  final CalculationRepository _repo;

  List<Calculation> items = const [];
  bool isLoading = true;
  Calculation? lastDeleted;

  String _query = '';
  String get query => _query;

  /// Строка поиска: ищем по названию и категории.
  void setQuery(String q) {
    final v = q.trim().toLowerCase();
    if (v == _query) return;
    _query = v;
    notifyListeners();
  }

  /// То, что показываем на экране с учётом поиска.
  List<Calculation> get visibleItems => _query.isEmpty
      ? items
      : items
          .where((c) =>
              c.displayTitle.toLowerCase().contains(_query) ||
              c.categoryName.toLowerCase().contains(_query))
          .toList();

  void init() {
    _repo.addListener(load);
    load();
  }

  @override
  void dispose() {
    _repo.removeListener(load);
    super.dispose();
  }

  Future<void> load() async {
    items = await _repo.getAll();
    isLoading = false;
    notifyListeners();
  }

  /// Сначала убираем из списка (этого требует Dismissible), потом из базы.
  Future<void> delete(Calculation c) async {
    final id = c.id;
    if (id == null) return;
    items = items.where((e) => e.id != id).toList();
    lastDeleted = c;
    notifyListeners();
    await _repo.delete(id);
  }

  Future<void> undoDelete() async {
    final c = lastDeleted;
    if (c == null) return;
    lastDeleted = null;
    await _repo.restore(c);
  }

  Future<void> clearAll() async {
    lastDeleted = null;
    await _repo.clear();
  }
}
