import 'package:flutter/material.dart';
import 'package:orange_one/shared/widgets/app_logo.dart';

class BrandMark extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppLogo(),
      SizedBox(width: 12),
      Text(
        'OrangeONE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
