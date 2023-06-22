/// Plugin for [fetch_tray] to enable caching API responses. It is mainly used
/// for servers that don't send any caching headers, because this package will
/// force-cache all responses by default.
library fetch_tray_cache_plugin;

export 'src/fetch_tray_cache_base.dart';
export 'src/request/cached_tray_request.dart';
