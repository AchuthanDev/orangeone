import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/config/app_environment.dart';
import 'package:orange_one/core/config/environment_loader.dart';
import 'package:orange_one/features/initialization/presentation/providers/initialization_controller.dart';

void main() {
  test('transitions from loading to injected data', () async {
    final pending = Completer<AppEnvironment>();
    final states = <AsyncValue<AppEnvironment>>[];
    final container =
        ProviderContainer.test(
          overrides: [
            environmentLoaderProvider.overrideWithValue(() => pending.future),
          ],
        )..listen(
          initializationControllerProvider,
          (previous, next) => states.add(next),
          fireImmediately: true,
        );

    expect(states.single, isA<AsyncLoading<AppEnvironment>>());
    pending.complete(AppEnvironment.staging);
    expect(
      await container.read(initializationControllerProvider.future),
      AppEnvironment.staging,
    );
    expect(states.last, const AsyncData(AppEnvironment.staging));
  });

  test('exposes failure and retries only when requested', () async {
    final pending = Completer<AppEnvironment>();
    final recovery = Completer<AppEnvironment>();
    final failure = StateError('configuration unavailable');
    var calls = 0;
    final container = ProviderContainer.test(
      overrides: [
        environmentLoaderProvider.overrideWithValue(() {
          calls++;
          return calls == 1 ? pending.future : recovery.future;
        }),
      ],
    )..listen(initializationControllerProvider, (previous, next) {});
    final failedLoad = expectLater(
      container.read(initializationControllerProvider.future),
      throwsA(same(failure)),
    );
    pending.completeError(failure);
    await failedLoad;
    await container.pump();

    expect(
      container.read(initializationControllerProvider).error,
      same(failure),
    );
    expect(calls, 1);
    container.read(initializationControllerProvider.notifier).retry();
    expect(container.read(initializationControllerProvider).isLoading, isTrue);
    container.read(initializationControllerProvider.notifier).retry();
    expect(calls, 2);
    recovery.complete(AppEnvironment.development);
    expect(
      await container.read(initializationControllerProvider.future),
      AppEnvironment.development,
    );
    expect(calls, 2);
  });

  test('ignores retry actions during the initial load', () async {
    final pending = Completer<AppEnvironment>();
    var calls = 0;
    final container = ProviderContainer.test(
      overrides: [
        environmentLoaderProvider.overrideWithValue(() {
          calls++;
          return pending.future;
        }),
      ],
    )..listen(initializationControllerProvider, (previous, next) {});
    container.read(initializationControllerProvider.notifier)
      ..retry()
      ..retry();

    expect(calls, 1);
    pending.complete(AppEnvironment.production);
    await container.read(initializationControllerProvider.future);
  });

  test(
    'dependency changes cannot be overwritten by an obsolete load',
    () async {
      final original = Completer<AppEnvironment>();
      final replacement = Completer<AppEnvironment>();
      final container =
          ProviderContainer.test(
              overrides: [
                environmentLoaderProvider.overrideWithValue(
                  () => original.future,
                ),
              ],
            )
            ..listen(initializationControllerProvider, (previous, next) {})
            ..updateOverrides([
              environmentLoaderProvider.overrideWithValue(
                () => replacement.future,
              ),
            ]);
      await container.pump();
      replacement.complete(AppEnvironment.staging);
      await container.read(initializationControllerProvider.future);
      original.complete(AppEnvironment.production);
      await container.pump();

      expect(
        container.read(initializationControllerProvider).requireValue,
        AppEnvironment.staging,
      );
    },
  );

  test('disposes unused state and ignores its pending completion', () async {
    final pending = Completer<AppEnvironment>();
    final states = <AsyncValue<AppEnvironment>>[];
    final container =
        ProviderContainer.test(
            overrides: [
              environmentLoaderProvider.overrideWithValue(() => pending.future),
            ],
          )
          ..listen(
            initializationControllerProvider,
            (previous, next) => states.add(next),
            fireImmediately: true,
          ).close();
    await container.pump();
    expect(container.exists(initializationControllerProvider), isFalse);
    pending.complete(AppEnvironment.production);
    await container.pump();
    expect(states, hasLength(1));
    expect(container.exists(initializationControllerProvider), isFalse);
  });
}
