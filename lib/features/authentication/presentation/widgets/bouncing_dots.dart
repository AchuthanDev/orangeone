import 'dart:math' as math;

import 'package:flutter/material.dart';

class BouncingDots extends StatefulWidget {
  const new({super.key});
  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading OrangeONE',
    child: ExcludeSemantics(
      child: SizedBox(
        height: 24,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 3; index++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Transform.translate(
                    key: ValueKey('splash-dot-$index'),
                    offset: Offset(
                      0,
                      MediaQuery.disableAnimationsOf(context)
                          ? 0
                          : -8 *
                                math.max(
                                  0,
                                  math.sin(
                                    (_controller.value - index * .16) *
                                        math.pi *
                                        2,
                                  ),
                                ),
                    ),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 10, height: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
