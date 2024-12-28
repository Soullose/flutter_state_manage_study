// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesUtilsHash() =>
    r'9a86935a7de7bdfa9cd51d103bf439507c42c60d';

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

/// See also [sharedPreferencesUtils].
@ProviderFor(sharedPreferencesUtils)
const sharedPreferencesUtilsProvider = SharedPreferencesUtilsFamily();

/// See also [sharedPreferencesUtils].
class SharedPreferencesUtilsFamily extends Family<SharedPreferencesUtils> {
  /// See also [sharedPreferencesUtils].
  const SharedPreferencesUtilsFamily();

  /// See also [sharedPreferencesUtils].
  SharedPreferencesUtilsProvider call(
    SharedPreferences prefs,
    SharedPreferencesAsync asyncPrefs,
  ) {
    return SharedPreferencesUtilsProvider(
      prefs,
      asyncPrefs,
    );
  }

  @override
  SharedPreferencesUtilsProvider getProviderOverride(
    covariant SharedPreferencesUtilsProvider provider,
  ) {
    return call(
      provider.prefs,
      provider.asyncPrefs,
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
  String? get name => r'sharedPreferencesUtilsProvider';
}

/// See also [sharedPreferencesUtils].
class SharedPreferencesUtilsProvider
    extends AutoDisposeProvider<SharedPreferencesUtils> {
  /// See also [sharedPreferencesUtils].
  SharedPreferencesUtilsProvider(
    SharedPreferences prefs,
    SharedPreferencesAsync asyncPrefs,
  ) : this._internal(
          (ref) => sharedPreferencesUtils(
            ref as SharedPreferencesUtilsRef,
            prefs,
            asyncPrefs,
          ),
          from: sharedPreferencesUtilsProvider,
          name: r'sharedPreferencesUtilsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sharedPreferencesUtilsHash,
          dependencies: SharedPreferencesUtilsFamily._dependencies,
          allTransitiveDependencies:
              SharedPreferencesUtilsFamily._allTransitiveDependencies,
          prefs: prefs,
          asyncPrefs: asyncPrefs,
        );

  SharedPreferencesUtilsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.prefs,
    required this.asyncPrefs,
  }) : super.internal();

  final SharedPreferences prefs;
  final SharedPreferencesAsync asyncPrefs;

  @override
  Override overrideWith(
    SharedPreferencesUtils Function(SharedPreferencesUtilsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SharedPreferencesUtilsProvider._internal(
        (ref) => create(ref as SharedPreferencesUtilsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        prefs: prefs,
        asyncPrefs: asyncPrefs,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SharedPreferencesUtils> createElement() {
    return _SharedPreferencesUtilsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedPreferencesUtilsProvider &&
        other.prefs == prefs &&
        other.asyncPrefs == asyncPrefs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, prefs.hashCode);
    hash = _SystemHash.combine(hash, asyncPrefs.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SharedPreferencesUtilsRef
    on AutoDisposeProviderRef<SharedPreferencesUtils> {
  /// The parameter `prefs` of this provider.
  SharedPreferences get prefs;

  /// The parameter `asyncPrefs` of this provider.
  SharedPreferencesAsync get asyncPrefs;
}

class _SharedPreferencesUtilsProviderElement
    extends AutoDisposeProviderElement<SharedPreferencesUtils>
    with SharedPreferencesUtilsRef {
  _SharedPreferencesUtilsProviderElement(super.provider);

  @override
  SharedPreferences get prefs =>
      (origin as SharedPreferencesUtilsProvider).prefs;
  @override
  SharedPreferencesAsync get asyncPrefs =>
      (origin as SharedPreferencesUtilsProvider).asyncPrefs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
