import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orange_one/app/app.dart';
import 'package:orange_one/app/providers/product_dependencies.dart';
import 'package:orange_one/core/config/app_environment.dart';

void bootstrap(AppEnvironment environment) {
  environment.validateNativeFlavor(appFlavor);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        environmentProvider.overrideWithValue(environment),
        productRepositoryOverride,
        productDetailsRepositoryOverride,
      ],
      child: const App(),
    ),
  );
}
