import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String toCurrency({int decimals = 2}) {
    return NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: decimals,
    ).format(this);
  }

  String toPercentage({int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern('es_MX')
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(this);
  }

  bool get isPositive => this > 0;

  String get formatted => toCurrency();
}

extension NumExtension on num {
  String get ordinal {
    final n = this.toInt();
    if (n >= 11 && n <= 13) return '${n}th';
    if (n % 100 >= 11 && n % 100 <= 13) return '${n % 100}th';
    return '${n}th';
  }
}
