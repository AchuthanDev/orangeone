import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/app/app.dart';
import 'package:orange_one/app/router/app_router.dart';
import 'package:orange_one/core/config/api_configuration.dart';
import 'package:orange_one/core/errors/app_failure.dart';
import 'package:orange_one/features/authentication/domain/entities/auth_session.dart';
import 'package:orange_one/features/authentication/presentation/pages/splash_page.dart';
import 'package:orange_one/features/authentication/presentation/providers/auth_providers.dart';
import 'package:orange_one/shared/widgets/app_logo.dart';

import '../../../support/auth_fakes.dart';

class PendingRestoreRepository extends FakeAuthRepository {
  final restoration = Completer<AuthSession?>();
  @override
  Future<AuthSession?> restore() async => await restoration.future;
}

void main() {
  testWidgets('dots bounce in sequence and stop for reduced motion', (
    tester,
  ) async {
    var reducedMotion = false;
    Future<void> mount() => tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
        home: const SplashPage(),
      ),
    );
    await mount();
    await tester.pump(const Duration(milliseconds: 100));
    final first = tester.widget<Transform>(
      find.byKey(const ValueKey('splash-dot-0')),
    );
    final second = tester.widget<Transform>(
      find.byKey(const ValueKey('splash-dot-1')),
    );
    expect(first.transform.storage[13], lessThan(0));
    expect(first.transform.storage[13], isNot(second.transform.storage[13]));
    reducedMotion = true;
    await mount();
    await tester.pumpAndSettle();
    for (var index = 0; index < 3; index++) {
      expect(
        tester
            .widget<Transform>(find.byKey(ValueKey('splash-dot-$index')))
            .transform
            .storage[13],
        0,
      );
    }
    expect(find.byType(AppLogo), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final authenticated in [false, true]) {
    testWidgets('startup waits, then resolves authenticated=$authenticated', (
      tester,
    ) async {
      final repo = PendingRestoreRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
            utcNowProvider.overrideWithValue(() => testNow),
          ],
          child: const App(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.text('Tap to scan QR'), findsNothing);
      expect(find.text('Tap to scan Barcode'), findsNothing);
      repo.restoration.complete(authenticated ? testSession : null);
      await tester.pumpAndSettle();
      expect(find.byType(SplashPage), findsNothing);
      expect(
        find.text(authenticated ? 'Tap to scan Barcode' : 'Tap to scan QR'),
        findsOneWidget,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      );
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        authenticated ? '/home' : '/login',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('restore failure exits splash and offers session retry', (
    tester,
  ) async {
    final repo = PendingRestoreRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: const App(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    repo.restoration.completeError(
      const AppFailure(FailureKind.network, 'Unable to check your session.'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SplashPage), findsNothing);
    expect(find.text('Unable to check your session.'), findsOneWidget);
    expect(find.text('Retry session check'), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets('splash fits $size with enlarged text', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.6),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: const SplashPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Scan. Sell. Go.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
