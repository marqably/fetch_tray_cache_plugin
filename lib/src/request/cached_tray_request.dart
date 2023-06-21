/* CachedTrayRequest<T> extends TrayRequest<T> {
  final bool useCache;
  final Duration? cacheDuration;

}
 */

/* mixin TrayCacheMixin {
  bool get useCache => true;
  Duration? get cacheDuration => null;
} */

class CachedTrayRequest {
  final bool useCache;
  final Duration? cacheDuration;

  CachedTrayRequest({
    required this.useCache,
    required this.cacheDuration,
  });
}
