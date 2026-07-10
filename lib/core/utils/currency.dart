import 'package:intl/intl.dart';

const String kCurrencySymbol = 'C\$';

final NumberFormat kCurrencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: '$kCurrencySymbol ',
  decimalDigits: 0,
);
