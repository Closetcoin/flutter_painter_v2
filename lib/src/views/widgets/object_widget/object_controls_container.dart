import 'package:flutter/material.dart';
import 'object_layout_calculator.dart';
import 'object_selection_indicator.dart';
import 'object_scale_rotation_controls.dart';
import 'object_stretch_controls.dart';
import 'object_resize_controls.dart';
import '../../../controllers/drawables/object_drawable.dart';
import '../../../controllers/drawables/sized2ddrawable.dart';
import '../../../controllers/settings/object_settings.dart';

/// Container widget that renders all controls for a selected object.
/// This includes selection indicator, scale/rotation controls, and optionally stretch or resize controls.
class ObjectControlsContainer extends StatelessWidget {
  final Widget contentWidget;
  final ObjectDrawable drawable;
  final ObjectLayoutCalculator layout;
  final ObjectSettings settings;
  final double transformationScale;
  final double controlsSize;
  final Map<int, bool> controlsAreActive;
  final Map<int, dynamic> initialScaleDrawables;
  final int entryKey;
  final bool showRotationControl;
  final bool showScaleControl;

  // Callbacks for scale controls
  final void Function(int, DragStartDetails) onScaleControlPanStart;
  final void Function(int, DragUpdateDetails) onScaleControlPanUpdate;
  final void Function(int, DragEndDetails) onScaleControlPanEnd;

  // Callbacks for rotation control
  final void Function(int, DragStartDetails) onRotationControlPanStart;
  final void Function(int, DragUpdateDetails) onRotationControlPanUpdate;
  final void Function(int, DragEndDetails) onRotationControlPanEnd;

  // Callbacks for image stretch controls
  final void Function(int, DragStartDetails)? onImageStretchControlPanStart;
  final void Function(int, DragUpdateDetails)? onImageStretchControlPanUpdate;
  final void Function(int, DragEndDetails)? onImageStretchControlPanEnd;

  // Callbacks for resize controls
  final void Function(int, DragStartDetails)? onResizeControlPanStart;
  final void Function(int, DragUpdateDetails)? onResizeControlPanUpdate;
  final void Function(int, DragEndDetails)? onResizeControlPanEnd;

  const ObjectControlsContainer({
    Key? key,
    required this.contentWidget,
    required this.drawable,
    required this.layout,
    required this.settings,
    required this.transformationScale,
    required this.controlsSize,
    required this.controlsAreActive,
    required this.initialScaleDrawables,
    required this.entryKey,
    required this.showRotationControl,
    required this.showScaleControl,
    required this.onScaleControlPanStart,
    required this.onScaleControlPanUpdate,
    required this.onScaleControlPanEnd,
    required this.onRotationControlPanStart,
    required this.onRotationControlPanUpdate,
    required this.onRotationControlPanEnd,
    this.onImageStretchControlPanStart,
    this.onImageStretchControlPanUpdate,
    this.onImageStretchControlPanEnd,
    this.onResizeControlPanStart,
    this.onResizeControlPanUpdate,
    this.onResizeControlPanEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: layout.totalWidth,
      height: layout.totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Center the content widget within the larger container
          Positioned(
            top: layout.innerPadding,
            left: layout.innerPadding,
            child: contentWidget,
          ),

          // Selection indicator - inset by the stretch controls space
          Positioned(
            top: layout.stretchControlsExtension,
            bottom: layout.stretchControlsExtension,
            left: layout.stretchControlsExtension,
            right: layout.stretchControlsExtension,
            child: ObjectSelectionIndicator(
              settings: settings.selectionIndicatorSettings,
              transformationScale: transformationScale,
            ),
          ),

          // Scale and rotation corner controls
          if (showRotationControl || showScaleControl)
            ObjectScaleRotationControls(
              stretchControlsExtension: layout.stretchControlsExtension,
              controlSize: controlsSize,
              controlsAreActive: controlsAreActive,
              initialScaleDrawables: initialScaleDrawables,
              entryKey: entryKey,
              showRotationControl: showRotationControl,
              showScaleControl: showScaleControl,
              onScalePanStart: onScaleControlPanStart,
              onScalePanUpdate: onScaleControlPanUpdate,
              onScalePanEnd: onScaleControlPanEnd,
              onRotationPanStart: onRotationControlPanStart,
              onRotationPanUpdate: onRotationControlPanUpdate,
              onRotationPanEnd: onRotationControlPanEnd,
            ),

          // Image stretch controls (only for ImageDrawable)
          if (layout.shouldRenderStretchControls &&
              onImageStretchControlPanStart != null &&
              onImageStretchControlPanUpdate != null &&
              onImageStretchControlPanEnd != null)
            ObjectStretchControls(
              totalWidth: layout.totalWidth,
              totalHeight: layout.totalHeight,
              stretchControlsSize: layout.stretchControlsSize,
              settings: settings.stretchControlsSettings,
              controlsAreActive: controlsAreActive,
              onPanStart: onImageStretchControlPanStart!,
              onPanUpdate: onImageStretchControlPanUpdate!,
              onPanEnd: onImageStretchControlPanEnd!,
            ),

          // Resize controls (only for Sized2DDrawable)
          if (drawable is Sized2DDrawable &&
              onResizeControlPanStart != null &&
              onResizeControlPanUpdate != null &&
              onResizeControlPanEnd != null)
            ObjectResizeControls(
              stretchControlsExtension: layout.stretchControlsExtension,
              totalWidth: layout.totalWidth,
              totalHeight: layout.totalHeight,
              controlSize: controlsSize,
              controlsAreActive: controlsAreActive,
              onPanStart: onResizeControlPanStart!,
              onPanUpdate: onResizeControlPanUpdate!,
              onPanEnd: onResizeControlPanEnd!,
            ),
        ],
      ),
    );
  }
}
