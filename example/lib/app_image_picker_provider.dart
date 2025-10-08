import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:example/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_image_picker_provider.g.dart';

class PickedImage {
  final String path; // absolute temp path you can read
  final Uint8List bytes; // convenient if lib needs bytes
  final ImageSource source; // camera or gallery
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

extension PickedImageExt on PickedImage {
  Future<ui.Image> toUiImage() async {
    final image = await Image.memory(bytes).image.toUiImage;
    return image;
  }
}

/// Adds a method to get a [ui.Image] object from any [ImageProvider].
extension on ImageProvider {
  /// Returns an [ui.Image] object containing the image data from `this` object.
  Future<ui.Image> get toUiImage async {
    // Used to convert listener callback to future
    final completer = Completer<ui.Image>();

    // Resolve the image as an [ImageStream] and listen to the stream
    resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((info, _) {
        // Assign the [ui.Image] from the image information streamed as the completer value
        // When the image from the stream arrives, the completer is completed
        completer.complete(info.image);
      }),
    );

    // Wait for the image data from the completer to arrive from the callback
    return await completer.future;
  }
}

@riverpod
class AppImagePicker extends _$AppImagePicker {
  final _picker = ImagePicker();

  /// We keep only the *last* selected image in state (nullable).
  @override
  FutureOr<PickedImage?> build() async => null;

  /// Pick from gallery. Returns the DTO or null if user canceled.
  Future<PickedImage?> pickFromGallery({
    int? imageQuality, // 1..100 (jpeg compression); null = original
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final status =
          await ref.read(photosPermissionProvider.notifier).ensureGranted();
      if (status != PermissionStatus.granted) return null;

      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        requestFullMetadata: false,
      );
      if (x == null) return state.valueOrNull;

      return await _persistToTemp(x, ImageSource.gallery);
    });

    state = result;
    return result.valueOrNull;
  }

  /// Capture with camera. Returns the DTO or null if user canceled.
  Future<PickedImage?> captureWithCamera({
    int? imageQuality, // 1..100
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final status =
          await ref.read(cameraPermissionProvider.notifier).ensureGranted();
      if (status != PermissionStatus.granted) return null;

      final x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        requestFullMetadata: false,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (x == null) return state.valueOrNull;

      return await _persistToTemp(x, ImageSource.camera);
    });

    return state.valueOrNull;
  }

  Future<PickedImage> _persistToTemp(XFile x, ImageSource source) async {
    final dir = await _tempDir();

    // Preserve extension if present; default to .jpg
    final ext = p.extension(x.path).isNotEmpty ? p.extension(x.path) : '.jpg';
    final fileName = 'outfit_${DateTime.now().microsecondsSinceEpoch}$ext';
    final dest = p.join(dir.path, fileName);

    // Some platforms give you a temp path already; we still copy to control location
    await File(x.path).copy(dest);
    final bytes = await File(dest).readAsBytes();

    // Detect MIME type from file content (more reliable than extension)
    final mimeType = lookupMimeType('', headerBytes: bytes.take(1024).toList());
    final contentType = _mapMimeTypeToAllowedContentType(mimeType);

    return PickedImage(
      path: dest,
      bytes: bytes,
      source: source,
      createdAt: DateTime.now(),
      contentType: contentType,
    );
  }

  /// Maps detected MIME type to AllowedImageContentType enum
  AllowedImageContentType _mapMimeTypeToAllowedContentType(String? mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return AllowedImageContentType.imageJpeg;
      case 'image/png':
        return AllowedImageContentType.imagePng;
      case 'image/webp':
        return AllowedImageContentType.imageWebp;
      case 'image/heic':
        return AllowedImageContentType.imageHeic;
      case 'image/heif':
        return AllowedImageContentType.imageHeif;
      default:
        // Default to JPEG if MIME type is not recognized or is null
        return AllowedImageContentType.imageJpeg;
    }
  }

  Future<Directory> _tempDir() async {
    final base = await getTemporaryDirectory();
    final d = Directory(p.join(base.path, 'images'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }
}

@JsonEnum()
enum AllowedImageContentType {
  @JsonValue('image/jpeg')
  imageJpeg,
  @JsonValue('image/png')
  imagePng,
  @JsonValue('image/webp')
  imageWebp,
  @JsonValue('image/heic')
  imageHeic,
  @JsonValue('image/heif')
  imageHeif;

  String get mimeType => switch (this) {
        imageJpeg => 'image/jpeg',
        imagePng => 'image/png',
        imageWebp => 'image/webp',
        imageHeic => 'image/heic',
        imageHeif => 'image/heif',
      };
}
