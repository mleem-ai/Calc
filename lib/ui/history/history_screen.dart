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

  /// В раскладке для ПК шапку рисует оболочка, своей панели нет.
  final bool embedded;

  const HistoryScreen({
    super.key,
    required this.controller,
    required this.onOpen,
    this.embedded = false,
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
    final action = await HistoryDetailSheet.show(context, item);
    if (!context.mounted) return;
    if (action == HistoryAction.paste) {
      onOpen(item);
    } else if (action == HistoryAction.delete) {
      _onDismissed(context, item);
    }
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
        final items = controller.visibleItems;
        final searching = controller.query.isNotEmpty;
        final clearButton = TextButton(
          onPressed: () => _confirmClear(context),
          child: Text(
            AppStrings.clearAll.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: k.textPrimary),
          ),
        );
        final list = controller.isLoading
            ? const SizedBox.shrink()
            : items.isEmpty
                ? EmptyState(
                    title: searching
                        ? AppStrings.nothingFound
                        : AppStrings.historyEmpty,
                    subtitle: searching
                        ? AppStrings.nothingFoundHint
                        : AppStrings.historyEmptyHint,
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
                  );

        if (embedded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.items.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: clearButton,
                  ),
                ),
              Expanded(child: list),
            ],
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.historyTitle.toUpperCase()),
            actions: [if (controller.items.isNotEmpty) clearButton],
          ),
          body: list,
        );
      },
    );
  }
}
