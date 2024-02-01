import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:fetch_tray_cache_plugin/src/fetch_tray_cache_base.dart';
import 'package:logger/logger.dart';

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
  final bool loggingEnabled;
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printTime: true,
    ),
  );

  TrayCacheInterceptor({
    required this.cacheOptions,
    required this.maxAge,
    this.loggingEnabled = false,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // TODO: implement filter for logger
    /* final requestShouldLog =
        options.extra[TrayCachePluginKeys.requestShouldLog] as bool? ?? false; */

    final logPrefix =
        '[fetch_tray_cache_plugin] ${options.method} ${options.uri}';
    final key = cacheOptions.keyBuilder(options);
    final store = cacheOptions.store;

    final requestCacheDuration =
        options.extra[TrayCachePluginKeys.requestCacheDuration] as Duration?;

    final ignoreCache =
        CacheOptions.fromExtra(options)?.policy == CachePolicy.noCache;

    if (store != null && !ignoreCache) {
      final cache = await store.get(key);

      if (cache != null) {
        final difference = DateTime.now().difference(cache.responseDate);

        final cacheDuration = requestCacheDuration ?? maxAge;

        if (difference <= cacheDuration) {
          if (loggingEnabled) {
            logger.i(
              '$logPrefix Cache hit, returning cached response',
            );
          }
          return handler.resolve(
            cache.toResponse(
              options,
              fromNetwork: false,
            ),
          );
        } else {
          if (loggingEnabled) {
            logger.i(
              '$logPrefix Cache too old, deleting...',
            );
          }
          await store.delete(key);
        }
      }
    }

    if (loggingEnabled) {
      logger.i(
        '$logPrefix Sending request over network',
      );
    }

    handler.next(options);
  }
}
