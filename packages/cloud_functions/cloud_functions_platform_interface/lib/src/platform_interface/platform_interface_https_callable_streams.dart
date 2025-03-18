import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class HttpsCallableStreamsPlatform<R> extends PlatformInterface {
  HttpsCallableStreamsPlatform(
    this.origin,
    this.name,
    this.uri,
  )   : assert(name != null || uri != null),
        super(token: _token);

  static final Object _token = Object();

  static void verify(HttpsCallableStreamsPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The [origin] of the local emulator, such as "http://localhost:5001"
  final String? origin;

  /// The name of the function (required, non-nullable)
  final String? name;

  /// The URI of the function for 2nd gen functions
  final Uri? uri;

  Stream<T> stream<T>(Object? object);

  Future<R> get data;
}
