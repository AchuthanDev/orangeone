import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orange_one/core/config/app_environment.dart';
import 'package:orange_one/core/config/environment_loader.dart';

final AsyncNotifierProvider<InitializationController, AppEnvironment>
initializationControllerProvider =
    AsyncNotifierProvider.autoDispose<InitializationController, AppEnvironment>(
      InitializationController.new,
      name: 'initializationControllerProvider',
      // Configuration errors remain visible until explicitly retried.
      retry: (retryCount, error) => null,
    );

class InitializationController extends AsyncNotifier<AppEnvironment> {
  @override
  Future<AppEnvironment> build() => ref.watch(environmentLoaderProvider)();

  void retry() {
    if (state.isLoading) return;
    // Riverpod owns the async state and ignores results from obsolete builds.
    ref.invalidateSelf();
  }
}
