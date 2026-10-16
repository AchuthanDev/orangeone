import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_one/features/authentication/presentation/widgets/bouncing_dots.dart';
import 'package:orange_one/shared/widgets/app_logo.dart';

/// Displayed only while the existing session controller resolves access.
/// No artificial delay, duplicated session checks or navigation side effects.
class SplashPage extends StatelessWidget {
  const new({super.key});
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFFFF8A33),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    child: Scaffold(
      backgroundColor: const Color(0xFFBE4602),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-.54, -.72),
            end: Alignment(1, .6),
            colors: [Color(0xFFBE4602), Color(0xFFFF8A33)],
            stops: [.08, .94],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppLogo(size: 112),
                      SizedBox(height: 20),
                      Text(
                        'OrangeONE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Scan. Sell. Go.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 64),
                      BouncingDots(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
