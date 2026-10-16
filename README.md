# OrangeONE

Task 08: [Product Name & Tax edit workflow](docs/product-edit.md).
Task 09: [Startup splash and shared branding](docs/splash-branding.md).

Mobile inventory application for Android and iOS, backed by Odoo JSON-RPC.
Task 01 establishes the application foundation; Task 02 establishes feature and
layer directories without adding business features.
Task 03 adds a tested Riverpod async initialization controller and shared local
configuration injection; no backend service is initialized.
Task 04 adds QR authentication, shared Dio/JSON-RPC transport, secure sessions and
protected navigation. See [authentication setup and contract](docs/authentication.md).

## Requirements and scope

- Functional: independently installable development, staging and production apps;
  Riverpod dependency injection; GoRouter startup route; a minimal initialization
  screen; automated quality checks and native builds for every flavor.
- Quality: reproducible dependency resolution, strict analysis, tests, no secrets
  in source control, bounded CI jobs with read-only repository permissions.
- Constraints: Windows can validate Dart and Android; iOS compilation requires
  macOS and runs in GitHub Actions. No Apple signing is required for CI compilation.
- Deferred: product CRUD/barcode scanning, stock changes, caching/sync, Firebase,
  the full inventory dashboard and signed store distribution.

## Toolchain and provenance

Generated using Very Good CLI **1.5.0**, core template, on 2026-10-15:

```sh
very_good create flutter_app orange_one --output-directory . --platforms android,ios --application-id com.orangeone.app --description "OrangeONE mobile inventory management application."
```

The generated directory was moved into the repository root. Native flavors,
localization, editor launch configurations and strict lint tooling were retained.
The generated Bloc/Cubit example and dependencies were replaced with Riverpod.
Use Flutter **3.47.5 stable / Dart 3.13.4** (CI pins the same Flutter version).
Commit `pubspec.lock` and resolve CI dependencies with `--enforce-lockfile`.

