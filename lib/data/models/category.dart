/// Категория товара и цена доставки за кг.
class Category {
  final int? id;
  final String name;
  final double pricePerKg;
  final int sortOrder;

  const Category({
    this.id,
    required this.name,
    required this.pricePerKg,
    this.sortOrder = 0,
  });

  Category copyWith({
    int? id,
    String? name,
    double? pricePerKg,
    int? sortOrder,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        pricePerKg: pricePerKg ?? this.pricePerKg,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'price_per_kg': pricePerKg,
        'sort_order': sortOrder,
      };

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as int?,
        name: m['name'] as String,
        pricePerKg: (m['price_per_kg'] as num).toDouble(),
        sortOrder: (m['sort_order'] as int?) ?? 0,
      );
}
