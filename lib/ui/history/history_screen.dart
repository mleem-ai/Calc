import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../data/models/calculation.dart';
import '../common/empty_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'history_controller.dart';
import 'widgets/history_detail_sheet.dart';
import 'widgets/history_tile.dart';

/// Экран 2. История расчётов.
class HistoryScreen extends StatelessWidget {
  final HistoryController controller;
  final void Function(Calculation) onOpen;

  const HistoryScreen({
    super.key,
    required this.controller,
    required this.onOpen,
  });

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.clearConfirmTitle,
            style: AppTextStyles.title.copyWith(color: ctx.kx.textPrimary)),
        content: Text(AppStrings.clearConfirmText,
            style: AppTextStyles.body.copyWith(color: ctx.kx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete.toUpperCase()),
          ),
        ],
      ),
    );
    if (ok == true) await controller.clearAll();
  }

  Future<void> _showDetails(BuildContext context, Calculation item) async {
    final paste = await HistoryDetailSheet.show(context, item);
    if (paste == true) onOpen(item);
  }

  void _onDismissed(BuildContext context, Calculation item) {
    final k = context.kx;
    controller.delete(item);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text(AppStrings.deleted),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        action: SnackBarAction(
          label: AppStrings.undo.toUpperCase(),
          textColor: k.onInverse,
          onPressed: controller.undoDelete,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final k = context.kx;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.items;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.historyTitle.toUpperCase()),
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => _confirmClear(context),
                  child: Text(
                    AppStrings.clearAll.toUpperCase(),
                    style: AppTextStyles.label.copyWith(color: k.textPrimary),
                  ),
                ),
            ],
          ),
          body: controller.isLoading
              ? const SizedBox.shrink()
              : items.isEmpty
                  ? const EmptyState(
                      title: AppStrings.historyEmpty,
                      subtitle: AppStrings.historyEmptyHint,
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _onDismissed(context, item),
                          background: Container(
                            color: k.inverse,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              AppStrings.delete.toUpperCase(),
                              style: AppTextStyles.label
                                  .copyWith(color: k.onInverse),
                            ),
                          ),
                          child: HistoryTile(
                            item: item,
                            onTap: () => _showDetails(context, item),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
