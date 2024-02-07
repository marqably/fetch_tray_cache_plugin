import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:fetch_tray/fetch_tray.dart';
import 'package:logger/logger.dart';

import '../fetch_tray_cache.dart';

/// Type of cache store
enum TrayCacheStoreType {
  /// Store cache in memory
  memory,

  /// Store cache on disk with [Hive]
  hive,
}

class TrayCachePluginKeys {
  static const requestCacheDuration = '@fetch_tray_requestCacheDuration@';
  static const requestShouldLog = '@fetch_tray_requestShouldLog@';
}

/// Plugin to enable caching GET requests.
///
/// This plugin uses [dio_cache_interceptor](https://pub.dev/packages/dio_cache_interceptor)
/// to cache requests and a custom interceptor to handle cache expiration. By default,
/// requests are cached for [cacheDuration]. You can override this value by implementing
/// [CachedTrayRequest] on a [TrayRequest] and returning a different value for [cacheDuration].
class TrayCachePlugin implements TrayPlugin {
  final TrayCacheStoreType cacheStoreType;
  final Duration cacheDuration;

  final Level logLevel;
  late final CacheStore store;

  TrayCachePlugin({
    this.cacheStoreType = TrayCacheStoreType.memory,
    this.cacheDuration = const Duration(days: 7),
    this.logLevel = Level.error,
    String? cacheDirectory,
  }) {
    switch (cacheStoreType) {
      case TrayCacheStoreType.memory:
        store = MemCacheStore();
        break;
      case TrayCacheStoreType.hive:
        store = HiveCacheStore(cacheDirectory);
        break;
    }
  }

  @override
  List<Interceptor> get interceptors => [
        TrayCacheInterceptor(
          cacheOptions: cacheOptions,
          maxAge: cacheDuration,
          logLevel: logLevel,
        ),
        DioCacheInterceptor(
          options: cacheOptions,
        ),
      ];

  /// Options to be used by [dio_cache_interceptor]
  CacheOptions get cacheOptions => CacheOptions(
        store: store,
        policy: CachePolicy.forceCache,
      );

  @override
  Map<String, dynamic> getRequestExtra(TrayRequest request) {
    Map<String, dynamic> extra = {};

    if (request is CachedTrayRequest) {
      final cachedRequest = request as CachedTrayRequest;
      extra.addAll(
        cacheOptions
            .copyWith(
              policy: cachedRequest.useCache
                  ? CachePolicy.forceCache
                  : CachePolicy.noCache,
            )
            .toExtra(),
      );

      if (cachedRequest.cacheDuration != null) {
        extra.addAll(
          {
            TrayCachePluginKeys.requestCacheDuration:
                cachedRequest.cacheDuration!,
          },
        );
      }
    } else {
      extra.addAll(cacheOptions.toExtra());
    }

    extra.addAll({
      TrayCachePluginKeys.requestShouldLog:
          request.getEnvironment().showDebugInfo(),
    });

    return extra;
  }
}
