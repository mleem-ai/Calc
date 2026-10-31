import 'package:flutter/material.dart';

import '../../../core/app_strings.dart';
import '../../../core/money_format.dart';
import '../../../data/models/category.dart';
import '../../common/kx_button.dart';
import '../../common/kx_text_field.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Нижняя шторка добавления и правки категории.
class CategoryEditorSheet extends StatefulWidget {
  final Category? initial;
  final Future<String?> Function(String name, String price) onSubmit;
  final Future<String?> Function()? onDelete;

  const CategoryEditorSheet({
    super.key,
    this.initial,
    required this.onSubmit,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    Category? initial,
    required Future<String?> Function(String name, String price) onSubmit,
    Future<String?> Function()? onDelete,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CategoryEditorSheet(
        initial: initial,
        onSubmit: onSubmit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i?.name ?? '');
    _price = TextEditingController(
        text: i == null ? '' : MoneyFormat.input(i.pricePerKg, maxDecimals: 2));
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String?> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await action();
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.kx;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.editCategory.toUpperCase(),
              style: AppTextStyles.label.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 16),
            KxTextField(
              label: AppStrings.categoryName,
              controller: _name,
              numeric: false,
            ),
            const SizedBox(height: 12),
            KxTextField(
              label: AppStrings.categoryPrice,
              suffix: '₽/кг',
              controller: _price,
              errorText: _error,
            ),
            const SizedBox(height: 20),
            KxButton.primary(
              label: AppStrings.save,
              onPressed: _busy
                  ? null
                  : () => _run(() => widget.onSubmit(_name.text, _price.text)),
            ),
            if (widget.onDelete != null) ...[
              const SizedBox(height: 12),
              KxButton.outline(
                label: AppStrings.delete,
                icon: Icons.delete_outline,
                onPressed: _busy ? null : () => _run(widget.onDelete!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
