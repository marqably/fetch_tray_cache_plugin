// ignore_for_file: avoid_print

import 'dart:io';

import 'package:fetch_tray/utils/make_tray_request.dart';
import 'package:fetch_tray_cache_plugin/fetch_tray_cache.dart';

import 'models/post.dart';
import 'requests/get_all_posts_request.dart';

void main() async {
  // Pass the plugin to FetchTray.init
  FetchTray.init(
    plugins: [
      TrayCachePlugin(
        cacheStoreType: TrayCacheStoreType.memory,
        cacheDuration: const Duration(seconds: 2),
      ),
    ],
  );

  final request = GetAllPostsRequest();

  // First request will be from the server
  await makeTrayRequest<List<Post>>(request);

  // Subsequent requests will be from the cache for the duration of cacheDuration
  // passed to TrayCachePlugin
  await makeTrayRequest<List<Post>>(request);

  sleep(Duration(seconds: 5));

  // After cacheDuration, the request will be from the server again
  final responseAfterCacheDuration = await makeTrayRequest<List<Post>>(request);

  print(responseAfterCacheDuration);

  // Use FetchTray as usual
}
