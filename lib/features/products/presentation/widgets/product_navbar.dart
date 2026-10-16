import 'package:flutter/material.dart';
import 'package:orange_one/shared/theme/orange_theme.dart';

class ProductNavbar extends StatelessWidget implements PreferredSizeWidget {
  const new({
    required this.title,
    required this.onBack,
    required this.onEdit,
    required this.editTooltip,
    super.key,
  });
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;
  final String editTooltip;
  @override
  Size get preferredSize => const Size.fromHeight(80);
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: OrangeTheme.homeGradient),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              style: _buttonStyle,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              tooltip: editTooltip,
              onPressed: onEdit,
              style: _buttonStyle,
              color: Colors.white,
              disabledColor: Colors.white38,
              icon: const Icon(Icons.edit_square),
            ),
          ],
        ),
      ),
    ),
  );
  ButtonStyle get _buttonStyle => IconButton.styleFrom(
    backgroundColor: Colors.white.withValues(alpha: .2),
    fixedSize: const Size(48, 48),
  );
}
