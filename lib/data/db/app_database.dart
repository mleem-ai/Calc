import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/app_config.dart';
import '../models/app_settings.dart';

/// Открывает SQLite, создаёт схему, мигрирует.
class AppDatabase {
  /// Путь к файлу базы. null: стандартное место на устройстве.
  /// В тестах передают inMemoryDatabasePath.
  final String? path;
  AppDatabase({this.path});

  Future<Database>? _opening;

  /// База открывается один раз при первом обращении.
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final target = path ?? p.join(await getDatabasesPath(), AppConfig.dbName);
    return openDatabase(
      target,
      version: AppConfig.dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL UNIQUE,
        price_per_kg REAL    NOT NULL CHECK (price_per_kg >= 0),
        sort_order   INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE calculations (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        title          TEXT,
        created_at     INTEGER NOT NULL,
        price_cny      REAL    NOT NULL,
        qty            INTEGER NOT NULL CHECK (qty >= 1),
        weight_kg      REAL    NOT NULL,
        category_id    INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        category_name  TEXT    NOT NULL,
        rate           REAL    NOT NULL,
        commission_pct REAL    NOT NULL,
        per_kg_rub     REAL    NOT NULL,
        extra_rub      REAL    NOT NULL,
        total_rub      REAL    NOT NULL,
        per_item_rub   REAL    NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_calc_created ON calculations(created_at DESC)');
    await db.execute('''
      CREATE TABLE rate_snapshots (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        currency    TEXT    NOT NULL DEFAULT 'CNY',
        value       REAL    NOT NULL,
        source_date INTEGER,
        fetched_at  INTEGER NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_rate_fetched ON rate_snapshots(fetched_at DESC)');
    await db.execute('''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await _seed(db);
  }

  /// Шаги миграций по версиям. Пока версия одна, шагов нет.
  Future<void> _onUpgrade(Database db, int from, int to) async {
    // if (from < 2) { await db.execute('ALTER TABLE ...'); }
  }

  /// Стартовые категории и настройки по умолчанию.
  Future<void> _seed(Database db) async {
    final batch = db.batch();
    var order = 0;
    AppConfig.defaultCategories.forEach((name, price) {
      batch.insert('categories', {
        'name': name,
        'price_per_kg': price,
        'sort_order': order++,
      });
    });
    AppSettings.defaults().toMap().forEach((k, v) {
      batch.insert('settings', {'key': k, 'value': v});
    });
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    final db = await opening;
    await db.close();
    _opening = null;
  }
}
