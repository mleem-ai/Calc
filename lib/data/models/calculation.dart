import '../../domain/calc_input.dart';
import '../../domain/calc_result.dart';

/// Сохранённый расчёт: снимок входных данных и итог.
class Calculation {
  final int? id;
  final String? title;
  final DateTime createdAt; // UTC
  final double priceCny;
  final int qty;
  final double weightKg;
  final int? categoryId;
  final String categoryName;
  final double rate;
  final double commissionPct;
  final double perKgRub;
  final double extraRub;
  final double totalRub;
  final double perItemRub;

  const Calculation({
    this.id,
    this.title,
    required this.createdAt,
    required this.priceCny,
    required this.qty,
    required this.weightKg,
    this.categoryId,
    required this.categoryName,
    required this.rate,
    required this.commissionPct,
    required this.perKgRub,
    required this.extraRub,
    required this.totalRub,
    required this.perItemRub,
  });

  factory Calculation.fromInput(
    CalcInput i,
    CalcResult r, {
    int? categoryId,
    required String categoryName,
    String? title,
  }) =>
      Calculation(
        title: title,
        createdAt: DateTime.now().toUtc(),
        priceCny: i.priceCny,
        qty: i.qty,
        weightKg: i.weightKg,
        categoryId: categoryId,
        categoryName: categoryName,
        rate: i.rate,
        commissionPct: i.commissionPct,
        perKgRub: i.perKgRub,
        extraRub: i.extraRub,
        totalRub: r.totalRub,
        perItemRub: r.perItemRub,
      );

  /// Копия записи с присвоенным id (после вставки в базу).
  Calculation withId(int newId) => Calculation(
        id: newId,
        title: title,
        createdAt: createdAt,
        priceCny: priceCny,
        qty: qty,
        weightKg: weightKg,
        categoryId: categoryId,
        categoryName: categoryName,
        rate: rate,
        commissionPct: commissionPct,
        perKgRub: perKgRub,
        extraRub: extraRub,
        totalRub: totalRub,
        perItemRub: perItemRub,
      );

  CalcInput toInput() => CalcInput(
        priceCny: priceCny,
        qty: qty,
        weightKg: weightKg,
        rate: rate,
        commissionPct: commissionPct,
        perKgRub: perKgRub,
        extraRub: extraRub,
      );

  /// Название, а если его нет, то дата вида «21.10, 11:25».
  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final d = createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}, ${two(d.hour)}:${two(d.minute)}';
  }

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'created_at': createdAt.millisecondsSinceEpoch,
        'price_cny': priceCny,
        'qty': qty,
        'weight_kg': weightKg,
        'category_id': categoryId,
        'category_name': categoryName,
        'rate': rate,
        'commission_pct': commissionPct,
        'per_kg_rub': perKgRub,
        'extra_rub': extraRub,
        'total_rub': totalRub,
        'per_item_rub': perItemRub,
      };

  factory Calculation.fromMap(Map<String, Object?> m) => Calculation(
        id: m['id'] as int?,
        title: m['title'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            m['created_at'] as int,
            isUtc: true),
        priceCny: (m['price_cny'] as num).toDouble(),
        qty: m['qty'] as int,
        weightKg: (m['weight_kg'] as num).toDouble(),
        categoryId: m['category_id'] as int?,
        categoryName: m['category_name'] as String,
        rate: (m['rate'] as num).toDouble(),
        commissionPct: (m['commission_pct'] as num).toDouble(),
        perKgRub: (m['per_kg_rub'] as num).toDouble(),
        extraRub: (m['extra_rub'] as num).toDouble(),
        totalRub: (m['total_rub'] as num).toDouble(),
        perItemRub: (m['per_item_rub'] as num).toDouble(),
      );
}
