import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';

enum RateFetchKind { network, timeout, http, parse }

/// Ошибка получения курса.
class RateFetchException implements Exception {
  final RateFetchKind kind;
  final String message;
  const RateFetchException(this.kind, this.message);

  @override
  String toString() => 'RateFetchException($kind): $message';
}

/// Ответ ЦБ в виде, удобном приложению.
class CbrRate {
  final double valuePerOne; // Value / Nominal
  final DateTime? date;
  const CbrRate({required this.valuePerOne, this.date});
}

/// Единственный сетевой класс приложения.
class CbrApi {
  final http.Client _client;

  /// [client] можно подменить в тестах.
  CbrApi([http.Client? client]) : _client = client ?? http.Client();

  Future<CbrRate> fetchCnyRate() async {
    final http.Response res;
    try {
      res = await _client
          .get(Uri.parse(AppConfig.cbrUrl))
          .timeout(AppConfig.httpTimeout);
    } on TimeoutException {
      throw const RateFetchException(
          RateFetchKind.timeout, 'Превышено время ожидания');
    } catch (e) {
      throw RateFetchException(RateFetchKind.network, e.toString());
    }

    if (res.statusCode != 200) {
      throw RateFetchException(RateFetchKind.http, 'HTTP ${res.statusCode}');
    }

    try {
      final json =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final valute = json['Valute'] as Map<String, dynamic>;
      final cny = valute['CNY'] as Map<String, dynamic>;
      final value = (cny['Value'] as num).toDouble();
      final nominal = (cny['Nominal'] as num).toDouble();
      if (value <= 0 || nominal <= 0) {
        throw const FormatException('Неверные значения курса');
      }
      final dateStr = json['Date'] as String?;
      return CbrRate(
        valuePerOne: value / nominal,
        date: dateStr == null ? null : DateTime.tryParse(dateStr)?.toUtc(),
      );
    } catch (_) {
      throw const RateFetchException(
          RateFetchKind.parse, 'Не удалось разобрать ответ ЦБ');
    }
  }

  void close() => _client.close();
}
