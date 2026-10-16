# Feature modules

The existing `initialization/` module is a diagnostic screen, not a business
workflow. Its empty directories establish the layout without adding behavior.
No additional features are generated in Task 02.

Task 04 explicitly adds `authentication/` with implemented domain, data and
presentation layers. Its signed-in destination is minimal; no inventory/business
modules were scaffolded speculatively. See `docs/authentication.md` at the root.

When a feature is explicitly requested, use the folder convention in
[architecture](../../docs/architecture.md). Implement only the layers it needs;
do not fill empty directories with placeholder entities, repositories or use cases.
`.gitkeep` files retain currently empty directories in Git and can be removed as
real files are added.

Home owns the authenticated scanner landing, barcode camera, product lookup
actions and their data/domain/presentation layers. Products owns the independent product-details feature; scanner and lookup implementations must not
be placed there. App owns session injection and routing between features.


