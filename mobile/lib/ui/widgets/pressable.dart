import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Wraps a tappable surface with subtle press-scale feedback (0.98x), giving
/// buttons, cards, and tiles a consistent tactile response. When [onTap] is
/// null the child is returned inert (no gesture, no scale).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = AppMotion.pressScale,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (widget.onTap == null || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.emphasized,
        child: widget.child,
      ),
    );
  }
}
