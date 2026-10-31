import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kitex_calc/data/remote/cbr_api.dart';

const _okBody =
    '{"Date":"2026-10-21T11:30:00+03:00","Valute":{"CNY":{"Nominal":1,"Value":11.2345}}}';

void main() {
  test('успешный ответ даёт курс и дату', () async {
    final api = CbrApi(MockClient((_) async => http.Response(_okBody, 200)));
    final r = await api.fetchCnyRate();
    expect(r.valuePerOne, closeTo(11.2345, 0.00001));
    expect(r.date, isNotNull);
    expect(r.date!.toUtc().hour, 8); // 11:30 по Москве = 08:30 UTC
  });

  test('номинал делит значение', () async {
    const body =
        '{"Date":"2026-10-21T11:30:00+03:00","Valute":{"CNY":{"Nominal":10,"Value":112.0}}}';
    final api = CbrApi(MockClient((_) async => http.Response(body, 200)));
    final r = await api.fetchCnyRate();
    expect(r.valuePerOne, closeTo(11.2, 0.00001));
  });

  test('статус не 200 даёт ошибку http', () async {
    final api = CbrApi(MockClient((_) async => http.Response('oops', 500)));
    expect(
      api.fetchCnyRate(),
      throwsA(isA<RateFetchException>()
          .having((e) => e.kind, 'kind', RateFetchKind.http)),
    );
  });

  test('битый JSON даёт ошибку parse', () async {
    final api = CbrApi(MockClient((_) async => http.Response('not json', 200)));
    expect(
      api.fetchCnyRate(),
      throwsA(isA<RateFetchException>()
          .having((e) => e.kind, 'kind', RateFetchKind.parse)),
    );
  });

  test('нет юаня в ответе даёт ошибку parse', () async {
    const body = '{"Date":"2026-10-21T11:30:00+03:00","Valute":{}}';
    final api = CbrApi(MockClient((_) async => http.Response(body, 200)));
    expect(
      api.fetchCnyRate(),
      throwsA(isA<RateFetchException>()
          .having((e) => e.kind, 'kind', RateFetchKind.parse)),
    );
  });

  test('нет сети даёт ошибку network', () async {
    final api = CbrApi(MockClient((_) async {
      throw http.ClientException('no internet');
    }));
    expect(
      api.fetchCnyRate(),
      throwsA(isA<RateFetchException>()
          .having((e) => e.kind, 'kind', RateFetchKind.network)),
    );
  });
}
