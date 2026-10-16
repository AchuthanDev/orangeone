import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orange_one/core/config/app_environment.dart';

/// Injectable asynchronous read of the application's local configuration.
typedef EnvironmentLoader = Future<AppEnvironment> Function();

final environmentLoaderProvider = Provider<EnvironmentLoader>((ref) {
  final environment = ref.watch(environmentProvider);
  return () async => environment;
}, name: 'environmentLoaderProvider');
