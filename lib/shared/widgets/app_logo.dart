import 'package:flutter/material.dart';

/// The supplied, unmodified application logo; never tint brand artwork.
class AppLogo extends StatelessWidget {
  const new({this.size = 44, super.key});
  static const asset = 'assets/branding/app_logo.png';
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * .1),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(size * .27),
      border: Border.all(color: const Color(0x66FFFFFF)),
    ),
    child: Image.asset(
      asset,
      fit: BoxFit.contain,
      semanticLabel: 'OrangeONE application logo',
    ),
  );
}
