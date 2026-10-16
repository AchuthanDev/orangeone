import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/features/products/presentation/widgets/mock_discount_dialog.dart';

void main() {
  testWidgets('mock editor validates and returns local preview values', (
    tester,
  ) async {
    MockDiscount? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showDialog<MockDiscount>(
                  context: context,
                  builder: (context) => const MockDiscountDialog(
                    initial: (name: 'Offer', percent: '20'),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final percent = find.widgetWithText(TextFormField, 'Discount percent');
    await tester.enterText(percent, '200');
    await tester.tap(find.text('Apply mock discount'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a percentage from 0 to 100.'), findsOneWidget);
    expect(result, isNull);
    await tester.enterText(percent, '15');
    await tester.tap(find.text('Apply mock discount'));
    await tester.pumpAndSettle();
    expect(result, (name: 'Offer', percent: '15'));
    expect(tester.takeException(), isNull);
  });
}
