# fetch_tray_cache_plugin

A `fetch_tray` plugin to enable hard caching of requests. This plugin is designed to work with servers that don't send cache headers. It is not designed to work with servers that send cache headers.

The plugin is based on the [dio_cache_interceptor](https://pub.dev/packages/dio_cache_interceptor) package with a custom middleware to work with `fetch_tray` and on the client side (without cache headers).

## Usage

### Using memory cache

To use the memory cache, simply add the plugin to the `FetchTray` instance. The memory cache is not persistent and will be cleared when the app is closed.

````dart

```dart
import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_cache_plugin/fetch_tray_cache_plugin.dart';

void main() {
    FetchTray.init(
        plugins: [
            TrayCachePlugin(
                cacheStoreType: TrayCacheStoreType.memory,
                cacheDuration: const Duration(minutes: 5),
            ),
        ],
    );
}
````

### Using Hive cache

To use a persistent cache, you can use the `hive` store type. This implementation is based on the [dio_cache_interceptor_hive_store](https://pub.dev/packages/dio_cache_interceptor_hive_store) package.

You are required to provide a `cacheDirectory` to store the cache files.

```dart
import 'package:fetch_tray/fetch_tray.dart';
import 'package:fetch_tray_cache_plugin/fetch_tray_cache_plugin.dart';

void main() {
    FetchTray.init(
        plugins: [
            TrayCachePlugin(
                cacheStoreType: TrayCacheStoreType.hive,
                cacheDirectory: '/path/to/cache/directory',
            ),
        ],
    );
}
```
