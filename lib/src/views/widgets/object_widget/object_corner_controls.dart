import 'package:flutter/material.dart';
import 'object_control_box.dart';
import '../../../controllers/settings/accessibility_controls_settings.dart';

/// Position of a corner control
enum CornerPosition { topLeft, bottomLeft, topRight, bottomRight }

/// Type of corner control
enum CornerControlType { scale, rotation, remove }

/// A corner control widget for scale or rotation operations.
class ObjectCornerControl extends StatelessWidget {
  final CornerPosition position;
  final CornerControlType type;
  final double indicatorInset;
  final double controlSize;
  final double cornerOffset;
  final bool isActive;
  final Map<int, bool>? activeStates; // For checking if dragging
  final ControlWidgetBuilder? customWidgetBuilder;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final Future<void> Function()? onTap; // For remove control

  const ObjectCornerControl({
    Key? key,
    required this.position,
    required this.type,
    required this.indicatorInset,
    required this.controlSize,
    required this.cornerOffset,
    required this.isActive,
    this.activeStates,
    this.customWidgetBuilder,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    this.onTap,
  }) : super(key: key);

  double? get top {
    if (position == CornerPosition.topLeft ||
        position == CornerPosition.topRight) {
      // Position at indicator edge, then move up diagonally by cornerOffset
      return indicatorInset - cornerOffset;
    }
    return null;
  }

  double? get bottom {
    if (position == CornerPosition.bottomLeft ||
        position == CornerPosition.bottomRight) {
      // Position at indicator edge, then move down diagonally by cornerOffset
      return indicatorInset - cornerOffset;
    }
    return null;
  }

  double? get left {
    if (position == CornerPosition.topLeft ||
        position == CornerPosition.bottomLeft) {
      // Position at indicator edge, then move left diagonally by cornerOffset
      return indicatorInset - cornerOffset;
    }
    return null;
  }

  double? get right {
    if (position == CornerPosition.topRight ||
        position == CornerPosition.bottomRight) {
      // Position at indicator edge, then move right diagonally by cornerOffset
      return indicatorInset - cornerOffset;
    }
    return null;
  }

  MouseCursor get cursor {
    if (type == CornerControlType.rotation) {
      // Check if currently dragging
      final isDragging = activeStates != null && isActive;
      return isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab;
    }

    if (type == CornerControlType.remove) {
      return SystemMouseCursors.click;
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

  /// Icon to display based on control type
  IconData get icon {
    switch (type) {
      case CornerControlType.rotation:
        return Icons.refresh;
      case CornerControlType.scale:
        return Icons.zoom_out_map;
      case CornerControlType.remove:
        return Icons.close;
    }
  }

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
        child: type == CornerControlType.remove && onTap != null
            ? GestureDetector(
                // Remove control uses tap gesture with async callback
                onTap: onTap,
                child: customWidgetBuilder != null
                    ? customWidgetBuilder!(isActive)
                    : ObjectControlBox(
                        shape: BoxShape.circle,
                        active: isActive,
                        icon: icon,
                        iconSize: controlSize * 0.9,
                      ),
              )
            : GestureDetector(
                // Other controls use pan gestures
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: customWidgetBuilder != null
                    ? customWidgetBuilder!(isActive)
                    : ObjectControlBox(
                        shape: BoxShape.circle,
                        active: isActive,
                        icon: icon,
                        iconSize: controlSize * 0.9,
                      ),
              ),
      ),
    );
  }
}
