import 'package:flutter_test/flutter_test.dart';
import 'package:kitex_calc/data/models/rate_info.dart';

void main() {
  const ttl = Duration(hours: 12);

  test('без курса считается устаревшим', () {
    expect(const RateInfo().hasValue, false);
    expect(const RateInfo().isStale(ttl), true);
  });

  test('свежий курс не устарел, старый устарел', () {
    final fresh = RateInfo(
        cbrValue: 11.2,
        fetchedAt: DateTime.now().toUtc().subtract(const Duration(hours: 1)));
    final old = RateInfo(
        cbrValue: 11.2,
        fetchedAt: DateTime.now().toUtc().subtract(const Duration(hours: 13)));
    expect(fresh.isStale(ttl), false);
    expect(old.isStale(ttl), true);
  });

  test('withError оставляет сохранённый курс', () {
    final info = RateInfo(cbrValue: 11.2, fetchedAt: DateTime.now().toUtc());
    final e = info.withError('нет сети');
    expect(e.cbrValue, 11.2);
    expect(e.error, 'нет сети');
    expect(e.fromCache, true);
  });
}
