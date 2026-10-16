import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/config/app_environment.dart';
import 'package:orange_one/core/config/environment_loader.dart';

void main() {
  for (final environment in AppEnvironment.values) {
    test('loads the injected ${environment.name} configuration', () async {
      final container = ProviderContainer.test(
        overrides: [environmentProvider.overrideWithValue(environment)],
      );
      final loader = container.read(environmentLoaderProvider);

      expect(container.read(environmentLoaderProvider), same(loader));
      expect(await loader(), environment);
    });
  }

  test('configuration is isolated between containers', () async {
    final development = ProviderContainer.test(
      overrides: [
        environmentProvider.overrideWithValue(AppEnvironment.development),
      ],
    );
    final production = ProviderContainer.test(
      overrides: [
        environmentProvider.overrideWithValue(AppEnvironment.production),
      ],
    );

    expect(
      await development.read(environmentLoaderProvider)(),
      AppEnvironment.development,
    );
    expect(
      await production.read(environmentLoaderProvider)(),
      AppEnvironment.production,
    );
  });
}
