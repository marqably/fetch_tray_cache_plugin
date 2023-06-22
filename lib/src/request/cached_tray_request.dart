/// Custom interface to configure caching for a single request.
///
/// Implement this interface on a [TrayRequest] to configure caching for that
/// by overriding [useCache] and [cacheDuration].
///
/// Example:
///
/// ```dart
/// class TestCachedRequest extends MyRequest<String> implements CachedTrayRequest {
///  TestCachedRequest()
///     : super(
///         url: '/test-cached',
///       );
///
///   @override
///   Duration get cacheDuration => Duration(seconds: 5);
///
///   @override
///   bool get useCache => true;
/// }
/// ```
class CachedTrayRequest {
  final bool useCache;
  final Duration? cacheDuration;

  CachedTrayRequest({
    required this.useCache,
    required this.cacheDuration,
  });
}
