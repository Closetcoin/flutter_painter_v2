import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_image.g.dart';

class AppImage extends HookConsumerWidget {
  const AppImage.path({
    super.key,
    required this.path,
    this.showLoading = false,
    this.imageViewerOnTap = true,
    this.decoration,
  })  : _type = _AppImageType.path,
        memory = null,
        url = null;

  const AppImage.memory({
    super.key,
    required this.memory,
    this.showLoading = false,
    this.imageViewerOnTap = true,
    this.decoration,
  })  : _type = _AppImageType.memory,
        path = null,
        url = null;

  const AppImage.url({
    super.key,
    required this.url,
    this.showLoading = false,
    this.imageViewerOnTap = true,
    this.decoration,
  })  : _type = _AppImageType.url,
        path = null,
        memory = null;

  final _AppImageType _type;
  final String? url;
  final Uint8List? memory;
  final String? path;
  final bool showLoading;
  final bool imageViewerOnTap;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Image to be loaded
    final (imageProvider, file) = useMemoized<(ImageProvider?, File?)>(() {
      if ((_type.isPath && path == null) ||
          (_type.isMemory && memory == null) ||
          (_type.isUrl && url == null)) {
        return (null, null);
      }

      if (_type.isPath) {
        final file = File(path!);
        return (FileImage(file), file);
      } else if (_type.isMemory) {
        return (MemoryImage(memory!), null);
      } else {
        return (NetworkImage(url!), null);
      }
    }, [path, memory, url]);

    final isImageLoading = imageProvider != null
        ? ref.watch(cacheImageProvider(context, imageProvider)).isLoading
        : true;

    if (isImageLoading && showLoading) {
      return SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pathIsLoaded = _type.isPath && !isImageLoading && file != null;
    final memoryIsLoaded = _type.isMemory && !isImageLoading && memory != null;
    final urlIsLoaded = _type.isUrl && !isImageLoading && url != null;

    if (pathIsLoaded || memoryIsLoaded || urlIsLoaded) {
      return Container(
        decoration: decoration,
        child: switch (_type) {
          _AppImageType.path => Image.file(file!),
          _AppImageType.memory => Image.memory(memory!),
          _AppImageType.url => Image.network(url!),
        },
      );
    }

    return const SizedBox.shrink();
  }
}

enum _AppImageType { path, memory, url }

extension on _AppImageType {
  bool get isPath => this == _AppImageType.path;
  bool get isMemory => this == _AppImageType.memory;
  bool get isUrl => this == _AppImageType.url;
}

@riverpod
Future<bool> cacheImage(
  Ref ref,
  // ignore: avoid_build_context_in_providers
  BuildContext context,
  ImageProvider imageProvider,
) async {
  await precacheImage(imageProvider, context);
  return true;
}
