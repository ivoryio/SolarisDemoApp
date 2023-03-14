import 'package:flutter/material.dart';

import 'text_currency_value.dart';

class TransactionListItem extends StatelessWidget {
  final String vendor;
  final String date;
  final double amount;

  const TransactionListItem(
      {super.key,
      required this.vendor,
      required this.date,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          const Icon(Icons.article, size: 40),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vendor,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(date),
          ]),
        ],
      ),
      TextCurrencyValue(value: amount)
    ]);
  }
}
