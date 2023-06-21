import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

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

    final requestCacheDuration = options.extra['FT_cacheDuration'] as Duration?;

    print(requestCacheDuration);

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
