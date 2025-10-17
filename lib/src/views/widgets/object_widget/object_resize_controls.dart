import 'package:flutter/material.dart';
import 'object_control_box.dart';

/// Renders the 4 edge controls for resizing Sized2DDrawables.
class ObjectResizeControls extends StatelessWidget {
  final double indicatorInset;
  final double totalWidth;
  final double totalHeight;
  final double controlSize;
  final Map<int, bool> controlsAreActive;
  final void Function(int controlIndex, DragStartDetails details) onPanStart;
  final void Function(int controlIndex, DragUpdateDetails details) onPanUpdate;
  final void Function(int controlIndex, DragEndDetails details) onPanEnd;

  const ObjectResizeControls({
    Key? key,
    required this.indicatorInset,
    required this.totalWidth,
    required this.totalHeight,
    required this.controlSize,
    required this.controlsAreActive,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top edge - vertical resize (control index 4)
        Positioned(
          top: indicatorInset,
          left: (totalWidth / 2) - (controlSize / 2),
          width: controlSize,
          height: controlSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeUp,
            child: GestureDetector(
              onPanStart: (details) => onPanStart(4, details),
              onPanUpdate: (details) => onPanUpdate(4, details),
              onPanEnd: (details) => onPanEnd(4, details),
              child: ObjectControlBox(
                active: controlsAreActive[4] ?? false,
              ),
            ),
          ),
        ),
        // Bottom edge - vertical resize (control index 5)
        Positioned(
          bottom: indicatorInset,
          left: (totalWidth / 2) - (controlSize / 2),
          width: controlSize,
          height: controlSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeDown,
            child: GestureDetector(
              onPanStart: (details) => onPanStart(5, details),
              onPanUpdate: (details) => onPanUpdate(5, details),
              onPanEnd: (details) => onPanEnd(5, details),
              child: ObjectControlBox(
                active: controlsAreActive[5] ?? false,
              ),
            ),
          ),
        ),
        // Left edge - horizontal resize (control index 6)
        Positioned(
          left: indicatorInset,
          top: (totalHeight / 2) - (controlSize / 2),
          width: controlSize,
          height: controlSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeft,
            child: GestureDetector(
              onPanStart: (details) => onPanStart(6, details),
              onPanUpdate: (details) => onPanUpdate(6, details),
              onPanEnd: (details) => onPanEnd(6, details),
              child: ObjectControlBox(
                active: controlsAreActive[6] ?? false,
              ),
            ),
          ),
        ),
        // Right edge - horizontal resize (control index 7)
        Positioned(
          right: indicatorInset,
          top: (totalHeight / 2) - (controlSize / 2),
          width: controlSize,
          height: controlSize,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRight,
            child: GestureDetector(
              onPanStart: (details) => onPanStart(7, details),
              onPanUpdate: (details) => onPanUpdate(7, details),
              onPanEnd: (details) => onPanEnd(7, details),
              child: ObjectControlBox(
                active: controlsAreActive[7] ?? false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
