import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/app_config.dart';
import '../db/category_dao.dart';
import '../models/category.dart';

/// Понятная пользователю ошибка (текст можно показать в уведомлении).
class CategoryException implements Exception {
  final String message;
  const CategoryException(this.message);

  @override
  String toString() => message;
}

/// Список категорий в памяти.
class CategoryRepository extends ChangeNotifier {
  final CategoryDao _dao;
  CategoryRepository(this._dao);

  List<Category> _items = const [];

  List<Category> get items => List.unmodifiable(_items);

  Future<void> load() async {
    _items = await _dao.getAll();
    notifyListeners();
  }

  Category? byId(int? id) {
    if (id == null) return null;
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> add(String name, double pricePerKg) async {
    final n = name.trim();
    _validate(n, pricePerKg);
    _ensureUnique(n, exceptId: null);
    await _dao.insert(
        Category(name: n, pricePerKg: pricePerKg, sortOrder: _items.length));
    await load();
  }

  Future<void> update(Category c) async {
    final n = c.name.trim();
    _validate(n, c.pricePerKg);
    _ensureUnique(n, exceptId: c.id);
    await _dao.update(c.copyWith(name: n));
    await load();
  }

  Future<void> remove(int id) async {
    if (_items.length <= 1) {
      throw const CategoryException('Нельзя удалить последнюю категорию');
    }
    await _dao.delete(id);
    final rest = _items.where((c) => c.id != id).map((c) => c.id!).toList();
    await _dao.reorder(rest);
    await load();
  }

  /// Индексы как в ReorderableListView.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [..._items];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _dao.reorder(list.map((c) => c.id!).toList());
    await load();
  }

  /// Возвращает 5 стартовых категорий.
  Future<void> resetToDefaults() async {
    final list = AppConfig.defaultCategories.entries
        .map((e) => Category(name: e.key, pricePerKg: e.value))
        .toList();
    await _dao.replaceAll(list);
    await load();
  }

  void _validate(String name, double price) {
    if (name.isEmpty) {
      throw const CategoryException('Введите название категории');
    }
    if (price.isNaN || price.isInfinite || price < 0) {
      throw const CategoryException('Цена за кг должна быть числом от 0');
    }
  }

  void _ensureUnique(String name, {required int? exceptId}) {
    final lower = name.toLowerCase();
    final exists =
        _items.any((c) => c.id != exceptId && c.name.toLowerCase() == lower);
    if (exists) {
      throw const CategoryException('Такая категория уже есть');
    }
  }
}
