import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedProjector extends StatefulWidget {
  final Widget child;
  const AnimatedProjector({super.key, required this.child});

  @override
  State<AnimatedProjector> createState() => _AnimatedProjectorState();
}

class _AnimatedProjectorState extends State<AnimatedProjector>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(_glow.value * 0.4),
              blurRadius: 30 * _glow.value,
              spreadRadius: 5 * _glow.value,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
