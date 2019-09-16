part of firebase_admob;

class AdmobBannerController extends AdmobEventHandler {
  final MethodChannel _channel;

  AdmobBannerController(
      int id, Function(AdmobAdEvent, Map<String, dynamic>) listener)
      : _channel =
            MethodChannel('plugins.flutter.io/firebase_admob/banner_$id'),
        super(listener) {
    if (listener != null) {
      _channel.setMethodCallHandler(handleEvent);
      _channel.invokeMethod<dynamic>('setListener');
    }
  }

  void dispose() {
    _channel.invokeMethod<dynamic>('dispose');
  }
}
