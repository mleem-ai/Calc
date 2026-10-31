/// Состояние курса для интерфейса: что показываем и откуда.
class RateInfo {
  final double? cbrValue; // курс ЦБ без наценки
  final DateTime? sourceDate;
  final DateTime? fetchedAt;
  final bool fromCache;
  final String? error;

  const RateInfo({
    this.cbrValue,
    this.sourceDate,
    this.fetchedAt,
    this.fromCache = false,
    this.error,
  });

  bool get hasValue => cbrValue != null;

  /// true, если курса нет или он старше [ttl].
  bool isStale(Duration ttl) {
    final f = fetchedAt;
    if (cbrValue == null || f == null) return true;
    return DateTime.now().toUtc().difference(f) > ttl;
  }

  /// То же состояние, но с текстом ошибки. Сохранённый курс остаётся.
  RateInfo withError(String message) => RateInfo(
        cbrValue: cbrValue,
        sourceDate: sourceDate,
        fetchedAt: fetchedAt,
        fromCache: cbrValue != null,
        error: message,
      );
}
