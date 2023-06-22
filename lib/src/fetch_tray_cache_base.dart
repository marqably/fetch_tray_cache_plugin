import 'package:dio/src/dio_mixin.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:fetch_tray/fetch_tray.dart';

import '../fetch_tray_cache.dart';
import 'interceptors/cache_interceptor.dart';

enum TrayCacheStoreType {
  /// Store cache in memory
  memory,

  /// Store cache on disk with [Hive]
  hive,
}

class TrayCachePlugin implements TrayPlugin {
  final TrayCacheStoreType cacheStoreType;
  final Duration cacheDuration;

  late final CacheStore store;

  TrayCachePlugin({
    this.cacheStoreType = TrayCacheStoreType.memory,
    this.cacheDuration = const Duration(days: 7),
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
        ),
        DioCacheInterceptor(
          options: cacheOptions,
        ),
      ];

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
            'FT_cacheDuration': cachedRequest.cacheDuration!,
          },
        );
      }
    } else {
      extra.addAll(cacheOptions.toExtra());
    }

    return extra;
  }
}
