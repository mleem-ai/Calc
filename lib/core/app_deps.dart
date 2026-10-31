import '../data/db/app_database.dart';
import '../data/db/calculation_dao.dart';
import '../data/db/category_dao.dart';
import '../data/db/rate_dao.dart';
import '../data/db/settings_dao.dart';
import '../data/remote/cbr_api.dart';
import '../data/repositories/calculation_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/rate_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../ui/calc/calc_controller.dart';
import '../ui/history/history_controller.dart';
import '../ui/settings/settings_controller.dart';

/// Собирает всё приложение один раз при запуске и раздаёт зависимости.
class AppDeps {
  final AppDatabase db;
  final CbrApi cbrApi;
  final SettingsRepository settingsRepo;
  final CategoryRepository categoryRepo;
  final CalculationRepository calculationRepo;
  final RateRepository rateRepo;
  final CalcController calcController;
  final HistoryController historyController;
  final SettingsController settingsController;

  AppDeps._({
    required this.db,
    required this.cbrApi,
    required this.settingsRepo,
    required this.categoryRepo,
    required this.calculationRepo,
    required this.rateRepo,
    required this.calcController,
    required this.historyController,
    required this.settingsController,
  });

  static Future<AppDeps> create() async {
    final db = AppDatabase();
    final api = CbrApi();
    final settingsRepo = SettingsRepository(SettingsDao(db));
    final categoryRepo = CategoryRepository(CategoryDao(db));
    final calculationRepo = CalculationRepository(CalculationDao(db));
    final rateRepo = RateRepository(RateDao(db), api);

    await Future.wait([
      settingsRepo.init(),
      categoryRepo.load(),
      rateRepo.init(),
    ]);

    final calc = CalcController(
      settingsRepo: settingsRepo,
      categoryRepo: categoryRepo,
      calculationRepo: calculationRepo,
      rateRepo: rateRepo,
    )..init();
    final history = HistoryController(calculationRepo)..init();
    final settings = SettingsController(
      settingsRepo: settingsRepo,
      categoryRepo: categoryRepo,
      rateRepo: rateRepo,
    );

    return AppDeps._(
      db: db,
      cbrApi: api,
      settingsRepo: settingsRepo,
      categoryRepo: categoryRepo,
      calculationRepo: calculationRepo,
      rateRepo: rateRepo,
      calcController: calc,
      historyController: history,
      settingsController: settings,
    );
  }

  Future<void> dispose() async {
    calcController.dispose();
    historyController.dispose();
    settingsController.dispose();
    settingsRepo.dispose();
    categoryRepo.dispose();
    calculationRepo.dispose();
    rateRepo.dispose();
    cbrApi.close();
    await db.close();
  }
}
