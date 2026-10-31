/// Результат расчёта без округления.
class CalcResult {
  final double goodsRub;
  final double commissionRub;
  final double deliveryRub;
  final double extraRub;
  final double totalRub;
  final double perItemRub;

  const CalcResult({
    required this.goodsRub,
    required this.commissionRub,
    required this.deliveryRub,
    required this.extraRub,
    required this.totalRub,
    required this.perItemRub,
  });
}
