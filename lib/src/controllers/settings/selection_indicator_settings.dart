import 'package:flutter/material.dart';

/// Settings for customizing the selection indicator appearance and behavior.
class SelectionIndicatorSettings {
  /// The border radius of the selection indicator.
  final double borderRadius;

  /// The color of the selection indicator border.
  final Color borderColor;

  /// The width of the selection indicator border.
  final double borderWidth;

  /// The shadow color of the selection indicator.
  final Color shadowColor;

  /// The blur radius of the shadow.
  final double shadowBlurRadius;

  /// The offset of the shadow.
  final Offset shadowOffset;

  /// The padding around the object for the selection indicator.
  final double padding;

  /// Whether the selection indicator is enabled.
  final bool enabled;

  /// Creates a new [SelectionIndicatorSettings] instance.
  const SelectionIndicatorSettings({
    this.borderRadius = 0.0,
    this.borderColor = Colors.blue,
    this.borderWidth = 2.0,
    this.shadowColor = Colors.transparent,
    this.shadowBlurRadius = 0.0,
    this.shadowOffset = const Offset(0, 0),
    this.padding = 30.0,
    this.enabled = true,
  });

  /// Creates a copy of this [SelectionIndicatorSettings] with the given
  /// fields replaced with the new values.
  SelectionIndicatorSettings copyWith({
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? shadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? padding,
    bool? enabled,
  }) {
    return SelectionIndicatorSettings(
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      padding: padding ?? this.padding,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SelectionIndicatorSettings &&
        other.borderRadius == borderRadius &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.shadowColor == shadowColor &&
        other.shadowBlurRadius == shadowBlurRadius &&
        other.shadowOffset == shadowOffset &&
        other.padding == padding &&
        other.enabled == enabled;
  }

  @override
  int get hashCode {
    return borderRadius.hashCode ^
        borderColor.hashCode ^
        borderWidth.hashCode ^
        shadowColor.hashCode ^
        shadowBlurRadius.hashCode ^
        shadowOffset.hashCode ^
        padding.hashCode ^
        enabled.hashCode;
  }
}
