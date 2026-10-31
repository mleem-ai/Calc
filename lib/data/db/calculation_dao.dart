import 'package:sqflite/sqflite.dart';

import '../models/calculation.dart';
import 'app_database.dart';

/// SQL по таблице calculations.
class CalculationDao {
  final AppDatabase _database;
  CalculationDao(this._database);

  /// Новые сверху.
  Future<List<Calculation>> getAll({int limit = 100, int offset = 0}) async {
    final db = await _database.database;
    final rows = await db.query(
      'calculations',
      orderBy: 'created_at DESC, id DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(Calculation.fromMap).toList();
  }

  Future<Calculation?> getById(int id) async {
    final db = await _database.database;
    final rows = await db.query('calculations',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : Calculation.fromMap(rows.first);
  }

  /// Возвращает id новой записи.
  Future<int> insert(Calculation c) async {
    final db = await _database.database;
    return db.insert('calculations', c.toMap());
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete('calculations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _database.database;
    await db.delete('calculations');
  }

  Future<int> count() async {
    final db = await _database.database;
    final r = await db.rawQuery('SELECT COUNT(*) FROM calculations');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// Удаляет самые старые записи, если их больше [limit].
  Future<void> trimToLimit(int limit) async {
    final db = await _database.database;
    await db.rawDelete('''
      DELETE FROM calculations WHERE id NOT IN (
        SELECT id FROM calculations ORDER BY created_at DESC, id DESC LIMIT ?
      )
    ''', [limit]);
  }
}
