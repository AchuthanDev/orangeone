# Shared presentation

Place genuinely reusable, feature-independent UI in `widgets/`. Add shared theme
or other presentation directories only when approved designs and actual reuse
require them. Task 02 supplied directory structure; Task 04 adds the shared
`theme/` brand colors and Inter typography used by authentication.

Shared UI may depend on Flutter and appropriate core configuration or utilities.
It must not import `app/` or feature implementations, perform API/storage calls,
or own feature business rules. Keep widgets used by one feature in that feature's
`presentation/widgets/` directory.
See [architecture conventions](../../docs/architecture.md).
