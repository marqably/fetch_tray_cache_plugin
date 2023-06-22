import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Custom interceptor to handle cache expiration. This is necessary because
/// [dio_cache_interceptor] does not support cache expiration on the client side.
/// So if the server does not return a `Cache-Control` header, the cache will
/// never expire.
///
/// This interceptor checks if the cache is older than [maxAge] and deletes
/// it if it is. If the cache is not older than [maxAge], it returns the cached
/// response. If there is no cache, it continues the request.
///
/// [cacheOptions] have to be passed in order to figure out the cache key and
/// actually retrieve the cached item.
///
/// This interceptor should be used before [DioCacheInterceptor] to avoid
/// unnecessary requests.
class TrayCacheInterceptor extends Interceptor {
  final Duration maxAge;
  final CacheOptions cacheOptions;

  TrayCacheInterceptor({
    required this.cacheOptions,
    required this.maxAge,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final key = cacheOptions.keyBuilder(options);
    final store = cacheOptions.store;

    // TODO(@lukas): not used right now
    final requestCacheDuration = options.extra['FT_cacheDuration'] as Duration?;

    final ignoreCache =
        CacheOptions.fromExtra(options)?.policy == CachePolicy.noCache;

    if (store != null && !ignoreCache) {
      final cache = await store.get(key);

      if (cache != null) {
        print('Cache has entry');
        final difference = DateTime.now().difference(cache.responseDate);

        if (difference > maxAge) {
          print('Cache expired');
          await store.delete(key);
          handler.next(options);
          return;
        } else {
          return handler.resolve(
            cache.toResponse(
              options,
              fromNetwork: false,
            ),
          );
        }
      }
    }

    print('From network');

    handler.next(options);
  }
}
