// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_background_remover_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$backgroundRemoverHash() => r'0632b1cd964f31510e0397007344d428d1347205';

/// Provider to initialize the background remover.
///
/// This is a singleton provider that is initialized when the app starts.
/// It is used to ensure that the background remover is initialized before
/// it is used.
///
/// Copied from [BackgroundRemover].
@ProviderFor(BackgroundRemover)
final backgroundRemoverProvider =
    NotifierProvider<BackgroundRemover, bool>.internal(
  BackgroundRemover.new,
  name: r'backgroundRemoverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backgroundRemoverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BackgroundRemover = Notifier<bool>;
String _$imageBgRemoverHash() => r'fdf8389e6b0e37328374fd1ecbbbb84bcaec7f5f';

/// ref: https://pub.dev/packages/image_background_remover
///
/// Copied from [ImageBgRemover].
@ProviderFor(ImageBgRemover)
final imageBgRemoverProvider = AutoDisposeAsyncNotifierProvider<ImageBgRemover,
    MasterImageResult?>.internal(
  ImageBgRemover.new,
  name: r'imageBgRemoverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageBgRemoverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ImageBgRemover = AutoDisposeAsyncNotifier<MasterImageResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
