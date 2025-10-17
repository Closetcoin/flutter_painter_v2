import 'package:flutter/material.dart';
import '../../controllers/drawables/object_drawable.dart';
import '../../controllers/drawables/image_drawable.dart';
import '../../controllers/settings/stretch_controls_settings.dart';

/// Centralizes all layout calculations for object drawables.
/// This prevents repeated calculations and makes the layout logic easier to understand.
class ObjectLayoutCalculator {
  final ObjectDrawable drawable;
  final BoxConstraints constraints;
  final double objectPadding;
  final double transformationScale;
  final StretchControlsSettings stretchControlsSettings;
  final bool isSelected;

  ObjectLayoutCalculator({
    required this.drawable,
    required this.constraints,
    required this.objectPadding,
    required this.transformationScale,
    required this.stretchControlsSettings,
    required this.isSelected,
  });

  /// The size of the drawable content
  Size get contentSize => drawable.getSize(maxWidth: constraints.maxWidth);

  /// Whether this drawable can have stretch controls
  bool get canHaveStretchControls =>
      drawable is ImageDrawable && stretchControlsSettings.enabled;

  /// Whether stretch controls should be rendered
  bool get shouldRenderStretchControls => isSelected && canHaveStretchControls;

  /// Clamped size of stretch control boxes
  double get stretchControlsSize =>
      (stretchControlsSettings.controlSize / transformationScale)
          .clamp(8.0, 50.0);

  /// Offset distance for stretch controls from the border
  double get stretchControlsOffset =>
      stretchControlsSettings.controlOffset / transformationScale;

  /// Extra space needed for stretch controls and their tap targets
  double get stretchControlsExtension => canHaveStretchControls
      ? stretchControlsOffset +
          (stretchControlsSize * stretchControlsSettings.tapTargetSize / 2)
      : 0.0;

  /// The inner padding (objectPadding + stretch controls space)
  double get innerPadding => objectPadding + stretchControlsExtension;

  /// Total width including all padding and controls
  double get totalWidth =>
      contentSize.width + (objectPadding * 2) + (stretchControlsExtension * 2);

  /// Total height including all padding and controls
  double get totalHeight =>
      contentSize.height + (objectPadding * 2) + (stretchControlsExtension * 2);

  /// Top-left position for the entire container
  Offset get containerTopLeft => Offset(
        drawable.position.dx - totalWidth / 2,
        drawable.position.dy - totalHeight / 2,
      );
}
