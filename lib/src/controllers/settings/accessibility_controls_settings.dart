import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Type definition for custom control widget builders.
/// [isActive] is true when the control is being dragged.
typedef ControlWidgetBuilder = Widget Function(bool isActive);

/// Represents settings that control the accessibility and visibility of object controls.
/// These settings help optimize the UI for different input methods (touch vs mouse).
@immutable
class AccessibilityControlsSettings {
  /// Whether to show the rotation control in the top-right corner.
  /// This control allows rotating the object by dragging.
  ///
  /// On touch screens, rotation can be controlled with two-finger twist gestures,
  /// so this control may not be needed.
  ///
  /// By default, this is `true` on desktop platforms and `false` on mobile platforms.
  final bool showRotationControl;

  /// Whether to show the scale/resize control in the bottom-right corner.
  /// This control allows uniform scaling by dragging.
  ///
  /// On touch screens, scaling can be controlled with pinch gestures,
  /// so this control may not be needed.
  ///
  /// By default, this is `true` on desktop platforms and `false` on mobile platforms.
  final bool showScaleControl;

  /// The size of the corner controls in logical pixels.
  /// This determines the width and height of the circular control buttons.
  ///
  /// Defaults to 20.0 for a good balance between visibility and unobtrusiveness.
  final double controlSize;

  /// The diagonal offset distance for corner controls from the indicator corner.
  /// This moves controls outward on a 45-degree diagonal line from the corner.
  ///
  /// For example, an offset of 10.0 will move the control 10px right and 10px down
  /// from the bottom-right corner (or appropriate direction for other corners).
  ///
  /// Defaults to 24.0 (controls positioned away from the corner for better visibility).
  final double cornerOffset;

  /// Optional custom widget builder for the rotation control.
  /// If provided, this widget will be used instead of the default circular icon button.
  /// The builder receives [isActive] which is true when the control is being dragged.
  final ControlWidgetBuilder? rotationControlBuilder;

  /// Optional custom widget builder for the scale control.
  /// If provided, this widget will be used instead of the default circular icon button.
  /// The builder receives [isActive] which is true when the control is being dragged.
  final ControlWidgetBuilder? scaleControlBuilder;

  /// Creates an [AccessibilityControlsSettings] with the given values.
  ///
  /// By default on desktop, both controls are shown.
  /// On mobile, controls are hidden (pinch gestures preferred).
  const AccessibilityControlsSettings({
    this.showRotationControl = true,
    this.showScaleControl = true,
    this.controlSize = 20.0,
    this.cornerOffset = 24.0,
    this.rotationControlBuilder,
    this.scaleControlBuilder,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ///
  /// Note: To clear a widget builder, pass an explicit null-returning function.
  /// To keep the existing builder, don't pass the parameter.
  AccessibilityControlsSettings copyWith({
    bool? showRotationControl,
    bool? showScaleControl,
    double? controlSize,
    double? cornerOffset,
    ControlWidgetBuilder? rotationControlBuilder,
    ControlWidgetBuilder? scaleControlBuilder,
    bool clearRotationBuilder = false,
    bool clearScaleBuilder = false,
  }) {
    return AccessibilityControlsSettings(
      showRotationControl: showRotationControl ?? this.showRotationControl,
      showScaleControl: showScaleControl ?? this.showScaleControl,
      controlSize: controlSize ?? this.controlSize,
      cornerOffset: cornerOffset ?? this.cornerOffset,
      rotationControlBuilder: clearRotationBuilder
          ? null
          : (rotationControlBuilder ?? this.rotationControlBuilder),
      scaleControlBuilder: clearScaleBuilder
          ? null
          : (scaleControlBuilder ?? this.scaleControlBuilder),
    );
  }

  /// Compares two [AccessibilityControlsSettings] for equality.
  @override
  bool operator ==(Object other) {
    return other is AccessibilityControlsSettings &&
        other.showRotationControl == showRotationControl &&
        other.showScaleControl == showScaleControl &&
        other.controlSize == controlSize &&
        other.cornerOffset == cornerOffset;
  }

  @override
  int get hashCode => Object.hash(
        showRotationControl,
        showScaleControl,
        controlSize,
        cornerOffset,
      );
}
