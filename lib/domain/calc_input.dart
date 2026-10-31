/// Всё, что нужно для расчёта.
class CalcInput {
  final double priceCny;
  final int qty;
  final double weightKg;
  final double rate;
  final double commissionPct;
  final double perKgRub;
  final double extraRub;

  const CalcInput({
    required this.priceCny,
    required this.qty,
    required this.weightKg,
    required this.rate,
    required this.commissionPct,
    required this.perKgRub,
    required this.extraRub,
  });
}
