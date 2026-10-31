// Проверяет, что профиль компании попадает в «Поделиться».
// Использует те же фейки, что и calc_controller_test.dart.
import 'package:flutter_test/flutter_test.dart' show expect, test;

import 'calc_controller_test.dart' show makeEnv, manualSettings;

void main() {
  test('без профиля заголовок KITex Calc, внизу разделитель и подпись', () {
    final e = makeEnv();
    e.ctl.setPrice('120');
    final t = e.ctl.shareText();
    expect(t.startsWith('KITex Calc'), true);
    expect(t.contains('➖➖➖➖➖'), true);
    expect(t.trimRight().endsWith('Рассчитано в KITex Calc'), true);
  });

  test('с профилем: название компании сверху, контакт над подписью', () {
    final e = makeEnv(
      s: manualSettings()
          .copyWith(companyName: 'Карго Восток', companyContact: '@cargo_vostok'),
    );
    e.ctl.setPrice('120');
    final t = e.ctl.shareText();
    expect(t.startsWith('Карго Восток'), true);
    expect(t.contains('@cargo_vostok'), true);
    expect(t.trimRight().endsWith('Рассчитано в KITex Calc'), true);
  });
}
