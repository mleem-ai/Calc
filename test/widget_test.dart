import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/ui/common/kx_button.dart';
import 'package:kitex_calc/ui/common/kx_text_field.dart';
import 'package:kitex_calc/ui/theme/app_colors.dart';
import 'package:kitex_calc/ui/theme/app_theme.dart';

void main() {
  for (final entry in {
    'тёмной': AppTheme.dark(),
    'светлой': AppTheme.light(),
  }.entries) {
    testWidgets('поле и кнопки строятся в ${entry.key} теме', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: entry.value,
          home: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const KxTextField(label: 'Цена', suffix: '¥'),
                KxButton.primary(label: 'Сохранить', onPressed: () {}),
                KxButton.outline(label: 'Сброс', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      expect(find.text('ЦЕНА'), findsOneWidget);
      expect(find.text('СОХРАНИТЬ'), findsOneWidget);
      expect(find.text('СБРОС'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('цвета тем: тёмная чёрная, светлая белая', () {
    expect(AppTheme.dark().extension<KxColors>()!.bg, const Color(0xFF000000));
    expect(AppTheme.light().extension<KxColors>()!.bg, const Color(0xFFFFFFFF));
  });

  testWidgets('в поле можно ввести только числа', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: KxTextField(label: 'Цена', controller: controller),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'ab12,5x');
    expect(controller.text, '12,5');
  });
}