For a fresh workstation, install that stable Flutter SDK from the
[Flutter SDK archive](https://docs.flutter.dev/install/archive), then verify:

```sh
flutter --version
dart --version
dart pub global activate very_good_cli 1.5.0
very_good --version
java -version
flutter doctor -v
```

Use Android Studio's supported JDK 21 locally or Temurin JDK 17 as in CI.
Flutter's configured JDK is shown by `flutter doctor -v`; it can differ from
`java -version`. The Gradle wrapper supplies the pinned builder, so a global
Gradle installation is unnecessary (`android/gradlew --version`, or
`android\gradlew.bat --version` on Windows).

Android uses AGP **8.12.0**, Gradle **8.14.3**, and Kotlin **2.3.20**.
Gradle and Kotlin meet the minimum versions enforced by Flutter 3.47.5; they
replace the older template versions. Kotlin supplies its matching standard
library automatically, without a separate outdated dependency pin.
Flutter currently accepts this toolchain but warns about future removal of
Gradle 8 / AGP 8 support. Plan a tested AGP 9 migration before upgrading Flutter
to a release that removes it; build validation remains enabled.
CI installs Temurin **JDK 17** on **Ubuntu 24.04**; the local Flutter toolchain
uses Android Studio's **JDK 21.0.8**. The Java 25 executable on PATH is not
Flutter's configured JDK. Keep Gradle aligned with the
[AGP compatibility table](https://developer.android.com/build/releases/agp-8-12-0-release-notes).
Install Android Studio and its SDK, accept licenses with `flutter doctor
--android-licenses`, then check `flutter doctor -v`. Do not regenerate the app
over this repository; the CLI command above records bootstrap provenance.

## Running

```sh
flutter pub get
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart
```

Always pair a native flavor with its matching Dart entry point. Startup rejects
missing or mismatched native flavors before mounting the application. The starter page
is retained at `/diagnostics/initialization` for environment verification. The app
opens the login flow and validates any stored session before protected navigation.
VS Code launch configurations are included.

Login discovers the Odoo server address and port from the POS QR code. To customize timeouts, copy `config/odoo.example.json` to `config/development.local.json`,
adjust the timeout values and use:

```sh
flutter run --flavor development --target lib/main_development.dart --dart-define-from-file=config/development.local.json -d DEVICE_ID
```

All flavors support dynamic HTTP/HTTPS POS addresses; prefer HTTPS. Local files
are ignored. Do not place credentials or QR payloads in defines. Configuration,
permission setup and the exact backend contract are documented in the authentication guide.

| Flavor | Android application ID / iOS bundle ID |
| --- | --- |
| development | com.orangeone.app.dev |
| staging | com.orangeone.app.stg |
| production | com.orangeone.app |

These are provisional identifiers. Confirm ownership before Firebase registration,
Apple provisioning, Play Console registration or publishing.

## Validation

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
flutter test integration_test/app_test.dart --flavor development --target integration_test/app_test.dart -d DEVICE_ID
flutter build apk --debug --flavor development --target lib/main_development.dart
```

Unit tests cover matching, missing, unsupported and mismatched native flavors.
Widget tests cover startup and environment injection for all three environments,
plus a safe fallback for unknown routes and guarded authentication navigation.
Provider/widget tests also cover configuration injection and isolation, async
loading/success/error, explicit retry, duplicate-load prevention, obsolete results
and disposal. See [Task 03 verification](docs/task03-validation.md).
The integration smoke test requires a connected Android/iOS device or emulator.
For staging or production, pass both `--flavor FLAVOR` and
`--dart-define=TEST_FLAVOR=FLAVOR`; the test checks the native flavor and injects
the matching environment into app composition. It covers login navigation and
logout with controlled
authentication/camera overrides; it never calls production Odoo or uses a physical
camera. Real QR recognition and secure platform storage need separate device checks.

CI is split into independent workflows:

- `.github/workflows/quality.yaml`: formatting, analysis, widget tests, coverage,
  and Android emulator integration tests for every flavor on Ubuntu 24.04.
- `.github/workflows/android.yaml`: all three Android debug APK builds on Ubuntu 24.04.
- `.github/workflows/ios.yaml`: all three unsigned iOS release builds on macOS 26.

The iOS template includes Icon Composer assets, requiring Xcode 26 or newer.
The [macOS 26 runner image](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-Readme.md)
provides Xcode 26; the workflow reports the selected Xcode and Swift versions.

The emulator setup follows the
[Android emulator action](https://github.com/ReactiveCircus/android-emulator-runner).
The retained template license workflow checks dependency licenses separately.
Artifacts are validation outputs, not store-ready distributions. Required branch
checks should include quality, all three integration jobs, and all six
platform/flavor build jobs. A separate workflow cannot use another workflow's
`needs`; branch protection must require all of these checks.

## Architecture

See [architecture](docs/architecture.md) and [agent instructions](AGENTS.md).
`lib/app` owns composition and routing; `lib/core` holds reusable non-UI
infrastructure; `lib/shared` holds reusable UI. Feature modules use separate
`presentation/{pages,widgets,providers}`, `domain/{entities,repositories,use_cases}`
and `data/{models,data_sources,repositories}` directories. The existing
initialization page is under `presentation/pages`; unused directories are retained
with `.gitkeep` files. No additional features or placeholder implementations are
generated. Implement each layer only when real requirements need it.

UI dispatches actions through providers and domain contracts; data sources own IO.
Domain code remains independent of Flutter, Riverpod and API/storage details.
See the architecture document for allowed imports, dependency wiring and test layout.

See [Riverpod conventions](docs/state-management.md) for provider selection,
naming, async state handling, lifecycle/cleanup and dependency overrides in tests.
The startup page now renders configuration loading, success and a safe error with
an explicit Retry action. The successful diagnostic screen remains unchanged.

The diagnostic retains a minimal layout. Authentication uses the inspected login
and scanner references, Inter and reusable brand styling from the
[OrangeONE Figma system](https://www.figma.com/design/r6TjxFouED6tJ9fX6evjhz/OrangeONE---Mobile-Design-System?node-id=0-1)
for its two requested screens. The authenticated home is a minimal destination;
the inventory dashboard design and functionality are deferred.

## External service and release prerequisites

Dio and platform secure storage are now configured through Riverpod. The supplied
Odoo authentication contract is implemented; confirm deployment/database routing
and a live login with a fresh POS-generated QR code. Never embed credentials in Dart
sources or `--dart-define` (compiled app configuration is not secret storage).

Firebase needs separate environment registrations and approved platform
configuration. Add Crashlytics consent/error handling and Remote Config allowlists
with those features. Do not silently initialize production services in development.

Android release signing reads ignored `android/key.properties` or the generated
`ANDROID_KEYSTORE_*` environment settings. A real release requires a protected
signing keystore. iOS release distribution requires an Apple Developer team,
registered bundle IDs, certificates/profiles, App Store Connect access and a macOS
runner. Fastlane/TestFlight deployment is deferred until these inputs are supplied;
Task 01 CI does not publish or claim to validate signing.

## Workflow

Use short-lived feature branches and pull requests into `main`. Keep changes
focused, include validation evidence and require green CI before merging. Do not
commit credentials, keystores, provisioning profiles or generated build outputs.
Review dependency/action upgrades through Dependabot. No remote repository or
branch protection is configured by this local initialization.

See [Task 01 validation evidence](docs/validation.md) for checks executed locally and pending native/CI validation.



## Product barcode lookup (Task 05)

After login, Home shows **Tap to scan Barcode**. Tap the circle or label to scan.
The Home feature owns scanning and Odoo lookup. A successful match automatically opens product details. Unknown barcodes
automatically open a prefilled draft; saving is deferred. Tap the Home wordmark for Sign out.
`features/products` owns details, permissions and confirmed name/price updates.
See [Product details](docs/product-details.md).
See [Home scanner contract and architecture](docs/home-scanner.md).

Task 07 replaces the price dialog with a dedicated Products price workflow:
fixed CHF input, two-decimal validation, explicit confirmation, server permission
and price checks, acknowledged success and safe recovery after uncertain writes.
See [Product price update](docs/product-price-update.md).

#   o r a n g e o n e  
 