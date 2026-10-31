import 'calc_input.dart';
import 'calc_result.dart';

/// Единственное место, где живут формулы.
class PriceCalculator {
  static double _safe(double v) => (v.isNaN || v.isInfinite) ? 0 : v;

  static CalcResult calculate(CalcInput i) {
    final qty = i.qty < 1 ? 1 : i.qty;
    final goods = _safe(i.priceCny * qty * i.rate);
    final commission = _safe(goods * i.commissionPct / 100);
    final delivery = _safe(i.weightKg * qty * i.perKgRub);
    final extra = _safe(i.extraRub);
    final total = goods + commission + delivery + extra;
    return CalcResult(
      goodsRub: goods,
      commissionRub: commission,
      deliveryRub: delivery,
      extraRub: extra,
      totalRub: total,
      perItemRub: total / qty,
    );
  }

  /// Курс ЦБ с наценкой посредника.
  static double effectiveRate(double cbr, double markupPct) =>
      cbr * (1 + markupPct / 100);
}
