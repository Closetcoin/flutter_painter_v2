import 'package:flutter/material.dart';

/// Represents settings that control the appearance and behavior of stretch controls for images.
@immutable
class StretchControlsSettings {
  /// The size of the control boxes.
  ///
  /// Defaults to `10.0`.
  final double controlSize;

  /// The offset distance from the center of the edge to position the control box.
  /// Positive values move the control outward from the center.
  ///
  /// Defaults to `25.0`.
  final double controlOffset;

  /// The color of the control box when it's not active.
  ///
  /// Defaults to `Colors.white`.
  final Color inactiveColor;

  /// The color of the control box when it's active (being dragged).
  ///
  /// Defaults to `Colors.blue`.
  final Color activeColor;

  /// The color of the shadow surrounding the control box.
  ///
  /// Defaults to `Colors.black`.
  final Color shadowColor;

  /// The blur radius of the shadow.
  ///
  /// Defaults to `2.0`.
  final double shadowBlurRadius;

  /// The color of the control box border.
  ///
  /// Defaults to `Colors.grey`.
  final Color borderColor;

  /// The thickness of the control box border.
  ///
  /// Defaults to `1.0`.
  final double borderWidth;

  /// The shape of the control box.
  ///
  /// Defaults to `BoxShape.rectangle`.
  final BoxShape controlShape;

  /// Whether to show the stretch controls.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// Whether to show stretch controls on the top and bottom edges.
  ///
  /// Defaults to `true`.
  final bool showVerticalControls;

  /// Whether to show stretch controls on the left and right edges.
  ///
  /// Defaults to `true`.
  final bool showHorizontalControls;

  /// Creates a [StretchControlsSettings] with the given values.
  const StretchControlsSettings({
    this.controlSize = 10.0,
    this.controlOffset = 25.0,
    this.inactiveColor = Colors.white,
    this.activeColor = Colors.blue,
    this.shadowColor = Colors.black,
    this.shadowBlurRadius = 2.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.controlShape = BoxShape.rectangle,
    this.enabled = true,
    this.showVerticalControls = true,
    this.showHorizontalControls = true,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  StretchControlsSettings copyWith({
    double? controlSize,
    double? controlOffset,
    Color? inactiveColor,
    Color? activeColor,
    Color? shadowColor,
    double? shadowBlurRadius,
    Color? borderColor,
    double? borderWidth,
    BoxShape? controlShape,
    bool? enabled,
    bool? showVerticalControls,
    bool? showHorizontalControls,
  }) {
    return StretchControlsSettings(
      controlSize: controlSize ?? this.controlSize,
      controlOffset: controlOffset ?? this.controlOffset,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      activeColor: activeColor ?? this.activeColor,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      controlShape: controlShape ?? this.controlShape,
      enabled: enabled ?? this.enabled,
      showVerticalControls: showVerticalControls ?? this.showVerticalControls,
      showHorizontalControls:
          showHorizontalControls ?? this.showHorizontalControls,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StretchControlsSettings &&
        other.controlSize == controlSize &&
        other.controlOffset == controlOffset &&
        other.inactiveColor == inactiveColor &&
        other.activeColor == activeColor &&
        other.shadowColor == shadowColor &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.controlShape == controlShape &&
        other.enabled == enabled &&
        other.showVerticalControls == showVerticalControls &&
        other.showHorizontalControls == showHorizontalControls;
  }

  @override
  int get hashCode {
    return Object.hash(
      controlSize,
      controlOffset,
      inactiveColor,
      activeColor,
      shadowColor,
      shadowBlurRadius,
      borderColor,
      borderWidth,
      controlShape,
      enabled,
      showVerticalControls,
      showHorizontalControls,
    );
  }
}
