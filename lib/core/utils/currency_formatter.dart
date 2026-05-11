import 'package:intl/intl.dart';

String formatFCFA(double amount) {
  return '${NumberFormat('#,##0', 'fr_FR').format(amount)} FCFA';
}

String formatCurrency(double amount) => formatFCFA(amount);
