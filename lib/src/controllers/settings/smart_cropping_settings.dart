import 'package:flutter/foundation.dart';

/// Represents settings for smart square cropping after background removal.
@immutable
class SmartCroppingSettings {
  /// Whether to apply smart square crop after background removal.
  /// Defaults to true.
  final bool enabled;

  /// Alpha threshold for crop detection (0..255).
  /// Pixels with alpha above this value are considered part of the subject.
  /// Defaults to 12.
  final int alphaThreshold;

  /// Extra margin around the subject as a fraction (0..1).
  /// For example, 0.08 means 8% margin.
  /// Defaults to 0.08.
  final double marginFrac;

  /// Minimum crop size in pixels.
  /// The cropped image will not be smaller than this size.
  /// Defaults to 100.
  final int minSidePx;

  /// Sampling stride for faster crop detection.
  /// Higher values speed up detection but may be less precise.
  /// Defaults to 2.
  final int stride;

  /// Creates a [SmartCroppingSettings] with the given values.
  const SmartCroppingSettings({
    this.enabled = true,
    this.alphaThreshold = 12,
    this.marginFrac = 0.08,
    this.minSidePx = 100,
    this.stride = 2,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  SmartCroppingSettings copyWith({
    bool? enabled,
    int? alphaThreshold,
    double? marginFrac,
    int? minSidePx,
    int? stride,
  }) {
    return SmartCroppingSettings(
      enabled: enabled ?? this.enabled,
      alphaThreshold: alphaThreshold ?? this.alphaThreshold,
      marginFrac: marginFrac ?? this.marginFrac,
      minSidePx: minSidePx ?? this.minSidePx,
      stride: stride ?? this.stride,
    );
  }
}
