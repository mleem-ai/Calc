import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/app_deps.dart';
import '../../core/app_strings.dart';
import '../../core/money_format.dart';
import '../../data/models/calculation.dart';
import '../calc/calc_screen.dart';
import '../common/calc_mark.dart';
import '../common/kx_card.dart';
import '../common/kx_toast.dart';
import '../history/history_screen.dart';
import '../history/widgets/history_detail_sheet.dart';
import '../settings/settings_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Раскладка для ПК в духе веб-кабинета банка:
/// слева колонка с брендом, справа вкладки-«таблетки», поиск и большая карточка.
class DesktopShell extends StatefulWidget {
  final AppDeps deps;
  const DesktopShell({super.key, required this.deps});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _index = 0;
  final _search = TextEditingController();

  AppDeps get d => widget.deps;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setTab(int i) => setState(() => _index = i);

  void _openCalculation(Calculation c) {
    d.calcController.loadFrom(c);
    _setTab(0);
  }

  void _newCalc() {
    d.calcController.resetInputs();
    _setTab(0);
  }

  void _onSearch(String q) {
    d.historyController.setQuery(q);
    if (_index != 1) _setTab(1);
  }

  Future<void> _recentTap(Calculation c) async {
    final action = await HistoryDetailSheet.show(context, c);
    if (!mounted) return;
    if (action == HistoryAction.paste) {
      _openCalculation(c);
    } else if (action == HistoryAction.delete) {
      d.historyController.delete(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    return Scaffold(
      backgroundColor: k.bg,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 300,
              child: _Sidebar(
                deps: d,
                onRecentTap: _recentTap,
                onOpenHistory: () => _setTab(1),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    index: _index,
                    onTab: _setTab,
                    search: _search,
                    onSearch: _onSearch,
                    onNew: _newCalc,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: KxCard(
                      padding: const EdgeInsets.all(28),
                      child: IndexedStack(
                        index: _index,
                        children: [
                          CalcScreen(
                              controller: d.calcController, embedded: true),
                          HistoryScreen(
                            controller: d.historyController,
                            onOpen: _openCalculation,
                            embedded: true,
                          ),
                          SettingsScreen(
                              controller: d.settingsController, embedded: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вкладки-«таблетки», поиск и кнопка «Новый».
class _TopBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTab;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final VoidCallback onNew;

  const _TopBar({
    required this.index,
    required this.onTab,
    required this.search,
    required this.onSearch,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    const labels = [
      AppStrings.navCalc,
      AppStrings.navHistory,
      AppStrings.navSettings,
    ];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          _Pill(
            label: labels[i],
            selected: i == index,
            onTap: () => onTab(i),
          ),
          const SizedBox(width: 8),
        ],
        const Spacer(),
        SizedBox(
          width: 260,
          height: 44,
          child: TextField(
            controller: search,
            onChanged: onSearch,
            style: AppTextStyles.body.copyWith(color: k.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: Icon(Icons.search, color: k.textSecondary, size: 20),
              contentPadding: EdgeInsets.zero,
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close, size: 18, color: k.textSecondary),
                      onPressed: () {
                        search.clear();
                        onSearch('');
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 44,
          child: FilledButton.icon(
            onPressed: onNew,
            icon: const Icon(Icons.add, size: 20),
            label: Text(AppStrings.newCalc.toUpperCase()),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    return Material(
      color: selected ? k.inverse : k.card,
      shape: StadiumBorder(side: BorderSide(color: k.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: selected ? k.onInverse : k.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Левая колонка: бренд, курс, тарифы, последние расчёты, сообщества.
class _Sidebar extends StatelessWidget {
  final AppDeps deps;
  final Future<void> Function(Calculation) onRecentTap;
  final VoidCallback onOpenHistory;

  const _Sidebar({
    required this.deps,
    required this.onRecentTap,
    required this.onOpenHistory,
  });

  Future<void> _open(BuildContext context, KitexLink l) async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(l.url),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok && context.mounted) KxToast.show(context, AppStrings.linkFailed);
  }

  Widget _label(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          t.toUpperCase(),
          style:
              AppTextStyles.label.copyWith(color: context.kx.textSecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    final calc = deps.calcController;
    final settings = deps.settingsController;
    final history = deps.historyController;

    return ListenableBuilder(
      listenable: Listenable.merge([calc, settings, history]),
      builder: (context, _) {
        final company = settings.settings.companyName;
        final recent = history.items.take(4).toList();
        return ListView(
          children: [
            KxCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CalcMark(height: 44),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConfig.appName,
                          style: AppTextStyles.title
                              .copyWith(color: k.textPrimary),
                        ),
                        if (company.isNotEmpty)
                          Text(
                            company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption
                                .copyWith(color: k.textSecondary),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, AppStrings.sidebarRate),
                  Text(
                    '${MoneyFormat.number(calc.rate, decimals: 4)} ₽ / ¥',
                    style: AppTextStyles.numeric
                        .copyWith(color: k.textPrimary, fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calc.rateCaption,
                    style: AppTextStyles.caption
                        .copyWith(color: k.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, AppStrings.sidebarTariffs),
                  for (final c in settings.categories)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(c.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body
                                    .copyWith(color: k.textPrimary)),
                          ),
                          Text(
                            '${MoneyFormat.input(c.pricePerKg, maxDecimals: 2)} ₽',
                            style: AppTextStyles.numeric.copyWith(
                                color: k.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KxCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, AppStrings.sidebarRecent),
                  if (recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(AppStrings.sidebarEmpty,
                          style: AppTextStyles.caption
                              .copyWith(color: k.textSecondary)),
                    ),
                  for (final c in recent)
                    InkWell(
                      onTap: () => onRecentTap(c),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(c.displayTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body
                                      .copyWith(color: k.textPrimary)),
                            ),
                            Text(
                              MoneyFormat.rub(c.totalRub),
                              style: AppTextStyles.numeric.copyWith(
                                  color: k.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onOpenHistory,
                      child: Text(AppStrings.navHistory.toUpperCase()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            KxCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(context, AppStrings.sidebarCommunities),
                  for (final l in AppConfig.kitexLinks)
                    InkWell(
                      onTap: () => _open(context, l),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(l.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body
                                      .copyWith(color: k.textPrimary)),
                            ),
                            Icon(Icons.north_east,
                                size: 16, color: k.textSecondary),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
