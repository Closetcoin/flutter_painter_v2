// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cameraPermissionHash() => r'fbeb7bd278dfb8323fbab4c1327a187ed629fe41';

/// See also [CameraPermission].
@ProviderFor(CameraPermission)
final cameraPermissionProvider =
    AutoDisposeNotifierProvider<CameraPermission, PermissionStatus>.internal(
  CameraPermission.new,
  name: r'cameraPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cameraPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CameraPermission = AutoDisposeNotifier<PermissionStatus>;
String _$photosPermissionHash() => r'9d7511e86ad8f63fcdff0dae09a694107f052787';

/// See also [PhotosPermission].
@ProviderFor(PhotosPermission)
final photosPermissionProvider =
    AutoDisposeNotifierProvider<PhotosPermission, PermissionStatus>.internal(
  PhotosPermission.new,
  name: r'photosPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$photosPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PhotosPermission = AutoDisposeNotifier<PermissionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
