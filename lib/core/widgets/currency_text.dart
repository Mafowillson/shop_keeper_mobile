import 'package:flutter/material.dart';
import 'package:shopkeeper/core/utils/currency_formatter.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;

  const CurrencyText(
    this.amount, {
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatFCFA(amount),
      style: style,
    );
  }
}
