import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/features/products/domain/entities/product_details.dart';
import 'package:orange_one/features/products/domain/repositories/product_details_repository.dart';
import 'package:orange_one/features/products/presentation/providers/product_details_providers.dart';

import '../../support/product_details_fakes.dart';

void main() {
  test(
    'an obsolete refresh cannot replace a new session repository result',
    () async {
      var repo = FakeDetailsRepository();
      final dependency = Provider<ProductDetailsRepository>((ref) => repo);
      final container = ProviderContainer.test(
        overrides: [
          productDetailsRepositoryProvider.overrideWith(
            (ref) => ref.watch(dependency),
          ),
        ],
      );
      final provider = productDetailsControllerProvider('0010101010');
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final pending = Completer<ProductDetailsState>();
      repo.pending = pending;
      final obsolete = container.read(provider.notifier).refresh();
      repo = FakeDetailsRepository()..product = null;
      container.invalidate(dependency);
      await container.read(provider.future);
      pending.complete(
        const ProductDetailsState(detailsFixture, ProductAccess()),
      );
      await obsolete;
      expect(container.read(provider).requireValue.product, isNull);
    },
  );
}
