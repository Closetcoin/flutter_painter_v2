import 'package:flutter/material.dart';
import 'object_control_box.dart';

/// Position of an edge control (top, bottom, left, or right)
enum EdgePosition { top, bottom, left, right }

/// A parameterized edge control widget that can be used for stretch or resize operations.
/// This eliminates code duplication for the 4 edge controls.
class ObjectEdgeControl extends StatelessWidget {
  final EdgePosition position;
  final double totalWidth;
  final double totalHeight;
  final double controlSize;
  final double tapTargetSize;
  final bool isActive;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final Color inactiveColor;
  final Color? activeColor;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Color borderColor;
  final double borderWidth;
  final BoxShape controlShape;

  const ObjectEdgeControl({
    Key? key,
    required this.position,
    required this.totalWidth,
    required this.totalHeight,
    required this.controlSize,
    required this.tapTargetSize,
    required this.isActive,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.inactiveColor,
    required this.activeColor,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.borderColor,
    required this.borderWidth,
    required this.controlShape,
  }) : super(key: key);

  bool get isVertical =>
      position == EdgePosition.top || position == EdgePosition.bottom;
  bool get isHorizontal =>
      position == EdgePosition.left || position == EdgePosition.right;

  double get controlWidth =>
      isVertical ? controlSize * tapTargetSize : controlSize * tapTargetSize;
  double get controlHeight =>
      isVertical ? controlSize * tapTargetSize : controlSize * tapTargetSize;

  double? get top {
    if (position == EdgePosition.top) return 0.0;
    if (position == EdgePosition.bottom) return null;
    // Left or right - center vertically
    return (totalHeight / 2) - (controlHeight / 2);
  }

  double? get bottom {
    if (position == EdgePosition.bottom) return 0.0;
    return null;
  }

  double? get left {
    if (position == EdgePosition.left) return 0.0;
    if (position == EdgePosition.right) return null;
    // Top or bottom - center horizontally
    return (totalWidth / 2) - (controlWidth / 2);
  }

  double? get right {
    if (position == EdgePosition.right) return 0.0;
    return null;
  }

  MouseCursor get cursor {
    switch (position) {
      case EdgePosition.top:
        return SystemMouseCursors.resizeUp;
      case EdgePosition.bottom:
        return SystemMouseCursors.resizeDown;
      case EdgePosition.left:
        return SystemMouseCursors.resizeLeft;
      case EdgePosition.right:
        return SystemMouseCursors.resizeRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: controlWidth,
      height: controlHeight,
      child: Stack(
        children: [
          // Large tap area
          GestureDetector(
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: controlWidth,
              height: controlHeight,
              color: Colors.transparent,
            ),
          ),
          // Visual control box (centered)
          Positioned(
            top: (controlHeight - controlSize) / 2,
            left: (controlWidth - controlSize) / 2,
            child: MouseRegion(
              cursor: cursor,
              child: SizedBox(
                width: controlSize,
                height: controlSize,
                child: ObjectControlBox(
                  active: isActive,
                  inactiveColor: inactiveColor,
                  activeColor: activeColor,
                  shadowColor: shadowColor,
                  shadowBlurRadius: shadowBlurRadius,
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                  shape: controlShape,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
