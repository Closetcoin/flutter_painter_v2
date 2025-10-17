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

  /// Draws the image with proper support for independent scaleX/scaleY.
  /// Overrides the parent draw method to handle eraseMask with non-uniform scaling.
  @override
  void draw(Canvas canvas, Size size) {
    if (hidden) return;

    canvas.save();

    // Draw assist lines first (these are not affected by rotation)
    drawAssists(canvas, size);

    // Translate to object position, then rotate
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-position.dx, -position.dy);

    // If there are erase masks, apply them using saveLayer
    if (eraseMask.isNotEmpty) {
      // Save a new layer for applying the erase mask
      canvas.saveLayer(null, Paint());

      // Draw the object
      drawObject(canvas, size);

      // Apply erase masks by drawing paths with BlendMode.clear
      // For ImageDrawable, we need to use scaleX and scaleY instead of uniform scale
      final erasePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.clear
        ..strokeWidth = 10 *
            ((scaleX + scaleY) /
                2); // Use average of scaleX and scaleY for stroke width

      // Check if this drawable is horizontally flipped
      final isFlipped = isFlippedHorizontally;

      // Apply the same flip transformation as the object if needed
      if (isFlipped) {
        canvas.save();
        canvas.scale(-1, 1);
      }

      // The erase paths are stored in object-local coordinates (unscaled, unrotated, unflipped)
      // We need to transform them to canvas coordinates using scaleX and scaleY
      for (final localErasePath in eraseMask) {
        if (localErasePath.length < 2) continue;

        final canvasPath = Path();
        bool firstPoint = true;

        for (final localPoint in localErasePath) {
          // Transform local point to canvas coordinates
          // Apply scaleX and scaleY for proper stretching support
          final flippedPosition = isFlipped ? position.scale(-1, 1) : position;

          final scaledPoint = Offset(
            flippedPosition.dx + localPoint.dx * scaleX,
            flippedPosition.dy + localPoint.dy * scaleY,
          );

          if (firstPoint) {
            canvasPath.moveTo(scaledPoint.dx, scaledPoint.dy);
            firstPoint = false;
          } else {
            canvasPath.lineTo(scaledPoint.dx, scaledPoint.dy);
          }
        }

        canvas.drawPath(canvasPath, erasePaint);
      }

      if (isFlipped) {
        canvas.restore();
      }

      // Restore the layer
      canvas.restore();
    } else {
      // No erase mask, just draw the object normally
      drawObject(canvas, size);
    }

    canvas.restore();
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
