import 'package:flutter/material.dart';
import 'object_edge_control.dart';
import '../../../controllers/settings/settings.dart';

/// Renders all 4 stretch controls for ImageDrawables.
/// This eliminates the duplication of nearly identical code for each edge.
class ObjectStretchControls extends StatelessWidget {
  final double totalWidth;
  final double totalHeight;
  final double stretchControlsSize;
  final StretchControlsSettings settings;
  final Map<int, bool> controlsAreActive;
  final void Function(int controlIndex, DragStartDetails details) onPanStart;
  final void Function(int controlIndex, DragUpdateDetails details) onPanUpdate;
  final void Function(int controlIndex, DragEndDetails details) onPanEnd;

  const ObjectStretchControls({
    Key? key,
    required this.totalWidth,
    required this.totalHeight,
    required this.stretchControlsSize,
    required this.settings,
    required this.controlsAreActive,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top edge - vertical stretch (control index 4)
        if (settings.showVerticalControls)
          ObjectEdgeControl(
            position: EdgePosition.top,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            controlSize: stretchControlsSize,
            tapTargetSize: settings.tapTargetSize,
            isActive: controlsAreActive[4] ?? false,
            onPanStart: (details) => onPanStart(4, details),
            onPanUpdate: (details) => onPanUpdate(4, details),
            onPanEnd: (details) => onPanEnd(4, details),
            inactiveColor: settings.inactiveColor,
            activeColor: settings.activeColor,
            shadowColor: settings.shadowColor,
            shadowBlurRadius: settings.shadowBlurRadius,
            borderColor: settings.borderColor,
            borderWidth: settings.borderWidth,
            controlShape: settings.controlShape,
          ),
        // Bottom edge - vertical stretch (control index 5)
        if (settings.showVerticalControls)
          ObjectEdgeControl(
            position: EdgePosition.bottom,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            controlSize: stretchControlsSize,
            tapTargetSize: settings.tapTargetSize,
            isActive: controlsAreActive[5] ?? false,
            onPanStart: (details) => onPanStart(5, details),
            onPanUpdate: (details) => onPanUpdate(5, details),
            onPanEnd: (details) => onPanEnd(5, details),
            inactiveColor: settings.inactiveColor,
            activeColor: settings.activeColor,
            shadowColor: settings.shadowColor,
            shadowBlurRadius: settings.shadowBlurRadius,
            borderColor: settings.borderColor,
            borderWidth: settings.borderWidth,
            controlShape: settings.controlShape,
          ),
        // Left edge - horizontal stretch (control index 6)
        if (settings.showHorizontalControls)
          ObjectEdgeControl(
            position: EdgePosition.left,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            controlSize: stretchControlsSize,
            tapTargetSize: settings.tapTargetSize,
            isActive: controlsAreActive[6] ?? false,
            onPanStart: (details) => onPanStart(6, details),
            onPanUpdate: (details) => onPanUpdate(6, details),
            onPanEnd: (details) => onPanEnd(6, details),
            inactiveColor: settings.inactiveColor,
            activeColor: settings.activeColor,
            shadowColor: settings.shadowColor,
            shadowBlurRadius: settings.shadowBlurRadius,
            borderColor: settings.borderColor,
            borderWidth: settings.borderWidth,
            controlShape: settings.controlShape,
          ),
        // Right edge - horizontal stretch (control index 7)
        if (settings.showHorizontalControls)
          ObjectEdgeControl(
            position: EdgePosition.right,
            totalWidth: totalWidth,
            totalHeight: totalHeight,
            controlSize: stretchControlsSize,
            tapTargetSize: settings.tapTargetSize,
            isActive: controlsAreActive[7] ?? false,
            onPanStart: (details) => onPanStart(7, details),
            onPanUpdate: (details) => onPanUpdate(7, details),
            onPanEnd: (details) => onPanEnd(7, details),
            inactiveColor: settings.inactiveColor,
            activeColor: settings.activeColor,
            shadowColor: settings.shadowColor,
            shadowBlurRadius: settings.shadowBlurRadius,
            borderColor: settings.borderColor,
            borderWidth: settings.borderWidth,
            controlShape: settings.controlShape,
          ),
      ],
    );
  }
}
