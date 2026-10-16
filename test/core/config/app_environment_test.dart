import 'package:flutter_test/flutter_test.dart';
import 'package:orange_one/core/config/app_environment.dart';

void main() {
  for (final environment in AppEnvironment.values) {
    group(environment.name, () {
      test('accepts the matching native flavor', () {
        expect(
          () => environment.validateNativeFlavor(environment.name),
          returnsNormally,
        );
      });

      for (final nativeFlavor in <String?>[
        null,
        '',
        'unsupported',
        ...AppEnvironment.values
            .where((value) => value != environment)
            .map((value) => value.name),
      ]) {
        test('rejects native flavor $nativeFlavor', () {
          expect(
            () => environment.validateNativeFlavor(nativeFlavor),
            throwsStateError,
          );
        });
      }
    });
  }
}
