import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_strings.dart';
import '../../core/money_format.dart';
import '../../core/number_parser.dart';
import '../../core/platform_info.dart';
import '../../data/models/category.dart';
import '../common/kitex_logo.dart';
import '../common/kx_button.dart';
import '../common/kx_text_field.dart';
import '../common/kx_toast.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'calc_controller.dart';
import 'widgets/rate_bar.dart';
import 'widgets/result_card.dart';

/// Экран 1. Калькулятор. Только отображение, вся логика в CalcController.
class CalcScreen extends StatefulWidget {
  final CalcController controller;

  /// В раскладке для ПК: без своей панели, поля слева, чек справа.
  final bool embedded;

  const CalcScreen({super.key, required this.controller, this.embedded = false});

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _weight = TextEditingController();
  final _rate = TextEditingController();
  final _commission = TextEditingController();
  final _perKg = TextEditingController();
  final _extra = TextEditingController(text: '0');
  int _lastTick = -1;

  CalcController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _syncFields();
    _lastTick = c.syncTick;
    c.addListener(_onController);
  }

  @override
  void dispose() {
    c.removeListener(_onController);
    for (final t in [_price, _qty, _weight, _rate, _commission, _perKg, _extra]) {
      t.dispose();
    }
    super.dispose();
  }

  void _onController() {
    if (_lastTick != c.syncTick) {
      _lastTick = c.syncTick;
      _syncFields();
    }
  }

  /// Переписывает текст в полях только там, где значение реально изменилось,
  /// чтобы не сбивать ввод пользователя.
  void _syncFields() {
    _setNum(_price, c.priceCny, blankZero: true);
    if (NumberParser.parseInt(_qty.text) != c.qty) _qty.text = '${c.qty}';
    _setNum(_weight, c.weightKg, blankZero: true);
    _setNum(_rate, c.rate);
    _setNum(_commission, c.commissionPct);
    _setNum(_perKg, c.perKgRub);
    _setNum(_extra, c.extraRub);
  }

  void _setNum(TextEditingController t, double v, {bool blankZero = false}) {
    if (NumberParser.parse(t.text) != v) {
      t.text = (blankZero && v == 0) ? '' : MoneyFormat.input(v);
    }
  }

  Future<void> _onSave() async {
    if (c.priceCny <= 0) {
      KxToast.show(context, AppStrings.enterPrice);
      return;
    }
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _TitleDialog(),
    );
    if (title == null || !mounted) return;
    final t = title.trim();
    await c.saveCurrent(title: t.isEmpty ? null : t);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    KxToast.show(context, AppStrings.saved);
  }

  Future<void> _onRefreshRate() async {
    await c.refreshRate();
    if (!mounted) return;
    if (c.rateInfo.error != null) {
      KxToast.show(context, AppStrings.rateFailedToast);
    }
  }

  Future<void> _onShare() async {
    if (c.priceCny <= 0) {
      KxToast.show(context, AppStrings.enterPrice);
      return;
    }
    if (isDesktopPlatform) {
      await Clipboard.setData(ClipboardData(text: c.shareText()));
      if (!mounted) return;
      KxToast.show(context, AppStrings.copied);
      return;
    }
    await SharePlus.instance.share(ShareParams(text: c.shareText()));
  }

  Future<void> _pickCategory() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final k = ctx.kx;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  AppStrings.chooseCategory.toUpperCase(),
                  style: AppTextStyles.label.copyWith(color: k.textSecondary),
                ),
              ),
              for (final cat in c.categories)
                ListTile(
                  title: Text(cat.name, style: AppTextStyles.body),
                  subtitle: Text(
                    '${MoneyFormat.input(cat.pricePerKg, maxDecimals: 2)} ₽/кг',
                    style: AppTextStyles.numeric
                        .copyWith(fontSize: 13, color: k.textSecondary),
                  ),
                  trailing: cat.id == c.category?.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    c.selectCategory(cat);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _inputFields() => [
        KxTextField(
          label: AppStrings.fieldPrice,
          suffix: '¥',
          controller: _price,
          onChanged: c.setPrice,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldQty,
                integerOnly: true,
                controller: _qty,
                onChanged: c.setQty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldWeight,
                suffix: 'кг',
                controller: _weight,
                onChanged: c.setWeight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _CategoryField(category: c.category, onTap: _pickCategory),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldRate,
                controller: _rate,
                onChanged: c.setRate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldCommission,
                suffix: '%',
                controller: _commission,
                onChanged: c.setCommission,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldDelivery,
                suffix: '₽/кг',
                controller: _perKg,
                onChanged: c.setPerKg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KxTextField(
                label: AppStrings.fieldExtra,
                suffix: '₽',
                controller: _extra,
                onChanged: c.setExtra,
              ),
            ),
          ],
        ),
      ];

  List<Widget> _resultBlock() => [
        ResultCard(result: c.result),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: KxButton.primary(
                label: AppStrings.save,
                icon: Icons.bookmark_add_outlined,
                onPressed: _onSave,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KxButton.outline(
                label: AppStrings.share,
                icon: isDesktopPlatform ? Icons.copy : Icons.ios_share,
                onPressed: _onShare,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RateBar(
          caption: c.rateCaption,
          isLoading: c.isRefreshingRate,
          canReset: c.rateEditedManually,
          showRefresh: c.isAutoRate,
          onRefresh: _onRefreshRate,
          onReset: c.resetRateToDefault,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return ListenableBuilder(
        listenable: c,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _inputFields(),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _resultBlock(),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            KitexLogo(size: 30),
            SizedBox(width: 10),
            Text('KITEX CALC'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.reset,
            onPressed: c.resetInputs,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) => ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ..._inputFields(),
            const SizedBox(height: 20),
            ..._resultBlock(),
          ],
        ),
      ),
    );
  }
}

/// Поле выбора категории: открывает список снизу.
class _CategoryField extends StatelessWidget {
  final Category? category;
  final VoidCallback onTap;
  const _CategoryField({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            AppStrings.fieldCategory.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: k.textSecondary),
          ),
        ),
        Material(
          color: k.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: k.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category?.name ?? '—',
                        style: AppTextStyles.body
                            .copyWith(color: k.textPrimary, fontSize: 17),
                      ),
                    ),
                    Icon(Icons.expand_more, color: k.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Диалог ввода названия перед сохранением расчёта.
class _TitleDialog extends StatefulWidget {
  const _TitleDialog();

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _ctl = TextEditingController();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.saveDialogTitle,
          style: AppTextStyles.title.copyWith(color: context.kx.textPrimary)),
      content: KxTextField(
        label: AppStrings.saveDialogLabel,
        controller: _ctl,
        numeric: false,
        textInputAction: TextInputAction.done,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctl.text),
          child: Text(AppStrings.save.toUpperCase()),
        ),
      ],
    );
  }
}
