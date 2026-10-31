import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'core/app_deps.dart';
import 'ui/shell/main_shell.dart';
import 'ui/splash/calc_splash.dart';
import 'ui/theme/app_theme.dart';

/// Корень приложения. Тема берётся из настроек и меняется на лету.
class KitexCalcApp extends StatelessWidget {
  final AppDeps deps;
  const KitexCalcApp({super.key, required this.deps});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: deps.settingsRepo,
      builder: (context, _) => MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: deps.settingsRepo.current.themeMode,
        home: _Root(deps: deps),
      ),
    );
  }
}

/// Сначала анимированная заставка, затем плавный переход на основной экран.
class _Root extends StatefulWidget {
  final AppDeps deps;
  const _Root({required this.deps});

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _ready
          ? MainShell(key: const ValueKey('main'), deps: widget.deps)
          : CalcSplash(
              key: const ValueKey('splash'),
              onDone: () => setState(() => _ready = true),
            ),
    );
  }
}
