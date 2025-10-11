import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
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
  ///
  /// Returns a [ui.Image] with transparent background.
  /// Throws an exception if processing fails.
  static Future<ui.Image> removeBackground({
    required ui.Image inputImage,
    double threshold = 0.5,
    bool smoothMask = true,
    bool enhanceEdges = true,
    int padPx = 6,
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
    if (padPx > 0) {
      final pngBytes = await _uiImageToPngBytes(processedImg);
      final padded = _padTransparentBorder(pngBytes, padPx: padPx);
      // Convert back to ui.Image
      return await _pngBytesToUiImage(padded.bytes);
    }

    return processedImg;
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
    final decoded = decodePng(pngBytes);
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

    final padded = Image(
      width: decoded.width + padPx * 2,
      height: decoded.height + padPx * 2,
      numChannels: 4,
    );
    fill(padded, color: ColorRgba8(0, 0, 0, 0)); // transparent
    compositeImage(padded, decoded, dstX: padPx, dstY: padPx);

    final out = Uint8List.fromList(encodePng(padded));
    return _Master(
      bytes: out,
      image: padded,
      width: padded.width,
      height: padded.height,
    );
  }
}

class _Master {
  final Uint8List bytes;
  final Image image;
  final int width;
  final int height;

  _Master({
    required this.bytes,
    required this.image,
    required this.width,
    required this.height,
  });
}
