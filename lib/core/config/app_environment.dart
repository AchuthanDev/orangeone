import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Native build flavor and matching Dart entry point must always agree.
enum AppEnvironment {
  development,
  staging,
  production;

  /// Prevents a native app from starting with another environment's services.
  void validateNativeFlavor(String? nativeFlavor) {
    if (nativeFlavor != name) {
      throw StateError(
        'Native flavor must be $name; received ${nativeFlavor ?? 'none'}. '
        'Use --flavor $name --target lib/main_$name.dart.',
      );
    }
  }
}

final environmentProvider = Provider<AppEnvironment>(
  (ref) => throw StateError('Environment must be supplied at bootstrap.'),
  name: 'environmentProvider',
);
