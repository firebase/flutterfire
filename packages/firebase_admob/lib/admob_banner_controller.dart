part of firebase_admob;

class BannerAdController extends AdmobEventHandler {
  BannerAdController(
      int id, Function(AdmobAdEvent, Map<String, dynamic>) listener)
      : _channel =
            MethodChannel('plugins.flutter.io/firebase_admob/banner_$id'),
        super(listener) {
    if (listener != null) {
      _channel.setMethodCallHandler(handleEvent);
      _channel.invokeMethod<dynamic>('setListener');
    }
  }

  final MethodChannel _channel;

  void dispose() {
    _channel.invokeMethod<dynamic>('dispose');
  }
}
