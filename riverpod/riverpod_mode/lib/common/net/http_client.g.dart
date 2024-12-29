// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$netFetchHash() => r'2ce83b11ffac28079177300f58690f83fc754e47';

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

/// See also [netFetch].
@ProviderFor(netFetch)
const netFetchProvider = NetFetchFamily();

/// See also [netFetch].
class NetFetchFamily extends Family<AsyncValue<ResultData?>> {
  /// See also [netFetch].
  const NetFetchFamily();

  /// See also [netFetch].
  NetFetchProvider call({
    required String url,
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    Object? data,
    Options? options,
    Map<String, dynamic>? header,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    dynamic noTip = false,
  }) {
    return NetFetchProvider(
      url: url,
      method: method,
      params: params,
      data: data,
      options: options,
      header: header,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      noTip: noTip,
    );
  }

  @override
  NetFetchProvider getProviderOverride(
    covariant NetFetchProvider provider,
  ) {
    return call(
      url: provider.url,
      method: provider.method,
      params: provider.params,
      data: provider.data,
      options: provider.options,
      header: provider.header,
      onSendProgress: provider.onSendProgress,
      onReceiveProgress: provider.onReceiveProgress,
      noTip: provider.noTip,
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
  String? get name => r'netFetchProvider';
}

/// See also [netFetch].
class NetFetchProvider extends AutoDisposeFutureProvider<ResultData?> {
  /// See also [netFetch].
  NetFetchProvider({
    required String url,
    DioMethod method = DioMethod.get,
    Map<String, dynamic>? params,
    Object? data,
    Options? options,
    Map<String, dynamic>? header,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    dynamic noTip = false,
  }) : this._internal(
          (ref) => netFetch(
            ref as NetFetchRef,
            url: url,
            method: method,
            params: params,
            data: data,
            options: options,
            header: header,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
            noTip: noTip,
          ),
          from: netFetchProvider,
          name: r'netFetchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$netFetchHash,
          dependencies: NetFetchFamily._dependencies,
          allTransitiveDependencies: NetFetchFamily._allTransitiveDependencies,
          url: url,
          method: method,
          params: params,
          data: data,
          options: options,
          header: header,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          noTip: noTip,
        );

  NetFetchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.method,
    required this.params,
    required this.data,
    required this.options,
    required this.header,
    required this.onSendProgress,
    required this.onReceiveProgress,
    required this.noTip,
  }) : super.internal();

  final String url;
  final DioMethod method;
  final Map<String, dynamic>? params;
  final Object? data;
  final Options? options;
  final Map<String, dynamic>? header;
  final void Function(int, int)? onSendProgress;
  final void Function(int, int)? onReceiveProgress;
  final dynamic noTip;

  @override
  Override overrideWith(
    FutureOr<ResultData?> Function(NetFetchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NetFetchProvider._internal(
        (ref) => create(ref as NetFetchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
        method: method,
        params: params,
        data: data,
        options: options,
        header: header,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        noTip: noTip,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ResultData?> createElement() {
    return _NetFetchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NetFetchProvider &&
        other.url == url &&
        other.method == method &&
        other.params == params &&
        other.data == data &&
        other.options == options &&
        other.header == header &&
        other.onSendProgress == onSendProgress &&
        other.onReceiveProgress == onReceiveProgress &&
        other.noTip == noTip;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, method.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);
    hash = _SystemHash.combine(hash, data.hashCode);
    hash = _SystemHash.combine(hash, options.hashCode);
    hash = _SystemHash.combine(hash, header.hashCode);
    hash = _SystemHash.combine(hash, onSendProgress.hashCode);
    hash = _SystemHash.combine(hash, onReceiveProgress.hashCode);
    hash = _SystemHash.combine(hash, noTip.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NetFetchRef on AutoDisposeFutureProviderRef<ResultData?> {
  /// The parameter `url` of this provider.
  String get url;

  /// The parameter `method` of this provider.
  DioMethod get method;

  /// The parameter `params` of this provider.
  Map<String, dynamic>? get params;

  /// The parameter `data` of this provider.
  Object? get data;

  /// The parameter `options` of this provider.
  Options? get options;

  /// The parameter `header` of this provider.
  Map<String, dynamic>? get header;

  /// The parameter `onSendProgress` of this provider.
  void Function(int, int)? get onSendProgress;

  /// The parameter `onReceiveProgress` of this provider.
  void Function(int, int)? get onReceiveProgress;

  /// The parameter `noTip` of this provider.
  dynamic get noTip;
}

class _NetFetchProviderElement
    extends AutoDisposeFutureProviderElement<ResultData?> with NetFetchRef {
  _NetFetchProviderElement(super.provider);

  @override
  String get url => (origin as NetFetchProvider).url;
  @override
  DioMethod get method => (origin as NetFetchProvider).method;
  @override
  Map<String, dynamic>? get params => (origin as NetFetchProvider).params;
  @override
  Object? get data => (origin as NetFetchProvider).data;
  @override
  Options? get options => (origin as NetFetchProvider).options;
  @override
  Map<String, dynamic>? get header => (origin as NetFetchProvider).header;
  @override
  void Function(int, int)? get onSendProgress =>
      (origin as NetFetchProvider).onSendProgress;
  @override
  void Function(int, int)? get onReceiveProgress =>
      (origin as NetFetchProvider).onReceiveProgress;
  @override
  dynamic get noTip => (origin as NetFetchProvider).noTip;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
