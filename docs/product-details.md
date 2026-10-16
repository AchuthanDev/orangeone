# Task 06 — Product details

Task 07 replaces the original price dialog with the dedicated
[product price update workflow](product-price-update.md). Task 08 replaces the
name dialog with the dedicated [Name & Tax page](product-edit.md). Both workflows
retain server permission checks and refresh details.

## Ownership and navigation

Home retains scanner and initial exact barcode lookup. App composition routes a
completed match automatically to `/home/products/details?barcode=…`; a null match
opens `/home/products/new?barcode=…` automatically. There is no intermediate user
confirmation. The scanner stops while a destination is open and resets on return.
Details is a separate `features/products` data/domain/presentation feature. It
loads authoritative data itself, supports direct navigation, refresh and safe
loading/empty/failure states. All routes remain protected by session restoration
and logout checks. Add product remains a prefilled draft without saving.

## Confirmed server operations

The existing central Dio/JSON-RPC client, timeouts and secure session are reused.
The app binds the details repository to the current session origin, bearer token
and a disposal cancellation token. HTTP and HTTPS dynamic POS origins remain
supported in all flavors. No authentication data is logged.

- `auth/token/check`: map the server's whitespace-separated `scopes` string.
  Missing scopes deny management actions by default.
- `api/products/find`: exact barcode; map id/name/barcode/price/stock quantity,
  optional reference/unit and taxes. Percent taxes display their percent; fixed,
  grouped and division taxes retain their server names instead of inventing a
  combined effective percentage.
- `api/products/name/update`: `{product_id, name}`, requires
  `product:name_update`.
- `api/products/price/update`: `{product_id, price}`, requires
  `product:price_update`.

Paths above are prefixed `/mupi/mobile/`. Backend controller/model source is the
contract authority. The server enforces permissions again on every write.
The form validates trimmed names (1–200 characters) and finite nonnegative prices.
The explicit Confirm update action performs one write, prevents duplicate
submission, then re-reads details and permissions. Writes are never automatically
retried. After an uncertain network outcome, refresh before submitting again.
Authentication rejection clears only the matching current session; permission
denial does not sign out. UI errors exclude backend internals.

## Design and unsupported fields

Reference: Figma node 182:724 and the user-supplied PNG/SVG. The Figma connector
returned its plan limit, so implementation/visual inspection used supplied exports.
The page follows the orange hero, product card, stock pill, rounded white body,
barcode/price/tax rows and discount card with management actions. Layout scrolls
and adapts to phone widths and text scaling.

The server does not return currency, description or category: these are not
fabricated. The user confirmed CHF as the display currency; prices show CHF and two decimals.
Stock update is visibly disabled with an explanation: no stock-write endpoint or
scope is supplied. It cannot mutate inventory.

Discount is explicitly **Mock data / Preview only** in every flavor. Its local
editor updates offer name and a validated 0–100 percentage, never the product's
price or backend. The screenshot's 200% example is replaced by 20%. The sample
schedule remains 12–18 Oct 2026; no real promotion is inferred. Local edits are
discarded when the details page is removed. A later backend contract is required
for discount persistence, actual scheduling and stock adjustments.

## Verification

Focused tests cover mapping and malformed responses, missing products, scopes,
origin and write payloads, session rejection versus authorization failure,
input validation, controller refresh, loading/empty/error widgets, confirmation,
automatic scanner navigation and returning to scan. Camera/network dependencies
are controlled; no real Odoo records are mutated by tests.

Verification on 16 October 2026: `flutter analyze --fatal-infos
--fatal-warnings` passed with no issues; `flutter test --coverage` passed all
197 tests. The controlled Android integration test passed on SM A315F via
wireless debugging (login, automatic details/draft routing, back and logout).
The product page was rendered at 390×844 and visually inspected against the
supplied export. Enlarged-text widget layouts passed at 320×568, 390×844 and
844×390. iOS builds and real Odoo name/price writes were not exercised.
The final arm64 development APK built successfully and the normal app was
installed/launched on SM A315F; live Flutter preview was restored after testing.

UI refinements: header navigation is fixed above the scrollable body. A separate
safe-area-aware glossy action bar fixes the 56-point Update Price / Update Stock
controls at the bottom, reserving space so content is never obscured. Wide layouts
place buttons side by side. CHF is displayed as requested; pull-to-refresh replaces
the redundant refresh buttons. Hero and discount card shadows follow the supplied
SVG. These fixed-header/sticky-action conventions are recorded in AGENTS.md.


