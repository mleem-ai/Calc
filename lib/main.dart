import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'core/app_deps.dart';
import 'core/platform_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (needsSqliteFfi) {
    // Windows и Linux: SQLite через ffi, база лежит в папке данных приложения.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getApplicationSupportDirectory();
    await databaseFactory.setDatabasesPath(dir.path);
  }

  if (!isDesktopPlatform) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  final deps = await AppDeps.create();
  runApp(KitexCalcApp(deps: deps));
}
