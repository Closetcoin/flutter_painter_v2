import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permission_providers.g.dart';

@riverpod
class CameraPermission extends _$CameraPermission {
  @override
  PermissionStatus build() => PermissionStatus.denied;

  Future<PermissionStatus> refresh() async =>
      state = await Permission.camera.status;

  Future<PermissionStatus> ensureGranted() async {
    PermissionStatus status = await Permission.camera.status;

    return state = switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited =>
        await Permission.camera.request(),
      _ => status,
    };
  }
}

@riverpod
class PhotosPermission extends _$PhotosPermission {
  @override
  PermissionStatus build() => PermissionStatus.denied;

  Future<PermissionStatus> refresh() async =>
      state = await Permission.photos.status;

  Future<PermissionStatus> ensureGranted() async {
    PermissionStatus status = await Permission.photos.status;

    return state = switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited =>
        await Permission.photos.request(),
      _ => status,
    };
  }
}
