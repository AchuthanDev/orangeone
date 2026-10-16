# Products feature — product details

This feature owns product details, server permission mapping, confirmed name and
price updates, refresh and the explicitly labelled local discount preview.
Scanner pages and initial barcode lookup remain in `features/home`. App routing
passes the barcode between features; neither imports the other's internals.
See `docs/product-details.md` for contracts, limitations and verification.
The dedicated price update page, controller, confirmation and CHF validation are
documented in `docs/product-price-update.md`. Both pages reuse the neutral glass
`ProductActionSurface`; no scanner implementation belongs in this feature.

The dedicated Name & Tax page, company tax selection and combined update contract
are documented in `docs/product-edit.md`. Price and information pages share the
`ProductNameCard`, including its stock badge, and keep independent controllers.
