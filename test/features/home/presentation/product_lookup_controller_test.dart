import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/features/home/domain/entities/product.dart';
import 'package:orange_one/features/home/presentation/providers/product_providers.dart';

import '../../../support/product_fakes.dart';

void main() {
  late FakeProductRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = FakeProductRepository();
    container = ProviderContainer.test(
      overrides: [productRepositoryProvider.overrideWithValue(repository)],
    )..listen(productLookupControllerProvider, (previous, next) {});
  });

  test('explicit idle/loading/found state preserves leading zeros', () async {
    expect(container.read(productLookupControllerProvider).value, isNull);
    repository.pending = Completer<Product?>();
    final operation = container
        .read(productLookupControllerProvider.notifier)
        .scan(' 0010101010 ');
    expect(container.read(productLookupControllerProvider).isLoading, isTrue);
    expect(repository.barcodes, ['0010101010']);
    repository.pending!.complete(fixtureProduct);
    await operation;
    expect(
      container.read(productLookupControllerProvider).value?.product,
      fixtureProduct,
    );
  });
  test(
    'suppresses concurrent scans and repeated code until explicit rescan',
    () async {
      repository.pending = Completer<Product?>();
      final controller = container.read(
        productLookupControllerProvider.notifier,
      );
      final operation = controller.scan('0010101010');
      await controller.scan('different');
      repository.pending!.complete(fixtureProduct);
      await operation;
      await controller.scan('0010101010');
      expect(repository.barcodes.length, 1);
      controller.scanAgain();
      await controller.scan('0010101010');
      expect(repository.barcodes.length, 2);
    },
  );
  test('missing product is a successful lookup with no match', () async {
    repository.product = null;
    await container
        .read(productLookupControllerProvider.notifier)
        .scan('unknown');
    final state = container.read(productLookupControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.value?.barcode, 'unknown');
    expect(state.value?.product, isNull);
  });
  for (final raw in ['', '   ', 'x\u0000y', List.filled(257, 'x').join()]) {
    test(
      'invalid input never calls repository (${raw.length} chars)',
      () async {
        await container
            .read(productLookupControllerProvider.notifier)
            .scan(raw);
        expect(repository.barcodes, isEmpty);
        expect(
          container.read(productLookupControllerProvider).error,
          isA<AppFailure>(),
        );
      },
    );
  }
  test('only recoverable read failures offer retry', () async {
    repository.failure = const AppFailure(FailureKind.network, 'Offline');
    final controller = container.read(productLookupControllerProvider.notifier);
    await controller.scan('0010101010');
    expect(repository.barcodes.length, 1);
    repository.failure = null;
    await controller.retry();
    expect(repository.barcodes.length, 2);
    expect(container.read(productLookupControllerProvider).hasError, isFalse);
    controller.scanAgain();
    repository.failure = const AppFailure(
      FailureKind.forbidden,
      'No permission',
    );
    await controller.scan('0010101010');
    await controller.retry();
    expect(repository.barcodes.length, 3);
  });
  test('dependency replacement ignores an obsolete pending lookup', () async {
    repository.pending = Completer<Product?>();
    final operation = container
        .read(productLookupControllerProvider.notifier)
        .scan('0010101010');
    final replacement = FakeProductRepository()..product = null;
    container.updateOverrides([
      productRepositoryProvider.overrideWithValue(replacement),
    ]);
    await container.pump();
    repository.pending!.complete(fixtureProduct);
    await operation;
    expect(container.read(productLookupControllerProvider).value, isNull);
  });
  test('disposal ignores a pending lookup result', () async {
    repository.pending = Completer<Product?>();
    final operation = container
        .read(productLookupControllerProvider.notifier)
        .scan('0010101010');
    container.dispose();
    repository.pending!.complete(fixtureProduct);
    await operation;
  });
}
