import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_cache_plugin/fetch_tray_cache.dart';
import 'package:test/test.dart';

class FakeCachedRequest extends TrayRequest<void> implements CachedTrayRequest {
  FakeCachedRequest({
    this.cacheDuration,
    this.useCache = true,
  });

  @override
  final Duration? cacheDuration;

  @override
  final bool useCache;
}

void main() {
  group('CachedTrayRequest', () {
    test('overrides global cache duration', () {
      final globalDuration = const Duration(days: 7);
      final requestDuration = const Duration(days: 1);

      final cachePlugin = TrayCachePlugin(
        cacheDuration: globalDuration,
      );

      FetchTray.init(
        plugins: [
          cachePlugin,
        ],
      );

      final request = FakeCachedRequest(
        cacheDuration: requestDuration,
      );

      final requestExtra = cachePlugin.getRequestExtra(request);

      expect(
        requestExtra[TrayCachePluginKeys.requestCacheDuration],
        equals(requestDuration),
      );
    });
  });
}
