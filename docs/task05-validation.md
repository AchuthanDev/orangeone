# Task 05 validation — 2026-10-16

Implemented Home → barcode scanner → Odoo read-only lookup, safe product mapping,
found/not-found/error states, read-only product information, protected draft
navigation, and shared permission-aware camera infrastructure. No dependencies,
backend modules, inventory records or CI workflows were changed.

## Automated checks

- `dart format --output=none --set-exit-if-changed lib test integration_test`:
  passed (70 Dart files).
- `flutter analyze --fatal-infos --fatal-warnings`: no issues.
- `flutter test --coverage`: **180 tests passed**; coverage output remains under
  the ignored coverage directory.
- `flutter test integration_test/app_test.dart --flavor development
  --dart-define=TEST_FLAVOR=development -d 192.168.1.5:42371`: **passed on SM A315F**.
  The test built/installed an Android development APK and ran the controlled
  login → lookup found → rescan → not found → draft → return → logout journey.
  Authentication, product repository and scan callbacks were overridden with
  fixture dependencies. It did not contact Odoo or modify inventory.

Focused tests cover request origin/auth/params, safe optional mapping and invalid
data, backend `limit=1` response policy, token rejection versus permission denial,
read retry, duplicate suppression, disposed/obsolete results, actual Dio request
cancellation, deep-link/logout guards, draft-prefill navigation, camera permission
states, startup errors, background detection suppression and format filtering.
Widget layout checks include 320×568, 390×844 and 844×390 with 1.6× text.

## Visual and device checks

The scanner was rendered at 390×844 using fixture product information and bundled
Inter/Material icon fonts. The result panel was adjusted to remain visible;
read-only information opens separately. Preview artifact (ignored build output):
`build/task05-scanner-preview.png`.

Figma direct inspection was blocked by the connector's Starter-plan limit.
Implementation used the user-supplied PNG/SVG/CSS exports and existing assets.
No claim of independently verified Figma pixel parity is made.

The initial device run exposed an off-screen rescan control; the compact result
panel and integration interaction were corrected. A later wireless transport
disconnect interrupted startup. After reconnection, the final device smoke run
passed. These failed attempts were not treated as successful verification.

## Not verified

- Real product barcode decoding with the physical camera across supported formats.
- Live Odoo product lookup or deployed module/runtime compatibility.
- iOS compilation/device behavior or staging/production binary builds in this task.
- Full Home/Product details designs; supplied node `182:724` contains details and
  editing/discount actions beyond this task. Add product remains a draft only,
  as explicitly requested.

See [product contract, scope and platform format policy](home-scanner.md).

Final camera recovery verification also covers a successful retry after a failed
startup, without showing raw platform details. Final formatting and analysis
passed, and the complete suite again passed all 180 tests. A normal Android
arm64 development APK also built successfully after the integration run.


Both iOS Info plists now describe camera use for login QR and product barcode
scanning, and local-network use for sign-in and lookup; both parsed as XML.
The normal development app was installed and launched on SM A315F at the user's
updated wireless address, 192.168.1.5:36225. The Flutter preview remains connected.



## User-requested ownership and design correction

Moved lookup data/domain/presentation and corresponding tests to features/home.
Products is now reserved for the independent product-details feature. Removed
the information modal and success-state extra controls. Home now uses the supplied
landing design and its exported box-scan SVG. Successful lookup keeps the camera
available while repeated and concurrent lookups remain controlled. The existing
QR-login camera remains single-scan. Logout is available from the Home wordmark.

Final correction verification: all 181 tests passed; analysis found no issues.
Rendered previews: build/home-landing-corrected.png and
build/home-scanner-corrected.png. The Android live app was hot restarted with the
correction; a persistent APK is being rebuilt for installation.


The corrected normal APK was installed and launched successfully on SM A315F
at 192.168.1.5:36225, with live Flutter preview reconnected. This replaces the
earlier APK and preserves the corrected UI after a cold app restart.

