import 'package:flutter/foundation.dart';

/// Represents settings for the background remover functionality.
@immutable
class BackgroundRemoverSettings {
  /// Threshold for background removal (0..1).
  /// Higher values remove more background.
  /// Defaults to 0.5.
  final double threshold;

  /// Whether to apply bilinear smoothing to mask edges.
  /// Defaults to true.
  final bool smoothMask;

  /// Whether to apply extra refinement on boundaries.
  /// Defaults to true.
  final bool enhanceEdges;

  /// Padding in pixels to add as a transparent border around the image.
  /// Defaults to 6.
  final int padPx;

  /// Creates a [BackgroundRemoverSettings] with the given values.
  const BackgroundRemoverSettings({
    this.threshold = 0.5,
    this.smoothMask = true,
    this.enhanceEdges = true,
    this.padPx = 6,
  });

  /// Creates a copy of this but with the given fields replaced with the new values.
  BackgroundRemoverSettings copyWith({
    double? threshold,
    bool? smoothMask,
    bool? enhanceEdges,
    int? padPx,
  }) {
    return BackgroundRemoverSettings(
      threshold: threshold ?? this.threshold,
      smoothMask: smoothMask ?? this.smoothMask,
      enhanceEdges: enhanceEdges ?? this.enhanceEdges,
      padPx: padPx ?? this.padPx,
    );
  }
}
