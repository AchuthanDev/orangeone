import 'package:flutter/material.dart';
import 'package:orange_one/features/products/domain/use_cases/update_product_price.dart';

class PriceChangeDialog extends StatefulWidget {
  const new({required this.confirmation, super.key});
  final PriceChangeConfirmation confirmation;
  @override
  State<PriceChangeDialog> createState() => _PriceChangeDialogState();
}

class _PriceChangeDialogState extends State<PriceChangeDialog> {
  bool _answered = false;
  void _answer(bool accepted) {
    if (_answered) return;
    setState(() => _answered = true);
    Navigator.pop(context, accepted);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Confirm price update'),
    content: Text(
      '${widget.confirmation.product.name}\n\n'
      'Current price: '
      'CHF ${widget.confirmation.product.price.toStringAsFixed(2)}\n'
      'New price: CHF ${widget.confirmation.price.formatted}\n\n'
      'Save this product price to Odoo?',
    ),
    actions: [
      TextButton(
        onPressed: _answered ? null : () => _answer(false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _answered ? null : () => _answer(true),
        child: const Text('Confirm update'),
      ),
    ],
  );
}
