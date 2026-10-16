import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/features/products/presentation/pages/product_details_page.dart';
import 'package:orange_one/features/products/presentation/providers/product_details_providers.dart';

import '../../support/product_details_fakes.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('details fits $size with enlarged text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productDetailsRepositoryProvider.overrideWithValue(
              FakeDetailsRepository(),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: const ProductDetailsPage(barcode: '0010101010'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final headerPosition = tester.getTopLeft(find.text('Product'));
      final pricePosition = tester.getTopLeft(find.text('Update Price'));
      final stockPosition = tester.getTopLeft(find.text('Update Stock'));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Update Price')), pricePosition);
      expect(tester.getTopLeft(find.text('Update Stock')), stockPosition);
      expect(find.text('Update Price').hitTestable(), findsOneWidget);
      expect(tester.getTopLeft(find.text('Product')), headerPosition);
      expect(find.byTooltip('Back to scanner').hitTestable(), findsOneWidget);
      expect(find.byTooltip('Edit product name').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
