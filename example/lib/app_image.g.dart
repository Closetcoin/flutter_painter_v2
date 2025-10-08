// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_image.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cacheImageHash() => r'8b305fe5fa8ea6ea7df828469085bbba41d25002';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [cacheImage].
@ProviderFor(cacheImage)
const cacheImageProvider = CacheImageFamily();

/// See also [cacheImage].
class CacheImageFamily extends Family<AsyncValue<bool>> {
  /// See also [cacheImage].
  const CacheImageFamily();

  /// See also [cacheImage].
  CacheImageProvider call(
    BuildContext context,
    ImageProvider<Object> imageProvider,
  ) {
    return CacheImageProvider(
      context,
      imageProvider,
    );
  }

  @override
  CacheImageProvider getProviderOverride(
    covariant CacheImageProvider provider,
  ) {
    return call(
      provider.context,
      provider.imageProvider,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cacheImageProvider';
}

/// See also [cacheImage].
class CacheImageProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [cacheImage].
  CacheImageProvider(
    BuildContext context,
    ImageProvider<Object> imageProvider,
  ) : this._internal(
          (ref) => cacheImage(
            ref as CacheImageRef,
            context,
            imageProvider,
          ),
          from: cacheImageProvider,
          name: r'cacheImageProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cacheImageHash,
          dependencies: CacheImageFamily._dependencies,
          allTransitiveDependencies:
              CacheImageFamily._allTransitiveDependencies,
          context: context,
          imageProvider: imageProvider,
        );

  CacheImageProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
    required this.imageProvider,
  }) : super.internal();

  final BuildContext context;
  final ImageProvider<Object> imageProvider;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CacheImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CacheImageProvider._internal(
        (ref) => create(ref as CacheImageRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
        imageProvider: imageProvider,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CacheImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CacheImageProvider &&
        other.context == context &&
        other.imageProvider == imageProvider;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);
    hash = _SystemHash.combine(hash, imageProvider.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CacheImageRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;

  /// The parameter `imageProvider` of this provider.
  ImageProvider<Object> get imageProvider;
}

class _CacheImageProviderElement extends AutoDisposeFutureProviderElement<bool>
    with CacheImageRef {
  _CacheImageProviderElement(super.provider);

  @override
  BuildContext get context => (origin as CacheImageProvider).context;
  @override
  ImageProvider<Object> get imageProvider =>
      (origin as CacheImageProvider).imageProvider;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
