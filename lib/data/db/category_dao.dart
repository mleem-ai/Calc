import '../models/category.dart';
import 'app_database.dart';

/// SQL по таблице categories.
class CategoryDao {
  final AppDatabase _database;
  CategoryDao(this._database);

  Future<List<Category>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('categories', orderBy: 'sort_order, id');
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query('categories',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Category.fromMap(rows.first);
  }

  /// Возвращает id новой записи.
  Future<int> insert(Category c) async {
    final db = await _database.database;
    return db.insert('categories', c.toMap());
  }

  Future<void> update(Category c) async {
    final db = await _database.database;
    await db.update('categories', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }

  /// Расчёты остаются, у них category_id станет NULL.
  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  /// Проставляет sort_order по порядку списка id.
  Future<void> reorder(List<int> idsInOrder) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (var i = 0; i < idsInOrder.length; i++) {
        await txn.update('categories', {'sort_order': i},
            where: 'id = ?', whereArgs: [idsInOrder[i]]);
      }
    });
  }

  /// Полная замена списка (сброс к стартовым значениям).
  Future<void> replaceAll(List<Category> list) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete('categories');
      for (var i = 0; i < list.length; i++) {
        await txn.insert('categories', list[i].copyWith(sortOrder: i).toMap());
      }
    });
  }
}
