import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart';
import 'package:image_background_remover/image_background_remover.dart' as ibr;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_background_remover_provider.g.dart';

/// Provider to initialize the background remover.
///
/// This is a singleton provider that is initialized when the app starts.
/// It is used to ensure that the background remover is initialized before
/// it is used.
@Riverpod(keepAlive: true)
class BackgroundRemover extends _$BackgroundRemover {
  @override
  bool build() => false;

  Future<void> init() async {
    if (state) return;
    await ibr.BackgroundRemover.instance.initializeOrt();

    ref.onDispose(() {
      ibr.BackgroundRemover.instance.dispose();
      state = false;
    });

    state = true;
  }
}

/// ref: https://pub.dev/packages/image_background_remover
@riverpod
class ImageBgRemover extends _$ImageBgRemover {
  @override
  FutureOr<MasterImageResult?> build() async => null;

  Future<void> reset() async => state = const AsyncData(null);

  /// Remove background from [input].
  ///
  /// [threshold]: 0..1 (higher removes more background; default 0.5).
  /// [smoothMask]: bilinear smoothing of mask edges.
  /// [enhanceEdges]: extra refinement on boundaries.
  /// [padPx]: pad the image with a transparent border.
  ///
  /// Returns a [MasterImageResult].
  Future<MasterImageResult?> remove({
    required PickedImage input,
    double threshold = 0.5,
    bool smoothMask = true,
    bool enhanceEdges = true,
    int padPx = 6,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final timings = <StepTiming>[];

      final isInitialized = ref.read(backgroundRemoverProvider);
      if (!isInitialized) {
        if (kDebugMode) print('Background remover not initialized');
        await ref.read(backgroundRemoverProvider.notifier).init();
      }

      // 1) EXIF normalize
      final t1 = Stopwatch()..start();
      // Fixes the picture orientation for some devices. In some devices the
      // exif data shows picture in landscape mode when they're actually in
      // portrait.
      final exif = await FlutterExifRotation.rotateAndSaveImage(
        path: input.path,
      );
      final bytes = await exif.readAsBytes();
      t1.stop();
      timings.add(StepTiming('Normalize Rotation', t1.elapsed));

      // 2) Background removal (full-res)
      final t2 = Stopwatch()..start();
      // Run the model → returns ui.Image with alpha
      final ui.Image uiImg = await ibr.BackgroundRemover.instance.removeBg(
        bytes,
        threshold: threshold,
        smoothMask: smoothMask,
        enhanceEdges: enhanceEdges,
      );
      // Convert ui.Image → PNG bytes
      final pngBytes = await _uiImageToPngBytes(uiImg);
      t2.stop();
      timings.add(StepTiming('Background Removal', t2.elapsed));

      // 3) Optional pad only (transparent border), or pass-through
      final t3 = Stopwatch()..start();
      final master = padPx > 0
          ? _padTransparentBorder(pngBytes, padPx: padPx)
          : _Master.fromDecoded(decodePng(pngBytes)!, pngBytes);
      t3.stop();
      timings.add(StepTiming('Pad Transparent Border', t3.elapsed));

      // Persist to temp so downstream code can use a path
      final outPath = await _savePngToTemp(pngBytes);

      return MasterImageResult(
        pngBytes: master.bytes,
        image: master.image,
        width: master.width,
        height: master.height,
        bytesIn: input.bytes.length,
        bytesPng: master.bytes.length,
        timings: timings,
        savedPath: outPath,
      );
    });

    return state.valueOrNull;
  }

  Future<Uint8List> _uiImageToPngBytes(ui.Image img) async {
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw 'Failed to encode image to PNG bytes.';
    }
    return byteData.buffer.asUint8List();
  }

  _Master _padTransparentBorder(Uint8List pngBytes, {int padPx = 6}) {
    final decoded = decodePng(pngBytes);
    if (decoded == null) {
      throw 'Failed to decode PNG.';
    }
    if (padPx <= 0) {
      return _Master.fromDecoded(decoded, pngBytes);
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

  Future<String> _savePngToTemp(Uint8List png) async {
    final dir = await getTemporaryDirectory();
    final folder = Directory(p.join(dir.path, 'knitworth_bg'));

    if (!await folder.exists()) await folder.create(recursive: true);

    final path = p.join(
      folder.path,
      'knitworth_image_background_remover_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    final f = File(path);
    await f.writeAsBytes(png, flush: true);
    return path;
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

  factory _Master.fromDecoded(Image decoded, Uint8List originalBytes) {
    return _Master(
      bytes: originalBytes,
      image: decoded,
      width: decoded.width,
      height: decoded.height,
    );
  }
}

class StepTiming {
  final String name;
  final Duration duration;
  const StepTiming(this.name, this.duration);
}

class MasterImageResult {
  final Uint8List pngBytes; // RGBA PNG with transparent bg (post-trim/pad)
  final Image image;
  final int width;
  final int height;
  final int bytesIn; // original picked bytes
  final int bytesPng; // master PNG size
  final List<StepTiming> timings;
  final String? savedPath; // temp file path

  const MasterImageResult({
    required this.pngBytes,
    required this.image,
    required this.width,
    required this.height,
    required this.bytesIn,
    required this.bytesPng,
    required this.timings,
    required this.savedPath,
  });
}

class PickedImage {
  final String path; // absolute temp path you can read
  final Uint8List bytes; // convenient if lib needs bytes
  final String source; // camera or gallery
  final DateTime createdAt;
  final AllowedImageContentType contentType; // detected MIME type

  const PickedImage({
    required this.path,
    required this.bytes,
    required this.source,
    required this.createdAt,
    required this.contentType,
  });
}

enum AllowedImageContentType {
  imageJpeg,
  imagePng,
  imageWebp,
  imageHeic,
  imageHeif;

  String get mimeType => switch (this) {
        imageJpeg => 'image/jpeg',
        imagePng => 'image/png',
        imageWebp => 'image/webp',
        imageHeic => 'image/heic',
        imageHeif => 'image/heif',
      };
}
