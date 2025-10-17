import 'package:flutter/material.dart';
import 'object_control_box.dart';

/// Position of a corner control
enum CornerPosition { topLeft, bottomLeft, topRight, bottomRight }

/// Type of corner control
enum CornerControlType { scale, rotation }

/// A corner control widget for scale or rotation operations.
class ObjectCornerControl extends StatelessWidget {
  final CornerPosition position;
  final CornerControlType type;
  final double stretchControlsExtension;
  final double controlSize;
  final bool isActive;
  final Map<int, bool>? activeStates; // For checking if dragging
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  const ObjectCornerControl({
    Key? key,
    required this.position,
    required this.type,
    required this.stretchControlsExtension,
    required this.controlSize,
    required this.isActive,
    this.activeStates,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  double? get top {
    if (position == CornerPosition.topLeft ||
        position == CornerPosition.topRight) {
      return stretchControlsExtension;
    }
    return null;
  }

  double? get bottom {
    if (position == CornerPosition.bottomLeft ||
        position == CornerPosition.bottomRight) {
      return stretchControlsExtension;
    }
    return null;
  }

  double? get left {
    if (position == CornerPosition.topLeft ||
        position == CornerPosition.bottomLeft) {
      return stretchControlsExtension;
    }
    return null;
  }

  double? get right {
    if (position == CornerPosition.topRight ||
        position == CornerPosition.bottomRight) {
      return stretchControlsExtension;
    }
    return null;
  }

  MouseCursor get cursor {
    if (type == CornerControlType.rotation) {
      // Check if currently dragging
      final isDragging = activeStates != null && isActive;
      return isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab;
    }

    // Scale cursors
    switch (position) {
      case CornerPosition.topLeft:
        return SystemMouseCursors.resizeUpLeft;
      case CornerPosition.bottomLeft:
        return SystemMouseCursors.resizeDownLeft;
      case CornerPosition.topRight:
        return SystemMouseCursors.resizeUpRight;
      case CornerPosition.bottomRight:
        return SystemMouseCursors.resizeDownRight;
    }
  }

  BoxShape get shape =>
      type == CornerControlType.rotation ? BoxShape.circle : BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: controlSize,
      height: controlSize,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: ObjectControlBox(
            shape: shape,
            active: isActive,
          ),
        ),
      ),
    );
  }
}
