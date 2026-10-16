import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orange_one/features/home/domain/use_cases/lookup_product.dart';

/// Task 05 handoff: product creation and its approved form are a later task.
class AddProductStartPage extends StatelessWidget {
  const new({required this.barcode, super.key});
  final String? barcode;

  @override
  Widget build(BuildContext context) {
    String? validated;
    try {
      validated = LookupProduct.validate(barcode ?? '');
    } on FormatException {
      validated = null;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (validated == null)
              const Text('A valid product barcode is required.')
            else ...[
              TextFormField(
                initialValue: validated,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product name'),
                maxLength: 200,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Reference (optional)',
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Draft only. Saving products will be available '
                'in a later task.',
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.goNamed('productScanner'),
              child: const Text('Return to scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
