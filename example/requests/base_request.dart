import 'package:fetch_tray/fetch_tray.dart';

class TestBaseRequest<T> extends TrayRequest<T> {
  TestBaseRequest({
    super.url,
    super.params,
    super.body,
    super.method = MakeRequestMethod.get,
    super.headers,
  });

  @override
  TrayEnvironment getEnvironment() {
    return TrayEnvironment(
      baseUrl: 'https://dummyjson.com',
      headers: {
        'Content-Type': 'application/json',
      },
      debugLevel: FetchTrayDebugLevel.none,
    );
  }
}
