import 'package:flutter/material.dart';

import '../../core/app_deps.dart';
import '../../core/app_strings.dart';
import '../../data/models/calculation.dart';
import '../calc/calc_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

/// Нижняя навигация на 3 вкладки. Состояние вкладок сохраняется.
class MainShell extends StatefulWidget {
  final AppDeps deps;
  const MainShell({super.key, required this.deps});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _setTab(int i) => setState(() => _index = i);

  /// Из истории открываем расчёт обратно в калькуляторе.
  void _openCalculation(Calculation c) {
    widget.deps.calcController.loadFrom(c);
    _setTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CalcScreen(controller: deps.calcController),
          HistoryScreen(
            controller: deps.historyController,
            onOpen: _openCalculation,
          ),
          SettingsScreen(controller: deps.settingsController),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: AppStrings.navCalc,
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: AppStrings.navHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
