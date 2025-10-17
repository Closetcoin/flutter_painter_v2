import 'package:flutter/foundation.dart';

/// Represents settings that control the accessibility and visibility of object controls.
/// These settings help optimize the UI for different input methods (touch vs mouse).
@immutable
class AccessibilityControlsSettings {
  /// Whether to enlarge the object corner controls (20px vs 10px).
  /// Larger controls are easier to tap and drag on touch screens.
  ///
  /// By default, this is `true` on mobile platforms (larger touch targets)
  /// and `false` on desktop platforms (smaller mouse targets).
  final bool enlargeControls;

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

  /// Creates an [AccessibilityControlsSettings] with the given values.
  ///
  /// If not specified, defaults are platform-dependent:
  /// - Mobile: enlargeControls=true, controls hidden (pinch gestures preferred)
  /// - Desktop: enlargeControls=false, controls shown (mouse precision)
  const AccessibilityControlsSettings({
    this.enlargeControls = false,
    this.showRotationControl = true,
    this.showScaleControl = true,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  AccessibilityControlsSettings copyWith({
    bool? enlargeControls,
    bool? showRotationControl,
    bool? showScaleControl,
  }) {
    return AccessibilityControlsSettings(
      enlargeControls: enlargeControls ?? this.enlargeControls,
      showRotationControl: showRotationControl ?? this.showRotationControl,
      showScaleControl: showScaleControl ?? this.showScaleControl,
    );
  }

  /// Compares two [AccessibilityControlsSettings] for equality.
  @override
  bool operator ==(Object other) {
    return other is AccessibilityControlsSettings &&
        other.enlargeControls == enlargeControls &&
        other.showRotationControl == showRotationControl &&
        other.showScaleControl == showScaleControl;
  }

  @override
  int get hashCode => Object.hash(
        enlargeControls,
        showRotationControl,
        showScaleControl,
      );
}
