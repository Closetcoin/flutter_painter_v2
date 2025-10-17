import 'package:flutter/material.dart';
import 'object_corner_controls.dart';

/// Renders the corner controls for scaling and rotation.
class ObjectScaleRotationControls extends StatelessWidget {
  final double stretchControlsExtension;
  final double controlSize;
  final Map<int, bool> controlsAreActive;
  final Map<int, dynamic> initialScaleDrawables; // For rotation cursor state
  final int entryKey;
  final bool showRotationControl;
  final bool showScaleControl;
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

  const ObjectScaleRotationControls({
    Key? key,
    required this.stretchControlsExtension,
    required this.controlSize,
    required this.controlsAreActive,
    required this.initialScaleDrawables,
    required this.entryKey,
    required this.showRotationControl,
    required this.showScaleControl,
    required this.onScalePanStart,
    required this.onScalePanUpdate,
    required this.onScalePanEnd,
    required this.onRotationPanStart,
    required this.onRotationPanUpdate,
    required this.onRotationPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right corner - rotation control (index 2)
        if (showRotationControl)
          ObjectCornerControl(
            position: CornerPosition.topRight,
            type: CornerControlType.rotation,
            stretchControlsExtension: stretchControlsExtension,
            controlSize: controlSize,
            isActive: controlsAreActive[2] ?? false,
            activeStates: initialScaleDrawables.containsKey(entryKey)
                ? controlsAreActive
                : null,
            onPanStart: (details) => onRotationPanStart(2, details),
            onPanUpdate: (details) => onRotationPanUpdate(2, details),
            onPanEnd: (details) => onRotationPanEnd(2, details),
          ),
        // Bottom-right corner - resize/scale control (index 3)
        if (showScaleControl)
          ObjectCornerControl(
            position: CornerPosition.bottomRight,
            type: CornerControlType.scale,
            stretchControlsExtension: stretchControlsExtension,
            controlSize: controlSize,
            isActive: controlsAreActive[3] ?? false,
            onPanStart: (details) => onScalePanStart(3, details),
            onPanUpdate: (details) => onScalePanUpdate(3, details),
            onPanEnd: (details) => onScalePanEnd(3, details),
          ),
      ],
    );
  }
}
