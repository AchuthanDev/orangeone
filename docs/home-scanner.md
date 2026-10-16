# Task 05 — Home and product barcode lookup

## Scope and design

Home owns the authenticated scanner landing page, camera page and all barcode
lookup actions. The supplied landing PNG/SVG defines the gradient, OrangeONE
wordmark, white circle with the exported box-scan icon, “Tap to scan Barcode”,
“Scan Your Product”, and footer. The barcode page follows the supplied scanner
PNG/CSS: orange header, open-corner frame, live camera status and compact last
scanned card. The exported vector icon is `assets/icons/box_scan.svg`.

Task 06 adds the separate details feature in `features/products`. Home routes
lookup results automatically through app composition; see [Product details](product-details.md).
Logout remains available through the Home wordmark Account menu.
The Figma connector was rate-limited, so visual verification used the supplied
exports. The API supplies a numeric price without a currency code; the card
shows the returned price to two decimal places without assuming CHF.


As explicitly requested, **Add product is a draft only**: the scanned barcode is
read-only; name, price and optional reference can be entered. Drafts are held in
the current page's form fields and discarded on leaving it. There is no save API,
offline write queue, product update, stock adjustment or price mutation in this
task. The supplied `products/save` route is an upsert and requires a separate
creation task with duplicate/race rules, permissions and explicit confirmation.

## Confirmed API contract

Source: `mupi_mobile_pos_api/controllers/mobile_pos_api.py`, `find_product` and
`_format_product`; token failures follow the supplied mobile authentication model.

- POST `/mupi/mobile/api/products/find`, JSON-RPC 2.0, named params
  `{"barcode":"<scanned string>"}`, matching request/response IDs.
- Use the current secure session's origin and a per-request bearer token. Never
  use the optional build-time fallback server for authenticated product requests.
- Required scope: `product:read`.
- Success: `{"ok":true,"product":{...}}`; no match:
  `{"ok":true,"product":null}`. Missing `product` is a protocol error.
- The server searches exact barcode, `available_in_pos=true`, and company shared
  or matching the token's company, **with `limit=1`**. The app displays the record
  selected by that backend rule. It cannot detect duplicates hidden by the server
  and does not invent an ambiguity-selection API. Arrays/multiple-result response
  shapes are rejected as protocol failures instead of selecting one locally.
- Map positive integer ID, nonblank name, exact barcode and finite numeric price
  and `stock_quantity`. Negative stock is valid. Optional UOM/reference safely
  default to empty strings. Stock reflects the backend's `qty_available`, without
  claiming a warehouse-specific or offline quantity.
- Known token-invalid/expired/POS-closed results and HTTP/JSON-RPC authentication
  failures clear the current session. Missing product permission is a distinct
  forbidden failure and does not automatically log the user out. Unexpected
  server errors use safe static messages; backend traces are never displayed.

## Architecture, state and cancellation

`features/home/domain` owns Product, ProductRepository and LookupProduct.
`data` owns the Odoo source, JSON mapper and repository. Presentation owns the
scanner, result panel, draft page and manual Riverpod providers. Home landing callbacks are supplied by app composition.

`app/providers/product_dependencies.dart` binds `productRepositoryProvider` at
the existing root ProviderScope. It watches the current authenticated session,
injects the shared JSON-RPC client, and cancels its Dio request when disposed.
It only logs out the same session that made a rejected request. Home widgets import another feature's presentation or data implementation.

`productLookupControllerProvider` / ProductLookupController is auto-disposed.
Idle is `AsyncData(null)`, pending is `AsyncLoading`, a completed lookup contains
its barcode and nullable product, and failure is `AsyncError(AppFailure)`.
Automatic retry is disabled. Only network/timeout read failures offer manual
retry. Repository and camera-builder providers are overrideable in tests.
Changing dependencies, signing out or leaving the scanner disposes/cancels the
request; generation and mounted checks reject late results.

Barcode validation trims outer whitespace, preserves case and leading zeros,
and rejects empty, oversized (>256 characters) or control-containing values.
Completed lookups automatically open details or the prefilled add-product draft.
Detection pauses while the destination is open and resets when it closes.
Errors offer safe read retries or Scan another barcode. Login retains single-scan
behavior. There are no automatic inventory mutations.

## Camera and navigation

The shared CodeCamera owns permission requests, denied/restricted/permanent
states, safe camera errors, Settings/retry actions, app background/resume and
controller disposal. Login retains its QR-only wrapper. Product formats common
to Android/iOS are EAN-13, EAN-8, UPC-E, Code 128, Code 39, Code 93 and ITF-14.
Android additionally enables UPC-A and Codabar. Apple Vision can report UPC-A as
EAN-13; the app deliberately does not strip its leading zero or guess a second
barcode. Codabar is not enabled on iOS because it requires newer system support.
Physical decoding across these formats still requires device verification.

Named protected routes:

| Name | Path | Input/result |
| --- | --- | --- |
| home | `/home` | Current authenticated session |
| productScanner | `/home/scan` | Back returns `false` when pushed |
| addProduct | `/home/products/new` | Validated `barcode` query parameter |

Existing startup restoration, login redirects, logout and unknown-route handling
remain. Product deep links cannot bypass authentication or restoration. The add
page validates its route input before showing a prefilled draft.

## Verification boundaries

Unit/provider/widget checks cover mapping, exact request shape, malformed or
multiple results, no match, auth versus permission failures, duplicate scans,
manual retry, disposal, stale dependencies, logout guards, draft navigation,
permission states, format filtering and enlarged text at 320×568, 390×844 and
844×390. The integration smoke journey uses fake authentication, product data and
camera callbacks; it does not call a live Odoo server or mutate inventory.

A pre-existing login-brand overflow was observed at 320 pixels with 1.6× text
while investigating scanner layouts. Login visual changes are outside this task;
scanner responsiveness is tested after authenticated startup.



