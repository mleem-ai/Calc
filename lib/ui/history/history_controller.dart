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
