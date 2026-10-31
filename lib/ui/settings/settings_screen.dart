import 'package:flutter/material.dart';

import '../../core/app_config.dart';
import '../../core/app_strings.dart';
import '../../core/money_format.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/category.dart';
import '../common/kx_button.dart';
import '../common/kx_card.dart';
import '../common/kx_text_field.dart';
import '../common/calc_loader.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'settings_controller.dart';
import 'widgets/category_editor_sheet.dart';
import 'widgets/kitex_links_block.dart';

/// Экран 3. Настройки.
class SettingsScreen extends StatefulWidget {
  final SettingsController controller;
  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _manual;
  late final TextEditingController _markup;
  late final TextEditingController _commission;
  late final TextEditingController _companyName;
  late final TextEditingController _companyContact;

  SettingsController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    final s = c.settings;
    _manual = TextEditingController(text: MoneyFormat.input(s.manualRate));
    _markup = TextEditingController(text: MoneyFormat.input(s.markupPct));
    _commission =
        TextEditingController(text: MoneyFormat.input(s.defaultCommissionPct));
    _companyName = TextEditingController(text: s.companyName);
    _companyContact = TextEditingController(text: s.companyContact);
  }

  @override
  void dispose() {
    _manual.dispose();
    _markup.dispose();
    _commission.dispose();
    _companyName.dispose();
    _companyContact.dispose();
    super.dispose();
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: context.kx.textSecondary),
        ),
      );

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.resetCategoriesTitle,
            style: AppTextStyles.title.copyWith(color: ctx.kx.textPrimary)),
        content: Text(AppStrings.resetCategoriesText,
            style: AppTextStyles.body.copyWith(color: ctx.kx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.reset.toUpperCase()),
          ),
        ],
      ),
    );
    if (ok == true) await c.resetCategories();
  }

  void _editCategory(Category? cat) {
    CategoryEditorSheet.show(
      context,
      initial: cat,
      onSubmit: (name, price) => cat == null
          ? c.addCategory(name, price)
          : c.updateCategory(cat, name, price),
      onDelete: cat == null ? null : () => c.deleteCategory(cat.id!),
    );
  }

  Widget _rateBlock(AppSettings s) {
    final k = context.kx;
    final info = c.rateInfo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<RateMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: RateMode.manual,
              label: Text(AppStrings.modeManual),
            ),
            ButtonSegment(
              value: RateMode.auto,
              label: Text(AppStrings.modeAuto),
            ),
          ],
          selected: {s.rateMode},
          onSelectionChanged: (v) => c.setRateMode(v.first),
        ),
        const SizedBox(height: 16),
        if (s.rateMode == RateMode.manual)
          KxTextField(
            label: AppStrings.fieldRate,
            suffix: '₽',
            controller: _manual,
            errorText: c.errors['manualRate'],
            onChanged: c.setManualRate,
          )
        else ...[
          KxTextField(
            label: AppStrings.markup,
            suffix: '%',
            controller: _markup,
            errorText: c.errors['markup'],
            onChanged: c.setMarkup,
          ),
          const SizedBox(height: 12),
          KxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.cbrRate.toUpperCase(),
                  style: AppTextStyles.label.copyWith(color: k.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  info.hasValue
                      ? '${MoneyFormat.number(info.cbrValue!, decimals: 4)} ₽ за 1 ¥'
                      : AppStrings.cbrNone,
                  style: AppTextStyles.numeric
                      .copyWith(color: k.textPrimary, fontSize: 18),
                ),
                if (info.fetchedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.updatedAt} ${MoneyFormat.dateTime(info.fetchedAt!)}',
                    style:
                        AppTextStyles.caption.copyWith(color: k.textSecondary),
                  ),
                ],
                if (info.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${AppStrings.rateUpdateFailed}: ${info.error}',
                    style:
                        AppTextStyles.caption.copyWith(color: k.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KxButton.outline(
                  label: AppStrings.rateRefresh,
                  icon: Icons.refresh,
                  onPressed: c.isRefreshing ? null : c.refreshRate,
                ),
              ),
              if (c.isRefreshing) ...[
                const SizedBox(width: 16),
                const CalcLoader(size: 34),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _categoriesBlock() {
    final k = context.kx;
    final cats = c.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KxCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < cats.length; i++) ...[
                if (i > 0) const Divider(),
                InkWell(
                  onTap: () => _editCategory(cats[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(cats[i].name,
                              style: AppTextStyles.body
                                  .copyWith(color: k.textPrimary)),
                        ),
                        Text(
                          '${MoneyFormat.input(cats[i].pricePerKg, maxDecimals: 2)} ₽/кг',
                          style: AppTextStyles.numeric
                              .copyWith(color: k.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right,
                            size: 20, color: k.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KxButton.primary(
                label: AppStrings.addCategory,
                icon: Icons.add,
                onPressed: () => _editCategory(null),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KxButton.outline(
                label: AppStrings.resetCategories,
                onPressed: _confirmReset,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settingsTitle.toUpperCase())),
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final s = c.settings;
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              _section(AppStrings.sectionRate),
              _rateBlock(s),
              _section(AppStrings.sectionCommission),
              KxTextField(
                label: AppStrings.defaultCommission,
                suffix: '%',
                controller: _commission,
                errorText: c.errors['commission'],
                onChanged: c.setDefaultCommission,
              ),
              _section(AppStrings.sectionCategories),
              _categoriesBlock(),
              _section(AppStrings.sectionCompany),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  AppStrings.companyHint,
                  style: AppTextStyles.caption
                      .copyWith(color: context.kx.textSecondary),
                ),
              ),
              KxTextField(
                label: AppStrings.companyName,
                numeric: false,
                controller: _companyName,
                onChanged: c.setCompanyName,
              ),
              const SizedBox(height: 12),
              KxTextField(
                label: AppStrings.companyContact,
                numeric: false,
                controller: _companyContact,
                onChanged: c.setCompanyContact,
              ),
              _section(AppStrings.sectionTheme),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(AppStrings.themeDark),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(AppStrings.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(AppStrings.themeSystem),
                  ),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => c.setTheme(v.first),
              ),
              _section(AppStrings.sectionKitex),
              const KitexLinksBlock(links: AppConfig.kitexLinks),
            ],
          );
        },
      ),
    );
  }
}
