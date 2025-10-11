import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_background_remover/image_background_remover.dart' as ibr;

/// Static utility class for background removal operations.
///
/// This class provides methods to remove backgrounds from images using
/// the image_background_remover package.
class BackgroundRemoverUtil {
  static bool _isInitialized = false;

  /// Initialize the background remover.
  ///
  /// This must be called once before using [removeBackground].
  static Future<void> initialize() async {
    if (_isInitialized) return;
    await ibr.BackgroundRemover.instance.initializeOrt();
    _isInitialized = true;
  }

  /// Dispose the background remover.
  ///
  /// Call this when the app is shutting down.
  static void dispose() {
    if (!_isInitialized) return;
    ibr.BackgroundRemover.instance.dispose();
    _isInitialized = false;
  }

  /// Check if the background remover is initialized.
  static bool get isInitialized => _isInitialized;

  /// Remove background from [inputImage].
  ///
  /// [inputImage]: The ui.Image to process.
  /// [threshold]: 0..1 (higher removes more background; default 0.5).
  /// [smoothMask]: bilinear smoothing of mask edges.
  /// [enhanceEdges]: extra refinement on boundaries.
  /// [padPx]: pad the image with a transparent border.
  /// [applyCrop]: whether to apply smart square crop after background removal.
  /// [alphaThreshold]: alpha threshold for crop detection (0..255; default 12).
  /// [marginFrac]: extra margin around subject for crop (default 0.08 = 8%).
  /// [minSidePx]: minimum crop size in pixels (default 100).
  /// [stride]: sampling stride for faster crop detection (default 2).
  ///
  /// Returns a [ui.Image] with transparent background.
  /// Throws an exception if processing fails.
  static Future<ui.Image> removeBackground({
    required ui.Image inputImage,
    double threshold = 0.5,
    bool smoothMask = true,
    bool enhanceEdges = true,
    int padPx = 6,
    bool applyCrop = true,
    int alphaThreshold = 12,
    double marginFrac = 0.08,
    int minSidePx = 100,
    int stride = 2,
  }) async {
    // Ensure initialized
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Background remover not initialized, initializing...');
      }
      await initialize();
    }

    // 1) Convert input ui.Image to PNG bytes
    final inputBytes = await _uiImageToPngBytes(inputImage);

    // 2) Background removal (full-res)
    // Run the model → returns ui.Image with alpha
    final ui.Image processedImg = await ibr.BackgroundRemover.instance.removeBg(
      inputBytes,
      threshold: threshold,
      smoothMask: smoothMask,
      enhanceEdges: enhanceEdges,
    );

    // 3) Optional pad (transparent border)
    ui.Image finalImage = processedImg;
    if (padPx > 0) {
      final pngBytes = await _uiImageToPngBytes(processedImg);
      final padded = _padTransparentBorder(pngBytes, padPx: padPx);
      finalImage = await _pngBytesToUiImage(padded.bytes);
    }

    // 4) Optional smart square crop
    if (applyCrop) {
      final pngBytes = await _uiImageToPngBytes(finalImage);
      final cropped = await _smartSquareCrop(
        pngBytes: pngBytes,
        alphaThreshold: alphaThreshold,
        marginFrac: marginFrac,
        minSidePx: minSidePx,
        stride: stride,
      );
      if (cropped != null) {
        finalImage = await _pngBytesToUiImage(cropped);
      }
    }

    return finalImage;
  }

  static Future<Uint8List> _uiImageToPngBytes(ui.Image img) async {
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to encode image to PNG bytes.');
    }
    return byteData.buffer.asUint8List();
  }

  static Future<ui.Image> _pngBytesToUiImage(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (ui.Image image) {
      completer.complete(image);
    });
    return await completer.future;
  }

  static _Master _padTransparentBorder(Uint8List pngBytes, {int padPx = 6}) {
    final decoded = img.decodePng(pngBytes);
    if (decoded == null) {
      throw Exception('Failed to decode PNG.');
    }
    if (padPx <= 0) {
      return _Master(
        bytes: pngBytes,
        image: decoded,
        width: decoded.width,
        height: decoded.height,
      );
    }

    final padded = img.Image(
      width: decoded.width + padPx * 2,
      height: decoded.height + padPx * 2,
      numChannels: 4,
    );
    img.fill(padded, color: img.ColorRgba8(0, 0, 0, 0)); // transparent
    img.compositeImage(padded, decoded, dstX: padPx, dstY: padPx);

    final out = Uint8List.fromList(img.encodePng(padded));
    return _Master(
      bytes: out,
      image: padded,
      width: padded.width,
      height: padded.height,
    );
  }

  /// Smart square crop that finds the subject and crops to a square containing it.
  ///
  /// Returns PNG bytes of the cropped square image, or null if cropping fails.
  static Future<Uint8List?> _smartSquareCrop({
    required Uint8List pngBytes,
    required int alphaThreshold,
    required double marginFrac,
    required int minSidePx,
    required int stride,
  }) async {
    try {
      // 1) Decode
      final decoded = img.decodePng(pngBytes);
      if (decoded == null) return null;

      final w = decoded.width, h = decoded.height;

      // 2) Find bbox of subject via alpha > threshold (strided for speed)
      int minX = w, minY = h, maxX = -1, maxY = -1;
      final clampedStride = stride.clamp(1, 8);

      for (int y = 0; y < h; y += clampedStride) {
        for (int x = 0; x < w; x += clampedStride) {
          final pixel = decoded.getPixel(x, y);
          if (pixel.a > alphaThreshold) {
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
          }
        }
      }

      // If nothing opaque found, fall back to centered square
      if (maxX < 0 || maxY < 0) {
        final minSide = w < h ? w : h;
        final side = minSide.clamp(minSidePx, minSide);
        final cx = w ~/ 2, cy = h ~/ 2;
        final half = side ~/ 2;
        final left = (cx - half).clamp(0, w - side);
        final top = (cy - half).clamp(0, h - side);

        final square = img.copyCrop(
          decoded,
          x: left,
          y: top,
          width: side,
          height: side,
        );

        return Uint8List.fromList(img.encodePng(square));
      }

      // 3) Subject bbox (tight)
      final bboxW = maxX - minX + 1;
      final bboxH = maxY - minY + 1;
      final cx = (minX + maxX) ~/ 2;
      final cy = (minY + maxY) ~/ 2;

      // 4) Square that contains the bbox + margin, centered on the bbox center
      final bboxMax = bboxW > bboxH ? bboxW : bboxH;
      int side = (bboxMax * (1.0 + marginFrac)).round();

      // Respect min/max bounds
      final maxSquare = w < h ? w : h;
      if (side < minSidePx) side = minSidePx;
      if (side > maxSquare) side = maxSquare;

      // 5) Place square centered on bbox center, then clamp into image bounds
      int left = (cx - side / 2).floor();
      int top = (cy - side / 2).floor();
      if (left < 0) left = 0;
      if (top < 0) top = 0;
      if (left + side > w) left = w - side;
      if (top + side > h) top = h - side;

      // 6) Crop (guaranteed to fully contain the subject)
      final square = img.copyCrop(
        decoded,
        x: left,
        y: top,
        width: side,
        height: side,
      );

      // 7) Encode
      return Uint8List.fromList(img.encodePng(square));
    } catch (e) {
      if (kDebugMode) print('Smart crop failed: $e');
      return null;
    }
  }
}

class _Master {
  final Uint8List bytes;
  final img.Image image;
  final int width;
  final int height;

  _Master({
    required this.bytes,
    required this.image,
    required this.width,
    required this.height,
  });
}
