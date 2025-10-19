import 'dart:math';

import 'package:flutter/foundation.dart';

import 'haptic_feedback_settings.dart';
import 'background_remover_settings.dart';
import 'smart_cropping_settings.dart';
import 'stretch_controls_settings.dart';
import 'selection_indicator_settings.dart';
import 'accessibility_controls_settings.dart';

// Removed unnecessary function typedef - now using simple bool

/// Represents settings used to control object drawables in the UI
@immutable
class ObjectSettings {
  /// The layout-assist settings of the current object.
  final ObjectLayoutAssistSettings layoutAssist;

  /// Accessibility settings for object controls.
  /// Controls the size and visibility of corner controls for better touch/mouse support.
  final AccessibilityControlsSettings accessibilityControls;

  /// Whether to automatically select an object drawable after it is added.
  ///
  /// When `true`, newly added image drawables will be automatically selected,
  /// making them immediately editable without requiring a manual tap.
  ///
  /// Defaults to `false`.
  final bool autoSelectAfterAdd;

  /// Whether to allow only a single object drawable at a time.
  ///
  /// When `true`, adding a new object drawable (like an image or text) will automatically
  /// remove all existing object drawables. Additionally, the object cannot be deselected
  /// by tapping the background - it will always remain selected. Free-style drawings,
  /// shapes, and backgrounds are not affected by this setting.
  ///
  /// Defaults to `false`.
  final bool singleObjectMode;

  /// Settings for background removal operations.
  final BackgroundRemoverSettings backgroundRemoverSettings;

  /// Settings for smart cropping after background removal.
  final SmartCroppingSettings smartCroppingSettings;

  /// Settings for stretch controls on images.
  final StretchControlsSettings stretchControlsSettings;

  /// Settings for the selection indicator appearance and behavior.
  final SelectionIndicatorSettings selectionIndicatorSettings;

  /// Whether crop mode is enabled for ImageDrawables.
  ///
  /// When `true`, stretch controls will crop the image instead of stretching it.
  /// This allows users to crop images by dragging the edge controls.
  ///
  /// Defaults to `false`.
  final bool cropMode;

  /// Creates a [ObjectSettings] with the given values.
  const ObjectSettings({
    this.layoutAssist = const ObjectLayoutAssistSettings(),
    this.accessibilityControls = const AccessibilityControlsSettings(),
    this.autoSelectAfterAdd = false,
    this.singleObjectMode = false,
    this.backgroundRemoverSettings = const BackgroundRemoverSettings(),
    this.smartCroppingSettings = const SmartCroppingSettings(),
    this.stretchControlsSettings = const StretchControlsSettings(),
    this.selectionIndicatorSettings = const SelectionIndicatorSettings(),
    this.cropMode = false,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ObjectSettings copyWith({
    ObjectLayoutAssistSettings? layoutAssist,
    AccessibilityControlsSettings? accessibilityControls,
    bool? autoSelectAfterAdd,
    bool? singleObjectMode,
    BackgroundRemoverSettings? backgroundRemoverSettings,
    SmartCroppingSettings? smartCroppingSettings,
    StretchControlsSettings? stretchControlsSettings,
    SelectionIndicatorSettings? selectionIndicatorSettings,
    bool? cropMode,
  }) {
    return ObjectSettings(
      layoutAssist: layoutAssist ?? this.layoutAssist,
      accessibilityControls:
          accessibilityControls ?? this.accessibilityControls,
      autoSelectAfterAdd: autoSelectAfterAdd ?? this.autoSelectAfterAdd,
      singleObjectMode: singleObjectMode ?? this.singleObjectMode,
      backgroundRemoverSettings:
          backgroundRemoverSettings ?? this.backgroundRemoverSettings,
      smartCroppingSettings:
          smartCroppingSettings ?? this.smartCroppingSettings,
      stretchControlsSettings:
          stretchControlsSettings ?? this.stretchControlsSettings,
      selectionIndicatorSettings:
          selectionIndicatorSettings ?? this.selectionIndicatorSettings,
      cropMode: cropMode ?? this.cropMode,
    );
  }
}

/// Represents settings that control the behavior of layout assist for objects.
///
/// Layout assist helps in arranging objects by snapping them to common arrangements
/// (such as vertical and horizontal centers, right angle rotations, etc...).
@immutable
class ObjectLayoutAssistSettings {
  /// The default value for [positionalEnterDistance].
  static const double defaultPositionalEnterDistance = 1;

  /// The default value for [positionalExitDistance].
  static const double defaultPositionalExitDistance = 10;

  /// The default value for [rotationalEnterAngle].
  static const double defaultRotationalEnterAngle = pi / 80;

  /// The default value for [rotationalExitAngle].
  static const double defaultRotationalExitAngle = pi / 16;

  /// Have layout assist enabled or not.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// What kind of haptic feedback to trigger when the object snaps to an arrangement.
  ///
  /// Defaults to [HapticFeedbackSettings.medium].
  final HapticFeedbackSettings hapticFeedback;

  /// The distance from center to detect that the object reached the assist area.
  ///
  /// When the object is this distance close to the center, it enters layout assist.
  final double positionalEnterDistance;

  /// The distance from center to detect that the object exited the assist area.
  ///
  /// When the object is this distance far from the center, it leaves layout assist.
  final double positionalExitDistance;

  /// The angle to detect that the object entered the rotational assist range.
  ///
  /// When the object is this angle close to an assist angle, it starts layout assist.
  final double rotationalEnterAngle;

  /// The angle to detect that the object exited the rotational assist range.
  ///
  /// When the object is this angle far from an assist angle, it leaves layout assist.
  final double rotationalExitAngle;

  /// Creates an [ObjectLayoutAssistSettings].
  const ObjectLayoutAssistSettings({
    this.enabled = true,
    this.hapticFeedback = HapticFeedbackSettings.medium,
    this.positionalEnterDistance = defaultPositionalEnterDistance,
    this.positionalExitDistance = defaultPositionalExitDistance,
    this.rotationalEnterAngle = defaultRotationalEnterAngle,
    this.rotationalExitAngle = defaultRotationalExitAngle,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  ObjectLayoutAssistSettings copyWith({
    bool? enabled,
    HapticFeedbackSettings? hapticFeedback,
    double? positionalEnterDistance,
    double? positionalExitDistance,
    double? rotationalEnterAngle,
    double? rotationalExitAngle,
  }) {
    return ObjectLayoutAssistSettings(
      enabled: enabled ?? this.enabled,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      positionalEnterDistance:
          positionalEnterDistance ?? this.positionalEnterDistance,
      positionalExitDistance:
          positionalExitDistance ?? this.positionalExitDistance,
      rotationalEnterAngle: rotationalEnterAngle ?? this.rotationalEnterAngle,
      rotationalExitAngle: rotationalExitAngle ?? this.rotationalExitAngle,
    );
  }
}
