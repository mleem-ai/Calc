/// Курс юаня, полученный от ЦБ (без наценки).
class RateSnapshot {
  final int? id;
  final String currency;
  final double value; // рублей за 1 единицу валюты
  final DateTime? sourceDate; // дата курса из ответа ЦБ
  final DateTime fetchedAt; // когда получили, UTC

  const RateSnapshot({
    this.id,
    this.currency = 'CNY',
    required this.value,
    this.sourceDate,
    required this.fetchedAt,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'currency': currency,
        'value': value,
        'source_date': sourceDate?.millisecondsSinceEpoch,
        'fetched_at': fetchedAt.millisecondsSinceEpoch,
      };

  factory RateSnapshot.fromMap(Map<String, Object?> m) => RateSnapshot(
        id: m['id'] as int?,
        currency: m['currency'] as String,
        value: (m['value'] as num).toDouble(),
        sourceDate: m['source_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['source_date'] as int,
                isUtc: true),
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(
            m['fetched_at'] as int,
            isUtc: true),
      );
}
