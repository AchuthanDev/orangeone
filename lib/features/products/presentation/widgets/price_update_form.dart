import 'package:flutter/material.dart';
import 'package:orange_one/shared/theme/orange_theme.dart';

class PriceUpdateForm extends StatelessWidget {
  const new({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.enabled,
    this.error,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String? error;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('New Price', style: TextStyle(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        key: const Key('new-price-input'),
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => focusNode.unfocus(),
        decoration: InputDecoration(
          prefixText: 'CHF ',
          hintText: 'Enter new price',
          errorText: error,
          errorMaxLines: 3,
          filled: !enabled,
          fillColor: const Color(0xFFF5F6F8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDADCE0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: OrangeTheme.brand, width: 2),
          ),
        ),
      ),
    ],
  );
}

class PriceUpdateNotice extends StatelessWidget {
  const new({
    required this.message,
    this.success = false,
    this.title,
    super.key,
  });
  final String message;
  final bool success;
  final String? title;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? const Color(0xFFE8F7EF) : const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            success ? Icons.check_circle_outline : Icons.info_outline,
            color: success ? const Color(0xFF078362) : OrangeTheme.dark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF078362),
                      ),
                    ),
                  ),
                Text(
                  message,
                  style: TextStyle(
                    color: success ? const Color(0xFF078362) : OrangeTheme.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
