import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/config/api_configuration.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/features/authentication/domain/entities/auth_session.dart';
import 'package:orange_one/features/authentication/presentation/providers/auth_providers.dart';

import '../../../support/auth_fakes.dart';

void main() {
  testWidgets('session expiry clears local authentication automatically', (
    tester,
  ) async {
    var now = testNow;
    final repository = FakeAuthRepository()
      ..restored = AuthSession(
        accessToken: testSession.accessToken,
        backendOrigin: testSession.backendOrigin,
        expiresAt: testNow.add(const Duration(seconds: 1)),
        tokenId: 7,
        userId: 2,
        posSessionId: 106,
        posConfigId: 1,
        companyId: 1,
      );
    final scope = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        utcNowProvider.overrideWithValue(() => now),
      ],
    );
    await scope.read(sessionControllerProvider.future);
    expect(scope.read(sessionControllerProvider).value, isNotNull);
    now = now.add(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await scope.pump();
    expect(scope.read(sessionControllerProvider).value, isNull);
    expect(repository.signOuts, 1);
  });

  late FakeAuthRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        utcNowProvider.overrideWithValue(() => testNow),
      ],
    );
  });

  test('restores once and prevents concurrent login operations', () async {
    await container.read(sessionControllerProvider.future);
    repository.pendingLogin = Completer<AuthSession>();
    final first = container
        .read(sessionControllerProvider.notifier)
        .signIn('fixture QR');
    final duplicate = await container
        .read(sessionControllerProvider.notifier)
        .signIn('fixture QR');
    expect(duplicate, isFalse);
    expect(repository.signIns, 1);
    expect(container.read(sessionControllerProvider).isLoading, isTrue);
    repository.pendingLogin!.complete(testSession);
    expect(await first, isTrue);
    expect(container.read(sessionControllerProvider).value?.userId, 2);
    expect(repository.restores, 1);
  });

  test('logout during login prevents stale authenticated state', () async {
    await container.read(sessionControllerProvider.future);
    repository.pendingLogin = Completer<AuthSession>();
    final login = container
        .read(sessionControllerProvider.notifier)
        .signIn('fixture QR');
    await container.read(sessionControllerProvider.notifier).signOut();
    repository.pendingLogin!.complete(testSession);
    expect(await login, isFalse);
    expect(container.read(sessionControllerProvider).value, isNull);
    expect(repository.signOuts, 1);
  });

  test(
    'invalid input never calls repository and exposes safe failure',
    () async {
      await container.read(sessionControllerProvider.future);
      expect(
        await container.read(sessionControllerProvider.notifier).signIn(''),
        isFalse,
      );
      expect(repository.signIns, 0);
      expect(container.read(sessionControllerProvider).error, same(invalidQr));
      container.read(sessionControllerProvider.notifier).clearLoginFailure();
      expect(container.read(sessionControllerProvider).hasError, isFalse);
    },
  );

  test('restoration failure is not automatically retried', () async {
    repository.failure = storageFailure;
    await expectLater(
      container.read(sessionControllerProvider.future),
      throwsA(same(storageFailure)),
    );
    await container.pump();
    expect(repository.restores, 1);
    expect(container.read(sessionControllerProvider).hasError, isTrue);
  });

  test(
    'resume revalidation cannot retain a server-invalidated session',
    () async {
      repository.restored = testSession;
      await container.read(sessionControllerProvider.future);
      repository.restored = null;
      await container.read(sessionControllerProvider.notifier).revalidate();
      expect(container.read(sessionControllerProvider).value, isNull);
      expect(repository.restores, 2);
    },
  );
}
