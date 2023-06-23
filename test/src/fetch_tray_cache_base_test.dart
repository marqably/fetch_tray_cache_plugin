import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_cache_plugin/fetch_tray_cache.dart';
import 'package:test/test.dart';

void main() {
  group('TrayCachePlugin', () {
    test('can be registered with fetch_tray', () {
      FetchTray.init(
        plugins: [
          TrayCachePlugin(
            cacheStoreType: TrayCacheStoreType.memory,
            cacheDuration: const Duration(seconds: 2),
          ),
        ],
      );

      final instance = FetchTray.instance;

      expect(instance.plugins.length, 1);
      expect(instance.plugins.first, isA<TrayCachePlugin>());
    });

    test('defaults to a memory cache', () {
      final cachePlugin = TrayCachePlugin();

      expect(cachePlugin.cacheStoreType, equals(TrayCacheStoreType.memory));
    });

    test('has correct interceptors', () {
      final cachePlugin = TrayCachePlugin();

      expect(cachePlugin.interceptors.length, 2);
      expect(cachePlugin.interceptors.first, isA<TrayCacheInterceptor>());
      expect(cachePlugin.interceptors.last, isA<DioCacheInterceptor>());
    });

    test('returns correct requestExtra', () {
      final cachePlugin = TrayCachePlugin();
      final request = TrayRequest();

      final requestExtra = cachePlugin.getRequestExtra(request);

      expect(requestExtra, isA<Map<String, dynamic>>());
    });
  });
}
