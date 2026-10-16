import 'package:flutter/material.dart';
import 'package:orange_one/features/products/domain/entities/product_tax.dart';
import 'package:orange_one/shared/theme/orange_theme.dart';

class ProductTaxChoice {
  const new(this.id);
  final int? id;
}

/// Selection is explicit: dismissing never clears an existing tax assignment.
class ProductTaxSheet extends StatelessWidget {
  const new({required this.taxes, required this.selectedIds, super.key});
  final List<ProductTax> taxes;
  final List<int>? selectedIds;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Select Tax',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Close tax selection',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if ((selectedIds?.length ?? 0) > 1)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Multiple taxes are currently assigned. Selecting '
                'an option replaces all of them.',
              ),
            ),
          _option(context, null, 'No Tax', selectedIds?.isEmpty ?? false),
          for (final tax in taxes)
            _option(
              context,
              tax.id,
              tax.label,
              selectedIds?.length == 1 && selectedIds!.contains(tax.id),
            ),
        ],
      ),
    ),
  );

  Widget _option(BuildContext context, int? id, String label, bool selected) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF202124),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xFFDADCE0)),
          ),
          onPressed: () => Navigator.pop(context, ProductTaxChoice(id)),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              const SizedBox(width: 12),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? OrangeTheme.scannerAccent
                    : const Color(0xFFDADCE0),
              ),
            ],
          ),
        ),
      );
}
