import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// SQL по таблице settings (ключ-значение).
class SettingsDao {
  final AppDatabase _database;
  SettingsDao(this._database);

  Future<Map<String, String>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('settings');
    return {
      for (final r in rows) r['key'] as String: r['value'] as String,
    };
  }

  Future<void> set(String key, String value) async {
    final db = await _database.database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> setMany(Map<String, String> values) async {
    final db = await _database.database;
    final batch = db.batch();
    values.forEach((k, v) {
      batch.insert('settings', {'key': k, 'value': v},
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }
}
