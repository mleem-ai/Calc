import '../models/rate_snapshot.dart';
import 'app_database.dart';

/// SQL по таблице rate_snapshots.
class RateDao {
  final AppDatabase _database;
  RateDao(this._database);

  /// Самый свежий снимок по валюте.
  Future<RateSnapshot?> getLatest(String currency) async {
    final db = await _database.database;
    final rows = await db.query(
      'rate_snapshots',
      where: 'currency = ?',
      whereArgs: [currency],
      orderBy: 'fetched_at DESC, id DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : RateSnapshot.fromMap(rows.first);
  }

  Future<void> insert(RateSnapshot s) async {
    final db = await _database.database;
    await db.insert('rate_snapshots', s.toMap());
  }

  /// Оставляет [keep] последних записей.
  Future<void> trim(int keep) async {
    final db = await _database.database;
    await db.rawDelete('''
      DELETE FROM rate_snapshots WHERE id NOT IN (
        SELECT id FROM rate_snapshots ORDER BY fetched_at DESC, id DESC LIMIT ?
      )
    ''', [keep]);
  }
}
