import 'dart:ui';

import 'object_drawable.dart';

/// A drawable of an image as an object.
class ImageDrawable extends ObjectDrawable {
  /// The image to be drawn.
  final Image image;

  /// Whether the image is flipped or not.
  final bool flipped;

  /// Whether the background has been removed from this image.
  final bool backgroundRemoved;

  /// The scale factor for the X axis (width).
  final double scaleX;

  /// The scale factor for the Y axis (height).
  final double scaleY;

  /// Creates an [ImageDrawable] with the given [image].
  ImageDrawable({
    required Offset position,
    double rotationAngle = 0,
    double scale = 1,
    double? scaleX,
    double? scaleY,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    List<List<Offset>> eraseMask = const [],
    required this.image,
    this.flipped = false,
    this.backgroundRemoved = false,
  })  : scaleX = scaleX ?? scale,
        scaleY = scaleY ?? scale,
        super(
            position: position,
            rotationAngle: rotationAngle,
            scale: scale,
            assists: assists,
            assistPaints: assistPaints,
            hidden: hidden,
            locked: locked,
            eraseMask: eraseMask);

  /// Creates an [ImageDrawable] with the given [image], and calculates the scale based on the given [size].
  /// The scale will be calculated such that the size of the drawable fits into the provided size.
  ///
  /// For example, if the image was 512x256 and the provided size was 128x128, the scale would be 0.25,
  /// fitting the width of the image into the size (128x64).
  ImageDrawable.fittedToSize({
    required Offset position,
    required Size size,
    double rotationAngle = 0,
    Set<ObjectDrawableAssist> assists = const <ObjectDrawableAssist>{},
    Map<ObjectDrawableAssist, Paint> assistPaints =
        const <ObjectDrawableAssist, Paint>{},
    bool locked = false,
    bool hidden = false,
    List<List<Offset>> eraseMask = const [],
    required Image image,
    bool flipped = false,
    bool backgroundRemoved = false,
  }) : this(
            position: position,
            rotationAngle: rotationAngle,
            scale: _calculateScaleFittedToSize(image, size),
            assists: assists,
            assistPaints: assistPaints,
            image: image,
            flipped: flipped,
            hidden: hidden,
            locked: locked,
            eraseMask: eraseMask,
            backgroundRemoved: backgroundRemoved);

  /// Creates a copy of this but with the given fields replaced with the new values.
  @override
  ImageDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? scaleX,
    double? scaleY,
    Image? image,
    bool? flipped,
    bool? locked,
    List<List<Offset>>? eraseMask,
    bool? backgroundRemoved,
  }) {
    return ImageDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      image: image ?? this.image,
      flipped: flipped ?? this.flipped,
      locked: locked ?? this.locked,
      eraseMask: eraseMask ?? this.eraseMask,
      backgroundRemoved: backgroundRemoved ?? this.backgroundRemoved,
    );
  }

  /// Draws the image on the provided [canvas] of size [size].
  @override
  void drawObject(Canvas canvas, Size size) {
    final scaledSize = Offset(
      image.width.toDouble() * scaleX,
      image.height.toDouble() * scaleY,
    );
    final position = this.position.scale(flipped ? -1 : 1, 1);

    if (flipped) {
      canvas.save();
      canvas.scale(-1, 1);
    }

    // Draw the image onto the canvas.
    // Use filterQuality for better rendering when scaling
    canvas.drawImageRect(
        image,
        Rect.fromPoints(Offset.zero,
            Offset(image.width.toDouble(), image.height.toDouble())),
        Rect.fromPoints(position - scaledSize / 2, position + scaledSize / 2),
        Paint()..filterQuality = FilterQuality.high);

    if (flipped) {
      canvas.restore();
    }
  }

  /// Calculates the size of the rendered object.
  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    return Size(
      image.width * scaleX,
      image.height * scaleY,
    );
  }

  /// Returns whether this image drawable is horizontally flipped.
  @override
  bool get isFlippedHorizontally => flipped;

  /// Compares two [ImageDrawable]s for equality.
  // @override
  // bool operator ==(Object other) {
  //   return other is ImageDrawable &&
  //       super == other &&
  //       other.image == image;
  // }
  //
  // @override
  // int get hashCode => hashValues(
  //     hidden,
  //     hashList(assists),
  //     hashList(assistPaints.entries),
  //     position,
  //     rotationAngle,
  //     scale,
  //     image);

  static double _calculateScaleFittedToSize(Image image, Size size) {
    if (image.width >= image.height) {
      return size.width / image.width;
    } else {
      return size.height / image.height;
    }
  }
}
