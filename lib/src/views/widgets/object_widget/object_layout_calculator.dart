import 'package:flutter/material.dart';
import '../../../controllers/drawables/object_drawable.dart';
import '../../../controllers/drawables/image_drawable.dart';
import '../../../controllers/settings/stretch_controls_settings.dart';

/// Centralizes all layout calculations for object drawables.
/// This prevents repeated calculations and makes the layout logic easier to understand.
class ObjectLayoutCalculator {
  final ObjectDrawable drawable;
  final BoxConstraints constraints;
  final double objectPadding;
  final double transformationScale;
  final StretchControlsSettings stretchControlsSettings;
  final bool isSelected;
  final double cornerControlsSize;
  final double cornerControlsOffset;
  final bool showCornerControls;

  ObjectLayoutCalculator({
    required this.drawable,
    required this.constraints,
    required this.objectPadding,
    required this.transformationScale,
    required this.stretchControlsSettings,
    required this.isSelected,
    required this.cornerControlsSize,
    required this.cornerControlsOffset,
    required this.showCornerControls,
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

  /// Extra space needed for corner controls (rotation/scale)
  /// This accounts for the control size and diagonal offset
  double get cornerControlsExtension => (isSelected && showCornerControls)
      ? cornerControlsOffset + (cornerControlsSize / 2)
      : 0.0;

  /// The maximum extension needed (either from stretch or corner controls)
  double get maxControlsExtension =>
      stretchControlsExtension > cornerControlsExtension
          ? stretchControlsExtension
          : cornerControlsExtension;

  /// The inner padding uses the max extension
  /// Content is positioned to leave room for whichever control needs more space
  double get innerPadding => maxControlsExtension + objectPadding;

  /// Total width including all padding and max controls extension
  /// Uses the max of stretch or corner controls, not the sum
  double get totalWidth =>
      contentSize.width + (objectPadding * 2) + (maxControlsExtension * 2);

  /// Total height including all padding and max controls extension
  /// Uses the max of stretch or corner controls, not the sum
  double get totalHeight =>
      contentSize.height + (objectPadding * 2) + (maxControlsExtension * 2);

  /// Top-left position for the entire container
  Offset get containerTopLeft => Offset(
        drawable.position.dx - totalWidth / 2,
        drawable.position.dy - totalHeight / 2,
      );
}
