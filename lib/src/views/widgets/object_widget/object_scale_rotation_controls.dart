import 'package:flutter/material.dart';
import 'object_corner_controls.dart';
import '../../../controllers/settings/accessibility_controls_settings.dart';

/// Renders the corner controls for scaling, rotation, and removal.
class ObjectScaleRotationControls extends StatelessWidget {
  final double indicatorInset;
  final double controlSize;
  final double cornerOffset;
  final Map<int, bool> controlsAreActive;
  final Map<int, dynamic> initialScaleDrawables; // For rotation cursor state
  final int entryKey;
  final bool showRotationControl;
  final bool showScaleControl;
  final bool showRemoveControl;
  final ControlWidgetBuilder? rotationControlBuilder;
  final ControlWidgetBuilder? scaleControlBuilder;
  final ControlWidgetBuilder? removeControlBuilder;
  final void Function(int controlIndex, DragStartDetails details)
      onScalePanStart;
  final void Function(int controlIndex, DragUpdateDetails details)
      onScalePanUpdate;
  final void Function(int controlIndex, DragEndDetails details) onScalePanEnd;
  final void Function(int controlIndex, DragStartDetails details)
      onRotationPanStart;
  final void Function(int controlIndex, DragUpdateDetails details)
      onRotationPanUpdate;
  final void Function(int controlIndex, DragEndDetails details)
      onRotationPanEnd;
  final Future<void> Function()? onRemoveTap;

  const ObjectScaleRotationControls({
    Key? key,
    required this.indicatorInset,
    required this.controlSize,
    required this.cornerOffset,
    required this.controlsAreActive,
    required this.initialScaleDrawables,
    required this.entryKey,
    required this.showRotationControl,
    required this.showScaleControl,
    required this.showRemoveControl,
    this.rotationControlBuilder,
    this.scaleControlBuilder,
    this.removeControlBuilder,
    required this.onScalePanStart,
    required this.onScalePanUpdate,
    required this.onScalePanEnd,
    required this.onRotationPanStart,
    required this.onRotationPanUpdate,
    required this.onRotationPanEnd,
    this.onRemoveTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-left corner - remove control (index 8)
        if (showRemoveControl && onRemoveTap != null)
          ObjectCornerControl(
            position: CornerPosition.topLeft,
            type: CornerControlType.remove,
            indicatorInset: indicatorInset,
            controlSize: controlSize,
            cornerOffset: cornerOffset,
            isActive: false, // Remove control doesn't have active state
            customWidgetBuilder: removeControlBuilder,
            onTap: onRemoveTap, // Async tap callback
            onPanStart: (details) {}, // No-op for remove
            onPanUpdate: (details) {}, // No-op for remove
            onPanEnd: (details) {}, // No-op for remove
          ),
        // Top-right corner - rotation control (index 2)
        if (showRotationControl)
          ObjectCornerControl(
            position: CornerPosition.topRight,
            type: CornerControlType.rotation,
            indicatorInset: indicatorInset,
            controlSize: controlSize,
            cornerOffset: cornerOffset,
            isActive: controlsAreActive[2] ?? false,
            activeStates: initialScaleDrawables.containsKey(entryKey)
                ? controlsAreActive
                : null,
            customWidgetBuilder: rotationControlBuilder,
            onPanStart: (details) => onRotationPanStart(2, details),
            onPanUpdate: (details) => onRotationPanUpdate(2, details),
            onPanEnd: (details) => onRotationPanEnd(2, details),
          ),
        // Bottom-right corner - resize/scale control (index 3)
        if (showScaleControl)
          ObjectCornerControl(
            position: CornerPosition.bottomRight,
            type: CornerControlType.scale,
            indicatorInset: indicatorInset,
            controlSize: controlSize,
            cornerOffset: cornerOffset,
            isActive: controlsAreActive[3] ?? false,
            customWidgetBuilder: scaleControlBuilder,
            onPanStart: (details) => onScalePanStart(3, details),
            onPanUpdate: (details) => onScalePanUpdate(3, details),
            onPanEnd: (details) => onScalePanEnd(3, details),
          ),
      ],
    );
  }
}
